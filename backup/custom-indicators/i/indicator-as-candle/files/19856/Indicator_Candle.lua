-- Id: 5193
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=9077

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("Indicator candle");
    indicator:description("Indicator candle");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("IN", "Indicator", "", "");
    indicator.parameters:setFlag("IN",core.FLAG_INDICATOR);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local open=nil;
local close=nil;
local high=nil;
local low=nil;
local IndOpen;
local IndClose;
local IndHigh;
local IndLow;

function Prepare(nameOnly)
    source = instance.source;
   
    local ind_ = core.indicators:findIndicator(instance.parameters:getString("IN"));
    local params_c = instance.parameters:getCustomParameters("IN");
    local params_o = instance.parameters:getCustomParameters("IN");
    local params_h = instance.parameters:getCustomParameters("IN");
    local params_l = instance.parameters:getCustomParameters("IN");
   assert (ind_:requiredSource() == core.Tick, "The chosen indicator must use a ticks as source!");

    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.IN .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    IndOpen = ind_:createInstance(source.open, params_o);
    IndClose = ind_:createInstance(source.close, params_c);
    IndHigh = ind_:createInstance(source.high, params_h);
    IndLow = ind_:createInstance(source.low, params_l);
	
	 first = IndLow.DATA:first();
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    high:setPrecision(math.max(2, instance.source:getPrecision()));
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    low:setPrecision(math.max(2, instance.source:getPrecision()));
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    close:setPrecision(math.max(2, instance.source:getPrecision()));
    instance:createCandleGroup(instance.parameters.IN, instance.parameters.IN, open, high, low, close);
end

function Update(period, mode)
   if (period>first) then
    IndClose:update(mode);
    IndOpen:update(mode);
    IndHigh:update(mode);
    IndLow:update(mode);
    close[period]=IndClose.DATA[period];
    open[period]=IndOpen.DATA[period];
    high[period]=IndHigh.DATA[period];
    low[period]=IndLow.DATA[period];
    if open[period]>close[period] then
     open:setColor(period,instance.parameters.DNclr); 
    else
     open:setColor(period,instance.parameters.UPclr);
    end
   end 
end

