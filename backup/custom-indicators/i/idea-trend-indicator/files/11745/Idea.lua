-- Id: 4137
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4739

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
    indicator:name("Idea");
    indicator:description("Idea");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("PERIOD", "Period", "", 20);
	indicator.parameters:addDouble("Level", "Level", "", 1);
	indicator.parameters:addString("Method", "Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA"); 
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");	
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of Up Trend", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("Down", "Color of Down Trend", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local PERIOD;
local Level;
local Method;

local first;
local source = nil;

-- Streams block
local Idea = nil;
local Indicator= {};

-- Routine
function Prepare(nameOnly)
    Method = instance.parameters.Method;
    PERIOD = instance.parameters.PERIOD;
    source = instance.source;
    Level = instance.parameters.Level;
    local name = profile:id() .. "(" .. source:name() .. ", " .. PERIOD .. ", " .. Level .. ", " .. Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	Indicator["High"] = core.indicators:create(Method, source.high, PERIOD);
	Indicator["Low"] = core.indicators:create(Method, source.low, PERIOD);
	Indicator["Close"] = core.indicators:create(Method, source.close, PERIOD);
	
	first = Indicator["Close"].DATA:first();

    Idea = instance:addStream("Idea", core.Bar, name, "Idea", instance.parameters.Up, first);
    Idea:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period < first or  not source:hasData(period) then
	return;
	end
	
	
	  Indicator["High"]:update(mode);
	  Indicator["Low"]:update(mode);
	  Indicator["Close"]:update(mode);
	  

        Idea[period] = ( Indicator["High"].DATA[period]- Indicator["Close"].DATA[period] ) / ( Indicator["Close"].DATA[period]- Indicator["Low"].DATA[period]);
		
		if   Idea[period] < Level then
		Idea:setColor(period, instance.parameters.Up);	
		else
		Idea:setColor(period, instance.parameters.Down);	
		end
    
end

