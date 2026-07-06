-- Id: 8191
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27873

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
    indicator:name("Velocity/Acceleration");
    indicator:description("Velocity/Acceleration");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("VP", "Velocity Period", "Velocity Period", 14);
	indicator.parameters:addInteger("VS", "Velocity Shift", "Velocity Shift", 0);
	 
    indicator.parameters:addInteger("AP", "Acceleration Period", "Acceleration Period", 10);   
    indicator.parameters:addInteger("AS", "Acceleration Shift", "Acceleration Shift", 0);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Velocity_color", "Color of Velocity", "Color of Velocity", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("Acceleration_color", "Color of Acceleration", "Color of Acceleration", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local VP;
local AP;
local VS;
local AS;

local first;
local source = nil;
local RV, RA;
-- Streams block
local Velocity = nil;
local Acceleration = nil;
local FIRST={};
-- Routine
function Prepare(nameOnly)
    VP = instance.parameters.VP;
    AP = instance.parameters.AP;
    VS = instance.parameters.VS;
    AS = instance.parameters.AS;
    source = instance.source;
    first = source:first()+VP;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(VP) .. ", " .. tostring(VS) .. ", " .. tostring(AP) .. ", " .. tostring(AS) .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
	    RV = instance:addInternalStream(first,0);
		RA = instance:addInternalStream(first+AP,0);
		
		
			if  VS > 0 then
			FIRST[1]= first + VS;
			else
			FIRST[1]= first;
			end
			
			if  AS > 0 then
			FIRST[2]= first+AP + AS;
			else
			FIRST[2]= first;
			end
	  
        Velocity = instance:addStream("Velocity", core.Line, name .. ".Velocity", "Velocity", instance.parameters.Velocity_color, FIRST[1], VS);
    Velocity:setPrecision(math.max(2, instance.source:getPrecision()));
		Velocity:setWidth(instance.parameters.width1);
        Velocity:setStyle(instance.parameters.style1);
		
        Acceleration = instance:addStream("Acceleration", core.Line, name .. ".Acceleration", "Acceleration", instance.parameters.Acceleration_color, FIRST[2], AS);
    Acceleration:setPrecision(math.max(2, instance.source:getPrecision()));
		Acceleration:setWidth(instance.parameters.width2);
        Acceleration:setStyle(instance.parameters.style2);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


    if period < first  then
	return;
	end
	
        RV[period] = source[period]*100/source[period-VP];
		
	if period < first+AP  then
	return;
	end	
		
        RA[period] =  RV[period]*100/RV[period-AP];
		
		
	Shift (RV,Velocity,VS,period, FIRST[1]);	
	Shift (RA, Acceleration, AS, period, FIRST[2]);	
    
end



function Shift (from , to, shift, period, X)
  

	 

	local p= period+shift;	
	
	if  shift < 0 then	
	
	   if  period+shift < X then
	   return;
	   end
	
	end
	
    to[p]= from[period];

end
