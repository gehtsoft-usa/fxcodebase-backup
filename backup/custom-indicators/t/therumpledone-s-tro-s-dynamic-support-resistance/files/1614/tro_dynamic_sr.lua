-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=882
-- Id: 533

--+------------------------------------------------------------------+
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

-- +------------------------------------------------------------------+
-- |   TRO_DYNAMIC_FIBS_SR_Trail                                      |
-- |                                                                  |
-- |   Copyright � 2009, Avery T. Horton, Jr. aka TheRumpledOne       |
-- |                                                                  |
-- |   PO BOX 43575, TUCSON, AZ 85733                                 |
-- |                                                                  |
-- |   GIFTS AND DONATIONS ACCEPTED                                   |
-- |   All my indicators should be considered donationware. That is   |
-- |   you are free to use them for your personal use, and are        |
-- |   under no obligation to pay for them. However, if you do find   |
-- |   this or any of my other indicators help you with your trading  |
-- |   then any Gift or Donation as a show of appreciation is         |
-- |   gratefully accepted.                                           |
-- |                                                                  |
-- |   Gifts or Donations also keep me motivated in producing more    |
-- |   great free indicators. :-)                                     |
-- |                                                                  |
-- |   PayPal - THERUMPLEDONE@GMAIL.COM                               |
-- +------------------------------------------------------------------+
-- Author's site: http://www.therumpledone.com/

function Init()
    indicator:name("TRO's Dymamic SR");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("NR", "Number of periods for Resistance", "", 5, 2, 10000);
	 indicator.parameters:addInteger("NS", "Number of periods for Support", "", 5, 2, 10000);
    indicator.parameters:addInteger("Threshold", "Threshold (in pips)", "", 0, 0, 10000);
    indicator.parameters:addInteger("Trigger", "Trigger value (in pips)", "", 5, 2, 10000);
    indicator.parameters:addBoolean("ShowTriggers", "Show Triggers", "", true);
    indicator.parameters:addBoolean("ResetOnNewDay", "Reset support/resistance on new day", "", false);
	indicator.parameters:addBoolean("Signal", "Strategy Mode", "", false);

    indicator.parameters:addColor("colorR", "Color of resistance", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("colorS", "Color of support", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("colorSh", "Color of high trigger", "", core.rgb(127, 0, 0));
    indicator.parameters:addColor("colorLg", "Color of low trigger", "", core.rgb(0, 127, 0));
end

local source;
local NR, NS;
local bid;
local ask;
local first;
local Threshold;
local Trigger;
local ResetOnNewDay;
local ShowTriggers;
local Signal;
local DynR;
local DynS;
local LgTrig;
local ShTrig;
local BuySignal;
local SellSignal;
local DayCandle;
local host;
local offset;
local CandleLength;
local Out;
function Prepare(nameOnly)
    host = core.host;
    offset = host:execute("getTradingDayOffset");
    source = instance.source;
  
    local s, e;
    s, e = core.getcandle(source:barSize(), core.now(), 0);
    CandleLength = e - s;

    NR = instance.parameters.NR;
	NS = instance.parameters.NS;
    Threshold = instance.parameters.Threshold * source:pipSize();
    Trigger = instance.parameters.Trigger * source:pipSize();
    ResetOnNewDay = instance.parameters.ResetOnNewDay;
    ShowTriggers = instance.parameters.ShowTriggers;
	Signal = instance.parameters.Signal;

    local name = profile:id() .. "(" .. source:name() .. ", " .. NR .. ", " .. NS .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    if source:isBid() then
        bid = source;
        ask = core.host:execute("getAskPrice");
    else
        ask = source;
        bid = core.host:execute("getBidPrice");
    end
    first = source:first() + math.max(NS,NR);

    DynR = instance:addStream("R", core.Line, name .. ".R", "R", instance.parameters.colorR, first);
    DynS = instance:addStream("S", core.Line, name .. ".S", "S", instance.parameters.colorS, first);

    if ShowTriggers then
        LgTrig = instance:addStream("Lg", core.Line, name .. ".Lg", "Lg", instance.parameters.colorLg, first);
        ShTrig = instance:addStream("Sh", core.Line, name .. ".Sh", "Sh", instance.parameters.colorSh, first);
        Sell = instance:createTextOutput ("Sell", "Sell", "Wingdings", 10, core.H_Center, core.V_Top, instance.parameters.colorS, 0);
        Buy = instance:createTextOutput ("Buy", "Buy", "Wingdings", 10, core.H_Center, core.V_Bottom, instance.parameters.colorR, 0);
    else
        LgTrig = instance:addInternalStream(first, 0);
        ShTrig = instance:addInternalStream(first, 0);
    end
	
	if Signal then
	Out = instance:addStream("Signal", core.Bar, name .. ".Signal", "Signal", core.rgb(0, 0, 0), first);
	end

    DayCandle = instance:addInternalStream(0, 0);
end

function Update(period, mode)


    if Signal then
	Out[period]=0;
	end
    local candle;
    candle = core.getcandle("D1", source:date(period), offset);
    DayCandle[period] = candle;
    if period >= first then
        if CandleLength < 1 and DayCandle[period - 1] ~= DayCandle[period] and ResetOnNewDay then
            DynR[period] = source.high[period];
            DynS[period] = source.low[period];
        else
            local hh, ll;
            ll = mathex.min(source.low, period- NS+1 , period);
			hh = mathex.max(source.high, period- NR+1 , period);
            DynR[period] = hh;
            DynS[period] = ll;
            LgTrig[period] = ll + Trigger;
            ShTrig[period] = hh - Trigger;
            if DynR[period] ~= source.high[period] and DynR[period] < DynR[period - 1] then
                DynR[period] = DynR[period - 1];
                ShTrig[period] = ShTrig[period - 1];
            end
            if DynS[period] ~= source.low[period] and DynS[period] > DynS[period - 1] then
                DynS[period] = DynS[period - 1];
                LgTrig[period] = LgTrig[period - 1];
            end
            local alertBuy, alertSell;
            local green, red;
            alertBuy = LgTrig[period] + Threshold;
            alertSell = ShTrig[period] - Threshold;
            green = (source.open[period] < source.close[period]);
            red = (source.open[period] > source.close[period]);

            local bid1, ask1;
            if period == source:size() - 1 then
                bid1 = bid.close[period];
                ask1 = ask.close[period];
            else
                bid1 = bid.low[period];
                ask1 = ask.high[period];
            end

            if ask1 > alertBuy and source.low[period] <= alertBuy and green then
                if ShowTriggers then
                    Buy:set(period, alertBuy, "\225");
					if Signal then
					Out[period]=1;
					end
                end
            end
            if bid1 < alertSell and source.high[period] >= alertSell and red then
                if ShowTriggers then
                    Sell:set(period, alertSell, "\226");
					if Signal then
					Out[period]=-1;
					end
                end
            end
        end
    else
        if source:hasData(period) then
            DynR[period] = source.close[period];
            DynS[period] = source.close[period];
            LgTrig[period] = source.close[period] - Trigger;
            ShTrig[period] = source.close[period] + Trigger;
        end
    end
end


