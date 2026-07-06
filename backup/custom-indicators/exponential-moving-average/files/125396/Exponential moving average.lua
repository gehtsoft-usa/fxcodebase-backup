-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=28&t=61403

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("Exponential moving average");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 14, 2, 2000);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block


local  Period; 
local first;
local source = nil;
local k; 
local MA;

-- Routine
 function Prepare(nameOnly)    
 
    Period= instance.parameters.Period;
	
	local Parameters= Period;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    k = 2.0 / (Period + 1.0);
			
    source = instance.source; 
	first=source:first()+Period;
	 
   
 
	MA = instance:addStream("MA" , core.Line, " MA "," MA ",instance.parameters.color, first);
	MA:setWidth(instance.parameters.width);
    MA:setStyle(instance.parameters.style);
    MA:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)
 
	
    if period == first then
	MA[period]=mathex.avg(source,period-Period+1, period);
	return;
	end
	

	--https://stockcharts.com/school/doku.php?id=chart_school:technical_indicators:moving_averages
	--EMA: {Close - previous} x multiplier + previous.
	
    MA[period]=(source[period] - MA[period-1]) * k + MA[period-1];
	
	-- TS Version	
	--EMA: (1 - multiplier) * previous + multiplier * Close ;
	--EMA: previous - multiplier*previous + multiplier * Close ;
	--EMA: previous + multiplier*(Close-previous) 
	
	
				  
end

