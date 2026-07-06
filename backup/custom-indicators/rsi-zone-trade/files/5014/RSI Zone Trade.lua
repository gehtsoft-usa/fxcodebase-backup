-- Id: 1865
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2345

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
    indicator:name("RSIZONE");
    indicator:description("RSIZONE");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

   indicator.parameters:addGroup("RSI");
    indicator.parameters:addInteger("RF", "RSI Period", "", 14, 2, 1000);
	indicator.parameters:addInteger("RSF", "RSI  Signal Line Period", "", 14, 2, 1000);
	indicator.parameters:addString("M" , "Method for avegage", "", "MVA");
    indicator.parameters:addStringAlternative("M" , "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("M", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("M" , "LWMA", "", "LWMA");
	
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
local RF, RSF, M;
local Up,Down, Neutral;
local first;
local source = nil;

-- Streams block
local HZU = nil;
local HZL = nil;

local open=nil;
local close=nil;
local high=nil;
local low=nil;

local RSI;
local MVA;

-- Routine
 function Prepare(nameOnly)  
    RF = instance.parameters.RF;
	RSF = instance.parameters.RSF;
	M = instance.parameters.M;
    source = instance.source;
	  Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. RF.. ", ".. RSF .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    
	
	RSI = core.indicators:create("RSI", source.close, RF);
    assert(core.indicators:findIndicator(M) ~= nil, M .. " indicator must be installed");
	MVA = core.indicators:create(M, RSI.DATA, RSF);
    first = math.max( RSI.DATA:first(),MVA.DATA:first());	
    
	
 
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
	
	
    if period < first or not source:hasData(period) then
	open:setColor(period, Neutral);	
	return;
	end
      
	  RSI:update(mode);
      MVA:update(mode); 
		   
		           
				   if RSI.DATA[period] > 50 and  RSI.DATA[period] > MVA.DATA[period] then
		           open:setColor(period, Up);					   
				   elseif RSI.DATA[period] < 50 and  RSI.DATA[period] < MVA.DATA[period] then
				   open:setColor(period, Down);	
				   else
				   open:setColor(period, Neutral);	
				   end
	
	 
end

