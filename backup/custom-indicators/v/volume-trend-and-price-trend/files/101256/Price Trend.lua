
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62389

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
    indicator:name("Price Trend");
    indicator:description("Price Trend");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 50);
	 indicator.parameters:addInteger("Offset", "Offset", "Offset", 100);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Line Color", "Color of Line", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "Price Trend Confirmed by Volume", "Color of Line", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color3", "Price Trend unconfirmed by Volume", "Color of Line", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Offset;
local first;
local source = nil;

-- Streams block 
local Regression=nil;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Offset= instance.parameters.Offset;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Regression = instance:addStream("Regression", core.Line, name, "Regression", instance.parameters.color1, first);
		Regression:setWidth(instance.parameters.width1);
        Regression:setStyle(instance.parameters.style1); 
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


   if period < Period then
	return;
	end
 
    local i;
	local a, b,x,Value,Slope1,Slope2;	
	       if period==source:size()-1 then
				a, b, dev, raff =mathex.regChannel  (source.close, period-Period+1, period);	 
				for i=source:size()-1-Period+1, period, 1 do	 
				x = (i - (source:size()-1-Period+1 ) + 1);
				Regression[i]= a * x + b;
				end
		 
			 
				Slope2 =mathex.lregSlope  (source.volume, period-Period+1, period);	 
				Slope1 =mathex.lregSlope  (source.close, period-Period+1, period);	 
				
				
				if Slope1 > 0  then
				Value=Regression[period]+source:pipSize()*Offset;
				elseif Slope1 < 0   then
				Value=Regression[period]-source:pipSize()*Offset;
				else
				Value=Regression[period];
				end
				
					if (Slope1> 0 and Slope2> 0 ) 
					or  (Slope1< 0 and Slope2> 0 ) 
					then
					core.host:execute ("drawLine", 1,  source:date(period-Period+1), Value, source:date(period), Value, instance.parameters.color2, instance.parameters.width2, instance.parameters.width2, win32.formatNumber(Value, false, source:getPrecision()));
					else
					core.host:execute ("drawLine", 1,  source:date(period-Period+1), Value, source:date(period), Value, instance.parameters.color3, instance.parameters.width2, instance.parameters.width2, win32.formatNumber(Value, false, source:getPrecision()));
					end
				 
	    end
 
	
	if period > Period then
	Regression[period-Period]=nil;
	end
end

