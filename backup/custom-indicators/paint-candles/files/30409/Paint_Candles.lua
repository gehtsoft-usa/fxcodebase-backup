-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=16320
-- Id: 6388

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Paint candles");
    indicator:description("Paint candles");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addColor("UPclr", "UP Candle Color", "", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("DNclr", "DN Candle Color", "", core.COLOR_DOWNCANDLE);
    indicator.parameters:addColor("clr1", "Color 1", "", core.rgb(255, 255, 0));
    indicator.parameters:addColor("clr2", "Color 2", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr3", "Color 3", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("clr4", "Color 4", "", core.rgb(0, 255, 255));
    indicator.parameters:addColor("clr5", "Color 5", "", core.rgb(128, 0, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Colors=nil;
local ArrColors={};
local ArrDates={};
local CountColors;

local source;
local first;
local useStorage;
local name;

local open=nil;
local close=nil;
local high=nil;
local low=nil;

local MustUpdate;

-- Routine
function Prepare(nameOnly)
  source = instance.source;
  first=source:first();
  name = "Paint candles";
  instance:name(name);
  if nameOnly then return end
  Colors=instance:addInternalStream(first, 0);
  open = instance:addStream("open", core.Line, name, "open", core.COLOR_UPCANDLE, first)
  high = instance:addStream("high", core.Line, name, "high", core.COLOR_UPCANDLE, first)
  low = instance:addStream("low", core.Line, name, "low", core.COLOR_UPCANDLE, first)
  close = instance:addStream("close", core.Line, name, "close", core.COLOR_UPCANDLE, first)
  instance:createCandleGroup("PaintCandles", "", open, high, low, close);
  
    
  core.host:execute ("addCommand", -1, "Save candle colors", "Save candle colors");
  core.host:execute ("addCommand", 0, "Remove paints", "Remove paints");
  core.host:execute ("addCommand", 1, "Color #1", "Color #1");
  core.host:execute ("addCommand", 2, "Color #2", "Color #2");
  core.host:execute ("addCommand", 3, "Color #3", "Color #3");
  core.host:execute ("addCommand", 4, "Color #4", "Color #4");
  core.host:execute ("addCommand", 5, "Color #5", "Color #5");
  useStorage =  pcall(require, "storagedb");
  LoadParameters();
  MustUpdate=true;
end

function SaveParameters()
 local i;
 local DB;
 if useStorage then
  DB  = storagedb.get_db(name);
  for i=1,CountColors,1 do
   DB:put("Color" .. i, ArrColors[i]);
   DB:put("Date" .. i, ArrDates[i]);
  end
  DB:put("CountColors", CountColors);
 end 
end

function LoadParameters()
 local i;
 local Date, Color, Bar;
 if useStorage then
  DB  = storagedb.get_db(name);
  CountColors=tonumber(DB:get("CountColors", 0));
  for i=1,CountColors,1 do
   Date=(DB:get("Date" .. i));
   Color=(DB:get("Color" .. i));
   ArrColors[i]=Color;
   ArrDates[i]=Date;
  end
 end 
end

-- Indicator calculation routine
function Update(period)    
 open[period]=source.open[period];
 close[period]=source.close[period];
 low[period]=source.low[period];
 high[period]=source.high[period];
 if close[period]>=open[period] then
  open:setColor(period, instance.parameters.UPclr);
 else
  open:setColor(period, instance.parameters.DNclr);
 end
 if period==source:size()-1 then
  if MustUpdate then
   SetCandlesColor();
   MustUpdate=false;
  end
 else
  MustUpdate=true;
 end
end

function SetDefaultColors()
 CountColors=0;
 instance:updateFrom(first);
end

function SetCandlesColor()
 local i;
 local Bar;
 for i=1,CountColors,1 do
  Bar=core.findDate(source, ArrDates[i], false);
  open:setColor(Bar, instance.parameters:getColor("clr" .. ArrColors[i]));
 end
end

function AddBar(date, color)
 local i;
 for i=1,CountColors,1 do
  if ArrDates[i]==date then
   ArrColors[i]=color;
   return;
  end
 end
 CountColors=CountColors+1;
 ArrDates[CountColors]=date;
 ArrColors[CountColors]=color;
end

function AsyncOperationFinished(cookie, success, message)
 if cookie==0 then
  SetDefaultColors();
  return;
 elseif cookie==-1 then
  SaveParameters();
  return; 
 end
 t, c = core.parseCsv(message, ";");
 local date=t[1];
 AddBar(date, cookie);
 SetCandlesColor();
end

