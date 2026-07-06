-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27946
-- Id: 8224

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
    indicator:name("Bandpass Filter");
    indicator:description("Bandpass Filter");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N1", "Cutoff period of the  1. filter", "", 10);
    indicator.parameters:addInteger("N2", "Cutoff period of the 2. filter", "", 35);
	
	indicator.parameters:addString("Type", "Price Type", "", "Leading");
    indicator.parameters:addStringAlternative("Type", "Leading", "", "Leading");
    indicator.parameters:addStringAlternative("Type", "Lagging", "", "Lagging");
	
	 indicator.parameters:addInteger("Period", "Lagging Signal Period", "", 10);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("BF_color", "Color of Bandpass Filter", "Color of Bandpass Filter", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("Signal_color", "Color of Signal", "Color of Signal", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local N1, N2,N3;
local p;

local first;
local source = nil;
local Type;
-- Streams block
local f1, f2;
local a, b, c;
local A, B, C;
local gz, signal;
local FIRSTPeriod;
-- Routine
function Prepare(nameOnly)
    N1 = instance.parameters.N1;
	N2 = instance.parameters.N2;
    Period = instance.parameters.Period;	
	N3= math.sqrt(N1*N2);
	Type = instance.parameters.Type;
  
    source = instance.source;
    first = source:first()+3;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(N1) .. ", " .. tostring(N2) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
	
		f1 = instance:addInternalStream(0, 0);
		f2 = instance:addInternalStream(0, 0);
		
		a=math.exp((-math.pi/N1));
		b=2* a *math.cos(math.rad(1.732*math.pi/N1));
		c=math.exp((-2*math.pi/N1));
		
		A=math.exp((-math.pi/N2));
		B=2* A *math.cos(math.rad(1.732*math.pi/N2));
		C=math.exp((-2*math.pi/N2));
        gz = instance:addStream("BF", core.Line, name, "Bandpass Filter", instance.parameters.BF_color, first);
    gz:setPrecision(math.max(2, instance.source:getPrecision()));
		gz:setWidth(instance.parameters.width1);
        gz:setStyle(instance.parameters.style1);		
		
		if Type ==  "Lagging" then
		FIRST= first+Period;
		else
		FIRST=first+1;
		end
		
		signal = instance:addStream("SIGNAL", core.Line, name, Type .." Signal", instance.parameters.Signal_color, FIRST);
    signal:setPrecision(math.max(2, instance.source:getPrecision()));
		signal:setWidth(instance.parameters.width2);
        signal:setStyle(instance.parameters.style2);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first   then
	return;
	end
	
	 
	  f1[period]=(b+c)*f1[period-1]-(c+b*c)*f1[period-2]+c*c*f1[period-3]+((1-b+c)*(1-c)/8)*(source[period]+3*source[period-1]+3*source[period-2]+source[period-3]);
      f2[period]=(B+C)*f2[period-1]-(C+B*C)*f2[period-2]+C*C*f2[period-3]+((1-B+C)*(1-C)/8)*(source[period]+3*source[period-1]+3*source[period-2]+source[period-3]);  
	  
	  gz[period]= f1[period]-f2[period];
	  
	  
	    if period < FIRST then 
		  return;
		  end
	  
	  if Type == "Lagging" then		  
	  signal[period] = mathex.avg (gz, period-Period+1, period);
	  else
	  signal[period]=(((gz[period]-gz[period-1])*N3/(2*math.pi))+gz[period])/1.414;
	  end
    
end

