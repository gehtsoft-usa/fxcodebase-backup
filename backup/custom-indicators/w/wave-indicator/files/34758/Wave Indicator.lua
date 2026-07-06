-- Id: 6705
-- More information about this indicator can be found at:
-- http://fxcodebase.com/

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
    indicator:name("Wave Indicator");
    indicator:description("Wave Indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Method", "Method", "Method" , "4");
    indicator.parameters:addStringAlternative("Method", "1", "1" , "1");
    indicator.parameters:addStringAlternative("Method", "2", "2" , "2");
	indicator.parameters:addStringAlternative("Method", "3", "3" , "3");
    indicator.parameters:addStringAlternative("Method", "4", "4" , "4");
    indicator.parameters:addStringAlternative("Method", "All", "All" , "All");
	indicator.parameters:addStringAlternative("Method", "Average", "Average" , "Average");
	
	
	indicator.parameters:addInteger("Period1", "1. Period" , "", 12)
	indicator.parameters:addInteger("Period2", "2. Period" , "", 24)
	indicator.parameters:addInteger("Period3", "3. Period" , "", 12)
	indicator.parameters:addInteger("Period4", "4. Period" , "", 12)
	indicator.parameters:addInteger("Period5", "5. Period" , "", 12)
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("C1", "1. Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("C2", "2. Line Color", "", core.rgb(255,0 , 0));
	indicator.parameters:addColor("C3", "3. Line Color", "", core.rgb(0,  0, 255));
	indicator.parameters:addColor("C4", "4. Line Color", "", core.rgb(128, 128, 128));

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period1=12;
local Period2=24;
local Period3=12;
local Period4=12;
local Period5=12;
local Method;
local first;
local source = nil;
local CI={};
-- Streams block
local A, B, C, D, E, F, G,H, I, J; 
local C1, C2, C3, C4;
-- Routine
function Prepare(nameOnly)

     C1 = instance.parameters. C2;
	 C2 = instance.parameters.C2;
	 C3 = instance.parameters.C3;
	 C4 = instance.parameters.C4;
	 Period1 = instance.parameters.Period1;
	 Period2 = instance.parameters.Period2;
	 Period3 = instance.parameters.Period3;
	 Period4 = instance.parameters.Period4;
     Period5 = instance.parameters.Period5
    source = instance.source;
    first = source:first();
	Method = instance.parameters.Method;

    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		  A =instance:addInternalStream(0, 0);	  
		  B =instance:addInternalStream(0, 0);
		  C =instance:addInternalStream(0, 0);
		  D =instance:addInternalStream(0, 0);
		  E =instance:addInternalStream(0, 0);
		  F =instance:addInternalStream(0, 0);
		  G =instance:addInternalStream(0, 0);
		  H  =instance:addInternalStream(0, 0);
		  I  =instance:addInternalStream(0, 0);
		  J =instance:addInternalStream(0, 0);
		 
		if Method == "All" then
		CI["1"] = instance:addStream("CI1", core.Line, name .. ".1", "1", C1, first);
    CI["1"]:setPrecision(math.max(2, instance.source:getPrecision()));
		CI["2"] = instance:addStream("CI2", core.Line, name .. ".2", "2", C2, first);
    CI["2"]:setPrecision(math.max(2, instance.source:getPrecision()));
		CI["3"] = instance:addStream("CI3", core.Line, name .. ".3", "3", C3, first);
    CI["3"]:setPrecision(math.max(2, instance.source:getPrecision()));
		CI["4"] = instance:addStream("CI4", core.Line, name .. ".4", "4", C4, first);
    CI["4"]:setPrecision(math.max(2, instance.source:getPrecision()));
		else	
		CI["All"] = instance:addStream("CI", core.Line, name .. ".CI", "CI", C1, first);		
    CI["All"]:setPrecision(math.max(2, instance.source:getPrecision()));
		end
	
	end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values



function Update(period)
    if period < first   then
	return;
	end
	
	
	
	if period  < Period1 then
	return;
	end
	
	B[period] = Calculate(period, Period1, source); 
	
	if period  < Period2 then
	return;
	end
	C[period] = Calculate(period, Period2, source) ;
	D[period] = B[period]-C[period];
	
	if period  <  Period2 +Period3 then
	return;
	end
	E[period] = Calculate(period, Period3, D);
	F[period] = E[period]-E[period-1];
	
	
	if period  <  Period2 +Period3 + Period4 then
	return;
	end
	
	G[period] = Calculate(period, Period4, F);
	H[period] = (G[period]-G[period-1])*(-100);
	
	if period  <  Period2 +Period3 + Period4+ Period5 then
	return;
	end
	
	I[period] =  Calculate(period, Period5, H);
	J[period] =  (I[period]-I[period-1])*(10);
	
	
	if  Method == "1" then 
	CI["All"][period] = E[period];
	elseif Method == "2" then
	CI["All"][period] = H[period];
	elseif Method == "3" then
	CI["All"][period] = I[period];
	elseif Method == "4" then
	CI["All"][period] = J[period];
	elseif Method == "All" then
	CI["1"][period] = E[period];
	CI["2"][period] = H[period];
	CI["3"][period] = I[period];
	CI["4"][period] = J[period];
	else
	CI["All"][period] = ( E[period]+ H[period] + I[period]+  J[period]) /4 ;
	end
	
	

 end
 
 
function  Calculate(p, P, Source) 

   local Sum=0;
   local Count = 0
   
   local i;
   
   for i =  (p - P),  p+P-1 , 1 do
	   if  i <  (Source:size()-1 )  and i  >  (Source:first() ) then
	   Sum = Sum + Source[i];
	    Count=  Count+1;
	   end
	   
   end
     
   
   return    (Sum/Count) ;

end
