-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=14770
-- Id: 6049

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("T3 DPO");
    indicator:description("T3 DPO");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("T", "T3 Period", " ", 8);
    indicator.parameters:addDouble("B", "B", "", 0.7);
	
	indicator.parameters:addGroup("Style");    
	indicator.parameters:addInteger("width", " Grid Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", " Grid Style", " ", core.LINE_SOLID);
	 indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("T3_color", "Color of T3", "Color of T3", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local T;
local B;

local first;
local source = nil;
local MVA;
-- Streams block
local T3 = nil;
local b2, b3, c1,c2,c3,c4,n;
local w1=0;
local w2=0;
local e1;
local e2;
local e3;
local e4;
local e5;
local e6;
-- Routine
function Prepare(nameOnly)
    T = instance.parameters.T;
    B = instance.parameters.B;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(T) .. ", " .. tostring(B) .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	    b2=B*B;
		b3=b2*B;
		c1=-b3;
		c2=(3*(b2+b3));
		c3=-3*(2*b2+B+b3);
		c4=(1+3*B+b3+3*b2);
		n=T;
		
		n = 1 + 0.5*(n-1);
		w1 = 2 / (n + 1);
		w2 = 1 - w1;
		
		e1=instance:addInternalStream(0, 0);
		e2=instance:addInternalStream(0, 0);
		e3=instance:addInternalStream(0, 0);
		e4=instance:addInternalStream(0, 0);
		e5=instance:addInternalStream(0, 0);
		e6=instance:addInternalStream(0, 0);
		
		MVA = core.indicators:create("MVA", source, T);
		  
		      first = MVA.DATA:first()


    if (not (nameOnly)) then
        T3 = instance:addStream("T3", core.Line, name, "T3_DPO", instance.parameters.T3_color, first);
		T3:setWidth(instance.parameters.width);
	    T3:setStyle(instance.parameters.style);	
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period  <  first  then
	return;
	end
	
	MVA:update(mode);
	   
	 e1[period] = w1*MVA.DATA[period] + w2*e1[period-1];
	 e2[period] = w1*e1[period-1] + w2*e2[period-1];
	 e3[period] = w1*e2[period-1] + w2*e3[period-1];
	 e4[period] = w1*e3[period-1] + w2*e4[period-1];
	 e5[period] = w1*e4[period-1] + w2*e5[period-1];
	 e6[period] = w1*e5[period-1] + w2*e6[period-1];
	 
	 T3[period] = c1*e6[period] + c2*e5[period] + c3*e4[period] + c4*e3[period];
  
end

