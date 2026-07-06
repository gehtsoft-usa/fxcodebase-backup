-- Id: 21727
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66296


--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Yang-Zhang volatility estimator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Calculation");
	 indicator.parameters:addInteger("N", "N", "", 20);
    indicator.parameters:addInteger("Period", "Period", "",200);

	

	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", " Signal Line Color", "", core.rgb(255, 0, 0));

	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local N,Period,n;
local first;
local source = nil;

local Data1, Data2,Data3;
local Vyangzhang,Signal;
local No,Nc;

 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end


    N= instance.parameters.N;
	n=N;
   
    Period= instance.parameters.Period;

	
	Data1 = instance:addInternalStream(0, 0);
	Data2 = instance:addInternalStream(0, 0);
	Data3 = instance:addInternalStream(0, 0);
	No = instance:addInternalStream(0, 0);
	Nc = instance:addInternalStream(0, 0);

	source = instance.source;
	
	first= source:first()+1;

    	
	Vyangzhang = instance:addStream("Vyangzhang", core.Line, "Vyangzhang", "Vyangzhang", instance.parameters.color1, first+N*4 );
    Vyangzhang:setPrecision(math.max(10, instance.source:getPrecision()));
    Signal = instance:addStream("Signal", core.Line, "Signal", "Signal", instance.parameters.color2, first+N*4 +Period);
    Signal:setPrecision(math.max(10, instance.source:getPrecision()));
		
end

-- Indicator calculation routine
function Update(period, mode)



    if period < first then
	return;
	end

    No[period] = math.log( source.open[period]) - math.log( source.close[period-1] ); 
	local Nu = math.log( source.high[period] ) - math.log( source.open[period] );
	local Nd = math.log( source.low[period] ) - math.log( source.open[period] );
	Nc[period] = math.log( source.close[period] ) - math.log( source.open[period] );

	
	
	Data1[period]=Nu * ( Nu - Nc[period] ) + Nd * ( Nd - Nc[period] );
	
	if period < first+N then
	return;
	end
	
    Vrs = 1 / n * mathex.sum(Data1, period-N+1,period);

    Noavg = 1 / n *  mathex.sum(No, period-N+1,period);
	
	
	if period < first+N*2 then
	return;
	end
	
	Data2[period]=( No[period] - Noavg )^2;
    Vo = 1 / ( n - 1 ) *  mathex.sum(Data2, period-N+1,period);

     Ncavg = 1 / n * mathex.sum(Nc, period-N+1,period);
	 
	 
	 if period < first+N*3 then
	return;
	end
	
	Data3[period]=(Nc[period] - Ncavg)^2;
     Vc = 1 / ( n - 1 ) *  mathex.sum(Data3, period-N+1,period);
	 
	 if period < first+N*4 then
	return;
	end

   local k = 0.34 / ( 1.34 + ( n + 1 ) / ( n - 1 ) )

   Vyangzhang[period] = Vo + k * Vc + ( 1 - k ) * Vrs;

				
    if period < first+N*4 +Period then
	return;
	end
		
    Signal[period]=mathex.avg(Vyangzhang, period-Period+1,period);		
				
		
 end


