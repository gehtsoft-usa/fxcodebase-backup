-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=68931
--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

local EntryActions = {};
local ExitActions = {};

-- START OF USER DEFINED SECTION
local STRATEGY_NAME = "SuperTrend Band StrategySRF";
function CreateParameters() 
    strategy.parameters:addInteger("N", "Number of periods", "", 10);
    strategy.parameters:addInteger("SINIR", "SINIR", "No description", 7500);
    strategy.parameters:addDouble("M", "Multiplier", "", 1.5);
end

local indi;
function CreateEntryIndicators(source)
    local profile = core.indicators:findIndicator("SUPERTREND BANDSRF");
    assert(profile ~= nil, "Please, download and install " .. "SuperTrend BANDSRF" .. ".LUA indicator");
    indi = core.indicators:create("SUPERTREND BANDSRF", source, instance.parameters.N, instance.parameters.SINIR, instance.parameters.M);
end

function UpdateIndicators()
    indi:update(core.UpdateLast);
end

function IsEntryLong(source, period)
    if not indi.DN:hasData(period - 1) then
        return;
    end
    return core.crossesOver(source.close, indi.DN, period);
end
function IsEntryShort(source, period)
    if not indi.UP:hasData(period - 1) then
        return;
    end
    return core.crossesUnder(source.close, indi.UP, period);
end
function IsExitLong(source, period)
    if not indi.UP:hasData(period - 1) then
        return;
    end
    return core.crossesUnder(source.close, indi.UP, period);
end
function IsExitShort(source, period)
    if not indi.DN:hasData(period - 1) then
        return;
    end
    return core.crossesOver(source.close, indi.DN, period);
end
-- END OF USER DEFINED SECTION

function Init()
    strategy:name(STRATEGY_NAME);
    strategy:description("");
    strategy:type(core.Both);
    strategy:setTag("NonOptimizableParameters", "StartTime,StopTime,ToTime,signaler_ToTime,signaler_show_alert,signaler_play_soundsignaler_sound_file,signaler_recurrent_sound,signaler_send_email,signaler_email,signaler_show_popup,signaler_debug_alert,use_advanced_alert,advanced_alert_key");
    strategy.parameters:addBoolean("type", "Price Type", "", true);
    strategy.parameters:setFlag("type", core.FLAG_BIDASK);
    strategy.parameters:addString("timeframe", "Timeframe", "", "m1");
    strategy.parameters:setFlag("timeframe", core.FLAG_PERIODS);
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000);
    strategy.parameters:addBoolean("close_on_opposite", "Close on opposite", "", true);
    strategy.parameters:addString("custom_id", "Custom ID", "", STRATEGY_NAME);
    CreateParameters();
end

local MAIN_SOURCE_ID = 1;
local main_source;
local base_size, offer_id, Account, Amount, AllowTrade, close_on_opposite, custom_id;
function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.bid:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    AllowTrade = instance.parameters.AllowTrade;
    Account = instance.parameters.Account;
    Amount = instance.parameters.Amount;
    close_on_opposite = instance.parameters.close_on_opposite;
    custom_id = instance.parameters.custom_id;
    main_source = ExtSubscribe(MAIN_SOURCE_ID, nil, instance.parameters.timeframe, instance.parameters.type, "bar")
    CreateEntryIndicators(main_source);
    base_size = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);
    offer_id = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
end

function ExtUpdate(id, source, period)
    UpdateIndicators();
    if IsEntryLong(main_source, period) then
        if close_on_opposite then
            CloseTrades("S");
        end
        OpenTrade("B");
    end
    if IsEntryShort(main_source, period) then
        if close_on_opposite then
            CloseTrades("B");
        end
        OpenTrade("S");
    end
    if IsExitLong(main_source, period) then
        CloseTrades("B");
    end
    if IsExitShort(source, period) then
        CloseTrades("S");
    end
end

function CloseTrades(side)
    local enum = core.host:findTable("trades"):enumerator();
    local row = enum:next();
    while row ~= nil do
        if row.BS == side
            and row.Instrument == main_source:instrument() 
            and (row.QTXT == custom_id or custom_id == "")
        then
            CloseTrade(row);
        end
        row = enum:next();
    end
end

function ExtAsyncOperationFinished(cookie, success, message, message1, message2)
end

function OpenTrade(side)
    local valuemap = core.valuemap();
    valuemap.OrderType = "OM";
    valuemap.OfferID = offer_id;
    valuemap.AcctID = Account;
    valuemap.Quantity = Amount * base_size;
    valuemap.BuySell = side;
    valuemap.CustomID = custom_id;
    local success, msg = terminal:execute(3, valuemap);
end

function CloseTrade(trade)
    local valuemap = core.valuemap();
    valuemap.BuySell = trade.BS == "B" and "S" or "B";
    valuemap.OrderType = "CM";
    valuemap.OfferID = trade.OfferID;
    valuemap.AcctID = trade.AccountID;
    valuemap.TradeID = trade.TradeID;
    valuemap.Quantity = trade.Lot;
    local success, msg = terminal:execute(2, valuemap);
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");