-- More information about this indicator can be found at:
-- http://www.fxcodebase.com/code/viewtopic.php?f=17&t=70057

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
    indicator:name("Transactions MACD");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "Short Period", "", 12, 1, 2000);
	indicator.parameters:addInteger("Period2", "Long Period", "", 26, 1, 2000);
	indicator.parameters:addInteger("Period3", "Signal Period", "", 9, 1, 2000);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");

	
 
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "MACD Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", "Signal Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("color3", "Histogram Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period1, Period2, Period3; 
local first;
local source = nil;
local stream; 
local ma1, ma2, ma3;
local Last=nil;
local MACD, HISTOGRAM, SIGNAL;
-- Routine
 function Prepare(nameOnly)   
 
 
   Period1= instance.parameters.Period1;
   Period2= instance.parameters.Period2;
   Period3= instance.parameters.Period3;
   Method= instance.parameters.Method;

    Last=nil;
	
	local Parameters= Period1..", "..Period2..", "..Period3 ..", "..Method;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	Transaction= core.indicators:create("TRANSACTIONS", source);
	
	
	ma1 = core.indicators:create(Method, Transaction.DATA, Period1);
	ma2 = core.indicators:create(Method, Transaction.DATA, Period2);
	
	
	first=math.max(ma1.DATA:first(),ma2.DATA:first() );
	MACD = instance:addStream("MACD" , core.Line, " MACD"," MACD",instance.parameters.color1, first );
	MACD:setWidth(instance.parameters.width);
    MACD:setStyle(instance.parameters.style);
    MACD:setPrecision(math.max(2, source:getPrecision()));
	
	
    ma3 = core.indicators:create(Method, MACD, Period3);
	
	
	SIGNAL = instance:addStream("SIGNAL" , core.Line, " SIGNAL"," SIGNAL",instance.parameters.color2, first+Period3 );
	SIGNAL:setWidth(instance.parameters.width);
    SIGNAL:setStyle(instance.parameters.style);
    SIGNAL:setPrecision(math.max(2, source:getPrecision()));
 
	
	HISTOGRAM= instance:addStream("HISTOGRAM" , core.Bar, " HISTOGRAM"," HISTOGRAM",instance.parameters.color3, first+Period3 );
 
	
	
	 core.host:execute("setTimer", 100, 1);
end

 

-- Indicator calculation routine
function Update(period, mode)
    Transaction:update(mode);
	ma1:update(mode);
	ma2:update(mode);
	
	if period < first
	then
	return;
	end
	
	
	MACD[period]=ma1.DATA[period]-ma2.DATA[period] ;
	
    ma3:update(mode);
    if period < first+Period3
	then
	return;
	end
	SIGNAL[period]= ma3.DATA[period] ;
	HISTOGRAM[period]= MACD[period]-SIGNAL[period];	
    
				  
end

 

 
function AsyncOperationFinished(cookie, success, message)
    if  source:size()~= 0 and cookie ==100  then
         
            
			ma1:update(core.UpdateAll );
			ma2:update(core.UpdateAll );
			ma3:update(core.UpdateAll );
			
			-- Last= source:serial(source:size()-1);
			 
			instance:updateFrom(0);
  	
    end
	
	 
end
