-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70256

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
    indicator:name("Bollinger Bands Breakout");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "Length", "", 22, 1, 2000);
    indicator.parameters:addInteger("Period2", "Smoothing", "", 22, 1, 2000);
	
 
 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "ADX Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	 indicator.parameters:addColor("color2", "Plus Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	
	 indicator.parameters:addColor("color3", "Minus Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local close, volume;
local first;
local source = nil;
 
local ADX,PLUS,MINUS;  
local OBV,stdev;
local plusDM, minusDM;
local Period1, Period2;
local EMA_PLUS, EMA_MINUS;
local trur;
local Data;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period1= instance.parameters.Period1;
	Period2= instance.parameters.Period2;
    Deviation= instance.parameters.Deviation;
	Central= instance.parameters.Central;
	
	
	local Parameters= Period1..", "..Period2;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
	OBV = instance:addInternalStream(0, 0);
	stdev = instance:addInternalStream(0, 0);
	trur= instance:addInternalStream(0, 0);
	
	plusDM = instance:addInternalStream(0, 0);
	minusDM = instance:addInternalStream(0, 0);
	
	EMA_PLUS = core.indicators:create("EMA", plusDM, Period1);
	EMA_MINUS = core.indicators:create("EMA", minusDM, Period1);
	
	Data = instance:addInternalStream(0, 0);	
	EMA = core.indicators:create("EMA", Data, Period2);
	
	
    first=source:first()+1;
	
	
	close = instance.source.close;
    volume = instance.source.volume;
 
   
	PLUS = instance:addStream("PLUS" , core.Line, " PLUS"," PLUS",instance.parameters.color2, first+Period1);
	PLUS:setWidth(instance.parameters.width2);
    PLUS:setStyle(instance.parameters.style2);
    PLUS:setPrecision(math.max(2, source:getPrecision()));
	
	
	MINUS = instance:addStream("MINUS" , core.Line, " MINUS"," MINUS",instance.parameters.color3, first+Period1);
	MINUS:setWidth(instance.parameters.width3);
    MINUS:setStyle(instance.parameters.style3);
    MINUS:setPrecision(math.max(2, source:getPrecision()));
	
	
	ADX = instance:addStream("ADX" , core.Line, " ADX"," ADX",instance.parameters.color1, first+Period1+Period2);
	ADX:setWidth(instance.parameters.width1);
    ADX:setStyle(instance.parameters.style1);
    ADX:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

   if period < first
	then
	return;
	end
   
     if period == first then
        OBV[period] = volume[period];
    elseif period > first then
        if close[period] > close[period - 1] then
            OBV[period] = OBV[period - 1] + volume[period];
        elseif close[period] < close[period - 1] then
            OBV[period] = OBV[period - 1] - volume[period];
        else
            OBV[period] = OBV[period - 1];
        end
    end
	
	
	plusDM[period]=0;
	minusDM[period]=0;
 
 
    if close[period] > close[period - 1] then
	plusDM[period]=volume[period];
	else
	minusDM[period]=volume[period];
	end
	
	EMA_PLUS:update(mode);
	EMA_MINUS:update(mode);
	
	
	if period < first+Period1
	then
	return;
	end
	
	stdev[period]=mathex.stdev (OBV, period-Period1+1, period ); 
	
	trur[period] = ((trur[period-1] * (Period1-1)) + stdev[period]) /Period1;
		
	PLUS[period]=100 * EMA_PLUS.DATA[period] / trur[period]
	MINUS[period]=100 * EMA_MINUS.DATA[period] / trur[period]
	

	
	
    if (MINUS[period]+PLUS[period])==0 then
	Data[period]=math.abs(PLUS[period] - MINUS[period]);
	else
    Data[period]=math.abs(PLUS[period] - MINUS[period]) / (MINUS[period]+PLUS[period]);
	end
	
	EMA:update(mode);
	
	if period < first
	then
	return;
	end
	
	ADX[period]= 100*EMA.DATA[period];
				  
end 