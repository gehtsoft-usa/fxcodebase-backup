
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27799


--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
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
    indicator:name("MACD on chart");
    indicator:description("MACD on chart");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ShortEMA", "Short EMA period", "", 12);
    indicator.parameters:addInteger("LongEMA", "Long EMA period", "", 26);
    indicator.parameters:addInteger("SignalPeriod", "Signal period", "", 9);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Fast_Clr", "Fast color", "Fast color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Fast_Width", "Fast width", "Fast width", 1, 1, 5);
    indicator.parameters:addInteger("Fast_Style", "Fast style", "Fast style", core.LINE_SOLID);
    indicator.parameters:setFlag("Fast_Style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Slow_Clr", "Slow color", "Slow color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Slow_Width", "Slow width", "Slow width", 1, 1, 5);
    indicator.parameters:addInteger("Slow_Style", "Slow style", "Slow style", core.LINE_SOLID);
    indicator.parameters:setFlag("Slow_Style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Signal_Clr", "Signal color", "Signal color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Signal_Width", "Signal width", "Signal width", 2, 1, 5);
    indicator.parameters:addInteger("Signal_Style", "Signal style", "Signal style", core.LINE_DASH);
    indicator.parameters:setFlag("Signal_Style", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local ShortEMA;
local LongEMA;
local SignalPeriod;
local Fast = nil;
local Slow = nil;
local Signal = nil;
local S_EMA, L_EMA, Sig_MVA;
local MACD;

function Prepare(nameOnly)  
    source = instance.source;
    
    ShortEMA=instance.parameters.ShortEMA;
    LongEMA=instance.parameters.LongEMA;
	
	 
    SignalPeriod=instance.parameters.SignalPeriod;
	
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.ShortEMA .. ", " .. instance.parameters.LongEMA .. ", " .. instance.parameters.SignalPeriod .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	
    S_EMA = core.indicators:create("EMA", source, ShortEMA);
    L_EMA = core.indicators:create("EMA", source, LongEMA);	
	first =math.max( S_EMA.DATA:first(),L_EMA.DATA:first());
	
    MACD = instance:addInternalStream(0, 0);
    Sig_MVA = core.indicators:create("MVA", MACD, SignalPeriod);
   
    Fast = instance:addStream("Fast", core.Line, name .. ".Fast", "Fast", instance.parameters.Fast_Clr, first);
    Slow = instance:addStream("Slow", core.Line, name .. ".Slow", "Slow", instance.parameters.Slow_Clr, first);
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Signal_Clr, Sig_MVA.DATA:first());
    Fast:setWidth(instance.parameters.Fast_Width);
    Fast:setStyle(instance.parameters.Fast_Style);
    Slow:setWidth(instance.parameters.Slow_Width);
    Slow:setStyle(instance.parameters.Slow_Style);
    Signal:setWidth(instance.parameters.Signal_Width);
    Signal:setStyle(instance.parameters.Signal_Style);
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    S_EMA:update(mode);
    L_EMA:update(mode);
    Fast[period] = S_EMA.DATA[period];
    Slow[period] = L_EMA.DATA[period];
    MACD[period] = Slow[period]-Fast[period];
	
   if (period<Sig_MVA.DATA:first()) then
   return;
   end
   
    Sig_MVA:update(mode);
    Signal[period] = Fast[period]-MACD[period]+Sig_MVA.DATA[period];
  
end

