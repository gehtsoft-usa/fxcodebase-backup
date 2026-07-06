-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60418

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
    indicator:name("VolatilityMA");
    indicator:description("VolatilityMA");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Lookback", "Lookback Period Duration in seconds", "Duration in seconds", 3000); 
	
    indicator.parameters:addDouble("Barrier", "Barrier", "Barrier", 2);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("VolatilityMA_color", "Color of VolatilityMA", "Color of VolatilityMA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Lookback;
local Barrier;

local first;
local source = nil;
local Period;
-- Streams block
local VolatilityMA = nil;
local Raw1,Raw2; 
local Second;
-- Routine
function Prepare(nameOnly)  
    Lookback = instance.parameters.Lookback;
    Barrier = instance.parameters.Barrier;
    source = instance.source;
    first = source:first()+1;
 
	
	
	
	Second=1/86400 ; 
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Lookback) .. ", " .. tostring(Barrier) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	Raw1 = instance:addInternalStream(0, 0);
    Raw2 = instance:addInternalStream(0, 0);   
	Period = instance:addInternalStream(0, 0);  

 
        VolatilityMA = instance:addStream("VolatilityMA", core.Line, name, "VolatilityMA", instance.parameters.VolatilityMA_color, first);
		VolatilityMA:setWidth(instance.parameters.width);
        VolatilityMA:setStyle(instance.parameters.style);
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

     Raw1[period]   =	(source[period]-source[period-1])/source[period];	
 	 Raw2[period]   = (source[period-1]-source[period])/source[period];
	 
    if period < first or not source:hasData(period) then
	return;
	end	
	
		local PERIOD= core.findDate (source, source:date(period)- Second * Lookback, false);
	
	if PERIOD==-1
	or PERIOD< first+1 
	or PERIOD>= period
    then
    return;
    end 
	
	
	
		local  Average = mathex.avg(Raw1, PERIOD, period);
       
	    local j; 
		local  Variance=0;
		
		for j = PERIOD, period, 1 do			 
		Variance =Variance+ math.pow( (Raw2[period-j] - Average),2);				
		end
					
		local  sDev = math.sqrt( Variance/(period-PERIOD) );
		local  sDevNow = ((source[period]-source[period-1])/source[period])/ sDev;
			
		 
		if  math.abs(sDevNow) > Barrier then
		Period[period]=1;
        else
		Period[period]=Period[period-1]+ 1;
        end		
			
		if period < Period[period] then
        return;
       end
	   
        VolatilityMA[period] = mathex.avg(source, period-Period[period]+1, period);
   
end

