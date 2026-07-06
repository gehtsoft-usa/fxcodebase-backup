-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60477
-- Id: 11403

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Price Action Trading Assistant");
    indicator:description("Price Action Trading Assistant");
    indicator:requiredSource(core.Bar);
	 indicator:setTag("replaceSource", "t");
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Method", "Method", "Method" , "Median");
    indicator.parameters:addStringAlternative("Method", "Median", "(high+low)/2", "Median");
    indicator.parameters:addStringAlternative("Method", "Typical", "(high+low+close)/3", "Typical");
    indicator.parameters:addStringAlternative("Method", "Weighted", "(high+low+2*close)/4", "Weighted");	
    indicator.parameters:addStringAlternative("Method", "Regular", "", "Regular");	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of Up Candle", "Color of Up", core.COLOR_UPCANDLE );
    indicator.parameters:addColor("Down", "Color of Down Candle", "Color of Down", core.COLOR_DOWNCANDLE );
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Method;
local first;
local source = nil;
local Up, Down;
local Price;
-- Streams block
local open, high, low, close, volume;

-- Routine
function Prepare(nameOnly)
    source = instance.source;
	Method=instance.parameters.Method;
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. Method .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
		if Method == "Median" then	
        Price= source.median;		
		elseif Method == "Typical" then
		Price= source.typical;	
		elseif Method == "Weighted" then
		Price= source.weighted;	
		else
		Price= source.open;	
		end

    if (not (nameOnly)) then
    open = instance:addStream("open", core.Line, name .. "." .. "Open", "open", 0, first);
    high = instance:addStream("high", core.Line, name .. "." .. "High", "high", 0, first);
    low = instance:addStream("low", core.Line, name .. "." .. "Low", "low", 0, first);
    close = instance:addStream("close", core.Line, name .. "." .. "Close", "close", 0, first);
	volume = instance:addStream("volume", core.Line, name .. "." .. "Volume", "Volume", 0,first);

    instance:createCandleGroup("PATA", "PATA", open, high, low, close, volume);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not  source:hasData(period) then
	return;
	end  
	   
	
        open[period] = source.open[period];  
		low[period] = source.low[period]; 
		close[period]=source.close[period]; 
		high[period] = source.high[period]; 
		volume[period] = source.volume[period]; 
			
		
		if source.close[period]>  Price[period] then
		open:setColor(period, Up);
		else
		open:setColor(period, Down);
		end
		
end

