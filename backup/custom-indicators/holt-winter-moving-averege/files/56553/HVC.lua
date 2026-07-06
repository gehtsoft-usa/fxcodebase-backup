-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=33313
-- Id: 8727

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
    indicator:name("Holt-Winter Channel");
    indicator:description("Holt-Winter Channel");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("a", "a", "a", 0.2);
    indicator.parameters:addDouble("b", "b", "b", 0.1);
    indicator.parameters:addDouble("c", "c", "c", 0.1);
    indicator.parameters:addDouble("d", "d", "d", 0.1);
	indicator.parameters:addDouble("T", "Multiplier", "Multiplier", 1);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Top_color", "Color of Top", "Color of Top", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Central_color", "Color of Central", "Color of Central", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Bottom_color", "Color of Bottom", "Color of Bottom", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local a;
local b;
local c;
local d;

local first;
local C = nil;

-- Streams block
local Top = nil;
local Central = nil;
local Bottom = nil;
local F,V,A ,Var,T;
-- Routine
function Prepare(nameOnly)
    a = instance.parameters.a;
    b = instance.parameters.b;
    c = instance.parameters.c;
    d = instance.parameters.d;
	T = instance.parameters.T;
    C = instance.source;
    first = C:first();	
	

    local name = profile:id() .. "(" .. C:name() .. ", " .. tostring(a) .. ", " .. tostring(b) .. ", " .. tostring(c) .. ", " .. tostring(d).. ", " .. tostring(T)  .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        F = instance:addInternalStream(0, 0);
        V = instance:addInternalStream(0, 0);
        A = instance:addInternalStream(0, 0);
        Var= instance:addInternalStream(0, 0);  
        Top = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.Top_color, first);
		Top:setWidth(instance.parameters.width1);
        Top:setStyle(instance.parameters.style1);
        Central = instance:addStream("Central", core.Line, name .. ".Central", "Central", instance.parameters.Central_color, first);
		Central:setWidth(instance.parameters.width2);
        Central:setStyle(instance.parameters.style2);
        Bottom = instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.Bottom_color, first);
		Bottom:setWidth(instance.parameters.width3);
        Bottom:setStyle(instance.parameters.style3);
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

        Central[period] =  F[period]+V[period]+0.5*A[period];		

		Var[period]= (1-d) * Var[period-1] + d* (C[period-1]-Central[period-1])^2;		
         local Stdt= math.sqrt(Var[period-1]); 
		
		Top[period] = Central[period] + T*Stdt;
        Bottom[period] =Central[period] - T *Stdt
    
end

