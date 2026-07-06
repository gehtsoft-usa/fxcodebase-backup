-- Id:  
-- More information about this indicator can be found at:
-- http://fxcodebase.com 

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

function Init()
    indicator:name("Candle Breakdown");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "Period", "", 14, 2, 2000);
	
	
	
    indicator.parameters:addBoolean("Body", "Add Body", "", true);
	indicator.parameters:addBoolean("Wick", "Add Wick", "", false);
	 indicator.parameters:addBoolean("Inverse", "Inverse Wick", "", true);
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", "Down Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local   Period1; 
local first;
local source = nil;
local Wick,Body,Inverse;
local Oscillator;  
local Up, Down;
local UP, DOWN;
-- Routine
 function Prepare(nameOnly)  


     Period1= instance.parameters.Period1; 
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " ..  Period1 .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	
	
  
	Wick= instance.parameters.Wick;
	Body= instance.parameters.Body;
	Inverse= instance.parameters.Inverse;
	
	Up = instance:addInternalStream(0, 0);
	Down = instance:addInternalStream(0, 0);
   
			
    source = instance.source;
	
	 first=source:first()+Period1;
    
   
 
	UP = instance:addStream("UP" , core.Line, " UP"," UP",instance.parameters.color1, first);
    UP:setPrecision(math.max(2, instance.source:getPrecision()));
	UP:setWidth(instance.parameters.width);
    UP:setStyle(instance.parameters.style);
	
	DOWN = instance:addStream("DOWN" , core.Line, " DOWN"," DOWN",instance.parameters.color2, first);
    DOWN:setPrecision(math.max(2, instance.source:getPrecision()));
	DOWN:setWidth(instance.parameters.width);
    DOWN:setStyle(instance.parameters.style);
    
	
	
end

-- Indicator calculation routine
function Update(period, mode)

  
    Up[period]=0;
	Down[period]=0;
	if source.close[period]>source.open[period] then
	
	if Body then
	Up[period]= math.abs(source.close[period]-source.open[period]);
	Down[period]=0;
	end
	
	if Wick then
	if Inverse then 
	Down[period]=Down[period] +(source.open[period]-source.low[period]);
	Up[period]=Up[period] +(source.high[period]-source.close[period]);
	else
	Up[period]=Up[period] +(source.open[period]-source.low[period]);
	Down[period]=Down[period] +(source.high[period]-source.close[period]);
	end
	end
	
	else
	if Body then
	Up[period]= 0;
	Down[period]= math.abs(source.close[period]-source.open[period]);
	end
	
	if Wick then
	if Inverse then 
	Down[period]=Down[period] +(source.close[period]-source.low[period]);
	Up[period]=Up[period] +(source.high[period]-source.open[period]);
	else
	Up[period]=Up[period] +(source.close[period]-source.low[period]);
	Down[period]=Down[period] +(source.high[period]-source.open[period]);
	end
	end
	
	end
	
    if period < first then
	return;
	end
	
	
	UP[period]=mathex.sum(Up, period-Period1+1, period);	
	DOWN[period]=mathex.sum(Down, period-Period1+1, period);	
    
				  
end

