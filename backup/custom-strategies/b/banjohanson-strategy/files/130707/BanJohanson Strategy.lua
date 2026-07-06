-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=31&t=69313

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
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
local STRATEGY_NAME = "Move Strategy";
function CreateParameters() 
    strategy.parameters:addInteger("min_move", "Min move, pips", "", 2);
    strategy.parameters:addInteger("max_move", "Max move, pips", "", 10);
end

local min_move, max_move
function CreateEntryIndicators(source)
    min_move = instance.parameters.min_move;
    max_move = instance.parameters.max_move;
end

function IsEntryLong(source, period)
    local move = (source.close[period - 1] - source.open[period - 1]) / source:pipSize();
    return source.open[period] > source.close[period]
        and move >= min_move and move <= max_move;
end
function IsEntryShort(source, period)
    local move = (source.open[period - 1] - source.close[period - 1]) / source:pipSize();
    return source.open[period] < source.close[period]
        and move >= min_move and move <= max_move;
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
    strategy.parameters:addString("custom_id", "Custom ID", "", STRATEGY_NAME);
    CreateParameters();
end

local MAIN_SOURCE_ID = 1;
local main_source;
local base_size, offer_id, Account, Amount, AllowTrade, custom_id;
function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.bid:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    AllowTrade = instance.parameters.AllowTrade;
    Account = instance.parameters.Account;
    Amount = instance.parameters.Amount;
    custom_id = instance.parameters.custom_id;
    main_source = ExtSubscribe(MAIN_SOURCE_ID, nil, instance.parameters.timeframe, instance.parameters.type, "bar")
    CreateEntryIndicators(main_source);
    base_size = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);
    offer_id = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
end

local last_serial;

function ExtUpdate(id, source, period)
    if last_serial == source:serial(period) then
        return;
    end
    last_serial = source:serial(period);
    local enum = core.host:findTable("orders"):enumerator();
    local row = enum:next();
    while row ~= nil do
        if (row.Type == "SE" or row.Type == "LE")
            and row.Instrument == main_source:instrument() 
            and (row.QTXT == custom_id or custom_id == "")
        then
            local valuemap = core.valuemap();
            valuemap.Command = "DeleteOrder";
            valuemap.OrderID = row.OrderID;
            local success, msg = terminal:execute(4, valuemap);
        end
        row = enum:next();
    end
    if IsEntryLong(main_source, period) then
        OpenTrade("B", main_source.open[period] + 3 * source:pipSize(), main_source.close[period] - 3 * source:pipSize());
    end
    if IsEntryShort(main_source, period) then
        OpenTrade("S", main_source.open[period] - 3 * source:pipSize(), main_source.close[period] + 3 * source:pipSize());
    end
end

function ExtAsyncOperationFinished(cookie, success, message, message1, message2)
end

function OpenTrade(side, rate, stop)
    local valuemap = core.valuemap();
    valuemap.OrderType = "SE";
    valuemap.Rate = rate;
    valuemap.OfferID = offer_id;
    valuemap.AcctID = Account;
    valuemap.Quantity = Amount * base_size;
    valuemap.RateStop = stop;
    valuemap.RateLimit = rate - (stop - rate) * 2;
    valuemap.BuySell = side;
    valuemap.CustomID = custom_id;
    local success, msg = terminal:execute(3, valuemap);
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");