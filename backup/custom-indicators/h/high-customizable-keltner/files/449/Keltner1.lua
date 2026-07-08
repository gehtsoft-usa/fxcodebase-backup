-- Id: 804
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=280

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Keltner Band");
    indicator:description("No description");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    -- indicator parameters
    indicator.parameters:addInteger("NM", "Number of the periods to smooth the center line", "", 50);
    indicator.parameters:addInteger("NB", "Number of periods to smooth deviation", "", 50);
    indicator.parameters:addDouble("F", "Factor which is used to apply the deviation", "", 1);

    -- source method
    indicator.parameters:addString("SRC", "The center line source", "", "C");
    indicator.parameters:addStringAlternative("SRC", "Close", "", "C");
    indicator.parameters:addStringAlternative("SRC", "Median (H+L)/2", "", "M1");
    indicator.parameters:addStringAlternative("SRC", "Median (H+L+C)/3", "", "M2");

    -- source smoothing method
    indicator.parameters:addBoolean("SC", "Show the center line", "", true);
    indicator.parameters:addString("MS", "The center line smoothing method", "", "MVA");
    indicator.parameters:addStringAlternative("MS", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MS", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MS", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MS", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MS", "Wilders", "", "WMA");

    -- variation method
    indicator.parameters:addString("MV", "Variation Method", "", "AHL");
    indicator.parameters:addStringAlternative("MV", "Smoothed H-L", "", "AHL");
    indicator.parameters:addStringAlternative("MV", "ATR of source", "", "ATR");
     indicator.parameters:addGroup("Upper Band Style");
    indicator.parameters:addColor("H_color", "Color of Upper Band Line", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("H_width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("H_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("H_style", core.FLAG_LINE_STYLE);
	 indicator.parameters:addGroup("Middle Band Style");
    indicator.parameters:addColor("M_color", "Color of Middle Band Line", "", core.rgb(0, 255, 255));
	indicator.parameters:addInteger("M_width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("M_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("M_style", core.FLAG_LINE_STYLE);
	 indicator.parameters:addGroup("Lower Band Style");
    indicator.parameters:addColor("L_color", "Color of Lower Band Line", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("L_width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("L_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("L_style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local NM;
local NB;
local MS;
local MV;
local SRC;
local F;
local SC;

local first;
local source = nil;

-- Streams block
local H = nil;
local M = nil;
local L = nil;

local AS;           -- alternative source
local MI;           -- middle line smoothed

local VM1;          -- the source stream for H-L variation method
local VMI;          -- the indicator for smoothing H-L variation method
local ATR;          -- ATR indicator for smoothing method

-- Routine
function Prepare(nameOnly)
    SC = instance.parameters.SC;
    NM = instance.parameters.NM;
    NB = instance.parameters.NB;
    SRC = instance.parameters.SRC;
    F = instance.parameters.F;
    MV = instance.parameters.MV;
    MS = instance.parameters.MS;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. "." .. SRC .. ", "
    -- preare the source
    if SRC == "C" then
        AS = source.close;
    elseif SRC == "M1" or SRC == "M2" then
        AS = instance:addInternalStream(source:first(), 0);
    else
        assert(false, "The source method is unknown");
    end

    -- create an indicator to calculate the middle line
    name = name .. MS .. "(" .. NM .. "), "
    assert(core.indicators:findIndicator(MS) ~= nil, MS .. " indicator must be installed");
    MI = core.indicators:create(MS, AS, NM);
    first = MI.DATA:first();

    if MV == "AHL" then
        name = name .. MS .. "(H-L, " .. NB .. "), "
        VM1 = instance:addInternalStream(source:first(), 0);
        VMI = core.indicators:create(MS, VM1, NB);
        if VMI.DATA:first() > first then
            first = MI.DATA:first();
        end
    elseif MV == "ATR" then
        name = name .. "ATR(" .. NB .. "), "
        ATR = core.indicators:create("ATR", source, NB);
        if ATR.DATA:first() > first then
            first = ATR.DATA:first();
        end
    else
        assert(false, "The variation method is unknown");
    end
    name = name .. F;
    name = name .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    H = instance:addStream("H", core.Line, name .. ".H", "H", instance.parameters.H_color, first);
	H:setWidth(instance.parameters.H_width);
    H:setStyle(instance.parameters.H_style);
    if SC then
        M = instance:addStream("M", core.Line, name .. ".M", "M", instance.parameters.M_color, first);
		M:setWidth(instance.parameters.M_width);
        M:setStyle(instance.parameters.M_style);
    else
        M = instance:addInternalStream(first, 0);
    end
    L = instance:addStream("L", core.Line, name .. ".L", "L", instance.parameters.L_color, first);
	L:setWidth(instance.parameters.L_width);
    L:setStyle(instance.parameters.L_style);
end

-- Indicator calculation routine
function Update(period, mode)
    if period >= source:first() then
        if SRC == "M1" then
            AS[period] = (source.high[period] + source.low[period]) / 2;
        elseif SRC == "M2" then
            AS[period] = (source.high[period] + source.low[period] + source.close[period]) / 3;
        end
        -- update the source smoothing indicator
        MI:update(mode);

        if MV == "AHL" then
            VM1[period] = source.high[period] - source.low[period];
            VMI:update(mode);
        elseif MV == "ATR" then
            ATR:update(mode);
        end
    end

    if period >= first then
        local v;
        M[period] = MI.DATA[period];
        if MV == "AHL" then
            VM1[period] = source.high[period] - source.low[period];
            v = VMI.DATA[period];
        elseif MV == "ATR" then
            v = ATR.DATA[period];
        end
        H[period] = M[period] + v * F;
        L[period] = M[period] - v * F;
    end
end

