-- Id: 20381
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15078

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
    indicator:name("Heikin-Ashi Partial candles indicator");
    indicator:description("Partial candles indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("replaceSource", "t");
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Type", "Type of candles", "", "OC");
    indicator.parameters:addStringAlternative("Type", "OHLC", "", "OHLC");
    indicator.parameters:addStringAlternative("Type", "OLC", "", "OLC");
    indicator.parameters:addStringAlternative("Type", "OHC", "", "OHC");
    indicator.parameters:addStringAlternative("Type", "OHL", "", "OHL");
    indicator.parameters:addStringAlternative("Type", "HLC", "", "HLC");
    indicator.parameters:addStringAlternative("Type", "HC", "", "HC");
    indicator.parameters:addStringAlternative("Type", "LC", "", "LC");
    indicator.parameters:addStringAlternative("Type", "OL", "", "OL");
    indicator.parameters:addStringAlternative("Type", "OH", "", "OH");
    indicator.parameters:addStringAlternative("Type", "OC", "", "OC");
    indicator.parameters:addStringAlternative("Type", "C", "", "C");
    indicator.parameters:addStringAlternative("Type", "O", "", "O");
end

local first;
local source = nil;
local Type;
local HA;
function Prepare(nameOnly)
    source = instance.source;
    Type = instance.parameters.Type;
    
    local name = profile:id() .. "(" .. source:name() .. " " .. Type ..")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	HA = core.indicators:create("HA", source);
	first = HA.DATA:first();
	
    open = instance:addInternalStream(first, 0);
    close = instance:addInternalStream(first, 0);
    high = instance:addInternalStream(first, 0);
    low = instance:addInternalStream(first, 0);
    instance:createCandleGroup("Partial candles", "", open, high, low, close);
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    HA:update(mode);
	
    if Type=="OHLC" then
     open[period]=HA.open[period];
     close[period]=HA.close[period];
     high[period]=HA.high[period];
     low[period]=HA.low[period];
    elseif Type=="OLC" then
     open[period]=HA.open[period];
     close[period]=HA.close[period];
     high[period]=math.max(open[period],close[period]);
     low[period]=HA.low[period];
    elseif Type=="OHC" then
     open[period]=HA.open[period];
     close[period]=HA.close[period];
     high[period]=HA.high[period];
     low[period]=math.min(open[period],close[period]);
    elseif Type=="OHL" then
     open[period]=HA.open[period];
     close[period]=open[period];
     high[period]=HA.high[period];
     low[period]=HA.low[period];
    elseif Type=="HLC" then
     close[period]=HA.close[period];
     open[period]=close[period];
     high[period]=HA.high[period];
     low[period]=HA.low[period];
    elseif Type=="HC" then
     close[period]=HA.close[period];
     open[period]=close[period];
     high[period]=HA.high[period];
     low[period]=close[period];
    elseif Type=="LC" then
     close[period]=HA.close[period];
     open[period]=close[period];
     high[period]=close[period];
     low[period]=HA.low[period];
    elseif Type=="OL" then
     open[period]=HA.open[period];
     close[period]=open[period];
     high[period]=open[period];
     low[period]=HA.low[period];
    elseif Type=="OH" then
     open[period]=HA.open[period];
     close[period]=open[period];
     high[period]=HA.high[period];
     low[period]=open[period];
    elseif Type=="OC" then
     open[period]=HA.open[period];
     close[period]=HA.close[period];
     high[period]=math.max(open[period],close[period]);
     low[period]=math.min(open[period],close[period]);
    elseif Type=="C" then
     close[period]=HA.close[period];
     open[period]=close[period];
     high[period]=close[period];
     low[period]=close[period];
    elseif Type=="O" then
     open[period]=HA.open[period];
     close[period]=open[period];
     high[period]=open[period];
     low[period]=open[period];
    end
  
end

