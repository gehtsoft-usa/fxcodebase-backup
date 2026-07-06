-- Id: 163
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=331

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- The Laguerre RSI was introduced by John Ehlers in his book �Cybernetic Analysis for stocks and futures�.
-- It uses a Laguerre filter to provide a �time warp� so that the low
-- frequency components are delayed more than the high frequency components, enabling much smoother filters
-- to be created using less data.
-- The typical usage the Laguerre RSI is to buy when the line crosses 0.15 and sell when price crosses 0.85.
-- The price damping factor can be customized for optimal use to best suit the trade instruments
-- data by altering the gamma factor usually between 0.55 and 0.85. The
-- lower the Gamma factor the faster more aggressive the entry. The scale is -0.5 to 1.05.

-- Indicator profile initialization routine
function Init()
    indicator:name("John Ehlers Laguerre Relative Strenght Index");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");

    indicator.parameters:addDouble("GAMMA", "Gamma", "", 0.7, -0.5, 1.05);
	indicator.parameters:addGroup("Style");

    indicator.parameters:addColor("LRSI_color", "Color of LRSI", "Color of LRSI", core.rgb(255, 0, 128));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 0.85);
	indicator.parameters:addDouble("central","Central Level","", 0.45);
    indicator.parameters:addDouble("oversold","Oversold Level","", 0.15);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local GAMMA;

local first;
local source = nil;

-- Streams block
local LRSI = nil;
local L0;
local L1;
local L2;
local L3;


-- Routine
function Prepare(nameOnly)
    GAMMA = instance.parameters.GAMMA;
    source = instance.source;
    first = source:first() + 30;
    local name = profile:id() .. "(" .. source:name() .. ", " .. GAMMA .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    LRSI = instance:addStream("LRSI", core.Line, name, "LRSI", instance.parameters.LRSI_color, first);
    LRSI:setPrecision(math.max(2, instance.source:getPrecision()));
	LRSI:setWidth(instance.parameters.width);
    LRSI:setStyle(instance.parameters.style);
	
    LRSI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	LRSI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
    LRSI:addLevel(instance.parameters.central, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
			
  
    L0 = instance:addInternalStream(0, 0);
    L1 = instance:addInternalStream(0, 0);
    L2 = instance:addInternalStream(0, 0);
    L3 = instance:addInternalStream(0, 0);
end

function calc(period)
   L0[period] = (1.0 - GAMMA) * (source[period]) + GAMMA * L0[period - 1];
   L1[period] = -GAMMA * L0[period] + L0[period - 1] + GAMMA * L1[period - 1];
   L2[period] = -GAMMA * L1[period] + L1[period - 1] + GAMMA * L2[period - 1];
   L3[period] = -GAMMA * L2[period] + L2[period - 1] + GAMMA * L3[period - 1];
end


-- Indicator calculation routine
function Update(period)
    if period >= first then
        calc(period);
        local CU, CD;
        CU = 0;
        CD = 0;
        if (L0[period] >= L1[period]) then
            CU = L0[period] - L1[period];
        else
            CD = L1[period] - L0[period];
        end
        if (L1[period] >= L2[period]) then
            CU = CU + L1[period] - L2[period];
        else
            CD = CD + L2[period] - L1[period];
        end
        if (L2[period] >= L3[period]) then
            CU = CU + L2[period] - L3[period];
        else
            CD = CD + L3[period] - L2[period];
        end
        if ((CU + CD) ~= 0) then
            LRSI[period] = CU / (CU + CD);
        else
            LRSI[period] = 1;
        end
    elseif period >= source:first() + 1 then
        calc(period);
    else
        L0[period] = 0;
        L1[period] = 0;
        L2[period] = 0;
        L3[period] = 0;
    end
end

