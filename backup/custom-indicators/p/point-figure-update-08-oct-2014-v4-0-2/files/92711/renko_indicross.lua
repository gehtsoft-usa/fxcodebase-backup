-- Id: 11141
-- More information about this indicator can be found at:
-- http://fxcodebase.com/

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
function createAverages(id, def_period)
    strategy.parameters:addString(id .. "_avg_Method", "Method (" .. id .. ")", "", "MVA");
    strategy.parameters:addStringAlternative(id .. "_avg_Method", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative(id .. "_avg_Method", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative(id .. "_avg_Method", "Wilder", "", "Wilder");
    strategy.parameters:addStringAlternative(id .. "_avg_Method", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative(id .. "_avg_Method", "SineWMA", "", "SineWMA");
    strategy.parameters:addStringAlternative(id .. "_avg_Method", "TriMA", "", "TriMA");
    strategy.parameters:addStringAlternative(id .. "_avg_Method", "LSMA", "", "LSMA");
    strategy.parameters:addStringAlternative(id .. "_avg_Method", "SMMA", "", "SMMA");
    strategy.parameters:addStringAlternative(id .. "_avg_Method", "HMA", "", "HMA");
    strategy.parameters:addStringAlternative(id .. "_avg_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    strategy.parameters:addStringAlternative(id .. "_avg_Method", "DEMA", "", "DEMA");
    strategy.parameters:addStringAlternative(id .. "_avg_Method", "T3", "", "T3");
    strategy.parameters:addStringAlternative(id .. "_avg_Method", "ITrend", "", "ITrend");
    strategy.parameters:addStringAlternative(id .. "_avg_Method", "Median", "", "Median");
    strategy.parameters:addStringAlternative(id .. "_avg_Method", "GeoMean", "", "GeoMean");
    strategy.parameters:addStringAlternative(id .. "_avg_Method", "REMA", "", "REMA");
    strategy.parameters:addStringAlternative(id .. "_avg_Method", "ILRS", "", "ILRS");
    strategy.parameters:addStringAlternative(id .. "_avg_Method", "IE/2", "", "IE/2");
    strategy.parameters:addStringAlternative(id .. "_avg_Method", "TriMAgen", "", "TriMAgen");
    strategy.parameters:addStringAlternative(id .. "_avg_Method", "JSmooth", "", "JSmooth");
    strategy.parameters:addStringAlternative(id .. "_avg_Method", "KAMA", "", "KAMA");
    strategy.parameters:addInteger(id .. "_avg_Period", "Period (" .. id .. ")", "", def_period);
end

function Init()
    strategy:name("Renko indi cross");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Generates buy/sell signals on indicators cross based on Renko");

    strategy.parameters:addGroup(resources:get("R_ParamGroup"));

    strategy.parameters:addGroup("Averages parameters");
    createAverages("fast", 7);
    createAverages("slow", 21);
    
    strategy.parameters:addInteger("renko_step", "Renko step", "", 50);

    strategy.parameters:addString("Type", resources:get("R_PriceType"), "", "Bid");
    strategy.parameters:addStringAlternative("Type", resources:get("R_Bid"), "", "Bid");
    strategy.parameters:addStringAlternative("Type", resources:get("R_Ask"), "", "Ask");
    strategy.parameters:addString("TF", resources:get("R_PeriodType"), "", "m15");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
   
    strategy.parameters:addGroup("Risk management");
    strategy.parameters:addString("amount_type", "Amount type", "", "risk");
    strategy.parameters:addStringAlternative("amount_type", "Amount in lots", "", "lots");
    strategy.parameters:addStringAlternative("amount_type", "% of risk", "", "risk");
    strategy.parameters:addInteger("amount_lots", "Trade size (in lots)", "", 1, 1, 10000);
    strategy.parameters:addInteger("amount_risk", "Trade size (% of risk)", "", 1, 1, 50);
    strategy.parameters:addBoolean("set_limit", "Set limit order", "", false);
    strategy.parameters:addDouble("limit", "Limit in pips", "If the value is 0, no limit order will be created.", 10, 0, 10000);
    strategy.parameters:addBoolean("set_stop", "Set stop order", "", false);
    strategy.parameters:addDouble("stop", "Stop in pips", "If the value is 0, no stop order will be created.", 10, 0, 10000);
    strategy.parameters:addBoolean("set_trailing", "Set trailing stop", "", false);
    strategy.parameters:addBoolean("use_dynamic_trailing", "Dynamic trailing mode", "", false);
    strategy.parameters:addInteger("trailing_stop", "Trailing stop (pips)",
        "If the value is 1, the dynamic trailing mode is used, i.e. the order rate is changed with every change of the market price. If the value is 0, the order is not trailing.",
        10, 0, 10000);
    strategy.parameters:addGroup("Trading");
    strategy.parameters:addString("Account", "Account", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addBoolean("CanTrade", "Allow Trading", "", false);
    strategy.parameters:setFlag("CanTrade", core.FLAG_ALLOW_TRADE);
    
    strategy.parameters:addGroup(resources:get("R_SignalGroup"));

    strategy.parameters:addBoolean("ShowAlert", resources:get("R_ShowAlert"), "", true);
    strategy.parameters:addBoolean("PlaySound", resources:get("R_PlaySound"), "", false);
    strategy.parameters:addFile("SoundFile", resources:get("R_SoundFile"), "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
end

local SoundFile;
local gSource = nil;        -- the source stream
local indi = nil;
local indi2 = nil;
local renko = nil;
local emr = nil;
local base_unit_size = nil;
local Account;

function Prepare()
    -- collect parameters
    ShowAlert = instance.parameters.ShowAlert;

    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), resources:get("R_SoundFileError"));

    Account = instance.parameters.Account;
    OfferId = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
    base_unit_size = core.host:execute("getTradingProperty", "minQuantity", instance.bid:instrument(), Account);
    emr = core.host:execute("getTradingProperty", "EMR", instance.bid:instrument(), Account);

    ExtSetupSignal(resources:get("R_Name") .. ":", ShowAlert);

    gSource = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "close");
    renko = core.indicators:create("RENKO_CANDLES", gSource, instance.bid:instrument(), instance.parameters.TF, instance.parameters.renko_step);

    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "AVERAGES" .. " indicator must be installed");
    indi = core.indicators:create("AVERAGES", renko.close, instance.parameters.fast_avg_Method, instance.parameters.fast_avg_Period);
    indi2 = core.indicators:create("AVERAGES", renko.close, instance.parameters.slow_avg_Method, instance.parameters.slow_avg_Period);
    
    local name = profile:id() .. "(" .. instance.bid:instrument()  .. "(" .. instance.parameters.TF  .. ")" .. ", " 
        .. instance.parameters.fast_avg_Method .. "-" .. instance.parameters.slow_avg_Method ..")";
    instance:name(name);
end

function isUpTrend(src)
    if src:size() < 2 then
        return false;
    end
    return src[NOW] > src[NOW - 1];
end

function isDownTrand(src)
    if src:size() < 2 then
        return false;
    end
    return src[NOW] < src[NOW - 1];
end

local lastBuySerial;
local lastSellSerial;

-- when tick source is updated
function ExtUpdate(id, source, period)
    -- update moving average
    indi:update(core.UpdateLast);
    indi2:update(core.UpdateLast);

    if (indi.DATA:hasData(NOW - 1) and indi2.DATA:hasData(NOW - 1)) then
        if core.crossesOver(indi.DATA, indi2.DATA, NOW) and isUpTrend(indi2.DATA) then
            if lastBuySerial ~= indi.DATA:serial(NOW) then
                exit("S");
                enter("B");
                lastBuySerial = indi.DATA:serial(NOW);
            end
            return;
        elseif core.crossesUnder(indi.DATA, indi2.DATA, NOW) and isDownTrand(indi2.DATA) then
            if lastSellSerial ~= indi.DATA:serial(NOW) then
                exit("B");
                enter("S");
                lastSellSerial = indi.DATA:serial(NOW);
            end
            return;
        end
    end
    
    if isUpTrend(indi2.DATA) then
        exit("S");
    elseif isDownTrand(indi2.DATA) then
        exit("B");
    end
end

function getAmount(stop)
    if instance.parameters.amount_type == "lots" or stop == nil then
        return instance.parameters.amount_lots * base_unit_size;
    else -- margin
        local balance = core.host:findTable("accounts"):find("AccountID", Account).Balance;
        local affordable_loss = balance * instance.parameters.amount_risk / 100.0;
        local possible_loss = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).PipCost * stop;
        return math.floor(affordable_loss / possible_loss) * base_unit_size;
    end
end

function enter(BuySell)
    local valuemap, success, msg;
    valuemap = core.valuemap();

    valuemap.OrderType = "OM";
    valuemap.OfferID = OfferId;
    valuemap.AcctID = Account;
    valuemap.BuySell = BuySell;
    valuemap.PegTypeStop = "M";
    
    if instance.parameters.set_limit then
        addPipLimitToOrder(valuemap, true, instance.parameters.limit);
    end
    local stop;
    if instance.parameters.set_stop then
        addPipStopToOrder(valuemap,
                          true,
                          instance.parameters.set_trailing,
                          instance.parameters.use_dynamic_trailing,
                          instance.parameters.trailing_stop,
                          instance.parameters.stop);
        stop = instance.parameters.stop;
    end
    valuemap.Quantity = getAmount(stop);

    success, msg = terminal:execute(101, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), gSource.close[NOW], "Open order failed" .. msg, gSource:date(NOW));
    end
end

-- exit from the specified direction
function exit(BuySell)
    local enum, row, valuemap, success, msg;

    -- check whether we have at least one trade on the specified account
    -- in the specified direction for the specified instrument
    local count = 0;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while count == 0 and row ~= nil do
        if row.AccountID == Account and
           row.OfferID == OfferId and
           row.BS == BuySell then
           count = count + 1;
        end
        row = enum:next();
    end

    if count > 0 then
        valuemap = core.valuemap();

        -- switch the direction since the order must be in oppsite direction
        if BuySell == "B" then
            BuySell = "S";
        else
            BuySell = "B";
        end
        valuemap.OrderType = "CM";
        valuemap.OfferID = OfferId;
        valuemap.AcctID = Account;
        valuemap.NetQtyFlag = "Y";
        valuemap.BuySell = BuySell;
        success, msg = terminal:execute(102, valuemap);

        if not(success) then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Close order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        end
    end
end

-- Attach Stop Orders to the Command
-- http://www.fxcodebase.com/documents/IndicoreSDK/web-content.html?key=TradingCommandsCreateOrder_A.html
function attachStop(valuemap, rateStop, trailStepStop)
    valuemap.RateStop = rateStop;
    valuemap.TrailStepStop = trailStepStop;
end
function attachPeggedStop(valuemap, pegTypeStop, pegPriceOffsetPipsStop, trailStepStop)
    valuemap.PegTypeStop = pegTypeStop;
    valuemap.PegPriceOffsetPipsStop = pegPriceOffsetPipsStop;
    valuemap.TrailStepStop = trailStepStop;
end
function addPipStopToOrder(order, is_buy, is_need_trailing, is_need_dynamic_trailing, trailing_stop, stop_pips)
    local trail_stop = nil;
    if is_need_trailing then
        if is_need_dynamic_trailing then
            trail_stop = 1;
        else
            trail_stop = trailing_stop;
        end
    end
    local stop;
    if is_buy then
        stop = -stop_pips;
    else
        stop = stop_pips;
    end
    attachPeggedStop(order, "O", stop, trail_stop);
end

-- Attach Limit Orders to the Command
-- http://www.fxcodebase.com/documents/IndicoreSDK/web-content.html?key=TradingCommandsCreateOrder_A.html
function attachLimit(valuemap, rateLimit)
    valuemap.RateLimit = rateLimit;
end
function attachPeggedLimit(valuemap, pegTypeLimit, pegPriceOffsetPipsLimit)
    valuemap.PegTypeLimit = pegTypeLimit;
    valuemap.PegPriceOffsetPipsLimit = pegPriceOffsetPipsLimit;    
end
function addPipLimitToOrder(order, is_buy, limit_pips)
    local limit;
    if is_buy then
        limit = limit_pips;
    else
        limit = -limit_pips;
    end
    attachPeggedLimit(order, "M", limit);
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
