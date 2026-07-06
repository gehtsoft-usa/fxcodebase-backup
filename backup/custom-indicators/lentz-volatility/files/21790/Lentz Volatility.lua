-- Id: 5443
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10521

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
    indicator:name("Lentz Volatility");
    indicator:description("Lentz Volatility");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("AP", "ATR Period", "", 20);
	indicator.parameters:addString("Method", "Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
	indicator.parameters:addInteger("MP", "EMA Period", "", 20);
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("UP", "Positiv  Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DOWN", "Negativ Color", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local AP;
local MP;
local Method;
local first;
local source = nil;
local ATR;
local MA;

-- Streams block
local LVI = nil;

-- Routine
function Prepare(nameOnly)
    Method = instance.parameters.Method;
    MP = instance.parameters.MP;
	 AP= instance.parameters.AP;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(AP).. ", " .. tostring(Method) .. ", " .. tostring(MP).. ")";
    instance:name(name);

    if (not (nameOnly)) then
	
        ATR= core.indicators:create("ATR",source , AP);
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
        MA= core.indicators:create(Method,ATR.DATA , MP);
        
        first = MA.DATA:first();
        LVI = instance:addStream("LVI", core.Bar, name, "LVI", instance.parameters.UP, first);
    LVI:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period >= first and source:hasData(period) then
	
	ATR:update(mode);
    MA:update(mode);
		
        LVI[period] = MA.DATA[period]- ATR.DATA[period];
		
		if LVI[period]> 0 then
		LVI:setColor(period, instance.parameters.UP);	
		else
		LVI:setColor(period, instance.parameters.DOWN);
		end
		
    end 
end

