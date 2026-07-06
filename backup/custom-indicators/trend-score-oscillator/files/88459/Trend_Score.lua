-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59046
-- Id: 9669

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
    indicator:name("Trend score oscillator");
    indicator:description("Trend score oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("PriceMethod", "Price method", "", "0");
    indicator.parameters:addStringAlternative("PriceMethod", "Open/Close", "", "0");
    indicator.parameters:addStringAlternative("PriceMethod", "Close/Close", "", "1");
    indicator.parameters:addString("PeriodMethod", "Period method", "", "0");
    indicator.parameters:addStringAlternative("PeriodMethod", "Use period", "", "0");
    indicator.parameters:addStringAlternative("PeriodMethod", "Do not use period", "", "1");
    indicator.parameters:addInteger("Period", "Period", "", 10);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local PriceMethod;
local PeriodMethod;
local Period;
local PM;
local TrendScore=nil;

function Prepare(nameOnly)
    source = instance.source;
    PriceMethod=tonumber(instance.parameters.PriceMethod);
    PeriodMethod=tonumber(instance.parameters.PeriodMethod);
    Period=instance.parameters.Period;
    first = source:first()+1;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.PriceMethod .. ", " .. instance.parameters.PeriodMethod .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    PM=instance:addInternalStream(0, 0);
    TrendScore = instance:addStream("TrendScore", core.Line, name .. ".TrendScore", "TrendScore", instance.parameters.clr, first);
    TrendScore:setPrecision(math.max(2, instance.source:getPrecision()));
    TrendScore:setWidth(instance.parameters.widthLinReg);
    TrendScore:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if period<first then
   return;
   end
   
    local PrevPrice;
    if PeriodMethod==0 then
     if PriceMethod==0 then
      PrevPrice=source.open[period];
     else
      PrevPrice=source.close[period-1];
     end
     if source.close[period]>PrevPrice then
      PM[period]=1;
     elseif source.close[period]<PrevPrice then
      PM[period]=-1;
     else
      PM[period]=0;
     end
	 
	 
     if period>first+Period then
      TrendScore[period]=mathex.sum(PM, period-Period+1, period);
     end
    else
     if PriceMethod==0 then
      PrevPrice=source.open[period];
     else
      PrevPrice=source.close[period-1];
     end
     if source.close[period]>PrevPrice then
      if TrendScore[period-1]>=0 then
       TrendScore[period]=TrendScore[period-1]+1;
      else
       TrendScore[period]=1;
      end
     elseif source.close[period]<PrevPrice then
      if TrendScore[period-1]<0 then
       TrendScore[period]=TrendScore[period-1]-1;
      else
       TrendScore[period]=-1;
      end
     else
      TrendScore[period]=TrendScore[period-1]; 
     end
    end
    
end

