-- Id: 2343
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2621

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("MA Crossover indicator");
    indicator:description("MA Crossover indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("FastMA_Method", "FastMA_Method", "", "EMA");
    indicator.parameters:addStringAlternative("FastMA_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("FastMA_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("FastMA_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("FastMA_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("FastMA_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("FastMA_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("FastMA_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("FastMA_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("FastMA_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("FastMA_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("FastMA_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("FastMA_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("FastMA_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("FastMA_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("FastMA_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("FastMA_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("FastMA_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("FastMA_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("FastMA_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("FastMA_Method", "JSmooth", "", "JSmooth");
    
    indicator.parameters:addInteger("FastMA_Period", "FastMA_Period", "", 5);

    indicator.parameters:addString("SlowMA_Method", "SlowMA_Method", "", "EMA");
    indicator.parameters:addStringAlternative("SlowMA_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("SlowMA_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("SlowMA_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("SlowMA_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("SlowMA_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("SlowMA_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("SlowMA_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("SlowMA_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("SlowMA_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("SlowMA_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("SlowMA_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("SlowMA_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("SlowMA_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("SlowMA_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("SlowMA_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("SlowMA_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("SlowMA_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("SlowMA_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("SlowMA_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("SlowMA_Method", "JSmooth", "", "JSmooth");
    
    indicator.parameters:addInteger("SlowMA_Period", "SlowMA_Period", "", 8);
    
    indicator.parameters:addGroup("Style");
	 indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 10);
    indicator.parameters:addColor("UP", "Up color", "Up color", core.rgb(0,255,0));
    indicator.parameters:addColor("DOWN", "Down color", "Down color", core.rgb(255,0,0));
end

local first;
local source = nil;
local FastMA_Method;
local FastMA_Period;
local SlowMA_Method;
local SlowMA_Period;
local SlowMA;
local FastMA;
local up;
local down;
local Range;

function Prepare(nameOnly)
    source = instance.source;
	ArrowSize=instance.parameters.ArrowSize;
    FastMA_Method=instance.parameters.FastMA_Method;
    FastMA_Period=instance.parameters.FastMA_Period;
    SlowMA_Method=instance.parameters.SlowMA_Method;
    SlowMA_Period=instance.parameters.SlowMA_Period;	
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator"); 
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.FastMA_Method .. ", " .. instance.parameters.FastMA_Period .. ", " .. instance.parameters.SlowMA_Method .. ", " .. instance.parameters.SlowMA_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    FastMA = core.indicators:create("AVERAGES", source.close, FastMA_Method, FastMA_Period, false);
    SlowMA = core.indicators:create("AVERAGES", source.open, SlowMA_Method, SlowMA_Period, false);
    first = math.max(FastMA.DATA:first(),SlowMA.DATA:first())+2;
    up = instance:createTextOutput ("Up", "Up", "Wingdings", ArrowSize, core.H_Center, core.V_Top, instance.parameters.UP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", ArrowSize, core.H_Center, core.V_Bottom, instance.parameters.DOWN, 0);
end

function Update(period, mode)
   if (period>first) then
    FastMA:update(mode);
    SlowMA:update(mode);
    if FastMA.DATA[period-1]>SlowMA.DATA[period-1] and FastMA.DATA[period-2]<SlowMA.DATA[period-2] and FastMA.DATA[period]>SlowMA.DATA[period] then
     down:set(period-1, source.low[period-1], "\225");
    end
    if FastMA.DATA[period-1]<SlowMA.DATA[period-1] and FastMA.DATA[period-2]>SlowMA.DATA[period-2] and FastMA.DATA[period]<SlowMA.DATA[period] then
     up:set(period-1, source.high[period-1], "\226");
    end
   end 
    
end

