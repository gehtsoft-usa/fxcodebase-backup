-- Id: 12168
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1376

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
    indicator:name("Bear Power with Normalization");
    indicator:description("The oscillators measures the buying and selling pressure in the market");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Frame", "Bears Period", "Time Frame", 13, 2 , 2000);
	indicator.parameters:addInteger("Period", "Normalization Period", " ", 13, 2 , 2000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Bears_color", "Color of Bears", "Color of Bears", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame;

local first;
local source = nil;

-- Streams block
local Bears = nil;
local EMA=nil;
local Raw;
local Period;
-- Routine
 function Prepare(nameOnly)  
    Frame = instance.parameters.Frame;
    source = instance.source;
	Period = instance.parameters.Period;    
	Raw= instance:addInternalStream(0, 0);
	
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ", " .. Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	EMA=core.indicators:create("EMA", source.close, Frame);
	first =  EMA.DATA:first() ;
	
    Bears = instance:addStream("Bears", core.Line, name, "Bears", instance.parameters.Bears_color, first+Period);
	Bears:setWidth(instance.parameters.width);
    Bears:setStyle(instance.parameters.style);
	
	Bears:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
  
  
    EMA:update(mode);

    if period < first or not  source:hasData(period) then
	return;
	end	 
	  
	 Raw[period] = source.low[period] - EMA.DATA[period]; 
	  
	 if period < first+Period then
    return;
    end	
 
	local min,max= mathex.minmax(Raw, period-Period+1, period);  
	local MAX= math.max(math.abs(min),math.abs(max))
		
	Bears[period]=Raw[period]/MAX;
		
    
end
