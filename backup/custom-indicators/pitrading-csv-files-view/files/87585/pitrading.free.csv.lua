-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=58426
-- Id: 9568

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
    indicator:name("Displays PITRADING historical data");
    indicator:description("Shows the csv files downloaded from http://www.pitrading.com/free_market_data.htm (unzip files before using!)");
    indicator:requiredSource(core.Bar);
    indicator:type(core.View);

    indicator.parameters:addFile("FILE", "File to display", "", "");
    indicator.parameters:addDate("FROM", "Date from", "", 0);
    indicator.parameters:setFlag("FROM", core.FLAG_DATE_OR_NULL);
    indicator.parameters:addDate("TO", "Date to", "", 0);
    indicator.parameters:setFlag("TO", core.FLAG_DATE_OR_NULL);
end

local O, H, L, C, V;
local pattern_line = "([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),[^,]*";
local pattern_date = "(%d%d)/(%d%d)/(%d%d%d%d)";
local timerId;
local file = nil;

-- initializes the instance of the indicator
function Prepare(onlyName)
    local name = profile:id() .. "(" .. instance.parameters.FILE ..  ")";

    instance:name(name);
    if onlyname then
        io.close(file);
        file = nil;
        return ;
    end
    file = io.open(instance.parameters.FILE, "r");
    assert (file ~= nil, "The file must be chosen and the file must exists");

    instance:initView(instance.parameters.FILE, 2, 0.01, true, false);

    O = instance:addStream("O", core.Line, name .. ".O", "O", core.rgb(255, 0, 0), 0);
    H = instance:addStream("H", core.Line, name .. ".H", "H", core.rgb(255, 0, 0), 0);
    L = instance:addStream("L", core.Line, name .. ".L", "L", core.rgb(255, 0, 0), 0);
    C = instance:addStream("C", core.Line, name .. ".C", "C", core.rgb(255, 0, 0), 0);
    V = instance:addStream("V", core.Line, name .. ".V", "V", core.rgb(255, 0, 0), 0);
    instance:createCandleGroup(instance.parameters.FILE, "CANDLE", O, H, L, C, V, "d");

    timerId = core.host:execute("setTimer", 1, 1);
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 and file ~= nil then
        local from, to;
        from = instance.parameters.FROM;
        to = instance.parameters.TO;
        local date, open, high, low, close, volume, t, s, lastdate, line;
        local year, month, day;
        lastdate = nil;
        t = {};
        t.hour = 0;
        t.min = 0;
        t.sec = 0;

        for line in file:lines() do
            date, open, high, low, close, volume = string.match(line, pattern_line, 0);
            if date ~= nil then
                month, day, year = string.match(date, pattern_date);
                if month ~= nil then
                    t.month = tonumber(month);
                    t.day = tonumber(day);
                    t.year = tonumber(year);
                    date = core.tableToDate(t);
                    if (from < 1 or date > from) and (to < 1 or date <= to) then
                        if lastdate == nil or date > lastdate then
                            instance:addViewBar(date);
                            s = O:size() - 1;
                            O[s] = tonumber(open);
                            H[s] = tonumber(high);
                            L[s] = tonumber(low);
                            C[s] = tonumber(close);
                            V[s] = tonumber(volume);
                        end
                    end
                end
            end
        end
        io.close(file);
        file = nil;
        core.host:execute("killTimer", timerId);
    end
end

function ReleaseInstance()
    if file ~= nil then
        io.close(file);
        file = nil;
        core.host:execute("killTimer", timerId);
    end
end


