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
    indicator:name("Transactions with MA");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 14, 2, 2000);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");

	
		indicator.parameters:addGroup("Bar Style"); 	
    indicator.parameters:addColor("transaction_color", "Bar Color", "", core.rgb(0, 255, 0));
	
	indicator.parameters:addGroup("MA Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period; 
local first;
local source = nil;
local stream; 
local MA, ma, transaction, Transaction;
local Last=nil;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
   Method= instance.parameters.Method;
	
	
	local Parameters= Period..", "..Method;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	Transaction= core.indicators:create("TRANSACTIONS", source);
	MA = core.indicators:create(Method, Transaction.DATA, Period);
    first=Transaction.DATA:first(); 
	stream = Transaction:getStream(0);
	
	transaction= instance:addStream("transaction" , core.Bar, " transaction"," transaction",instance.parameters.transaction_color, first );
 
	ma = instance:addStream("ma" , core.Line, " ma"," ma",instance.parameters.color, first );
	ma:setWidth(instance.parameters.width);
    ma:setStyle(instance.parameters.style);
    ma:setPrecision(math.max(2, source:getPrecision()));
	
	 core.host:execute("setTimer", 100, 1);
end

 

-- Indicator calculation routine
function Update(period, mode)
    Transaction:update(mode);
	
	if period < first
	then
	return;
	end
	
    MA:update(mode);
    if period < first+Period
	then
	return;
	end
	 transaction[period]= Transaction.DATA[period];	
     ma[period]= MA.DATA[period];
	-- ma[period]=mathex.avg(transaction, period-Period+1, period);
				  
end

 

 
function AsyncOperationFinished(cookie, success, message)
    if cookie == 100 and source:size()~= 0   then
         
            instance:updateFrom(0);
			MA:update(core.UpdateAll );
			
			--Last= source:serial(source:size()-1);
  	
    end
end
