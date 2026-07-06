-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=74820
--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                               https://appliedmachinelearning.systems/contact/  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+

-- The indicator corresponds to the Stochastic indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 6 "Momentum and Oscillators" (page 135-137)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Averages Stochastic");
    indicator:description("description=Shows the location of the current close relative to the high/low range over a set number of periods.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("K", "Number of periods for %K", "param_K_description=The number of periods for %K.", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "The number of periods for slow %D.", 3, 2, 1000);
    indicator.parameters:addInteger("D", "Number of periods for %D", "The number of periods for %D.", 3, 2, 1000);

    indicator.parameters:addString("MVAT_K", "Smoothing type for %K", "The type of smoothing algorithm for %K.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("MVAT_K", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MVAT_K", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("MVAT_K", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("MVAT_K", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("MVAT_K", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MVAT_K", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("MVAT_K", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("MVAT_K", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("MVAT_K", "T3", "", "T3");
    indicator.parameters:addStringAlternative("MVAT_K", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("MVAT_K", "Median", "", "Median");
    indicator.parameters:addStringAlternative("MVAT_K", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("MVAT_K", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("MVAT_K", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("MVAT_K", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("MVAT_K", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("MVAT_K", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("MVAT_K", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("MVAT_K", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("MVAT_K", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("MVAT_K", "HPF", "", "HPF");
    indicator.parameters:addStringAlternative("MVAT_K", "VAMA", "", "VAMA");
    indicator.parameters:addStringAlternative("MVAT_K", "The Fast Smoothed algorithm.", "The Fast Smoothed algorithm.", "FS");

    indicator.parameters:addString("MVAT_D", "Smoothing type for %D", "The type of smoothing algorithm for %D.", "MVA"); 
    indicator.parameters:addStringAlternative("MVAT_D", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MVAT_D", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("MVAT_D", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MVAT_D", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("MVAT_D", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("MVAT_D", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("MVAT_D", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MVAT_D", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("MVAT_D", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("MVAT_D", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("MVAT_D", "T3", "", "T3");
    indicator.parameters:addStringAlternative("MVAT_D", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("MVAT_D", "Median", "", "Median");
    indicator.parameters:addStringAlternative("MVAT_D", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("MVAT_D", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("MVAT_D", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("MVAT_D", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("MVAT_D", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("MVAT_D", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("MVAT_D", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("MVAT_D", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("MVAT_D", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("MVAT_D", "HPF", "", "HPF");
    indicator.parameters:addStringAlternative("MVAT_D", "VAMA", "", "VAMA");
 	

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrFirst", "%K line color", "%K line color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthFirst","%K line width", "%K line width", 1, 1, 5);
    indicator.parameters:addInteger("styleFirst","%K line style", "K line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleFirst", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrSecond","%D line color", "%D line color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthSecond", "%D line width", "%D line width", 1, 1, 5);
    indicator.parameters:addInteger("styleSecond", "%D line style", "%D line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSecond", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addInteger("overbought", "Overbought Level", "Overbought Level", 80, 0, 100);
    indicator.parameters:addInteger("oversold", "Oversold Level", "Oversold Level", 20, 0, 100);
    indicator.parameters:addInteger("level_overboughtsold_width","Level line width","Level line width", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style","Level line style", "Level line style", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);	
    indicator.parameters:addColor("level_overboughtsold_color", "Level line color", "Level Line color", core.rgb(255, 255, 0));

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local k;
local d;
local sd;
local averageTypeK = nil;
local averageTypeD = nil;

local source = nil;
local mins = nil;
local maxes = nil;
local mva = nil;
local FastK = nil;
local fastkFirst = nil;
local kFirst = nil;
local dFirst = nil;
local isFS = nil;

-- Streams block
local K = nil;
local D = nil;
 
-- Routine
function Prepare(nameOnly)
    assert(instance.parameters.oversold < instance.parameters.overbought, "Overbought should be bigger than oversold");

    k = instance.parameters.K;
    d = instance.parameters.D;
    sd = instance.parameters.SD;
    source = instance.source;

    mins = instance:addInternalStream(source:first() + k, 0);
    maxes = instance:addInternalStream(source:first() + k, 0);
    FastK = instance:addInternalStream(mins:first(), 0);

    fastkFirst = FastK:first();

    averageTypeK = instance.parameters.MVAT_K;
    averageTypeD = instance.parameters.MVAT_D;
	
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator"); 
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. k .. ", " .. d .. ", " .. sd .. ", " .. averageTypeK .. ", " .. averageTypeD .. ")";
    instance:name(name);
	
    if   (nameOnly) then
        return;
    end

	
    if averageTypeK ~= "FS" then
        mva = core.indicators:create("AVERAGES", FastK, averageTypeK, sd);
        K = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.clrFirst, mva.DATA:first());
        isFS = false;
    else
        K = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.clrFirst, FastK:first() + sd);
        isFS = true;
    end
    K:setWidth(instance.parameters.widthFirst);
    K:setStyle(instance.parameters.styleFirst);
    K:setPrecision(2);

    kFirst = K:first();

    signalLine = core.indicators:create( "AVERAGES", K, averageTypeD, d);
    D = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.clrSecond, signalLine.DATA:first());
    D:setWidth(instance.parameters.widthSecond);
    D:setStyle(instance.parameters.styleSecond);
    D:setPrecision(2);
    dFirst = D:first();

    D:addLevel(0);
    D:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    D:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    D:addLevel(100);
 
end

 
function Update(period, mode)
    if period >= fastkFirst then
        local minLow, maxHigh = mathex.minmax(source, period - k + 1, period);
        mins[period] = source.close[period] - minLow;
        maxes[period] = maxHigh - minLow;
        if maxes[period] > 0 then
            FastK[period] = mins[period] / maxes[period] * 100;
        else
            FastK[period] = 50;
        end
    end
    if isFS == false then
        mva:update(mode);
        if period >= kFirst then
            K[period] = mva.DATA[period];
        end
    else
        if period >= kFirst then
            local sumMax = mathex.sum(maxes, period - sd + 1, period);
            if sumMax == 0 then
                K[period] = 50;
            else
                local sumMin = mathex.sum(mins, period - sd + 1, period);
                K[period] = sumMin / sumMax * 100;
            end
        end
    end
    signalLine:update(mode);
    if period >= dFirst then
        D[period] = signalLine.DATA[period];
    end
 

end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+
--+------------------------------------------------+-----------------------------------------------+