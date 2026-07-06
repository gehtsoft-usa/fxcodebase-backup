-- Id: 13035
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61482

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("MA Candles");
    indicator:description("MA Candles");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
    indicator.parameters:addInteger("Period", "Period", "Period", 14);	
    indicator.parameters:addString("Method", "Method", "Method", "MVA");
	indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addBoolean("Filter", "Use High/Low Filter", "Use High/Low Filter", true);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Neutral", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Method;
local Price;
local first;
local source = nil;

-- Streams block
local Up = nil;
local Down = nil;
local Neutral = nil;

local Filter;
local open=nil;
local close=nil;
local high=nil;
local low=nil;

local MA;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    Method = instance.parameters.Method;
	Price = instance.parameters.Price;
	Filter = instance.parameters.Filter;
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Neutral = instance.parameters.Neutral;
    source = instance.source;
	
    local name = profile:id() .. "(" .. source:name().. ", " .. tostring(Price) .. ", " .. tostring(Period) .. ", " .. tostring(Method) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
		MA = core.indicators:create(Method, source[Price], Period);
		 
		first = MA.DATA:first();
		open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
		high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
		low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
		close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
		instance:createCandleGroup("ZONE", "", open, high, low, close);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    MA:update(mode);
	
	high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	
     
	if period < first  or not source:hasData(period) then
	open:setColor(period, Neutral);		
    return;
    end 
    
	local Flag=0;
	
	if source.close[period]> MA.DATA[period]  
	and( not Filter or source.low[period]> MA.DATA[period] )
	then
	Flag=1;
	elseif source.close[period]< MA.DATA[period]
	and( not Filter or source.high[period]< MA.DATA[period] )
	then
	Flag=-1;
	else
	Flag=0;
	end
	    if Flag== 1 then 
				open:setColor(period, Up);
		elseif  Flag== -1 then
				open:setColor(period, Down);	
		else 
				open:setColor(period, Neutral);
		end 	     
end

