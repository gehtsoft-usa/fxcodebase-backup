-- Id: 6379
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=16214

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
    indicator:name("Swing Shift");
    indicator:description("No description");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation");
	 indicator.parameters:addString("Mode" , "Method for avegage", "", "Cumulative");
    indicator.parameters:addStringAlternative("Mode" , "Cumulative", "", "Cumulative");
    indicator.parameters:addStringAlternative("Mode", "Absolute", "", "Absolute");
	
    indicator.parameters:addString("Method" , "Method for avegage", "", "MVA");
    indicator.parameters:addStringAlternative("Method" , "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
	 indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method" , "LWMA", "", "LWMA");	
	indicator.parameters:addStringAlternative("Method" , "SMMA", "", "SMMA");
	indicator.parameters:addStringAlternative("Method" , "TMA", "", "TMA");
	indicator.parameters:addStringAlternative("Method" , "WMA", "", "WMA");
	indicator.parameters:addStringAlternative("Method" , "VIDYA", "", "VIDYA");
	
	 indicator.parameters:addInteger("Period", "Period", "Period", 14,2,2000);
	 indicator.parameters:addDouble("Threshold", "Threshold (in Pips)", "", 0, 0,20000000);  
	  
	indicator.parameters:addGroup("Style");  
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Method, Period, Threshold;
local first;
local source = nil;
local Mode;
-- Streams block
local SS = nil;
local Anchor=nil;
local TREND;
local TP;
local Size;
-- Routine
function Prepare(nameOnly)
    Size= instance.parameters.Size;
    Mode= instance.parameters.Mode;
    Method= instance.parameters.Method;
	Period= instance.parameters.Period;	
	Threshold= instance.parameters.Threshold;
    source = instance.source;
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA=core.indicators:create(Method,  source, Period);
    first = MA.DATA:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Method) ..  ", " .. tostring(Period) ..  ", " .. tostring(Threshold)..  ", " .. tostring(Mode) .. ")";
    instance:name(name);

    if (not (nameOnly)) then 
	    TP = instance:createTextOutput ("TP", "TP", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.color, 0); 
		core.host:execute ("attachTextToChart", "TP")
        SS = instance:addStream("SS", core.Line, name, "SS", instance.parameters.color, first);
    SS:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period< first  or not source:hasData(period) then
	return;
	end
	
	 MA:update(mode);
	 
	 
	 local Slope =  (MA.DATA[period]- MA.DATA[period-1]) / source:pipSize();
 
	 if Slope > Threshold  and  TREND ~= true then
	 Anchor= period;
	 TREND= true;
	 elseif Slope < - Threshold and  TREND ~= false then
	 Anchor= period;
	  TREND= false;
	 end
	 
	   TP:setNoData (period);
	 
	 if Anchor== period then
	  TP:set(period , MA.DATA[period], "\108");		 
	 end
	 
	 
	if  Anchor == nil then
	return;
	end
	
	
	if period <  MA.DATA:first()
	or Anchor <  MA.DATA:first()
	or period< first 
	or not MA.DATA:hasData(period)
	or not MA.DATA:hasData(Anchor)
	then
	return;
	end
	
	if Mode == "Absolute" then 
     SS[period] =  (MA.DATA[period] - MA.DATA[Anchor]) / (MA.DATA[Anchor]/100);
    else    
	SS[period] =   SS[period-1] + (MA.DATA[period] - MA.DATA[period-1]) / (MA.DATA[Anchor]/100);
	end
end

