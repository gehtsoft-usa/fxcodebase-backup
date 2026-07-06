-- Id: 12215
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60982

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
    indicator:name("Break Out RSI");
    indicator:description("Break Out RSI");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("Period", "Period", "Period", 14);
    indicator.parameters:addColor("color", "Color of Line", "Color of Line", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;
local rsi;
-- Streams block
local Indication = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
	


    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);
    if   (nameOnly) then
        return;
    end
	
	
	rsi = core.indicators:create("RSI", source.open, Period);
    first = rsi.DATA:first();
	
    
    Indication = instance:addStream("Indication", core.Line, name, "Indication", instance.parameters.color, first);
	Indication:setPrecision(math.max(2, instance.source:getPrecision()));
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)


    rsi:update(mode);
		
    if period < first  then
	return;
	end
	


 
           local  Bottom,Top = mathex.minmax(source, period-Period+1,period);
           
 
            local AvgHighs =  mathex.avg(source.high, period-Period+1,period );
            local AvgLows = mathex.avg(source.low, period-Period+1,period );
			
		 
            if (source.close[period] >= Top) then      
                Indication[period] = 2;
			end	
           
            if (source.close[period] >= AvgHighs and source.close[period] < Top)  then          
                Indication[period] = 1;
			end	
            
            if (source.close[period] < AvgHighs and source.close[period] > AvgLows) then            
                Indication[period] = 0;
			end	
            
            if (source.close[period] <= AvgLows and source.close[period] > Bottom) then            
                Indication[period] = -1;
			end	
				
            
            if (source.close[period] <= Bottom) then            
                Indication[period] = -2;
			end	
           
    
end



 
	
 
