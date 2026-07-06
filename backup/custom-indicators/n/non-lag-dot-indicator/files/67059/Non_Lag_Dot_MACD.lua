-- Id: 9297
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1721

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
    indicator:name("Non Lag Dot MACD");
    indicator:description("Non Lag Dot MACD");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Filter", "Filter", "", 0);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 0);
    indicator.parameters:addString("Fast_Method", "Fast method", "", "MVA");
    indicator.parameters:addStringAlternative("Fast_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Fast_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Fast_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Fast_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Fast_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Fast_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Fast_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Fast_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Fast_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Fast_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Fast_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Fast_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Fast_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Fast_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Fast_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Fast_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Fast_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Fast_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Fast_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Fast_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Fast_Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("Fast_Period", "Fast period", "", 12);
    indicator.parameters:addString("Slow_Method", "Slow method", "", "MVA");
    indicator.parameters:addStringAlternative("Slow_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Slow_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Slow_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Slow_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Slow_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Slow_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Slow_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Slow_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Slow_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Slow_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Slow_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Slow_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Slow_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Slow_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Slow_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Slow_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Slow_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Slow_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Slow_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Slow_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Slow_Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("Slow_Period", "Slow period", "", 26);
    indicator.parameters:addString("Signal_Method", "Signal method", "", "MVA");
    indicator.parameters:addStringAlternative("Signal_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Signal_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Signal_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Signal_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Signal_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Signal_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Signal_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Signal_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Signal_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Signal_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Signal_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Signal_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Signal_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Signal_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Signal_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Signal_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Signal_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Signal_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Signal_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Signal_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Signal_Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("Signal_Period", "Signal period", "", 9);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("PUPclr", "Positive UP MACD color", "Positive UP MACD color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("PDNclr", "Positive DN MACD color", "Positive DN MACD color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("NUPclr", "Negative UP MACD color", "Negative UP MACD color", core.rgb(255, 0, 255));
    indicator.parameters:addColor("NDNclr", "Negative DN MACD color", "Negative DN MACD color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("UPclr", "Signal UP color", "Signal UP color", core.rgb(0, 255, 255));
    indicator.parameters:addColor("DNclr", "Signal DN color", "Signal DN color", core.rgb(255, 128, 0));
    indicator.parameters:addInteger("widthLinReg", "Signal width", "Signal width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Signal style", "Signal style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Filter;
local Deviation;
local Fast_Method;
local Fast_Period;
local Slow_Method;
local Slow_Period;
local Signal_Method;
local Signal_Period;
local Slow_MA;
local Fast_MA;
local Signal_MA;
local MACD=nil;
local Signal=nil;

function Prepare(nameOnly)
    source = instance.source;
    Filter=instance.parameters.Filter;
    Deviation=instance.parameters.Deviation;
    Fast_Method=instance.parameters.Fast_Method;
    Fast_Period=instance.parameters.Fast_Period;
    Slow_Method=instance.parameters.Slow_Method;
    Slow_Period=instance.parameters.Slow_Period;
    Signal_Method=instance.parameters.Signal_Method;
    Signal_Period=instance.parameters.Signal_Period;
    
	
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Filter .. ", " .. instance.parameters.Deviation .. ", " .. instance.parameters.Fast_Method .. ", " .. instance.parameters.Fast_Period .. ", " .. instance.parameters.Slow_Method .. ", " .. instance.parameters.Slow_Period .. ", " .. instance.parameters.Signal_Method .. ", " .. instance.parameters.Signal_Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");  
	assert(core.indicators:findIndicator("NONLAGDOT_AVERAGES") ~= nil, "Please, download and install NONLAGDOT_AVERAGES.LUA indicator");  
	
    Slow_MA = core.indicators:create("NONLAGDOT_AVERAGES", source, Slow_Method, Slow_Period, Filter, Deviation);
    Fast_MA = core.indicators:create("NONLAGDOT_AVERAGES", source, Fast_Method, Fast_Period, Filter, Deviation);
	
	first = math.max(Slow_MA.DATA:first(),Fast_MA.DATA:first());
	
	
    MACD = instance:addStream("MACD", core.Bar, name .. ".MACD", "MACD", instance.parameters.PUPclr, first);
	Signal_MA = core.indicators:create("AVERAGES", MACD, Signal_Method, Signal_Period, false);
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.UPclr, Signal_MA.DATA:first());
    Signal:setWidth(instance.parameters.widthLinReg);
    Signal:setStyle(instance.parameters.styleLinReg);
	
	MACD:setPrecision(math.max(2, instance.source:getPrecision()));
	Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    
end

function Update(period, mode)
 
    Slow_MA:update(mode);
    Fast_MA:update(mode);
	
	if (period<first ) then
	return;
	end
    MACD[period]=Fast_MA.DATA[period]-Slow_MA.DATA[period];
    Signal_MA:update(mode);
	
	if (period<Signal_MA.DATA:first() ) then
	return;
	end
	
    Signal[period]=Signal_MA.DATA[period];
    if MACD[period]>0 then
     if MACD[period]>=MACD[period-1] then
      MACD:setColor(period, instance.parameters.PUPclr);
     else
      MACD:setColor(period, instance.parameters.PDNclr);
     end
    else
     if MACD[period]>=MACD[period-1] then
      MACD:setColor(period, instance.parameters.NUPclr);
     else
      MACD:setColor(period, instance.parameters.NDNclr);
     end
    end
    if Signal[period]>=Signal[period-1] then
     Signal:setColor(period, instance.parameters.UPclr);
    else
     Signal:setColor(period, instance.parameters.DNclr);
    end
    
end

