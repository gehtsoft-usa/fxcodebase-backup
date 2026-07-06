
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62856

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
-- The indicator corresponds to the Larry Williams' Percent Range indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 6 "Momentum and Oscillators" (page 143)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Larry Williams' Percent Range");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Period","", 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrRLWUp", "Up Bar Color","", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("clrRLWDown", "Down Bar Color","", core.rgb(255, 0, 0)); 

    indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addInteger("overbought", "OB Level","", -20, -100, 0);
    indicator.parameters:addInteger("oversold","OS Level","", -80, -100, 0);
    indicator.parameters:addInteger("level_overboughtsold_width", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(255, 255, 0));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 0, 0, 100);

	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;

local first;
local source = nil;

-- Streams block
local RLW = nil;
local transparency;
-- Routine
function Prepare(nameOnly)


    n = instance.parameters.N;
    source = instance.source;
    first = source:first() + n - 1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	
	
    RLW = instance:addStream("RLW", core.Line, name, "%R", instance.parameters.clrRLWUp, first);
	RLW:setStyle(core.LINE_NONE);

    RLW:setPrecision(2);

    RLW:addLevel(0);
    RLW:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    RLW:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    RLW:addLevel(-100);
	
	transparency = instance.parameters.transparency;

	
	if transparency == 100 then
        transparency = 255;
    elseif transparency == 0 then
        transparency = 0;
    else
        transparency = math.floor(255 * (transparency / 100.0) + 0.5);
    end

	
	instance:ownerDrawn(true);

end

-- Indicator calculation routine
function Update(period)
    if period >= first then
        local from = period - n + 1;
        low, high = mathex.minmax(source, from, period);
        local diff = high - low;
        if (diff == 0) then
            RLW[period] = 0;
        else
            RLW[period] = (-100) * (high - source.close[period]) / diff;
        end
    end
end

local init = false;
 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
	
        if not init then 
		    context:createSolidBrush(1, instance.parameters.clrRLWUp);
            context:createSolidBrush(2, instance.parameters.clrRLWDown);
            init = true;
        end
  
    local First = math.max(first,context:firstBar ());
	local Last = math.max(source:size()-1,context:lastBar ());
	
    for period=First, Last, 1 do
    x, x1, x2 = context:positionOfBar (period);
	if x2 -x1 > 3 then
	x1=x-(x2-x1)/3;
	x2=x+(x2-x1)/3;
	end
	visible, y1 = context:pointOfPrice (-50);
	visible, y2 = context:pointOfPrice (RLW[period]);
		if RLW[period] > -50 then
		context:drawRectangle (-1, 1, x1, y1, x2, y2, transparency);
		else
		context:drawRectangle (-1,2, x1, y1, x2, y2, transparency);
		end
	end
	
        
end


