-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=16319

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Draw horizontal lines");
    indicator:description("Draw horizontal lines");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addFile("File", "File", "", "");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Default Color", "Default Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Default Line width", "Default Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Default Line style", "Default Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);

    indicator.parameters:addString("LabelHPos", "Label Horizontal position", "", "Right");
    indicator.parameters:addStringAlternative("LabelHPos", "Right", "", "Right");
    indicator.parameters:addStringAlternative("LabelHPos", "Left", "", "Left");
    indicator.parameters:addStringAlternative("LabelHPos", "Center", "", "Center");
    indicator.parameters:addString("LabelVPos", "Label Vertical position", "", "Bottom");
    indicator.parameters:addStringAlternative("LabelVPos", "Top", "", "Top");
    indicator.parameters:addStringAlternative("LabelVPos", "Bottom", "", "Bottom");
    indicator.parameters:addStringAlternative("LabelVPos", "Center", "", "Center");
    indicator.parameters:addColor("LabelClr", "Label Color", "Label Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("FontSize", "Label font size", "Label font size", 10);
end

local first;
local source = nil;
local handle;
local font;
local VPos, HPos, VPos2;
local LastPeriod;

function Prepare(nameOnly)
    source = instance.source;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    font = core.host:execute("createFont", "Arial", instance.parameters.FontSize, true, false);
    if instance.parameters.LabelHPos=="Right" then
     VPos=core.H_Left;
     HPos=core.CR_RIGHT;
    elseif instance.parameters.LabelHPos=="Left" then
     VPos=core.H_Right;
     HPos=core.CR_LEFT;
    else
     VPos=core.H_Center;
     HPos=core.CR_CENTER;
    end 
    if instance.parameters.LabelVPos=="Top" then
     VPos2=core.V_Top;
    elseif instance.parameters.LabelVPos=="Bottom" then
     VPos2=core.V_Bottom;
    else
     VPos2=core.V_Center;
    end
    LastPeriod=nil;
end

function Update(period, mode)
   if (period==source:size()-1) and LastPeriod~=period then
    LastPeriod=period;
    local i=1;
    local line;
    local error;
    handle,error=io.open(instance.parameters.File,"r");
    local T=nil;
    for line in handle:lines() do 
     T=line;
     if T~=nil then
      DrawLine(i,T);
     end 
     i=i+1;
    end
    handle:close();
   end 
end

function GetPar(Str, Number, Default)
 local Pos=string.find(Str," ");
 if Pos~=nil then
  local Value=string.sub(Str,1,Pos-1);
  local Str_=string.sub(Str,Pos+1);
  if Number then
   return tonumber(Value), Str_;
  else
   return Value, Str_;
  end
 else
  return Default, Str;
 end 
end

function DrawLine(id, Str)
 local Str_=Str .. " ";
 local Pos;
 local Price;
 local Color, Width, Style, Name;
 Price, Str_=GetPar(Str_, true, "");

 local DT_First, DT_Last;
 local DT, DT2;
 DT, Str_=GetPar(Str_, false, "");
 local DT2;
 DT2, Str_=GetPar(Str_, false, "");
 if DT~="" and DT2~="" then
  DT_First=StrToTime(DT .. " " .. DT2);
  if DT_First==nil then
   DT_First=source:date(first);
  end
 else
  DT_First=source:date(first);
 end 
 
 DT, Str_=GetPar(Str_, false, "");
 DT2, Str_=GetPar(Str_, false, "");
 if DT~="" and DT2~="" then
  DT_Last=StrToTime(DT .. " " .. DT2);
  if DT_Last==nil then
   DT_Last=source:date(source:size()-1);
  end
 else
  DT_Last=source:date(source:size()-1);
 end 
 
 
 local R, G, B;
 
 R, Str_=GetPar(Str_, true, nil);
 G, Str_=GetPar(Str_, true, nil);
 B, Str_=GetPar(Str_, true, nil);
 if R==nil or G==nil or B==nil then
  Color=instance.parameters.clr;
 else
  Color=core.rgb(R,G,B);
 end
 
 local Style_;
 Style_, Str_=GetPar(Str_, false, "");
 if Style_=="" then
  Style=instance.parameters.styleLinReg;
 else
  Style=GetStyle(Style_);
 end 
 Width, Str_=GetPar(Str_, true, instance.parameters.widthLinReg);
 Name, Str_=GetPar(Str_, false, nil);
 
 core.host:execute("drawLine", id, DT_First, Price, DT_Last, Price, Color, Style, Width);
 if Name~=nil then
  core.host:execute("drawLabel1", id, 0, HPos, Price, core.CR_CHART, VPos, VPos2, font, instance.parameters.LabelClr, Name)
 end 
end

function GetStyle(s)
 local Str=string.upper(s);
 if Str=="DASH" then
  return core.LINE_DASH;
 elseif Str=="DASHDOT" then
  return core.LINE_DASHDOT;
 elseif Str=="DOT" then
  return core.LINE_DOT;
 else
  return core.LINE_SOLID;
 end
end

function StrToTime(Str)
 local Y,M,D,Hour,Min;
 local Pos;
 local Str_=Str;
 Pos=string.find(Str_,"/");
 if Pos==nil then
  return nil;
 end
 M=(string.sub(Str_,1,Pos-1));
 Str_=string.sub(Str_,Pos+1);
 Pos=string.find(Str_,"/");
 if Pos==nil then
  return nil;
 end
 D=tonumber(string.sub(Str_,1,Pos-1));
 Str_=string.sub(Str_,Pos+1);
 Pos=string.find(Str_," ");
 if Pos==nil then
  return nil;
 end
 Y=tonumber(string.sub(Str_,1,Pos-1));
 Str_=string.sub(Str_,Pos+1);
 Pos=string.find(Str_,":");
 if Pos==nil then
  return nil;
 end
 Hour=tonumber(string.sub(Str_,1,Pos-1));
 Min=tonumber(string.sub(Str_,Pos+1));
 return core.datetime(Y,M,D,Hour,Min,0);
end


