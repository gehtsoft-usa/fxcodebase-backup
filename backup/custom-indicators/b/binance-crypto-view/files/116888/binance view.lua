-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65609

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
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

function Init()
    indicator:name("Binance View");
    indicator:description("Shows the market indexes in day, week or month resolution. The data is loaded from binance");
    indicator:requiredSource(core.Bar);
    indicator:type(core.View);

    indicator.parameters:addString("IDX", "Choose the Index", "", "LTCBTC");
    indicator.parameters:addString("TF", "Time frame", "", "1m");
    indicator.parameters:addStringAlternative("TF", "1 minute", "", "1m");
    indicator.parameters:addStringAlternative("TF", "3 minutes", "", "3m");
    indicator.parameters:addStringAlternative("TF", "5 minutes", "", "5m");
    indicator.parameters:addStringAlternative("TF", "15 minutes", "", "15m");
    indicator.parameters:addStringAlternative("TF", "30 minutes", "", "30m");
    indicator.parameters:addStringAlternative("TF", "1 hour", "", "1h");
    indicator.parameters:addStringAlternative("TF", "2 hours", "", "2h");
    indicator.parameters:addStringAlternative("TF", "4 hours", "", "4h");
    indicator.parameters:addStringAlternative("TF", "6 hours", "", "6h");
    indicator.parameters:addStringAlternative("TF", "8 hours", "", "8h");
    indicator.parameters:addStringAlternative("TF", "12 hours", "", "12h");
    indicator.parameters:addStringAlternative("TF", "1 day", "", "1d");
    indicator.parameters:addStringAlternative("TF", "3 days", "", "3d");
    indicator.parameters:addStringAlternative("TF", "1 week", "", "1w");
    indicator.parameters:addStringAlternative("TF", "1 month", "", "1M");

    indicator.parameters:addInteger("count", "Number of bars", "", 500, 1, 500);
    indicator.parameters:addDate("TO", "Date to", "", 0);
    indicator.parameters:setFlag("TO", core.FLAG_DATE);
end

local O, H, L, C, V;

-- initializes the instance of the indicator
function Prepare(onlyName)
    local IDX = instance.parameters.IDX;
    assert(IDX ~= "", "You must enter the instrument in case custom instrument is chosen. Try, for example, LTCBTC");
    local TF = instance.parameters.TF;
    local name = profile:id() .. "(" .. IDX .. "@binance, " .. TF .. ")";
    instance:name(name);
    if onlyname then
        return ;
    end

    instance:initView(IDX, 8, 0.00000001, true, false);

    O = instance:addStream("O", core.Line, name .. ".O", "O", core.rgb(255, 0, 0), 0);
    H = instance:addStream("H", core.Line, name .. ".H", "H", core.rgb(255, 0, 0), 0);
    L = instance:addStream("L", core.Line, name .. ".L", "L", core.rgb(255, 0, 0), 0);
    C = instance:addStream("C", core.Line, name .. ".C", "C", core.rgb(255, 0, 0), 0);
    V = instance:addStream("V", core.Line, name .. ".V", "V", core.rgb(255, 0, 0), 0);
    instance:createCandleGroup(IDX, IDX, O, H, L, C, V, TF);
    core.host:execute("setTimer", 1, 1);
    local res =  false;
    while res == false do
        res = StartLoading(IDX, TF, instance.parameters.count, instance.parameters.TO);
    end
end

function Update(period)
end

local loadingRequest;
local loading, loadError;
local token = {};
local pattern = "%[(%d+),\"([^\"]+)\",\"([^\"]+)\",\"([^\"]+)\",\"([^\"]+)\",\"([^\"]+)\",(%d+),\"([^\"]+)\",(%d+),\"([^\"]+)\",\"([^\"]+)\",\"([^\"]+)\"]";

function StartLoading(index, timeframe, count, _to)
    local to = core.dateToTable(_to);
    local convertedTo = os.time({year = to.year, month = to.month, day = to.day, hour = 0, min = 0, sec = 0});
    local url = "https://api.binance.com/api/v1/klines?symbol=" .. index .. "&interval=" .. timeframe
        .. "&limit=" .. count .. "&endTime=" .. convertedTo * 1000;
        core.host:trace(url);
    loadingRequest = http_lua.createRequest();

    loadingRequest:start(url);
    loading = true;
    core.host:execute("setStatus", "loading...");
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
        if loading then
            if not(loadingRequest:loading()) then
                loading = false;
                if loadingRequest:httpStatus() == 200 then
                    local body = loadingRequest:response();
                    local pos = 0;
                    while true do
                        local open_time, open, high, low, close, volume, close_time, quote_asset_volume,
                            number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume
                            = string.match(body, pattern, pos);
                        if open_time == nil then
                            break;
                        end
                        local date = os.date('!*t', open_time / 1000);
                        local bar_date = core.datetime(date.year, date.month, date.day, date.hour, date.min, date.sec);
                        pos = string.find(body, ']', pos) + 1;
                        instance:addViewBar(bar_date);
                        local s = O:size() - 1;
                        O[s] = open;
                        H[s] = high;
                        L[s] = low;
                        C[s] = close;
                        V[s] = volume;
                    end

                    errorLoad = false;
                    core.host:execute("setStatus", "");
                    return core.ASYNC_REDRAW;
                else
                    local body = loadingRequest:response();
                    errorLoad = true;
                    core.host:execute("setStatus", "load failed");
                end
            end
        end
    end
    return 0;
end

function ReleaseInstance()
    if loading then
        while (loadingRequest:loading()) do
        end
    end
    core.host:execute("killTimer", 1);
end

require("http_lua");