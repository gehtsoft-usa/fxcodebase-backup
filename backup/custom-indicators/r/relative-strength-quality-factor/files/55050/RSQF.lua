-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32296
-- Id: 8549

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("relative strength quality factor");
    indicator:description("relative strength quality factor");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("RP", "RSI Period", "RSI Period", 14);
    indicator.parameters:addInteger("QP", "Period", "Period", 14);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("RSQF_color", "Color of RSQF", "Color of RSQF", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 1);
    indicator.parameters:addDouble("oversold","Oversold Level","", -1);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local RP;
local QP;

local first;
local source = nil;

-- Streams block
local RSQF = nil;
local RSI;
local DEV;
-- Routine
function Prepare(nameOnly)
    RP = instance.parameters.RP;
    QP = instance.parameters.QP;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(RP) .. ", " .. tostring(QP) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        RSI=core.indicators:create("RSI",  source, RP);
        first = RSI.DATA:first();
	    DEV = instance:addInternalStream(0, 0);
        RSQF = instance:addStream("RSQF", core.Line, name, "RSQF", instance.parameters.RSQF_color, first+QP);
    RSQF:setPrecision(math.max(2, instance.source:getPrecision()));
		RSQF:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		RSQF:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		RSQF:setWidth(instance.parameters.width);
        RSQF:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

RSI:update(mode);
    if period < first   then
	return;
	end
	
	DEV[period] = math.abs(50 - RSI.DATA[period]);
	
	if period < first +QP   then
	return;
	end
	
	
	local AVDEV = mathex.avg(DEV, period-QP+1, period );
	
        RSQF[period] =((RSI.DATA[period] - 50))/AVDEV;    
end

