-- Id: 5937
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=14414

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
    indicator:name("Average Average True Range");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("ATR", "ATR Period", " ", 14);
    indicator.parameters:addInteger("MA", "MA Period", "No description", 50);
    indicator.parameters:addColor("Up", "Color of Up Bar", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn", "Color of Down Bar", "", core.rgb(255,0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local ATR;
local MA;

local first;
local source = nil;

-- Streams block
local AATR = nil;
local Indicator={};
-- Routine
function Prepare(nameOnly)
    ATR = instance.parameters.ATR;
    MA = instance.parameters.MA;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(ATR) .. ", " .. tostring(MA) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Indicator["ATR"] = core.indicators:create("ATR", source, ATR);
        Indicator["MVA"] = core.indicators:create("MVA", Indicator["ATR"].DATA, MA);
        
        first = math.max( Indicator["MVA"].DATA:first(), Indicator["ATR"].DATA:first());
        AATR = instance:addStream("AATR", core.Bar, name, "AATR", instance.parameters.Up, first);
    AATR:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period <first or not source:hasData(period) then
	return;
	end
	
       Indicator["ATR"]:update(mode); 
	    Indicator["MVA"]:update(mode);  

	   AATR[period] = Indicator["MVA"].DATA[period];
	   
	   if AATR[period] > AATR[period-1] then
	   AATR:setColor(period, instance.parameters.Up);
	   else
	   AATR:setColor(period, instance.parameters.Dn);
	   end
   
end

