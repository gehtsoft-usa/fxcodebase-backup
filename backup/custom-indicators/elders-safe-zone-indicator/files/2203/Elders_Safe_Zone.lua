-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1158&sid=e771a98f6d78bea9bee97875e3ca9bbb

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Elders Safe Zone indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("LookBack", "LookBack", "No description", 10);
    indicator.parameters:addInteger("StopFactor", "StopFactor", "No description", 3);
    indicator.parameters:addInteger("EMALength", "EMALength", "No description", 13);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Line_color", "Color of line", "Color of line", core.rgb(0, 255, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local LookBack;
local StopFactor;
local EMALength;

local first;
local source = nil;
local buffLine=nil;
local EMA;

function Prepare(nameOnly)
    source = instance.source;
    LookBack = instance.parameters.LookBack;
    StopFactor = instance.parameters.StopFactor;
    EMALength = instance.parameters.EMALength;
    local name = profile:id() .. "(" .. source:name() .. ", " .. LookBack .. ", " .. StopFactor .. ", " .. EMALength .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    EMA = core.indicators:create("EMA", source.close, EMALength);
    first = EMA.DATA:first();
    buffLine = instance:addStream("Line", core.Line, name .. ".Line", "Line", instance.parameters.Line_color, first);
	buffLine:setWidth(instance.parameters.width);
    buffLine:setStyle(instance.parameters.style);
end

function Update(period, mode)
    if (period>first+LookBack+3) then
     EMA:update(mode);
     local SafeStop=0.;
     local EMA0=EMA.DATA[period];
     local EMA1=EMA.DATA[period-1];
     local EMA2=EMA.DATA[period-2];
     local PreSafeStop=buffLine[period-1];
     local Pen=0.;
     local Counter=0;
     if EMA0>EMA1 then
      for value1=0,LookBack,1 do
       if source.low[period-value1]<source.low[period-value1-1] then
        Pen=source.low[period-value1-1]-source.low[period-value1]+Pen;
        Counter=Counter+1;
       end
      end
      if Counter>0 then
       SafeStop=source.close[period]-(StopFactor*Pen/Counter);
      else
       SafeStop=source.close[period]-(StopFactor*Pen);
      end
      if SafeStop<PreSafeStop and EMA1>EMA2 then
       SafeStop=PreSafeStop;
      end
     elseif EMA0<EMA1 then
      for value1=0,LookBack,1 do
       if source.high[period-value1]>source.high[period-value1-1] then
        Pen=source.high[period-value1]-source.high[period-value1-1]+Pen;
        Counter=Counter+1;
       end
      end
      if Counter>0 then
       SafeStop=source.close[period]+(StopFactor*Pen/Counter);
      else
       SafeStop=source.close[period]+(StopFactor*Pen);
      end
      if SafeStop>PreSafeStop and EMA1<EMA2 then
       SafeStop=PreSafeStop;
      end
     end
     PreSafeStop=SafeStop;
     buffLine[period]=SafeStop;
    end
end


