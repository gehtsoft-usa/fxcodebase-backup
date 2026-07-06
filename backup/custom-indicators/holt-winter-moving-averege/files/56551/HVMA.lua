-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=33313
-- Id: 8725

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
function Init()
    indicator:name("Holt-Winter Moving Averege");
    indicator:description("Holt-Winter Moving Averege");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("a", "a", "a", 0.2);
    indicator.parameters:addDouble("b", "b", "b", 0.1);
    indicator.parameters:addDouble("c", "c", "c", 0.1);
 
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Top_color", "Line Color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local a;
local b;
local c;

local first;
local C = nil;
local  HVMA;
local F,V,A ,Var,T;
-- Routine
function Prepare(nameOnly)
    a = instance.parameters.a;
    b = instance.parameters.b;
    c = instance.parameters.c;    
    C = instance.source;
    first = C:first();	

    local name = profile:id() .. "(" .. C:name() .. ", " .. tostring(a) .. ", " .. tostring(b) .. ", " .. tostring(c)  .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        F = instance:addInternalStream(0, 0);
        V = instance:addInternalStream(0, 0);
        A = instance:addInternalStream(0, 0);
        HVMA = instance:addStream("HVMA", core.Line, name .. ".HVMA", "HVMA", instance.parameters.Top_color, first);
		HVMA:setWidth(instance.parameters.width1);
        HVMA:setStyle(instance.parameters.style1);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first  then
	return;
	end    
   
	F[period] = (1-a)* (F[period-1] + V[period-1] +0.5*A[period-1]) +a*C[period];	
	V[period] = (1-b)* (V[period-1] +A[period-1]) +b*(F[period]-F[period-1]);
	A[period] = (1-c)* A[period-1] +c *(V[period]-V[period-1]); 

        HVMA[period] =  F[period]+V[period]+0.5*A[period];		
		
	 
end

