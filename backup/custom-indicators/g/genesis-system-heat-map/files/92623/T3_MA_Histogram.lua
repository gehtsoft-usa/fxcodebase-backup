-- Id: 11120

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60294

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
    indicator:name("T3 moving average Histogram ");
    indicator:description("T3 moving average Histogram");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 8, 1 , 2000);
    indicator.parameters:addDouble("b", "b", "", 0.618);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Color", "Up Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Color", "Down Color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Period;
local b;
local e1, e2, e3, e4, e5, e6;
local T3_MA=nil;
local c1, c2, c3, c4, w1, w2;
local Histogram;
local Trend;
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    source = instance.source;
    Period=instance.parameters.Period;
    b=instance.parameters.b;
    first = source:first()+2;
    e1 = instance:addInternalStream(first, 0);
    e2 = instance:addInternalStream(first, 0);
    e3 = instance:addInternalStream(first, 0);
    e4 = instance:addInternalStream(first, 0);
    e5 = instance:addInternalStream(first, 0);
    e6 = instance:addInternalStream(first, 0);
	Trend= instance:addInternalStream(first, 0);
   
   
   
    Histogram = instance:addStream("Histogram", core.Bar, name .. "Histogram", "Histogram", instance.parameters.Up, first);
    Histogram:setPrecision(math.max(2, instance.source:getPrecision()));
	 Histogram:addLevel(0, core.LINE_NONE , 1, core.rgb(128, 128, 128));    
	 Histogram:addLevel(1, core.LINE_NONE , 1, core.rgb(128, 128, 128));  	
 
	w1 = 2 / (2 + 0.5*(Period-1));
    w2 = 1 - w1;
    local b2=b*b;
    local b3=b2*b;
    c1=-b3;
    c2=3*(b2+b3);
    c3=-3*(2*b2+b+b3);
    c4=1+3*b+b3+3*b2;
	
	T3_MA = instance:addInternalStream(first, 0);
end

function Update(period, mode)

Histogram[period]=1;

if period<first then
return;
end

 
Calculate(period, mode);

	if T3_MA[period]> T3_MA[period-1] then
	Trend[period]=1;
	elseif T3_MA[period] < T3_MA[period-1] then
	Trend[period]=-1;
	else
	Trend[period]=Trend[period-1];
	end
	
	if( Trend[period]== 1  ) then
		Histogram:setColor(period, instance.parameters.Up);
	else  
			Histogram:setColor(period, instance.parameters.Down);
	end
end


function Calculate(period, mode)
  
    e1[period]=w1*source[period]+w2*e1[period-1];
    e2[period]=w1*e1[period]+w2*e2[period-1];
    e3[period]=w1*e2[period]+w2*e3[period-1];
    e4[period]=w1*e3[period]+w2*e4[period-1];
    e5[period]=w1*e4[period]+w2*e5[period-1];
    e6[period]=w1*e5[period]+w2*e6[period-1];
    T3_MA[period]=c1*e6[period]+c2*e5[period]+c3*e4[period]+c4*e3[period];
    
end

