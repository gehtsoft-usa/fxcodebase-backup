-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59048

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
    indicator:name("Hull candles");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Trend");
    indicator:setTag("replaceSource", "t");

    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("Period", "Period", "", 10);
end

local Method;
local Period;
local Period2;
local first;

local MA_O, MA_H, MA_L, MA_C;
local MA_O2, MA_H2, MA_L2, MA_C2;

local open = nil;
local high = nil;
local low = nil;
local close = nil;

function Prepare(nameOnly)
    source = instance.source;
   
    Method = instance.parameters.Method;
    Period = instance.parameters.Period;
    Period2 = math.floor(Period/2);
	
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");  
   
  
    
    MA_O = core.indicators:create("AVERAGES", source.open, Method, Period, false);
    MA_H = core.indicators:create("AVERAGES", source.high, Method, Period, false);
    MA_L = core.indicators:create("AVERAGES", source.low, Method, Period, false);
    MA_C = core.indicators:create("AVERAGES", source.close, Method, Period, false);

    MA_O2 = core.indicators:create("AVERAGES", source.open, Method, Period2, false);
    MA_H2 = core.indicators:create("AVERAGES", source.high, Method, Period2, false);
    MA_L2 = core.indicators:create("AVERAGES", source.low, Method, Period2, false);
    MA_C2 = core.indicators:create("AVERAGES", source.close, Method, Period2, false);
	
	
	first = math.max(MA_O.DATA:first(),MA_O2.DATA:first());
	
	
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("Hull candles", "Hull candles", open, high, low, close);
end

function Update(period, mode)
   if period<first then
   return;
   end
   
    MA_O:update(mode);
    MA_H:update(mode);
    MA_L:update(mode);
    MA_C:update(mode);

    MA_O2:update(mode);
    MA_H2:update(mode);
    MA_L2:update(mode);
    MA_C2:update(mode);
    
    local X_O = 2*MA_O2.DATA[period]-MA_O.DATA[period];
    local X_H = 2*MA_H2.DATA[period]-MA_H.DATA[period];
    local X_L = 2*MA_L2.DATA[period]-MA_L.DATA[period];
    local X_C = 2*MA_C2.DATA[period]-MA_C.DATA[period];
    
    high[period] = math.max(X_H, open[period-1], close[period-1]);
    low[period] = math.min(X_L, open[period-1], close[period-1]);
    open[period] = (open[period-1]+close[period-1])/2;
    close[period] = (X_O+X_H+X_L+X_C)/4;
   
end



