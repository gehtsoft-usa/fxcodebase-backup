-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=58834
-- Id: 9652

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Last bars table");
    indicator:description("Shows the information about the latest bars.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("RowNumber", "Number of rows", "", 5);
    AddColumn(1, "Date/Time");
    AddColumn(2, "Open");
    AddColumn(3, "High");
    AddColumn(4, "Low");
    AddColumn(5, "Close");
    AddColumn(6, "Volume");
    indicator.parameters:addString("Position", "Position", "", "Right");
    indicator.parameters:addStringAlternative("Position", "Right", "", "Right");
    indicator.parameters:addStringAlternative("Position", "Left", "", "Left");
    indicator.parameters:addColor("color", "Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 0, 0, 100);
    indicator.parameters:addInteger("FontSize", "Font size", "0 - default", 0);
end

function AddColumn(Num, Default)
 indicator.parameters:addString("Column" .. Num, "Column #" .. Num, "", Default);
 indicator.parameters:addStringAlternative("Column" .. Num, "Date/Time", "", "Date/Time");
 indicator.parameters:addStringAlternative("Column" .. Num, "Open", "", "Open");
 indicator.parameters:addStringAlternative("Column" .. Num, "High", "", "High");
 indicator.parameters:addStringAlternative("Column" .. Num, "Low", "", "Low");
 indicator.parameters:addStringAlternative("Column" .. Num, "Close", "", "Close");
 indicator.parameters:addStringAlternative("Column" .. Num, "Volume", "", "Volume");
 indicator.parameters:addStringAlternative("Column" .. Num, "Nothing", "", "Nothing");
end

local first = 0;
local source = nil;
local color;
local transparency;
local Table_Left, Table_Top;
local IntPositon;
local FontSize;
local RowNumber;
local ChartArr={};
local MaxLength, MaxStr;

-- initializes the instance of the indicator
function Prepare(onlyName)
    source = instance.source;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end

    instance:ownerDrawn(true);
    
    color = instance.parameters.color;
    FontSize = instance.parameters.FontSize;
    RowNumber = instance.parameters.RowNumber;
    instance:setLabelColor(color);
    core.host:execute("addCommand", 1000, "Move here", "Move here");
    Table_Left, Table_Top = 0, 0;
    if instance.parameters.Position=="Right" then
     IntPosition=0;
    else
     IntPosition=1;
    end
end

function GetValue(period, Num)
 local i;
 if period==-1 then
  if instance.parameters:getString("Column" .. Num)=="Nothing" then
   return "";
  else
   return instance.parameters:getString("Column" .. Num);
  end 
 end
 local lastBar=source:size()-1;
 if instance.parameters:getString("Column" .. Num)=="Date/Time" then
  return core.formatDate(source:date(lastBar-period));
 elseif instance.parameters:getString("Column" .. Num)=="Open" then 
  return source.open[lastBar-period];
 elseif instance.parameters:getString("Column" .. Num)=="High" then 
  return source.high[lastBar-period];
 elseif instance.parameters:getString("Column" .. Num)=="Low" then 
  return source.low[lastBar-period];
 elseif instance.parameters:getString("Column" .. Num)=="Close" then 
  return source.close[lastBar-period];
 elseif instance.parameters:getString("Column" .. Num)=="Volume" then 
  return source.volume[lastBar-period];
 else
  return "";
 end
end

function Update(period)
 local i1, i2;
 local Length;
 MaxLength=0;
 for i1=-1, RowNumber-1, 1 do 
  local Arr={};
  for i2=1, 6, 1 do
   Arr[i2]=GetValue(i1, i2);
   Length=string.len(Arr[i2]);
   if Length>MaxLength then
    MaxLength=Length;
    MaxStr=Arr[i2] .. "  ";
   end 
  end 
  ChartArr[i1]=Arr;
 end 
end

local init = false;
function AsyncOperationFinished(cookie, success, message, message1, message2)
 if cookie == 1000 then   
  local t, c;
  t, c = core.parseCsv(message, ";");
  if c >= 4 then
   Table_Left = tonumber(t[2]);
   Table_Top = tonumber(t[3]);
   IntPosition=1;
  end 
 end
end

function Draw(stage, context)
    if stage == 2 then
        if not init then
           if FontSize==0 then
              context:createFont(1, "Arial", 0, -context:pointsToPixels(source:pipSize()), 0);
            else  
              context:createFont(1, "Arial", 0, FontSize, 0);
            end 
            transparency = context:convertTransparency(instance.parameters.transparency);
            init = true;
        end
        
        if MaxLength==0 then
         return;
        end
        local i1, i2;
        local Right=context:right();
        local TableW, TableH=context:measureText(1, MaxStr, context.LEFT);
        for i1=-1,RowNumber-1,1 do
         for i2=1, 6, 1 do
          if IntPosition==0 then
           context:drawText(1, ChartArr[i1][i2], color, -1, Right-(7-i2)*TableW, Table_Top+(i1+4)*TableH, Right-(6-i2)*TableW, Table_Top+(i1+5)*TableH, context.RIGHT, transparency);
          else
           context:drawText(1, ChartArr[i1][i2], color, -1, Table_Left+(i2-1)*TableW, Table_Top+(i1+4)*TableH, Table_Left+i2*TableW, Table_Top+(i1+5)*TableH, context.RIGHT, transparency);
          end 
         end 
        end
        
    end
end



