-- Id: 8622
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32544

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Asymmetric fractals");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FrameBefore", "Number of bars before fractal", "Number of bars before fractal", 5);
    indicator.parameters:addInteger("FrameAfter", "Number of bars after fractal", "Number of bars after fractal", 2);
    
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UpClr", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("DnClr", "Down fractal color", "Down fractal color", core.rgb(255,0,0));
	indicator.parameters:addInteger("Size", "Font Size", "Size", 10);
end

local source;
local first;
local up, down;
local FrameBefore, FrameAfter;
local Size;

function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	
	Size=instance.parameters.Size;
    
    FrameBefore=instance.parameters.FrameBefore;
    FrameAfter=instance.parameters.FrameAfter;

  
    local name = profile:id() .. " ( " .. FrameBefore .. ", " .. FrameAfter .. " )";
    instance:name(name);
    if nameOnly then
        return;
    end
    up = instance:createTextOutput("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.UpClr, 0);
    down = instance:createTextOutput("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.DnClr, 0);
	
end

function Update(period, mode)
 if period>first+FrameBefore then
  local i;
  local UpFr, DnFr = true, true;
  for i=1, FrameBefore, 1 do
   if source.high[period-FrameAfter]<=source.high[period-i-FrameAfter] then
    UpFr=false;
   end
   if source.low[period-FrameAfter]>=source.low[period-i-FrameAfter] then
    DnFr=false;
   end
  end
  for i=1, FrameAfter, 1 do
   if source.high[period-FrameAfter]<=source.high[period-FrameAfter+i] then
    UpFr=false;
   end
   if source.low[period-FrameAfter]>=source.low[period-FrameAfter+i] then
    DnFr=false;
   end
  end
  if UpFr then
   up:set(period-FrameAfter, source.high[period-FrameAfter], "\226");
  else
   up:setNoData(period-FrameAfter);
  end
  if DnFr then
   down:set(period-FrameAfter, source.low[period-FrameAfter], "\225");
  else
   down:setNoData(period-FrameAfter);
  end
 end
end
