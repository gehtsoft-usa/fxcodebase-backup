-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=69268

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

function AddAverages(id, name, default)
    strategy.parameters:addString(id, name, "", default);
    strategy.parameters:addStringAlternative(id, "MVA", "", "MVA");
    strategy.parameters:addStringAlternative(id, "EMA", "", "EMA");
    strategy.parameters:addStringAlternative(id, "Wilder", "", "Wilder");
    strategy.parameters:addStringAlternative(id, "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative(id, "SineWMA", "", "SineWMA");
    strategy.parameters:addStringAlternative(id, "TriMA", "", "TriMA");
    strategy.parameters:addStringAlternative(id, "LSMA", "", "LSMA");
    strategy.parameters:addStringAlternative(id, "SMMA", "", "SMMA");
    strategy.parameters:addStringAlternative(id, "HMA", "", "HMA");
    strategy.parameters:addStringAlternative(id, "ZeroLagEMA", "", "ZeroLagEMA");
    strategy.parameters:addStringAlternative(id, "DEMA", "", "DEMA");
    strategy.parameters:addStringAlternative(id, "T3", "", "T3");
    strategy.parameters:addStringAlternative(id, "ITrend", "", "ITrend");
    strategy.parameters:addStringAlternative(id, "Median", "", "Median");
    strategy.parameters:addStringAlternative(id, "GeoMean", "", "GeoMean");
    strategy.parameters:addStringAlternative(id, "REMA", "", "REMA");
    strategy.parameters:addStringAlternative(id, "ILRS", "", "ILRS");
    strategy.parameters:addStringAlternative(id, "IE/2", "", "IE/2");
    strategy.parameters:addStringAlternative(id, "TriMAgen", "", "TriMAgen");
    strategy.parameters:addStringAlternative(id, "JSmooth", "", "JSmooth");
    strategy.parameters:addStringAlternative(id, "KAMA", "", "KAMA");
    strategy.parameters:addStringAlternative(id, "ARSI", "", "ARSI");
    strategy.parameters:addStringAlternative(id, "VIDYA", "", "VIDYA");
    strategy.parameters:addStringAlternative(id, "HPF", "", "HPF");
    strategy.parameters:addStringAlternative(id, "VAMA", "", "VAMA");
end
function CreateAverages(period, method, source)
    if method == "MVA" or method == "EMA" or method == "ARSI"
       or method == "KAMA" or method == "LWMA" or method == "SMMA"
        or method == "VIDYA"
    then
        --assert(core.indicators:findIndicator(method) ~= nil, method .. " indicator must be installed");
        return core.indicators:create(method, source, period);
    end
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES indicator");
    return core.indicators:create("AVERAGES", source, method, period);
end

-- START OF USER DEFINED SECTION
local STRATEGY_NAME = "Strategy";
function CreateParameters() 
    --create your algorithm parameters here
    strategy.parameters:addInteger("bars_since_last_trade", "Min bars since last trade", "", 30)
    strategy.parameters:addInteger("fast_ma_period", "Fast MA Period", "", 30);
    AddAverages("fast_ma_method", "Fast MA Method", "MVA");
    strategy.parameters:addInteger("slow_period", "Slow MA Period", "", 100);
    AddAverages("slow_method", "Slow MA Method", "MVA");    
    strategy.parameters:addString("tf3", "Third timeframe", "", "m5");
    strategy.parameters:setFlag("tf3", core.FLAG_BARPERIODS);
    strategy.parameters:addInteger("third_ma_period", "Third MA Period", "", 10);
    AddAverages("third_ma_method", "Third MA Method", "MVA");
    strategy.parameters:addDouble("Max_Pips_Away_From_Cross", "Max pips away from cross", "", 10);
end

local ma1, ma2, ma3;
local custom_id;
function CreateEntryIndicators(source)
    ma1 = CreateAverages(instance.parameters.fast_ma_period, instance.parameters.fast_ma_method, source);
    ma2 = CreateAverages(instance.parameters.slow_ma_period, instance.parameters.slow_ma_method, source);
    local third_source = ExtSubscribe(2, nil, instance.parameters.tf3, instance.parameters.type, "bar");
    ma3 = CreateAverages(instance.parameters.third_ma_period, instance.parameters.third_ma_method, third_source);
end

function UpdateIndicators()
    ma1:update(core.UpdateLast);
    ma2:update(core.UpdateLast);
    ma3:update(core.UpdateLast);
end

function GetLastTradeIndex(source)
    local enum = core.host:findTable("trades"):enumerator();
    local row = enum:next();
    local last_trade;
    while row ~= nil do
        if row.QTXT == custom_id then
            if last_trade == nil or last_trade.Time < row.Time then
                last_trade = row;
            end
        end
        row = enum:next();
    end
    if last_trade == nil then
        return nil;
    end
    return core.findDate(source, last_trade.Time, false);
end

function IsEntryLong(source, period)
    if not ma1.DATA:hasData(period - 1) 
        or not ma2.DATA:hasData(period - 1) 
        or not ma3.DATA:hasData(NOW - 1) 
    then
        return;
    end
    local last_trade_index = GetLastTradeIndex(source);
    return core.crossesOver(ma1.DATA, ma2.DATA, period)
        and (ma2.DATA[period] - source.close[period]) / source:pipSize() <= instance.parameters.Max_Pips_Away_From_Cross
        and ma1.DATA[period] > source.close[period]
        and ma1.DATA[period] > ma3.DATA[NOW]
        and ma2.DATA[period] > ma3.DATA[NOW]
        and (last_trade_index == nil or period - last_trade_index >= instance.parameters.bars_since_last_trade);
end
function IsEntryShort(source, period)
    if not ma1.DATA:hasData(period - 1) 
        or not ma2.DATA:hasData(period - 1) 
        or not ma3.DATA:hasData(NOW - 1) 
    then
        return;
    end
    local last_trade_index = GetLastTradeIndex(source);
    return core.crossesUnder(ma1.DATA, ma2.DATA, period)
        and (source.close[period] - ma2.DATA[period]) / source:pipSize() <= instance.parameters.Max_Pips_Away_From_Cross
        and ma1.DATA[period] < source.close[period]
        and ma1.DATA[period] < ma3.DATA[NOW]
        and ma2.DATA[period] < ma3.DATA[NOW]
        and (last_trade_index == nil or period - last_trade_index >= instance.parameters.bars_since_last_trade);
end
function IsExitLong(source, period)
    return false;
end
function IsExitShort(source, period)
    return false;
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
local base_size, offer_id, Account, Amount, AllowTrade, close_on_opposite;
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