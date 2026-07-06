-- Id: 11734
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60693

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+


function Init()
    indicator:name("Linda's Coil");
    indicator:description("Linda's Coil");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
 
	indicator.parameters:addGroup( "Calculation");
	indicator.parameters:addInteger("Period", " Period ", "", 3);
	
	indicator.parameters:addString("Method", "Method", "Method" , "Engulfed or Equal");
    indicator.parameters:addStringAlternative("Method", "Engulfed or Equal", "Engulfed or Equal" , "Engulfed or Equal");
    indicator.parameters:addStringAlternative("Method", "Engulfed", "Engulfed" , "Engulfed");
	
	indicator.parameters:addString("Type", "Type", "Type" , "Previous");
    indicator.parameters:addStringAlternative("Type", "In relation to the Previous Candle", "In relation to the Previous Candle" , "Previous");
    indicator.parameters:addStringAlternative("Type", "In relation to the Starting Candle", "In relation to the Starting Candle" , "Starting");
  
	indicator.parameters:addGroup(  "Style");	
	indicator.parameters:addColor("CoilColor", "Coil Color", "Coil Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Size", "Size", 20);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local CoilColor ;
local first;
local source = nil;
local Period;
local Type;
local Method; 
-- Streams block
local Coil; 
local Size; 
local Flag;
 
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	Period= instance.parameters.Period;
	Method= instance.parameters.Method;
	Type= instance.parameters.Type;
	Size= instance.parameters.Size;
    CoilColor= instance.parameters.CoilColor;
	first=source:first()+Period;
		
    local name = profile:id() .. "(" .. source:name() .. "," ..  Period  .. "," ..  Method  .. "," ..  Type  .. ")";
    instance:name(name);
	if nameOnly then
		Coil  = instance:createTextOutput ("Coil" , "Coil", "Wingdings", Size , core.H_Center, core.V_Bottom, CoilColor , first);
	end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period )
 
	
	if period < first then
	return;
	end
	
    Calculation (period);
	
end

function Calculation( End )
   
   local  Start = End-Period+1;
   
   
  
   local Flag= true;
   
   local period;
    for period  = Start+1, End, 1  do
	
	
	        if Type== "Previous" then
					if (((source.high[period]>= source.high[period-1] )
					or  (source.low[period]<= source.low[period-1] ) ) and Method== "Engulfed") 
					or
					(((source.high[period]> source.high[period-1] )
					or  (source.low[period]< source.low[period-1] ) ) and Method== "Engulfed or Equal")			
					then
					Flag=false;
					end
			else
			        if (((source.high[period]>= source.high[Start] )
					or  (source.low[period]<= source.low[Start] ) ) and Method== "Engulfed") 
					or
					(((source.high[period]> source.high[Start] )
					or  (source.low[period]< source.low[Start] ) ) and Method== "Engulfed or Equal")			
					then
					Flag=false;
					end
            end			
	
	end	 
	 
	 Coil:setNoData (End);	
	
	 if Flag then
	 Coil:set(End, source.low[End], "\254");	
	 end
end
 