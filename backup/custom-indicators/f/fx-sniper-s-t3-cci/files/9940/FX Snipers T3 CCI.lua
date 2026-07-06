-- Id: 3711
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3996

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

function Init()
    indicator:name("FX Sniper's T3 CCI");
    indicator:description("FX Sniper's T3 CCI");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addInteger("CCI_Period", "CCI Period", "", 14);
	indicator.parameters:addInteger("T3_Period", "T3 Period", "", 5);
    indicator.parameters:addDouble("Base", "Base", "", 0.618);
	
    indicator.parameters:addColor("T3_CCI_Up", "Color of Up T3_CCI", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("T3_CCI_Down", "Color of Down T3_CCI", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local b, CCI_Period,T3_Period;

local first;
local source = nil;

local b1, b2, b3, c1, c2, c3, c4, n, w1, w2;

	local  e1=0;
	local  e2=0;
	local  e3=0;
    local  e4=0;
	local  e5=0;
	local  e6=0;
	

local T3_CCI;

-- Streams block
local CCI;

-- Routine
function Prepare(nameOnly)
    T3_Period = instance.parameters.T3_Period;
    CCI_Period = instance.parameters.CCI_Period;  
    b1 = instance.parameters.Base;
    source = instance.source;
    	
	b2 = b1*b1;
    b3 = b2*b1;
    c1 = -b3;
    c2 = (3*(b2 + b3));
    c3 = -3*(2*b2 + b1 + b3);
    c4 = (1 + 3*b1 + b3 + 3*b2);
    n = T3_Period;

    if n < 1 then 
       n = 1;
	end	
	
    n = 1 + 0.5*(n - 1);
    w1 = 2 / (n + 1);
    w2 = 1 - w1;   	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(CCI_Period).. ", " .. tostring(T3_Period).. ", " .. tostring(b1) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        CCI= core.indicators:create("CCI", source,CCI_Period );	 
         
        first = CCI.DATA:first(); 
        T3_CCI = instance:addStream("T3_CCI", core.Bar, name, "T3_CCI", instance.parameters.T3_CCI_Up, first);
    T3_CCI:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not  source:hasData(period) then
	return;
	end
	
        
	CCI:update(mode);	
		  
       e1 = w1*CCI.DATA[period] + w2*e1;
       e2 = w1*e1 + w2*e2;
       e3 = w1*e2 + w2*e3;
       e4 = w1*e3 + w2*e4;
       e5 = w1*e4 + w2*e5;
       e6 = w1*e5 + w2*e6;    
       T3_CCI[period] = c1*e6 + c2*e5 + c3*e4 + c4*e3; 
		
			if  T3_CCI[period] >  T3_CCI[period-1] then	
			T3_CCI:setColor(period, instance.parameters.T3_CCI_Up);
			else	
			T3_CCI:setColor(period, instance.parameters.T3_CCI_Down);
			end 
    
end

