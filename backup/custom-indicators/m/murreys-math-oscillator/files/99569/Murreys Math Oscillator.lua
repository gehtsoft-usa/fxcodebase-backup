-- Id: 13893

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62065

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Murrey's Math Oscillator");
    indicator:description("Murrey's Math Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("length", "Look back Length", "Look back Length", 100);
    indicator.parameters:addDouble("mult", "Mutiplier", "Mutiplier", 0.125);
    indicator.parameters:addBoolean("lines", "Show Murrey Math Fractals", "Show Murrey Math Fractals", true);

	
	indicator.parameters:addGroup("Style");
 
	indicator.parameters:addColor("P1_color", "1.Positive Zone Color", "Zone Color", core.rgb(173, 255, 47));
	indicator.parameters:addColor("P2_color", "2. Positive Zone Color", "Zone Color", core.rgb(50, 205, 50));
	indicator.parameters:addColor("P3_color", "3. Positive Zone Color", "Zone Color", core.rgb(60, 179, 113));
	indicator.parameters:addColor("P4_color", "4. Positive Zone Color", "Zone Color", core.rgb(0, 128, 0));
	indicator.parameters:addColor("N1_color", "1. Negative Zone Color", "Zone Color", core.rgb(205, 92, 92));
	indicator.parameters:addColor("N2_color", "2. Negative Zone Color", "Zone Color", core.rgb(250, 128, 114));
	indicator.parameters:addColor("N3_color", "3. Negative Zone Color", "Zone Color", core.rgb(255, 160, 122));
	indicator.parameters:addColor("N4_color", "4. Negative Zone Color", "Zone Color", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral_color", "Neutral Color", "Neutral Color", core.rgb(0, 0, 288));
	
	
	indicator.parameters:addGroup("Line Levels");	
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
local length;
local mult;
local lines;

local first;
local source = nil; 
-- Streams block
local oscillator = nil;

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
    length = instance.parameters.length;
    mult = instance.parameters.mult;
    lines = instance.parameters.lines;
    source = instance.source;
    first = source:first()+length;

 	
 
        oscillator = instance:addStream("oscillator", core.Bar, name, "oscillator", instance.parameters.Neutral_color, first);
    oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
		if lines then
		oscillator:addLevel(mult*2 , instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		oscillator:addLevel(mult*4 , instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
		oscillator:addLevel(mult*6 , instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		oscillator:addLevel(mult*8 , instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    	
        oscillator:addLevel(-mult*2 , instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		oscillator:addLevel(-mult*4 , instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
		oscillator:addLevel(-mult*6 , instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		oscillator:addLevel(-mult*8 , instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);   	
        end		
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period) 
		
    if period < first or not source:hasData(period) then
	return;
	end
    
    --Donchanin Channel
	local lo, hi = mathex.minmax(source,period-length+1, period);
    local range = hi - lo;
	local multiplier = range * mult;
    local midline = lo + multiplier * 4;


    oscillator[period] =  (source.close[period] - midline)/(range/2);
	
	local Color;
	
	if oscillator[period] > 0 then
	   
	    if oscillator[period] <= mult*2  then
		Color=instance.parameters.P1_color;
		elseif oscillator[period] <= mult*4  then
		Color=instance.parameters.P2_color;
		elseif oscillator[period] <= mult*6  then
		Color=instance.parameters.P3_color;
		elseif oscillator[period] <= mult*8  then
		Color=instance.parameters.P4_color;
		else
		Color=instance.parameters.Neutral_color;
		end
	
	elseif  oscillator[period] < 0 then
	
	    if oscillator[period] >=  -mult*2  then
		Color=instance.parameters.N1_color; 
		elseif oscillator[period] >= -mult*4  then
		Color=instance.parameters.N2_color;
		elseif oscillator[period] >= -mult*6  then
		Color=instance.parameters.N3_color;
		elseif oscillator[period] >= -mult*8  then
		Color=instance.parameters.N4_color;
		else
		Color=instance.parameters.Neutral_color;
		end
	
	else
		Color=instance.parameters.Neutral_color;	
	
	end
	
	oscillator:setColor(period, Color);
     
end

