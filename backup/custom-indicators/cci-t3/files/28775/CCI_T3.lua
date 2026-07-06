-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15227
-- Id: 6173

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
    indicator:name("CCI T3");
    indicator:description("No description");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("CP", "CCI Period", "CCI Period", 50, 1, 2000);
    indicator.parameters:addInteger("TP", "T3 Period", "T3 Period", 5,1, 2000);
    indicator.parameters:addDouble("B", "B", "B", 0.618);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Color of Up", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DN", "Color of Down", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local CP;
local TP;
local B;
local CCI
local first;
local source = nil;
local UP, DN;
-- Streams block
local CCIT3 = nil;
local w1, w2;
local c1, c2, c3, c4;
local e1, e2, e3, e4, e5, e6;
-- Routine
function Prepare(nameOnly)
    CP = instance.parameters.CP;
    TP = instance.parameters.TP;
    B = instance.parameters.B;
	UP = instance.parameters.UP;
	DN = instance.parameters.DN;
    source = instance.source;
   
	
	local n, b2, b3;
		
	b2=B*B;
    b3=b2*B;
    c1=-b3;
    c2=(3*(b2+b3));
    c3=-3*(2*b2+B+b3);
    c4=(1+3*B+b3+3*b2);
    local n=TP;

   
    n = 1 + 0.5*(n-1);
    w1 = 2 / (n + 1);
    w2 = 1 - w1;
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(CP) .. ", " .. tostring(TP) .. ", " .. tostring(B) .. ")";
    instance:name(name);
	
    if (not (nameOnly)) then
        e1= instance:addInternalStream(0, 0);
        e2= instance:addInternalStream(0, 0);
        e3= instance:addInternalStream(0, 0);
        e4= instance:addInternalStream(0, 0);
        e5= instance:addInternalStream(0, 0);
        e6= instance:addInternalStream(0, 0);
        CCI = core.indicators:create("CCI", source, CP);
         first = CCI.DATA:first();
        CCIT3 = instance:addStream("CCIT3", core.Bar, name, "CCIT3", UP, first);
		CCIT3:setPrecision(math.max(2, instance.source:getPrecision()));	
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not source:hasData(period) then
	return;
	end
	
	  CCI:update(mode);
   
        e1[period] = w1* CCI.DATA[period] + w2*e1[period-1];
        e2[period] = w1*e1[period] + w2*e2[period-1];
        e3[period] = w1*e2[period] + w2*e3[period-1];
        e4[period] = w1*e3[period] + w2*e4[period-1];
        e5[period] = w1*e4[period] + w2*e5[period-1];
        e6[period] = w1*e5[period] + w2*e6[period-1];
	
        CCIT3[period] = c1*e6[period] + c2*e5[period] + c3*e4[period] + c4*e3[period];
		
		if  CCIT3[period] >  CCIT3[period-1] then
		CCIT3:setColor(period,UP);
		else
		CCIT3:setColor(period,DN);
		end
    
end

