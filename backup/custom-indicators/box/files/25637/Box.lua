-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=13128

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
    indicator:name("Box Indicator");
    indicator:description("Box Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Size", "Box Size", "", 100);
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("Dn", "Down Color", "", core.rgb(255, 0, 0));
	 
	 indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Size;

local first;
local source = nil;

-- Streams block
local Up = nil;
local Dn = nil;

-- Routine
function Prepare(nameOnly)
    Size = instance.parameters.Size;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Size) .. ")";
    instance:name(name);
    
	if   (nameOnly) then
        return;
    end
	
   
        Up = instance:addStream("Up", core.Line, name, "Up", instance.parameters.Up, first);
		Dn = instance:addStream("Dn", core.Line, name, "Dn", instance.parameters.Dn, first);
		
		Up:setWidth(instance.parameters.width);
        Up:setStyle(instance.parameters.style);
		
		Dn:setWidth(instance.parameters.width);
        Dn:setStyle(instance.parameters.style);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not source:hasData(period) then
	return;
	end
	
	
	Up[period] =  Up[period-1]; 
    Dn[period] = Dn[period-1];
    	
	
	if period == first then
     Up[period]= source.open[period]+ (Size/2)*source:pipSize() ;
	 Dn[period]= source.open[period]- (Size/2)*source:pipSize() ;	
	elseif core.crossesOver ( source.close, Up[period-1], period) then 
	 Up[period]= Up[period-1]+ (Size/2)*source:pipSize() ;
	 Dn[period]= Up[period-1]- (Size/2)*source:pipSize() ;
	  Dn:setBreak (period, true);
	  Up:setBreak (period, true);
	elseif core.crossesUnder ( source.close, Dn[period-1], period) then 	
	 Up[period]= Dn[period-1]+ (Size/2)*source:pipSize() ;
	 Dn[period]= Dn[period-1]- (Size/2)*source:pipSize() ;
	  Dn:setBreak (period, true);
	  Up:setBreak (period, true);
	
	end
	 
end

