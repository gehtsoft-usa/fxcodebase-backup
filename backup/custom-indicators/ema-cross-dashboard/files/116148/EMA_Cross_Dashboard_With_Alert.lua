-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65383

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("EMA Cross Dashboard With Alert");
    indicator:description("EMA Cross Dashboard With Alert");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addString("TFs", "List of TFs", "", "m30,H3,H4,D1");

    indicator.parameters:addInteger("MA1_Period", "MA1 Period", "", 60);
    indicator.parameters:addInteger("MA2_Period", "MA2 Period", "", 200);

    indicator.parameters:addGroup("Position");
    indicator.parameters:addString("Corner", "Corner", "", "0");
    indicator.parameters:addStringAlternative("Corner", "Right-Top", "", "0");
    indicator.parameters:addStringAlternative("Corner", "Left-Top", "", "1");
    indicator.parameters:addStringAlternative("Corner", "Right-Bottom", "", "2");
    indicator.parameters:addStringAlternative("Corner", "Left-Bottom", "", "3");
    indicator.parameters:addInteger("ShiftX", "Shift X", "Shift X", 0);
    indicator.parameters:addInteger("ShiftY", "Shift Y", "Shift Y", 0);

    indicator.parameters:addGroup("Alerts Sound"); 
    indicator.parameters:addBoolean("ChartAlert", "Chart alert", "", true);  
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);  
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
    indicator.parameters:addFile("AlertSound", "Alert Sound", "", "");
    indicator.parameters:setFlag("AlertSound", core.FLAG_SOUND);
    indicator.parameters:addBoolean("SendEmail", "Send email", "", false);
    indicator.parameters:addString("Email", "Email address", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
    indicator.parameters:addInteger("SignalTime", "Signal time, min", "Signal time, min", 180);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Tclr", "Table color", "Table color", core.rgb(0, 0, 0));
    indicator.parameters:addColor("TBclr", "Table backgroud color", "Table background color", core.rgb(88, 88, 88));
    indicator.parameters:addInteger("Twidth", "Table line width", "Table line width", 2);
    indicator.parameters:addColor("Hclr", "Text color", "Text color", core.rgb(0, 0, 0));
    indicator.parameters:addColor("UPclr", "Up setup color", "Up setup color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "Down setup color", "Down setup color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("transparency", "Transparency", "0 - opaque, 100 - transparent", 75, 0, 100);
end

local first;
local source = nil;
local InstrArray={};
local TFArray={};
local InstrCount, TFCount;
local IndArray1=nil;
local IndArray2=nil;
local IndCount;
local Res={};
local src;
local transparency;
local Alert;
local http;
local Alerts;
local Corner;
local ShiftX, ShiftY;
local LastSignalTime, SignalTime;
local MA_Sources={};
local MAs={};
local MA_Results={};
local MA_ResultsC={};
local MA_Count;
local UseTrace;
local LastMATime;
local InstrColor={};
local HistoryDepth;

local QueueArray={};
local QueueCount;
local loading;

function ParseC(Instr)
  local T, C=core.parseCsv(Instr, "/");
  if C==2 then
    return T[0], T[1];
  else
    return Instr, nil;
  end
end

function FindRes(index)
  local i;
  for i=0, MA_Count-1, 1 do
    if MA_Results[i+1]==MA_ResultsC[MA_Count-index] then
      return i;
    end
  end
  return nil;
end

function Signal(Dir, _Symbol, _TF, _Time)
 if SignalTime>0 and (_Time-LastSignalTime[_Symbol])*1440<SignalTime then
  return;
 end

 LastSignalTime[_Symbol]=_Time;

   local Subj=InstrArray[_Symbol] .. " " .. Dir .. " on " .. _TF;
  
  if instance.parameters.ChartAlert then
   core.host:execute("prompt", 1, "Alert" , Dir);
  end
  
  if instance.parameters.PlaySound then
   terminal:alertSound(instance.parameters.AlertSound, instance.parameters.RecurrentSound); 
  end

  if instance.parameters.SendEmail then
   local i;
   for i=0, EmailsCount-1, 1 do
    terminal:alertEmail(Emails[i], Subj, Dir);
   end 
  end

end

function Prepare(onlyName)
    source = instance.source;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end
    Corner=tonumber(instance.parameters.Corner);
    ShiftX=instance.parameters.ShiftX;
    ShiftY=instance.parameters.ShiftY;
    SignalTime=instance.parameters.SignalTime;
    UseTrace=instance.parameters.UseTrace;
    HistoryDepth=instance.parameters.HistoryDepth;
    ReadFile();
    IndArray1={};
    IndArray2={};
    Alerts={};
    src={};
    MA_Sources={};
    MAs={};
    LastSignalTime={};
    IndCount=0;
    MA_Count=0;
    instance:ownerDrawn(true);

    loading=true;
    local Queue={};
    QueueArray={};
    QueueCount=0;

    instance:setLabelColor(instance.parameters.Tclr);
    http = core.makeHttpLoader();
    LastMATime=0;
    local i1, i2, Ind, S;
    for i1=0, InstrCount-1, 1 do
     LastSignalTime[i1]=0;

     for i2=0, TFCount-1, 1 do
      index=i1*TFCount+i2;

      Queue={};
      Queue.IndCount=IndCount;
      Queue.Instr=InstrArray[i1];
      Queue.TF=TFArray[i2];
      QueueArray[QueueCount]=Queue;
      QueueCount=QueueCount+1;

      Res[IndCount]=0;
      Alerts[IndCount]=0;
      IndCount=IndCount+1;
     end
    end
    GetNextQueue();
end

function GetNextQueue()
  if QueueCount>0 then
    local Queue=QueueArray[QueueCount-1];
    QueueCount=QueueCount-1;
     S=core.host:execute ("getHistory1", 1000, Queue.Instr, Queue.TF, 2*math.max(instance.parameters.MA1_Period, instance.parameters.MA2_Period), 0, source:isBid());
     src[Queue.IndCount]=S;
     Ind1=core.indicators:create("EMA", src[Queue.IndCount], instance.parameters.MA1_Period);
     IndArray1[Queue.IndCount]=Ind1;
     Ind2=core.indicators:create("EMA", src[Queue.IndCount], instance.parameters.MA2_Period);
     IndArray2[Queue.IndCount]=Ind2;
  else
    loading=false;
  end
end

function AsyncOperationFinished(cookie)
  if cookie==1000 then
    local v1=IndCount+MA_Count;
    local v2=v1-QueueCount;
    if QueueCount>0 then
      core.host:execute("setStatus", "  Loading "..(v2) .. " / " ..  v1 );   
    else
      core.host:execute("setStatus", "");   
    end      
    GetNextQueue();
  end
  return core.ASYNC_REDRAW;
end

function GetInstrTF(index)
 local Instr, TF;
 Instr=math.floor(index/TFCount);
 TF=index-Instr*TFCount;
 return Instr, TF;
end

function ReadFile()
 local error;
 local handle;
 InstrArray, TFArray={}, {};
 InstrCount, TFCount=0, 0;

 TFArray, TFCount=core.parseCsv(instance.parameters.TFs, ",");

 local i;
 local Pos;
 for i=0, TFCount-1, 1 do
  Pos=string.find(TFArray[i], "*");
  if Pos~=nil then
   TFArray[i]=string.sub(TFArray[i], 0, Pos-1);
  end
 end

  local row, enum;  
  
  local UpInstr, DnInstr;
  enum = core.host:findTable("offers"):enumerator();
  row = enum:next();
  while row ~= nil do
    UpInstr, DnInstr=ParseC(row.Instrument);
    if DnInstr~=nil then
      InstrArray[InstrCount]=row.Instrument;
      InstrCount=InstrCount+1;
    end 
    row = enum:next();
  end
end

function Update(period, mode)
  if loading then
    return;
  end

 if period==source:size()-1 then
  local i;
  local InstrIndex, TFIndex;
  for i=0, IndCount-1, 1 do
    IndArray1[i]:update(core.UpdateAll);
    IndArray2[i]:update(core.UpdateAll);
    size1=IndArray1[i].DATA:size()-1;
    size2=IndArray2[i].DATA:size()-1;
    if size1>0 and size2>0 then
      local r10=IndArray1[i].DATA[size1];
      local r11=IndArray1[i].DATA[size1-1];
      local r20=IndArray2[i].DATA[size2];
      local r21=IndArray2[i].DATA[size2-1];

      if r10>r20 and r11<=r21 then
        Res[i]=1;
      elseif r10<r20 and r11>=r21 then
        Res[i]=-1;
      else
        Res[i]=0;
      end
   end 
  
  end

  for i=0, IndCount-1, 1 do
    if Res[i]==1 and Alerts[i]~=1 then
     Alerts[i]=1;
     InstrIndex, TFIndex=GetInstrTF(i);
     Signal("Up crossing", InstrIndex, TFArray[TFIndex], core.now());
    elseif Res[i]==-1 and Alerts[i]~=-1 then
     Alerts[i]=-1;
     InstrIndex, TFIndex=GetInstrTF(i);
     Signal("Down crossing", InstrIndex, TFArray[TFIndex], core.now());
    elseif Res[i]~=1 and Res[i]~=-1 then
     Alerts[i]=0;
    end
  
  end

 end 
end

function FindIndRes(InstrIndex, StrTF)
 local i;
 local _index;
 for i=0, TFCount-1, 1 do
  if TFArray[i]==StrTF then
    _index=InstrIndex*TFCount+i;
    return Res[_index];
  end
 end

 return nil;
end

local init=false;

function Draw(stage, context)
 if stage == 2 then
    
  if not init then
   context:createPen(1, context.SOLID, instance.parameters.Twidth, instance.parameters.Tclr);
   context:createFont(2, "Arial", 0, -context:pointsToPixels(source:pipSize()), 0);
   context:createSolidBrush(3, instance.parameters.UPclr);
   context:createSolidBrush(4, instance.parameters.DNclr);
   context:createSolidBrush(5, instance.parameters.TBclr);
   transparency = context:convertTransparency(instance.parameters.transparency);
   init = true;
  end
  
  local MaxText="Up cross    ";
  local w, h = context:measureText(2, MaxText, context.LEFT);
  local top, bottom, left, right = context:top(), context:bottom(), context:left(), context:right();
  context:setClipRectangle (left, top, right, bottom);
  local MinX, MinY;
  if Corner==0 then
   MinX, MinY = right-(TFCount+1)*w-ShiftX, top+ShiftY;
  elseif Corner==1 then
   MinX, MinY = left+ShiftX, top+ShiftY;
  elseif Corner==2 then
   MinX, MinY = right-(TFCount+1)*w-ShiftX, bottom-(InstrCount+1)*h-ShiftY;
  else
   MinX, MinY = left+ShiftX, bottom-(InstrCount+1)*h-ShiftY;
  end
  
  local i1, i2;
  local x1, x2, y1, y2;
  local Str;
  local Rclr;
  local InstrIndex;
  for i1=-1, InstrCount-1, 1 do
   for i2=-1, TFCount-1, 1 do
    x1=MinX+(i2+1)*w;
    x2=MinX+(i2+2)*w;
    y1=MinY+(i1+1)*h;
    y2=MinY+(i1+2)*h;
    
    Rclr=-1;
    
       InstrIndex=i1;

    if i1==-1 then
     if i2==-1 then
      Str="Pair";
     else
      Str=TFArray[i2];
     end
    else
     if i2==-1 then
      Str=InstrArray[InstrIndex];
     elseif Res[InstrIndex*TFCount+i2]~=nil then
      Str, Rclr=GetRes(Res[InstrIndex*TFCount+i2], i2);
     end
    end

    context:drawRectangle(1, 5, x1, y1, x2, y2);
    
    context:drawText(2, Str, instance.parameters.Hclr, -1, x1, y1, x2, y2, context.CENTER+context.VCENTER);

    if i2>-1 or i1==-1 then
      context:drawRectangle(1, Rclr, x1, y1, x2, y2, transparency);
    else
      if InstrColor[InstrIndex]==1 then
        context:drawRectangle(1, 3, x1, y1, x2, y2, transparency);
      elseif InstrColor[InstrIndex]==-1 then
        context:drawRectangle(1, 4, x1, y1, x2, y2, transparency);
      end  
    end  

    context:drawRectangle(1, -1, x1, y1, x2, y2);
    
   end
  end
  context:resetClipRectangle();
 end
end

function GetRes(index, iTF)
 local Str;
 local clr=-1;
 if index==0 then
  Str="";
 elseif index==1 then
  Str="Up cross";
  clr=4;
 elseif index==-1 then
  Str="Dn cross";
  clr=3;
 else
  Str="";
 end
 return Str, clr;
end