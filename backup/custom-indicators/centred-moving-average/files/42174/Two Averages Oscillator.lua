-- Id: 7697

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=24476

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Two Averages Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addString("Mode", "Calculation Mode", "", "Dynamic");
    indicator.parameters:addStringAlternative("Mode", "Dynamic", "", "Dynamic");
    indicator.parameters:addStringAlternative("Mode", "Static", "", "Static");
  
	
	
    indicator.parameters:addString("Method1", "Short MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method1", "CMA", "CMA" , "CMA");

    indicator.parameters:addInteger("Period1", "Short MA Period", "", 20);
	

    indicator.parameters:addString("Method2", "Long MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method2", "CMA", "CMA" , "CMA");	

    indicator.parameters:addInteger("Period2", "Long MA Period", "", 50);
	
    indicator.parameters:addGroup("Style");
	 indicator.parameters:addColor("UPUP", "Up in Up Trend ", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("UPDN", "Down in Up Trend ", "", core.rgb(0, 200, 0));
	 indicator.parameters:addColor("DNUP", "Up in Down Trend ", "", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("DNDN", "Down in Down Trend ", "", core.rgb(200, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block


local first;
local source = nil;
local One
local Two;
local Out;
local dummy;
local Method2,Method1;
local Period1, Period2;
local Mode;
-- Routine
function Prepare(nameOnly)
    Period1 = instance.parameters.Period1;
    Period2 = instance.parameters.Period2;
	Method2 = instance.parameters.Method2;
	Method1 = instance.parameters.Method1;
	Mode = instance.parameters.Mode;
    source = instance.source;
	
	
	  local name = profile:id() .. "(" .. source:name()  .. ", " .. tostring(Mode).. ", " .. tostring(Period1).. ", " .. tostring(Method1).. ", " .. tostring(Period2).. ", " .. tostring(Method2) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	assert(core.indicators:findIndicator(Method1) ~= nil, "Please, download and install" ..  Method1 .." indicator");
	assert(core.indicators:findIndicator(Method2) ~= nil, "Please, download and install" ..  Method2 .." indicator");
	
	if (Period1 >= Period2) then
       error("The short MA period must be smaller than long MA period");
    end
	
	
	 One = core.indicators:create( Method1, source, Period1);
	 Two = core.indicators:create( Method2, source , Period2);
		
    first = math.max(One.DATA:first(),  Two.DATA:first());

  
	 
        Out = instance:addStream("TAO", core.Bar, name, "TAO", instance.parameters.UPUP, first);
    Out:setPrecision(math.max(2, instance.source:getPrecision()));
 
end



-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    		  
	  
    if period < first or not source:hasData(period) then
	return;
	end
	
	
	if  ( Method1== "CMA" or  Method2== "CMA")  and period == source:size()-1 and  Mode == "Dynamic" and period > ( period -math.max(Period1, Period2) /2)
	then
	
	  One:update(core.UpdateAll);
	 Two:update(core.UpdateAll);
	
	    local i;
		
		
		for i= period -math.max(Period1, Period2) /2 , period, 1 do
		
	        	Out[i] =One.DATA[i] - Two.DATA[i];
		
				if Out[i] > 0 then
					if  Out[i] > Out[i-1] then
					Out:setColor(i, instance.parameters.UPUP);
					else
					Out:setColor(i, instance.parameters.UPDN);
					end                	
				else
					if  Out[i] > Out[i-1] then
					Out:setColor(i, instance.parameters.DNUP);
					else
					Out:setColor(i, instance.parameters.DNDN);
					end       
				end
		
		end
	
	
	else
	
	     One:update(mode);
	 Two:update(mode);
		Out[period] =One.DATA[period] - Two.DATA[period];
		
		if Out[period] > 0 then
			if  Out[period] > Out[period-1] then
			Out:setColor(period, instance.parameters.UPUP);
			else
			Out:setColor(period, instance.parameters.UPDN);
			end                	
		else
			if  Out[period] > Out[period-1] then
			Out:setColor(period, instance.parameters.DNUP);
			else
			Out:setColor(period, instance.parameters.DNDN);
			end       
		end
	end
    
end