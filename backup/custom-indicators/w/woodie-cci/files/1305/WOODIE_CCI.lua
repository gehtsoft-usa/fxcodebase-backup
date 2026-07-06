-- Id: 3806
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=719

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
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
    indicator:name("Woodie CCI with histogramm coloring");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("F", "Fast CCI Periods", "", 12);
    indicator.parameters:addInteger("S", "Slow CCI periods", "", 50);
    indicator.parameters:addInteger("N", "Length of neutral zone in bars", "", 6);
	
	indicator.parameters:addGroup("Overbought / Oversold Levels");
	indicator.parameters:addInteger("Overbought", "Overbought", "",100);
	indicator.parameters:addInteger("Oversold", "Oversold", "", -100);
        indicator.parameters:addInteger("level_overboughtsold_width", "Level lines width", "The width of the overbought/oversold levels", 1, 1, 5);
        indicator.parameters:addInteger("level_overboughtsold_style", "Level lines stype", "The style of the overbought/oversold levels", core.LINE_SOLID);
        indicator.parameters:addColor("level_overboughtsold_color", "Level lines color", "The color of the overbought/oversold levels"  , core.rgb(96, 96, 138));
        indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);


	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("F_width", "Up Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("F_style", "Up Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("F_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("F_color", "Color of Fast CCI", "", core.rgb(255, 255, 0));
		
	indicator.parameters:addInteger("S_width", "Up Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("S_style", "Up Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("S_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("S_color", "Color of Slow CCI", "", core.rgb(255, 128, 0));
	
    indicator.parameters:addColor("H_color", "Color of neutral bars", "", core.rgb(192, 192, 192));
    indicator.parameters:addColor("HR_color", "Color of red bars", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("HB_color", "Color of blue bar", "", core.rgb(0, 0, 255));
	
	indicator.parameters:addGroup("Slow Bar/Line Style");
	indicator.parameters:addString("Slow", "Style", "", "Bar");
	indicator.parameters:addStringAlternative("Slow", "Bar", "", "Bar");
	indicator.parameters:addStringAlternative("Slow", "Line", "", "Line");
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Fast;
local Slow;
local N;

local Slow;

local first;
local source = nil;
local CCIF;
local CCIS;

-- Streams block
local F = nil;
local S = nil;
local Z = nil;

-- Routine
function Prepare(nameOnly) 
    Fast = instance.parameters.F;
    Slow = instance.parameters.S;
    N = instance.parameters.N;

    source = instance.source;
	
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. Fast .. ", " .. Slow .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    CCIF = core.indicators:create("CCI", source, Fast);
    CCIS = core.indicators:create("CCI", source, Slow);
    first = math.max(CCIF.DATA:first(), CCIS.DATA:first());
   
	
    Z = instance:addInternalStream(0, 0);
    F = instance:addStream("F", core.Line, name .. ".F", "F", instance.parameters.F_color, first);
    F:setPrecision(math.max(2, instance.source:getPrecision()));
	F:setWidth(instance.parameters.F_width);
    F:setStyle(instance.parameters.F_style);
	
	if Slow == "Line" then
    S = instance:addStream("S", core.Line, name .. ".S", "S", instance.parameters.S_color, first);
    else
	S = instance:addStream("S", core.Bar, name .. ".S", "S", instance.parameters.S_color, first);
	end
    S:setPrecision(math.max(2, instance.source:getPrecision()));
	
    F:addLevel(instance.parameters.Oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    F:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    F:addLevel(instance.parameters.Overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);

end

-- Indicator calculation routine
function Update(period, mode)
    CCIF:update(mode);
    CCIS:update(mode);
    if period >= first then
        F[period] = CCIF.DATA[period];
        S[period] = CCIS.DATA[period];

        local flag = false;
        local v = 0;

        if period >= first + 1 then
            if (S[period] >= 0 and S[period - 1] < 0) or
               (S[period] < 0 and S[period - 1] >= 0) then
                    v = 1;
                    flag = true;
            elseif Z[period - 1] > 0 then
                flag = true;
                v = Z[period - 1] + 1;
            end
        else
            -- initally we are in the gray zone
            flag = true;
            v = 1;
        end

        if flag then
            Z[period] = v;
            if Z[period] > N then
                flag = false;
            end
        end

        if flag then
            S:setColor(period,instance.parameters.H_color);	
        else
            Z[period] = 0;
            if S[period] > 0 then
                S:setColor(period,instance.parameters.HB_color);	
            else
                 S:setColor(period,instance.parameters.HR_color);	
            end
        end
    else
        Z[period] = 0;
    end
end

