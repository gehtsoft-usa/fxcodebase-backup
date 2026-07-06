-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65959
-- Id: 21022

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


-- Features of this indicator
-- 1：Display 3 RSI lines of different periods and the MA of the first RSI line.
-- 2：Display MA of the first RSI's MA. Crosses of the two MAs can be used as the signals. 
-- 3：Display histogram from RSI or MA to middle level.
-- 4：Colored level lines; 2 colors MA lines; Color filling between overbought and oversell levels.
-- About RSI value：
-- RSI value of this indicator = original RSI value - 50
-- This is to make RSI changes around 0 (not 50), which is convenient to draw histograms.

function Init()
    indicator:name("RSI Signal")
    indicator:description("")
    indicator:requiredSource(core.Tick)
    indicator:type(core.Oscillator)

    indicator.parameters:addInteger("RSI1", "RSI 1 Period", "", 14)
    indicator.parameters:addColor("RSI1_color", "Line Color", "", core.colors().Aqua);
    indicator.parameters:addInteger("RSI1_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("RSI1_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("RSI1_width", "Line Width", "", 1, 1, 5);
    
    indicator.parameters:addInteger("RSI2", "RSI 2 Period", "", 7)
    indicator.parameters:addColor("RSI2_color", "Line Color", "", core.colors().Aqua);
    indicator.parameters:addInteger("RSI2_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("RSI2_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("RSI2_width", "Line Width", "", 1, 1, 5);

    indicator.parameters:addInteger("RSI3", "RSI 3 Period", "", 21)
    indicator.parameters:addColor("RSI3_color", "Line Color", "", core.colors().Aqua);
    indicator.parameters:addInteger("RSI3_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("RSI3_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("RSI3_width", "Line Width", "", 1, 1, 5);

    indicator.parameters:addInteger("OverBought", "Overbought Level", "", 70)
    indicator.parameters:addColor("OverBought_color", "Line Color", "", core.colors().FireBrick);
    indicator.parameters:addInteger("OverBought_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("OverBought_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("OverBought_width", "Line Width", "", 2, 1, 5);

    indicator.parameters:addInteger("OverSell", "Oversell Level", "", 30)
    indicator.parameters:addColor("OverSell_color", "Up Line Color", "", core.colors().Blue);
    indicator.parameters:addInteger("OverSell_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("OverSell_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("OverSell_width", "Line Width", "", 2, 1, 5);

    indicator.parameters:addGroup("Smooth RSI 1")
    indicator.parameters:addInteger("MA1_Period", "Smooth Period", "", 10)
    indicator.parameters:addString("MA1_Method", "Smooth Period", "", "MVA");
    indicator.parameters:addStringAlternative("MA1_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA1_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA1_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("MA1_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("MA1_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA1_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("MA1_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("MA1_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("MA1_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MA1_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("MA1_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("MA1_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("MA1_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("MA1_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("MA1_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("MA1_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("MA1_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("MA1_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("MA1_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("MA1_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("MA1_Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addColor("MA1_color", "Up Line Color", "", core.colors().Lime);
    indicator.parameters:addColor("MA1_color_dn", "Down Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("MA1_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("MA1_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("MA1_width", "Line Width", "", 2, 1, 5);
    
    indicator.parameters:addGroup("Set MA of Smoothed RSI 1")
    indicator.parameters:addInteger("MA2_Period", "MA Period", "", 5)
    indicator.parameters:addString("MA2_Method", "Smooth Period", "", "MVA");
    indicator.parameters:addStringAlternative("MA2_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA2_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA2_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("MA2_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("MA2_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA2_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("MA2_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("MA2_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("MA2_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MA2_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("MA2_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("MA2_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("MA2_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("MA2_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("MA2_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("MA2_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("MA2_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("MA2_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("MA2_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("MA2_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("MA2_Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addColor("MA2_color", "Up Line Color", "", core.colors().Lime);
    indicator.parameters:addColor("MA2_color_dn", "Down Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("MA2_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("MA2_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("MA2_width", "Line Width", "", 2, 1, 5);

    indicator.parameters:addGroup("Choose The Lines You Want to Display")
    indicator.parameters:addBoolean("RSILine1", "Enable RSI 1 Line", "", true)
    indicator.parameters:addBoolean("RSILine2", "Enable RSI 2 Line", "", false)
    indicator.parameters:addBoolean("RSILine3", "Enable RSI 3 Line", "", false)
    indicator.parameters:addBoolean("MALine1", "Enable Smoothed RSI 1", "", true)
    indicator.parameters:addBoolean("MALine2", "Enable MA of Smoothed RSI 1", "", true)

    indicator.parameters:addString("Histogram", "Choose How to Draw Histogram", "", "MA1ToLevel0")
    indicator.parameters:addStringAlternative("Histogram", "Draw Histogram for RSI 1", "", "RSI1ToMA1")
    indicator.parameters:addStringAlternative("Histogram", "Draw Histogram for Smoothed RSI 1", "", "MA1ToLevel0")
    indicator.parameters:addStringAlternative("Histogram", "Disable Histogram", "", "None")

    indicator.parameters:addString("ChangeHistogramColor", "Choose How to Change Histogram Color", "", "AsPerRSI1AndSmoothedRSI1")
    indicator.parameters:addStringAlternative("ChangeHistogramColor", "As Per Smoothed RSI-1 Direction", "", "AsPerMA1Direction")
    indicator.parameters:addStringAlternative("ChangeHistogramColor", "As Per RSI-1 and Smoothed RSI-1", "", "AsPerRSI1AndSmoothedRSI1")

    indicator.parameters:addColor("HIST_color", "Up Line Color", "", core.colors().Green);
    indicator.parameters:addColor("HIST_color_dn", "Down Line Color", "", core.colors().Brown);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local first
local source = nil

local Histo;

local RSILineBuffer1;
local RSILineBuffer2;
local RSILineBuffer3;

local MALine1Up;
local MALine2Up;

local RSI1;
local RSI2;
local RSI3;
local MALine1Buffer;
local MALine2Buffer;

-- Routine
function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)
    if (nameOnly) then
        return
    end

    source = instance.source
	
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator"); 

    RSI1 = core.indicators:create("RSI", source, instance.parameters.RSI1)
    RSI2 = core.indicators:create("RSI", source, instance.parameters.RSI2)
    RSI3 = core.indicators:create("RSI", source, instance.parameters.RSI3)

    RSILineBuffer1 = instance:addStream("RSI1", core.Line, "RSI1", "RSI1", instance.parameters.RSI1_color, 0)
    RSILineBuffer1:setPrecision(math.max(2, instance.source:getPrecision()));
    RSILineBuffer1:setWidth(instance.parameters.RSI1_width)
    RSILineBuffer1:setStyle(instance.parameters.RSI1_style)
    RSILineBuffer2 = instance:addStream("RSI2", core.Line, "RSI2", "RSI2", instance.parameters.RSI2_color, 0)
    RSILineBuffer2:setPrecision(math.max(2, instance.source:getPrecision()));
    RSILineBuffer2:setWidth(instance.parameters.RSI2_width)
    RSILineBuffer2:setStyle(instance.parameters.RSI2_style)
    RSILineBuffer3 = instance:addStream("RSI3", core.Line, "RSI3", "RSI3", instance.parameters.RSI3_color, 0)
    RSILineBuffer3:setPrecision(math.max(2, instance.source:getPrecision()));
    RSILineBuffer3:setWidth(instance.parameters.RSI3_width)
    RSILineBuffer3:setStyle(instance.parameters.RSI3_style)
    MALine1Up = core.indicators:create("AVERAGES", RSILineBuffer1, MA1_Method, MA1_Period, false);
    MALine1Buffer = instance:addStream("MA1", core.Line, "MA1", "MA1", instance.parameters.MA1_color, 0)
    MALine1Buffer:setPrecision(math.max(2, instance.source:getPrecision()));
    MALine1Buffer:setWidth(instance.parameters.MA1_width)
    MALine1Buffer:setStyle(instance.parameters.MA1_style)
    MALine2Up = core.indicators:create("AVERAGES", MALine1Up.DATA, MA2_Method, MA2_Period, false);
    MALine2Buffer = instance:addStream("MA2", core.Line, "MA2", "MA2", instance.parameters.MA2_color, 0)
    MALine2Buffer:setPrecision(math.max(2, instance.source:getPrecision()));
    MALine2Buffer:setWidth(instance.parameters.MA2_width)
    MALine2Buffer:setStyle(instance.parameters.MA2_style)
    RSILineBuffer1:addLevel(instance.parameters.OverSell - 50, instance.parameters.OverSell_style, instance.parameters.OverSell_width, instance.parameters.OverSell_color);
    RSILineBuffer1:addLevel(instance.parameters.OverBought - 50, instance.parameters.OverBought_style, instance.parameters.OverBought_width, instance.parameters.OverBought_color);

    Histo = instance:addStream("H1", core.Bar, "H1", "H1", instance.parameters.HIST_color, 0)
    Histo:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
function Update(period, mode)
    RSI1:update(mode)
    RSI2:update(mode)
    RSI3:update(mode)

    RSILineBuffer1[period] = RSI1.DATA[period] - 50.0;
    MALine1Up:update(mode)
    MALine2Up:update(mode)
    if (instance.parameters.RSILine2) then
        RSILineBuffer2[period] = RSI2.DATA[period] - 50.0;
    end
    if (instance.parameters.RSILine3) then
        RSILineBuffer3[period] = RSI3.DATA[period] - 50.0;
    end

    MALine1Buffer[period] = MALine1Up.DATA[period];
    if (MALine1Up.DATA[period] < MALine1Up.DATA[period - 1]) then
        MALine1Buffer:setColor(period, instance.parameters.MA1_color_dn);
    end

    if (instance.parameters.Histogram ~= "None") then
        -- Histogram type 2: draw histogram for MA-1 (MA of the RSI-1)
        if (instance.parameters.Histogram == "RSI1ToMA1") then
            local curDif = RSILineBuffer1[period] - MALine1Up.DATA[period];
            local preDif = RSILineBuffer1[period - 1] - MALine1Up.DATA[period - 1];
            Histo[period] = curDif;
            if (curDif > 0.0) then
                if (curDif > preDif) then
                    Histo:setColor(period, instance.parameters.HIST_color)
                else
                    Histo:setColor(period, instance.parameters.HIST_color_dn)
                end
            else
                if (curDif > preDif) then
                    Histo:setColor(period, instance.parameters.HIST_color)
                else
                    Histo:setColor(period, instance.parameters.HIST_color_dn)
                end
            end
        -- Histogram type 2: draw histogram for RSI-1
        elseif (instance.parameters.Histogram == "MA1ToLevel0") then
            local curMA = MALine1Up.DATA[period];
            Histo[period] = curMA;
            -- Option 1：Histogram color changes when RSI-1 and MA crosses.
            -- That is: When RSI1>MA1 or RSI-1<MA1, histogram color will change.
            if (instance.parameters.ChangeHistogramColor == "AsPerRSI1AndSmoothedRSI1") then
                local curDif = RSILineBuffer1[period] - MALine1Up.DATA[period];
                if (curDif > 0.0) then
                    Histo:setColor(period, instance.parameters.HIST_color)
                else
                    Histo:setColor(period, instance.parameters.HIST_color_dn)
                end
            -- Option 2：Histogram color changes according to direction of smoothed RSI-1 (MA-1)
            else
                local preMA = MALine1Up.DATA[period - 1];
                if (curMA > 0.0) then
                    if (curMA > preMA) then
                        Histo:setColor(period, instance.parameters.HIST_color)
                    else
                        Histo:setColor(period, instance.parameters.HIST_color_dn)
                    end
                else
                    if (curMA < preMA) then
                        Histo:setColor(period, instance.parameters.HIST_color_dn)
                    else
                        Histo:setColor(period, instance.parameters.HIST_color)
                    end
                end
            end
        end
    end
    -- calculate MA-2, MA of first RSI (RSI-1)'s MA.
    if (instance.parameters.MALine2) then
        if (MALine2Up.DATA[period] < MALine2Up.DATA[period - 1]) then
            MALine2Buffer:setColor(period, instance.parameters.MA2_color_dn);
        end
    end
end
