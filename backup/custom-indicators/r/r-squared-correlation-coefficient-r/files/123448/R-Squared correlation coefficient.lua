-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67286
 

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("RSquared");
    indicator:description("RSquared");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("color", "Color of RSquared", "Color of RSquared", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 1);
    indicator.parameters:addDouble("oversold","Oversold Level","", 0);
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

local first;
local source = nil;

-- Streams block
local RSquared = nil;
local Period ;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
		
    source = instance.source;
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
 


     RSquared = instance:addStream("RSquared", core.Line, name, "RSquared", instance.parameters.color, first); 
	 RSquared:setWidth(instance.parameters.width);
     RSquared:setStyle(instance.parameters.style);
	 
	 RSquared:setPrecision(math.max(2, instance.source:getPrecision()));
	 
	 RSquared:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	 RSquared:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

 if period < first or not  source:hasData(period) then
 return;
 end
 

local SumX  = 0;
local SumXX = 0;
local SumXY = 0;
local SumYY = 0;
local SumY  = 0;


 
								for k = 0, Period-1, 1 do
								
								
								  SumX  = SumX+(k+1)
								  SumXX = SumXX+((k+1)*(k+1))
								  SumXY = SumXY+((k+1)*source[period-k])
								  SumYY = SumYY+(source[period-k]*source[period-k])
								  SumY  = SumY+source[period-k]
										 
								 end
    
			
			
			local  Q1  = SumXY - SumX*SumY/Period
			local  Q2  = SumXX - SumX*SumX/Period
			local  Q3  = SumYY - SumY*SumY/Period
 
			
            RSquared[period]=((Q1*Q1)/(Q2*Q3));
			
	     
 end
 
 