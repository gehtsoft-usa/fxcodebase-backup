-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41290
-- Id: 9328

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("CCI custom candles");
    indicator:description("CCI custom candles");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("CCI_Period", "CCI period", "", 14);
    indicator.parameters:addInteger("Overbought", "Overbought level", "", 100);
    indicator.parameters:addInteger("Oversold", "Oversold level", "", -100);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.COLOR_DOWNCANDLE);
    indicator.parameters:addColor("OBclr", "Overbought color", "Overbought color", core.rgb(0, 255, 255));
    indicator.parameters:addColor("OSclr", "Oversold color", "Oversold color", core.rgb(255, 128, 255));
end

local first;
local source = nil;
local CCI_Period;
local Overbought;
local Oversold;
local CCI;
local open=nil;
local close=nil;
local high=nil;
local low=nil;

function Prepare(nameOnly)
    source = instance.source;
    CCI_Period=instance.parameters.CCI_Period;
    Overbought=instance.parameters.Overbought;
    Oversold=instance.parameters.Oversold;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.CCI_Period .. ", " .. instance.parameters.Overbought .. ", " .. instance.parameters.Oversold .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    CCI = core.indicators:create("CCI", source, CCI_Period);
	first = CCI.DATA:first();
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("CCI_Candles", "", open, high, low, close);
end

function Update(period, mode)
   
    open[period]=source.open[period];
    close[period]=source.close[period];
    high[period]=source.high[period];
    low[period]=source.low[period];
	
	if period>first then
    CCI:update(mode);
    if CCI.DATA[period]>Overbought then
     open:setColor(period, instance.parameters.OBclr);
    elseif CCI.DATA[period]<Oversold then
     open:setColor(period, instance.parameters.OSclr);
    elseif source.close[period]>=source.open[period] then
     open:setColor(period, instance.parameters.UPclr);
    else
     open:setColor(period, instance.parameters.DNclr);
    end
   end 
end

