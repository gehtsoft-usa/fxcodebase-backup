-- Id: 19245
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=659&start=40

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
    indicator:name("Automatic Fib or Gann levels on the base of H/L values");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Parameters");
    indicator.parameters:addInteger("N", "Number of periods to find H/L", "", 50);
	
	indicator.parameters:addInteger("Lookback", "Lookback periods", "", 4, 1, 200);

    indicator.parameters:addString("M", "Lines Method", "", "F");
    indicator.parameters:addStringAlternative("M", "Fibonacci", "", "F");
    indicator.parameters:addStringAlternative("M", "Gann", "", "G");
	indicator.parameters:addStringAlternative("M", "Custom", "", "C");
	
    indicator.parameters:addString("L", "Levels number", "", "3");
    indicator.parameters:addStringAlternative("L", "3 Lines", "", "3");
    indicator.parameters:addStringAlternative("L", "3 Lines (alt)", "", "3a");
    indicator.parameters:addStringAlternative("L", "5 Lines", "", "5");
    indicator.parameters:addStringAlternative("L", "7 Lines", "", "7");
    indicator.parameters:addStringAlternative("L", "9 Lines", "", "9");

    indicator.parameters:addBoolean("Flip", "Use L-H instead H-L", "", false);	
	
	indicator.parameters:addGroup("Custom Levels");
	indicator.parameters:addDouble("L1", "1. Level", "", -0.236);
	indicator.parameters:addDouble("L2", "2. Level", "", 0);
	indicator.parameters:addDouble("L3", "3. Level", "", 0.236);
	indicator.parameters:addDouble("L4", "4. Level", "", 0.382);
	indicator.parameters:addDouble("L5", "5. Level", "", 0.5);
	indicator.parameters:addDouble("L6", "6. Level", "", 0.618);
	indicator.parameters:addDouble("L7", "7. Level", "", 0.764);
	indicator.parameters:addDouble("L8", "8. Level", "", 1);
	indicator.parameters:addDouble("L9", "9. Level", "", 1.272);
	
 
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("L_color", "Color of level lines", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("L_width", "Width of level lines", "", 1, 1, 5);
    indicator.parameters:addInteger("L_style", "Style level lines", "", core.LINE_SOLID);
    indicator.parameters:setFlag("L_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("M_color", "Time marker color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("M_width", "Width of level lines", "", 1, 1, 5);
    indicator.parameters:addInteger("M_style", "Style level lines", "", core.LINE_DOT);
    indicator.parameters:setFlag("M_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addBoolean("ShowLabels", "Show Line Labels", "", true);
	
	indicator.parameters:addColor("Label_color", "Color Label", "",core.COLOR_LABEL );
	indicator.parameters:addInteger("Size", "Color Label", "", 10);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local N;
local M;
local L;
local L_color;
local L_width;
local L_style;
local M_color;
local M_width;
local M_style;
local ShowLabels;
local Flip;
--local T_color;

local first;
local source = nil;
local barSize;
local format;

-- Streams block
local D = nil;
local Lookback;
local Size;
-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    M = instance.parameters.M;
    L = instance.parameters.L;
	Size= instance.parameters.Size;
    L_color = instance.parameters.L_color;
    L_width = instance.parameters.L_width;
    L_style = instance.parameters.L_style;
    M_color = instance.parameters.M_color;
    M_width = instance.parameters.M_width;
    M_style = instance.parameters.M_style;
    ShowLabels = instance.parameters.ShowLabels;
    Flip = instance.parameters.Flip;
	
	Lookback= instance.parameters.Lookback;
    --T_color = instance.parameters.T_color;
    source = instance.source;
    local s, e; 

    first = source:first() + N*Lookback;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. M .. ", " .. L .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
   
    format = "%.3f=%." .. source:getPrecision() .. "f";
	
	CalcLevels();
	
	instance:ownerDrawn(true);

	
end

local MIN = nil;
local MAX = nil;
local P = nil;
local levels = nil;
local index = nil;

-- Indicator calculation routine
function Update(period)



end


local init = false;
 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
	
        if not init then
            context:createFont (1, "Arial", Size, Size, 0);
			context:createPen (2,  context:convertPenStyle (instance.parameters.L_style), instance.parameters.L_width, instance.parameters.L_color);
			context:createPen (3,   context:convertPenStyle (instance.parameters.M_style),  instance.parameters.M_width,  instance.parameters.M_color);
            init = true;
        end
 
 
   
	
	
	for i= 1, Lookback ,1 do
		
    
		period= source:size() - 1 -N*(i-1)  
		 
 
	   if period >  first then
	
        min, max, minp, maxp = mathex.minmax(source,period-N+1, period );
       -- p = math.min(minp, maxp);
		  d = max - min;

 

         
            local idx;
            idx = index[L];
			
			  x,  x1 , x2  =context:positionOfDate (source:date(period));
			  from, x =context:positionOfDate (source:date(period-N+1));
			  
 

            for k, v in pairs(idx) do
                if Flip then
                    price = max - d * levels[v];
                else
                    price = min + d * levels[v];
                end    
				
				visible, y =context:pointOfPrice (price);
				
                label = string.format(format, levels[v], price);
            
			  context:drawLine (2, from, y, x2, y );
			  
                if ShowLabels then
				
				   width, height = context:measureText (1, label, 0)
				   context:drawText (1, label,  instance.parameters.Label_color, -1, x2, y-height , x2+width, y , 0);
                   
                end
            end
          
		   
		   visible, y1 =context:pointOfPrice (min);
		   visible, y2 =context:pointOfPrice (max);
		     context:drawLine (3, from, y1, from, y2 );
        end
        
    end
end

function CalcLevels()
    levels = {};
    index = {};
    if M == "F" then
        levels[1] = -0.236;
        levels[2] = 0;
        levels[3] = 0.236;
        levels[4] = 0.382;
        levels[5] = 0.5;
        levels[6] = 0.618;
        levels[7] = 0.764;
        levels[8] = 1;
        levels[9] = 1.272;
        index["3"] = {4, 5, 6};
        index["3a"] = {2, 5, 8};
        index["5"] = {2, 4, 5, 6, 8};
        index["7"] = {2, 3, 4, 5, 6, 7, 8};
        index["9"] = {1, 2, 3, 4, 5, 6, 7, 8, 9};
    elseif  M== "G" then
        levels[1] = 0;
        levels[2] = 0.125;
        levels[3] = 0.25;
        levels[4] = 0.375;
        levels[5] = 0.5;
        levels[6] = 0.625;
        levels[7] = 0.75;
        levels[8] = 0.875;
        levels[9] = 1;
        index["3"] = {3, 5, 7};
        index["3a"] = {1, 5, 9};
        index["5"] = {1, 3, 5, 7, 9};
        index["7"] = {1, 3, 4, 5, 6, 7, 9};
        index["9"] = {1, 2, 3, 4, 5, 6, 7, 8, 9};
	elseif  M== "C" then	
	
	    levels[1] = instance.parameters.L1;
        levels[2] = instance.parameters.L2;
        levels[3] = instance.parameters.L3;
        levels[4] = instance.parameters.L4;
        levels[5] = instance.parameters.L5;
        levels[6] = instance.parameters.L6;
        levels[7] = instance.parameters.L7;
        levels[8] = instance.parameters.L8;
        levels[9] = instance.parameters.L9;
        index["3"] = {4, 5, 6};
        index["3a"] = {2, 5, 8};
        index["5"] = {2, 4, 5, 6, 8};
        index["7"] = {2, 3, 4, 5, 6, 7, 8};
        index["9"] = {1, 2, 3, 4, 5, 6, 7, 8, 9};
    end

end
