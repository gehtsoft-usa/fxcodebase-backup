-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34064
-- Id: 8879

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
    indicator:name("Min price change oscillator");
    indicator:description("Min price change oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ChangesPeriod", "Changes period", "", 4);
    indicator.parameters:addInteger("CheckPeriod", "Check period", "", 10);
    indicator.parameters:addBoolean("AbsChange", "Absolute change", "", false);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Iclr", "Indicator color", "Indicator color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Iwidth", "Indicator line width", "Indicator line width", 1, 1, 5);
    indicator.parameters:addInteger("Istyle", "Indicator line style", "Indicator line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Istyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Mclr", "Min color", "Min color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Mwidth", "Min line width", "Min line width", 1, 1, 5);
    indicator.parameters:addInteger("Mstyle", "Min line style", "Min line style", core.LINE_DASH);
    indicator.parameters:setFlag("Mstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Sclr", "Signal color", "Signal color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Swidth", "Signal dot size", "Signal dot size", 3, 1, 5);
end

local first;
local source = nil;
local ChangesPeriod;
local CheckPeriod;
local AbsChange;
local Range;
local Ind=nil;
local Min=nil;
local Signal=nil;

function Prepare(nameOnly)
    source = instance.source;
    ChangesPeriod=instance.parameters.ChangesPeriod;
    CheckPeriod=instance.parameters.CheckPeriod;
    AbsChange=instance.parameters.AbsChange;
    first = source:first()+1;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.ChangesPeriod .. ", " .. instance.parameters.CheckPeriod .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Range=instance:addInternalStream(first, 0);
    Ind = instance:addStream("Ind", core.Line, name .. ".Ind", "Ind", instance.parameters.Iclr, first+ChangesPeriod);
    Ind:setPrecision(math.max(2, instance.source:getPrecision()));
    Ind:setWidth(instance.parameters.Iwidth);
    Ind:setStyle(instance.parameters.Istyle);
    Min = instance:addStream("Min", core.Line, name .. ".Min", "Min", instance.parameters.Mclr, first+CheckPeriod +ChangesPeriod );
    Min:setPrecision(math.max(2, instance.source:getPrecision()));
    Min:setWidth(instance.parameters.Mwidth);
    Min:setStyle(instance.parameters.Mstyle);
    Signal = instance:addStream("Signal", core.Dot, name .. ".Signal", "Signal", instance.parameters.Sclr, first+CheckPeriod +ChangesPeriod );
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal:setWidth(instance.parameters.Swidth);
end

function Update(period, mode)
   if period<first then
   return;
   end
   
    if AbsChange then
     Range[period]=math.abs(source[period]-source[period-1]);
    else
     Range[period]=source[period]-source[period-1];
    end 
    if period<first+ChangesPeriod then
	return;
	end
	
     local sum=mathex.sum(Range, period-ChangesPeriod+1, period);
     Ind[period]=math.abs(sum);
	 
	 
     if period<first+CheckPeriod +ChangesPeriod then
	return;
	end
      Min[period]=mathex.min(Ind, period-CheckPeriod, period-1);
      if Ind[period]<Min[period] and Ind[period-1]>=Min[period-1] then
       Signal[period]=Min[period];
      else
       Signal[period]=nil;
      end
     
 
 
end

