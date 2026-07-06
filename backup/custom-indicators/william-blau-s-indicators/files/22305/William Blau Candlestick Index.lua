-- Id: 5484
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
    indicator:name("Candlestick Index");
    indicator:description("Candlestick Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
     indicator.parameters:addGroup("Momentum");
   indicator.parameters:addInteger("Period", "Period", "Period", 1);
   
   indicator.parameters:addString("Price", "CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");
   
     indicator.parameters:addGroup("Smoothing");
   indicator.parameters:addInteger("A", "First Smoothing Period", "", 20);
   indicator.parameters:addInteger("B", "Second Smoothing Period", "", 5);
   indicator.parameters:addInteger("C", "Third  Smoothing Period", "", 3);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("S1_color", "Color of CI Line", "", core.rgb(255, 0, 0));
	
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
local Price;
local first;
local source = nil;

-- Streams block
local CI = nil;
local Up, Down;
	
local CM;
local MinMax;
local EMA_C, EMA_B, EMA_A, EMA_3, EMA_2, EMA_1;
local A,B,C;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+Period;	
	
		Up = instance.parameters.Up;
	Down = instance.parameters.Down;

	Price = instance.parameters.Price;
	
	A = instance.parameters.A;
	B = instance.parameters.B;
	C = instance.parameters.C;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(A).. ", " .. tostring(B).. ", " .. tostring(C) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	MinMax = instance:addInternalStream(0, 0);
	CM = instance:addInternalStream(0, 0);
	
	EMA_A = core.indicators:create("EMA", CM, A);
	EMA_B = core.indicators:create("EMA", EMA_A.DATA, B);
	EMA_C = core.indicators:create("EMA", EMA_B.DATA, C);
	EMA_1 = core.indicators:create("EMA", MinMax , A);
	EMA_2 = core.indicators:create("EMA", EMA_1.DATA, B);
	EMA_3 = core.indicators:create("EMA", EMA_2.DATA, C);

   
        CI = instance:addStream("CI", core.Line, name, "CI", instance.parameters.S1_color, EMA_3.DATA:first() );
    CI:setPrecision(math.max(2, instance.source:getPrecision()));
		CI:addLevel(Up);
        CI:addLevel(Down); 
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not source:hasData(period) then
	return;
	end
	
	local min, max;	
	min,max = mathex.minmax(source, period - Period + 1, period);
	
	CM[period] =  source[Price][period] -  source[Price][period-Period];
	MinMax[period] = max-min;
	
	     EMA_A:update(mode);
	     EMA_B:update(mode);
	     EMA_C:update(mode);
		 
		 EMA_1:update(mode);
	     EMA_2:update(mode);
	     EMA_3:update(mode);
		 
		 if period < EMA_3.DATA:first() then
		 return;
		 end
	
        CI[period] = (100 * EMA_C.DATA[period]) / EMA_3.DATA[period];
		
    end

