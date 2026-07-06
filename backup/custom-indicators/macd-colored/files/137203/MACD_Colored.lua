-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70356

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

function Init()
    indicator:name("MACD_Colored_Histogram");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "Fast Period", "", 12, 1, 2000);
    indicator.parameters:addInteger("Period2", "Slow Period", "", 26, 1, 2000);	
    indicator.parameters:addInteger("Period3", "Signal Period", "", 9, 1, 2000);
 
	
	indicator.parameters:addGroup("MACD Line Style"); 	
    indicator.parameters:addColor("MACD_Up", "MACD Line Up Color", "", core.rgb(255,100,50));
	indicator.parameters:addColor("MACD_Down", "MACD Line Down Color", "", core.rgb(255,100,50));
	
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	
		indicator.parameters:addGroup("Signal Line Style"); 	
    indicator.parameters:addColor("Signal_Up", "Signal Line Up Color", "", core.rgb(50,100,255));
	indicator.parameters:addColor("Signal_Down", "Signal Line Down Color", "", core.rgb(50,100,255));
	
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("Histogram Style"); 	
    indicator.parameters:addColor("Histogram_Up_Up", "Up Trend Up Bar Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Histogram_Up_Down", "Up Trend Down Bar Color", "", core.rgb(0, 200, 0));
    
	indicator.parameters:addColor("Histogram_Down_Up", "Down Trend Up Bar Color", "", core.rgb( 255, 0, 0));
	indicator.parameters:addColor("Histogram_Down_Down", "Down Trend Down Bar Color", "", core.rgb(200, 0, 0));
	
	indicator.parameters:addColor("Histogram_Neutral_Up", "Neutral Trend Up Bar Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Histogram_Neutral_Down", "Neutral Trend Down Bar Color", "", core.rgb(0, 0, 200));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period1,Period2,Period3; 
local first;
local source = nil;
 
local MACD,macd, Line, Histogram;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
	Period3= instance.parameters.Period3;
	
	
	local Parameters= Period1..", "..Period2..", "..Period3;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
   
	
	macd= core.indicators:create("MACD", source, Period1, Period2, Period3);
	first=macd.SIGNAL:first();
   
 
	MACD = instance:addStream("MACD" , core.Line, " MACD"," MACD",instance.parameters.MACD_Up, first );
	MACD:setWidth(instance.parameters.width1);
    MACD:setStyle(instance.parameters.style1);
    MACD:setPrecision(math.max(2, source:getPrecision()));
	
	Signal = instance:addStream("Signal" , core.Line, " Signal"," Signal",instance.parameters.Signal_Up, first );
	Signal:setWidth(instance.parameters.width2);
    Signal:setStyle(instance.parameters.style2);
    Signal:setPrecision(math.max(2, source:getPrecision()));
	
	
	Histogram = instance:addStream("Histogram" , core.Bar, " Histogram"," Histogram",instance.parameters.Histogram_Up_Up, first ); 
    Histogram:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)



    macd:update(mode);

 
	if period < first
	then
	return;
	end
 
	
	
		
    MACD[period]= macd.MACD[period];
	
	    if MACD[period]> MACD[period-1] then
		MACD:setColor(period, instance.parameters.MACD_Up);
		else
		MACD:setColor(period, instance.parameters.MACD_Down);
		end
		
		
	
	Signal[period]= macd.SIGNAL[period];
	
	   if Signal[period]> Signal[period-1] then
		Signal:setColor(period, instance.parameters.Signal_Up);
		else
		Signal:setColor(period, instance.parameters.Signal_Down);
		end
		
		
		Histogram[period]= MACD[period]-Signal[period];
	
	if Histogram[period]  >0 
	and Histogram[period] > Signal[period]
	then	
		if Histogram[period]> Histogram[period-1] then
		Histogram:setColor(period, instance.parameters.Histogram_Up_Up);
		else
		Histogram:setColor(period, instance.parameters.Histogram_Up_Down);
		end
	
	elseif Histogram[period]  <0 
	and Histogram[period] < Signal[period]
	then	
		if Histogram[period]> Histogram[period-1] then
		Histogram:setColor(period, instance.parameters.Histogram_Down_Up);
		else
		Histogram:setColor(period, instance.parameters.Histogram_Down_Down);
		end
	else
		if Histogram[period]> Histogram[period-1] then
		Histogram:setColor(period, instance.parameters.Histogram_Neutral_Up);
		else
		Histogram:setColor(period, instance.parameters.Histogram_Neutral_Down);
		end
	end
				  
end

 