-- Id: 1443
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
    indicator:name("John Ehler's HilbertPeriod");
    indicator:description("John Ehler's HilbertPeriod");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Hilbert_color", "Color of Hilbert Line", "Color of Hilbert Line", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local OUT=nil;

local Smoother=nil;
local Detrender=nil;
local Q1=nil;
local Q2=nil;
local I1=nil;
local I2=nil;
local Re=nil;
local Im=nil;

local first;
local source = nil;

-- Streams block

-- Routine
function Prepare()
    source = instance.source;
    first = source:first();
	
	Smoother= instance:addInternalStream(5, 0);
	Detrender= instance:addInternalStream(5, 0);
	Q1 = instance:addInternalStream(5, 0);
	Q2 = instance:addInternalStream(5, 0);
	I1 = instance:addInternalStream(5, 0);
	I2 = instance:addInternalStream(5, 0);
	Re = instance:addInternalStream(5, 0);
	Im = instance:addInternalStream(5, 0);
	

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    OUT = instance:addStream("OUT", core.Line, name, "Hilbert", instance.parameters.Hilbert_color, 5);
    OUT:setPrecision(math.max(2, instance.source:getPrecision()));
	OUT:setWidth(instance.parameters.width);
    OUT:setStyle(instance.parameters.style);
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


		if period >5 then 
		Smoother[period] = (4*source.close[period] + 3*source.close[period-1] + 2*source.close[period-2] + source.close[period-3])/10;
		Detrender[period] = (0.25*Smoother[period] + 0.75*Smoother[period-2] - 0.75*Smoother[period-4] - 0.25*Smoother[period- 6])*(0.046*OUT[period-1] + 0.332);

		--Compute InPhase and Quadrature components
		Q1[period] = (0.25*Detrender[period] + 0.75*Detrender[period- 2] - 0.75*Detrender[period-4] - 0.25*Detrender[period-6])*(0.046*OUT[period-1] + 0.332);
		I1[period] = Detrender[period-3];

		--Advance the phase of I1 and Q1 by 90 degrees
		local jI = 0.25*I1[period] + 0.75*I1[period-2] - 0.75*I1[period-4] - 0.25*I1[period-6];
		local jQ = 0.25*Q1[period] + 0.75*Q1[period-2] - 0.75*Q1[period-4] - 0.25*Q1[period-6];
		
		--Phasor addition to equalize amplitude due to quadrature calculations (and 3 bar averaging)
		I2[period] = I1[period] - jQ;
		Q2[period] = Q1[period] + jI;

		--Smooth the I and Q components before applying the discriminator
		I2[period] = 0.15*I2[period] + 0.85*I2[period-1];
		Q2[period] = 0.15*Q2[period] + 0.85*Q2[period-1];

		--Homodyne Discriminator
		--Complex Conjugate Multiply
		local X1 = I2[period]*I2[period-1];
		local X2 = I2[period]*Q2[period-1];
		local Y1 = Q2[period]*Q2[period-1];
		local Y2 = Q2[period]*I2[period-1];
		Re[period] = X1 + Y1;
		Im[period] = X2 - Y2;

		--Smooth to remove undesired cross products
		Re[period] = 0.2*Re[period] + 0.8*Re[period-1];
		Im[period] = 0.2*Im[period] + 0.8*Im[period-1];

		--Compute Cycle Period
		if Im[period] ~= 0 and Re[period] ~= 0 then 
		OUT[period] = 360/((180/3.1415)*math.atan(Im[period]/Re[period]));
		end
		
		if OUT[period] > 1.5*OUT[period-1] then
		OUT[period] = 1.5*OUT[period-1];
		end
		
		if OUT[period] < 0.67*OUT[period-1] then 
		OUT[period] = 0.67*OUT[period-1];
		end
		
		if OUT[period] < 6 then
		OUT[period] = 6;
		end
		
		if OUT[period] > 50 then
		OUT[period] = 50;
		end
		
		OUT[period] = 0.2*OUT[period] + 0.8*OUT[period-1];

    end



end


