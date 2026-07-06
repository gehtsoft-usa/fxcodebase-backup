--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=606&start=10

function Init()
    indicator:name("Heikin-Ashi Smoothed");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Trend");
    indicator:setTag("replaceSource", "t");

    indicator.parameters:addString("Method1", "The smoothing method for prices", "The methods marked by the star (*) requires to have approriate indicators installed", "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method1", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method1", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method1", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method1", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method1", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method1", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method1", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method1", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method1", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method1", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method1", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method1", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method1", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method1", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method1", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method1", "JSmooth", "", "JSmooth");

    indicator.parameters:addInteger("N1", "Periods to smooth prices", "", 6, 1, 1000);

    indicator.parameters:addString("Method2", "The smoothing method for candles", "The methods marked by the star (*) requires to have approriate indicators installed", "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method2", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method2", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method2", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method2", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method2", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method2", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method2", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method2", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method2", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method2", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method2", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method2", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method2", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method2", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method2", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method2", "JSmooth", "", "JSmooth");

    indicator.parameters:addInteger("N2", "Periods to smooth candles", "", 6, 1, 1000);
    
    indicator.parameters:addBoolean("ShowSh", "Show shadows", "", true);
end

local smopen = nil;
local smhigh = nil;
local smlow = nil;
local smclose = nil;

local iopen = nil;
local ihigh = nil;
local ilow = nil;
local iclose = nil;

local smiopen = nil;
local smihigh = nil;
local smilow = nil;
local smiclose = nil;

local open = nil;
local high = nil;
local low = nil;
local close = nil;

local first1 = 0;
local first2 = 0;

-- Routine
function Prepare()
    source = instance.source;
   
    -- was missing, so N1 was not set
    local N1 = instance.parameters.N1;
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator"); 
    
    smopen = core.indicators:create("AVERAGES", source.open, instance.parameters.Method1, N1, false); 
    smclose = core.indicators:create("AVERAGES", source.close, instance.parameters.Method1, N1, false); 
    smhigh = core.indicators:create("AVERAGES", source.high, instance.parameters.Method1, N1, false); 
    smlow = core.indicators:create("AVERAGES", source.low, instance.parameters.Method1, N1, false); 
   
    first1 = smopen.DATA:first() + 1;

    iopen = instance:addInternalStream(first1, 0);
    iclose = instance:addInternalStream(first1, 0);
    ihigh = instance:addInternalStream(first1, 0);
    ilow = instance:addInternalStream(first1, 0);
   
    -- was missing, so N2 was not set
    local N2 = instance.parameters.N2;
   
    smiopen = core.indicators:create("AVERAGES", iopen, instance.parameters.Method2, N2, false); 
    smiclose = core.indicators:create("AVERAGES", iclose, instance.parameters.Method2, N2, false); 
    smihigh = core.indicators:create("AVERAGES", ihigh, instance.parameters.Method2, N2, false); 
    smilow = core.indicators:create("AVERAGES", ilow, instance.parameters.Method2, N2, false); 

    first2 = smiopen.DATA:first() + 1;

    local name = "Heikin-Ashi Smoothed" .. "(" .. source:name() .. "," .. instance.parameters.Method1 .. "(" .. instance.parameters.N1 .. ")," .. instance.parameters.Method2 .. "(" .. instance.parameters.N2.. "))"
    instance:name(name);
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first2)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first2)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first2)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first2)
    instance:createCandleGroup("HAS", "HAS", open, high, low, close);
end

-- Indicator calculation routine
function Update(period, mode)
    -- smooth source
    smopen:update(mode);
    smhigh:update(mode);
    smlow:update(mode);
    smclose:update(mode);

    if period >= first1 then
        -- calculate candles
        if (period == first1) then
            iopen[period] = (smopen.DATA[period - 1] + smclose.DATA[period - 1]) / 2;
        else
            iopen[period] = (iopen[period - 1] + iclose[period - 1]) / 2;
        end
        iclose[period] = (smopen.DATA[period] + smhigh.DATA[period] + smlow.DATA[period] + smclose.DATA[period]) / 4;
        ihigh[period] = math.max(iopen[period], iclose[period], smhigh.DATA[period]);
        ilow[period] = math.min(iopen[period], iclose[period], smlow.DATA[period]);

        -- smooth candles
        smiopen:update(mode);
        smihigh:update(mode);
        smilow:update(mode);
        smiclose:update(mode);
    end

    if period >= first2 then
        open[period] = smiopen.DATA[period];
        close[period] = smiclose.DATA[period];
        if instance.parameters.ShowSh then
         high[period] = math.max(open[period], close[period], smihigh.DATA[period]);
         low[period] = math.min(open[period], close[period], smilow.DATA[period]);
        else
	 high[period]=math.max(open[period],close[period]);
	 low[period]=math.min(open[period],close[period]);
	end 
    end
end



