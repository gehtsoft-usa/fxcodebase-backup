-- Id: 10448
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
    indicator:name("Ehlers CyberCycle");
    indicator:description("Ehlers CyberCycle");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
     indicator.parameters:addGroup("Calculation");  
    indicator.parameters:addDouble("Alpha", "Alpha", "Alpha", 0.07);
	 indicator.parameters:addGroup("Style");  
    indicator.parameters:addColor("CPeriodBuffer_color", "Color of CPeriodBuffer", "Color of CPeriodBuffer", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Alpha;
local DeltaPhase;
local first;
local source = nil;

-- Streams block
local Period = nil;
local Smooth,Cycle;
local Q1, I1, InstPeriod;
-- Routine
function Prepare(nameOnly)
    Alpha = instance.parameters.Alpha;
    source = instance.source;
    first = source:first()+3;
	
	Smooth = instance:addInternalStream(0, 0);
	Cycle = instance:addInternalStream(0, 0);
	DeltaPhase = instance:addInternalStream(0, 0);
	
	Q1 = instance:addInternalStream(0, 0);
	I1 = instance:addInternalStream(0, 0);
	InstPeriod = instance:addInternalStream(0, 0);

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Alpha) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Period = instance:addStream("Period", core.Line, name, "Period", instance.parameters.CPeriodBuffer_color, DeltaPhase:first());
    Period:setPrecision(math.max(2, instance.source:getPrecision()));
		Period:setWidth(instance.parameters.width);
        Period:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first   then
	return;
	end
	
	
	
	 Smooth[period] = ( source[period] + 2 * source[period-1] +   2 * source[period-2] + source[period-3] ) / 6;
     Cycle[period] =   ( 1 - 0.5 * Alpha ) * ( 1 - 0.5 * Alpha ) * ( Smooth[period] - 2 * Smooth[period-1] + Smooth[period-2] ) + 2 * ( 1 - Alpha ) * Cycle[period-1] - ( 1 - Alpha ) * ( 1 - Alpha ) * Cycle[period-2] ;
     
	 Q1[period]=(.0962*Cycle[period]+.5769*Cycle[period-2]-.5769*Cycle[period-4]-.0962*Cycle[period-6])*(.5+.08*InstPeriod[period-1]);
	 I1[period] = Cycle[period-3];
	 
 
	 if Q1[period]~=0 and Q1[period-1]~=0 then DeltaPhase[period]=(I1[period]/Q1[period]-I1[period-1]/Q1[period-1])/(1+I1[period]*I1[period-1]/(Q1[period]*Q1[period-1])); end
	 
	 if DeltaPhase[period] <0.1 then DeltaPhase[period] = 0.1; end
     if DeltaPhase[period] >1.1 then DeltaPhase[period] = 1.1; end
	 
	 local MedianDelta;
	 
	 
	 MedianDelta = Median(period);
	 if MedianDelta==0 then
	 return;
	 end
	
	local DC;
     if  MedianDelta == 0 then 
	 DC = 15;
	 else DC = 6.28318/MedianDelta + .5;
	 end
     InstPeriod[period] = .33*DC + .67*InstPeriod[period-1];   
	 Period[period]= .15*InstPeriod[period]+.85*Period[period-1];
	 
	 
    
end

function Median(period) 

local Temp={};
local i;
local j=1;

if not DeltaPhase:hasData(period-6+1) then
return 0;
end

for i=period, period-6+1, -1 do
Temp[j]=DeltaPhase[i];
j=j+1;
end

table.sort (Temp)


return Temp[3];


end

   