
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2522

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
    indicator:name("Williams Thrust");
    indicator:description("Williams Thrust");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Parameters");
    indicator.parameters:addInteger("LWO", "First Larry Williams Period", "", 250, 2, 1000);
	indicator.parameters:addInteger("MAO", "First Moving Average Period", "", 50, 2, 1000);
	indicator.parameters:addInteger("LWT", "Second Larry Williams Period", "", 50, 2, 1000);
	indicator.parameters:addInteger("MAT", "Second Moving Average Period", "", 10, 2, 1000);	
	
	indicator.parameters:addString("Method", "MA Type", "MA Type" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "HMA" , "HMA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local LWO, MAO, LWT, MAT;
local Up,Down, Neutral;
local first;
local source = nil;

-- Streams block
  
local open=nil;
local close=nil;
local high=nil;
local low=nil;

local indicator1;
local indicator2;
local MVA1;
local MVA2;

local Method;

-- Routine
function Prepare(nameOnly)
    Method= instance.parameters.Method;
    LWO = instance.parameters.LWO;
	LWT = instance.parameters.LWT;
	MAO = instance.parameters.MAO;
	MAT = instance.parameters.MAT;
	
	Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
	
    source = instance.source; 

    local name = profile:id() .. "(" .. source:name() .. ", " .. LWO.. ", ".. MAO.. ", ".. LWT..", " .. MAT ..",".. Method .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator(Method) ~= nil, "Please, download and install "..Method ..  " indicator");
	
	indicator1 = core.indicators:create("RLW", source, LWO);
	indicator2 = core.indicators:create("RLW", source, LWT);
	
	MVA1 = core.indicators:create(Method, indicator1.DATA, MAO);
	MVA2 = core.indicators:create(Method, indicator2.DATA, MAT);
	
	first = math.max(MVA1.DATA:first(), MVA2.DATA:first());	
	 
	open = instance:addStream("open", core.Line, name, "open", core.rgb(127, 127, 127), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(127, 127, 127), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(127, 127, 127), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(127, 127, 127), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode )

    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
    indicator1:update(mode);
	indicator2:update(mode);
	MVA1:update(mode);
	MVA2:update(mode);
	  
	if period < first or not source:hasData(period) then	
	open:setColor(period, Neutral);	
	return;
    end  
	  
		  
		   
		           
				   if indicator1.DATA[period] > MVA1.DATA[period] and  indicator2.DATA[period] > MVA2.DATA[period] then
		           open:setColor(period,  Up);
				   elseif indicator1.DATA[period] < MVA1.DATA[period] and  indicator2.DATA[period] < MVA2.DATA[period] then
				   open:setColor(period,  Down);
				   else
				   open:setColor(period, Neutral);	
				   end
		 
		    
	 
	  
    
end

