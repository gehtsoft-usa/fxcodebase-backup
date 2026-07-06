-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68624

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
    indicator:name("MACD_Colored_Histogram");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "Fast Period", "", 12, 1, 2000);
    indicator.parameters:addInteger("Period2", "Slow Period", "", 26, 1, 2000);	
    indicator.parameters:addInteger("Period3", "Signal Period", "", 9, 1, 2000);
 
	
	indicator.parameters:addGroup("Line Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255,105,180));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("Histogram Style"); 	
    indicator.parameters:addColor("colorUP", "Up Bar Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("colorDN", "Down Bar Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("colorNE", "Neutral Bar Color", "", core.rgb(128, 128, 128));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period1,Period2,Period3; 
local first;
local source = nil;
 
local MACD, Line, Histogram;
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
   
	
	MACD= core.indicators:create("MACD", source, Period1, Period2, Period3);
	first=MACD.SIGNAL:first();
   
 
	Line = instance:addStream("Line" , core.Line, " Line"," Line",instance.parameters.color, first );
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:setPrecision(math.max(2, source:getPrecision()));
	
	
	Histogram = instance:addStream("Histogram" , core.Bar, " Histogram"," Histogram",instance.parameters.colorNE, first ); 
    Histogram:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)



    MACD:update(mode);

 
	if period < first
	then
	return;
	end
 
	
	
		
    Histogram[period]= MACD.MACD[period];
	Line[period]= MACD.SIGNAL[period];
	
	if Histogram[period]  >0 
	and Histogram[period] > Line[period]
	then	
	Histogram:setColor(period, instance.parameters.colorUP);
	elseif Histogram[period]  <0 
	and Histogram[period] < Line[period]
	then	
	Histogram:setColor(period, instance.parameters.colorDN);
	else
	Histogram:setColor(period, instance.parameters.colorNE);
	end
				  
end

 