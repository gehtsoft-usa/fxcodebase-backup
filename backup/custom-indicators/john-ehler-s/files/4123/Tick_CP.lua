-- Id: 17493
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Tick Cycle Period");
    indicator:description("Tick Cycle Period");
    indicator:requiredSource(core.Tick	);
    indicator:type(core.Oscillator);

    indicator.parameters:addDouble("Imult", "Imult", "Imult", 0.635);
    indicator.parameters:addDouble("Qmult", "Qmult", "Qmult", 0.338);
    indicator.parameters:addColor("Frame_color", "Color of Frame", "Color of Frame", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Imult;
local Qmult;

local first;
local source = nil;

local Value3=nil;
local InPhase=nil;
local Quadrature=nil;
local Phase=nil;
local DeltaPhase=nil;
local InstPeriod=nil;

-- Streams block
local Frame = nil;

-- Routine
function Prepare()
    Imult = instance.parameters.Imult;
    Qmult = instance.parameters.Qmult;
    source = instance.source;
    first = source:first();
	
	InPhase = instance:addInternalStream(first, 0);
    Value3= instance:addInternalStream(first, 0);
	Value4= instance:addInternalStream(first, 0);
	Quadrature= instance:addInternalStream(first, 0);
	Phase = instance:addInternalStream(first, 0);
	DeltaPhase = instance:addInternalStream(first, 0);
	InstPeriod = instance:addInternalStream(first, 0);
	
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. Imult .. ", " .. Qmult .. ")";
    instance:name(name);
    Frame = instance:addStream("Frame", core.Line, name, "Frame", instance.parameters.Frame_color, first+61);
    Frame:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < 7 or not source:hasData(period) then
	return;
	end
	
 
	Value3[period] = source[period] - source[period-7];
 
	
				if period >= 61  then

						--Compute InPhase and Quadrature components
						InPhase[period] = 1.25*(Value3[period-4]  - Imult*Value3[period-2]) + Imult*InPhase[period-3];
						Quadrature[period] = Value3[period-2] - Qmult*Value3[period] + Qmult*Quadrature[period-2];

						--Use ArcTangent to compute the current phase
						if math.abs(InPhase[period] +InPhase[period-1]) > 0 then
						Phase[period] = (180/3.1415)*math.atan(math.abs((Quadrature[period]+Quadrature[period-1]) / (InPhase[period]+InPhase[period-1])));
						end 
						
						--Resolve the ArcTangent ambiguity
						if InPhase[period] < 0 and Quadrature[period] > 0 then 
						Phase[period] = 180 - Phase[period];
						end
						if InPhase[period] < 0 and Quadrature[period] < 0 then
						Phase[period] = 180 + Phase[period];
						end
						if InPhase[period] > 0 and Quadrature[period] < 0 then
						Phase[period] = 360 - Phase[period];
						end

						--Compute a differential phase, resolve phase wraparound, and limit delta phase errors
						DeltaPhase[period] = Phase[period-1] - Phase[period];
						if Phase[period-1] < 90 and Phase[period] > 270 then
						DeltaPhase[period] = 360 + Phase[period-1] - Phase[period];
						end
						if DeltaPhase[period] < 1 then 
						DeltaPhase[period] = 1;
						end
						if DeltaPhase[period] > 60  then 
						DeltaPhase[period] = 60;
						end

						--Sum DeltaPhases to reach 360 degrees.  The sum is the instantaneous period
						InstPeriod[period] = 0;
						 Value4[period] = 0;
						local count;
						for count =  0, 50, 1 do
							Value4[period] = Value4[period] + DeltaPhase[period-count];
							if Value4[period] > 360 and InstPeriod[period] == 0 then
							InstPeriod[period] = count;
							break;
							end
						end

						--Resolve Instantaneous Period errors and smooth
						 if InstPeriod[period] == 0 then 
						 InstPeriod[period] = InstPeriod[period-1];
						 end
						 
						 Frame[period] = 0.25*(InstPeriod[period]) + 0.75* Frame[period-1];
					end	 
	 
   
end

