-- Id: 5486
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10878


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
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("True Strength Index");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 2);
	
	
	  indicator.parameters:addGroup("Smoothing");
   indicator.parameters:addInteger("A", "First Smoothing Period", "", 20);
   indicator.parameters:addInteger("B", "Second Smoothing Period", "", 5);
   indicator.parameters:addInteger("C", "Third  Smoothing Period", "", 3);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UDM_color", "Color of UDM", "", core.rgb(0, 0, 255));
	
	indicator.parameters:addGroup("Levels");
	indicator.parameters:addDouble("Up", "Up Level", "", 25);
	indicator.parameters:addDouble("Down", "Down Level", "", -25);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;

-- Streams block
local UDM, ADM, DMI;
local High, Low;

local EMA_C, EMA_B, EMA_A, EMA_3, EMA_2, EMA_1;
local A,B,C;
local Up, Down;


-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+Period;
	
		Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	
	A = instance.parameters.A;
	B = instance.parameters.B;
	C = instance.parameters.C;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(A).. ", " .. tostring(B).. ", " .. tostring(C) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	UDM = instance:addInternalStream(0, 0);
	ADM = instance:addInternalStream(0, 0);
	
	
	EMA_A = core.indicators:create("EMA", UDM, A);
	EMA_B = core.indicators:create("EMA", EMA_A.DATA, B);
	EMA_C = core.indicators:create("EMA", EMA_B.DATA, C);
	EMA_1 = core.indicators:create("EMA", ADM , A);
	EMA_2 = core.indicators:create("EMA", EMA_1.DATA, B);
	EMA_3 = core.indicators:create("EMA", EMA_2.DATA, C);
	
    
        DTI = instance:addStream("DTI", core.Line, name, "DTI", instance.parameters.UDM_color, EMA_3.DATA:first());
    DTI:setPrecision(math.max(2, instance.source:getPrecision()));
		DTI:addLevel(Up);
        DTI:addLevel(Down); 
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period >= first and source:hasData(period) then
       

	
	   
	    UDM[period] =  source[period] -  source[period-Period];
		ADM[period] =   math.abs(source[period] -  source[period-Period]);
		
		EMA_A:update(mode);
	     EMA_B:update(mode);
	     EMA_C:update(mode);
		 
		 EMA_1:update(mode);
	     EMA_2:update(mode);
	     EMA_3:update(mode);
		 
		 if period < EMA_3.DATA:first() then
		 return;
		 end
		
		DTI[period]= (100 * EMA_C.DATA[period]) / EMA_1.DATA[period];
    end
end

