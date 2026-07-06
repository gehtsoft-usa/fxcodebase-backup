-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=68465

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

function Init()
    indicator:name("Closed trades indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addString("CustomID", "Custom ID", "", "Martingale");
end

local CustomID, db;

function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end;

    require("storagedb");
    CustomID = source:instrument() .. "_" .. source:barSize()  .. "_Martingale_" .. instance.parameters.CustomID;
    db = storagedb.get_db(CustomID);
end

function PopLast(data)
    local last = nil;
    local lastIdx;
    for i, val in pairs(data) do
        if val.CloseTime ~= nil and (last == nil or last.CloseTime < val.CloseTime) then
            last = val;
            lastIdx = i;
        end
    end
    if lastIdx ~= nil then
        data[lastIdx] = nil;
    end
    return last;
end

function ReadValue(json, position)
    local whaitFor = "";
    local start = position;
    while (position < json:len() + 1) do
        local ch = string.sub(json, position, position);
        position = position + 1;
        if ch == "\"" then
            start = position - 1;
            whaitFor = ch;
            break;
        elseif ch == "{" then
            start = position - 1;
            whaitFor = "}";
            break;
        elseif ch == "," or ch == "}" then
            return string.sub(json, start, position - 2), position - 1;
        end
    end
    while (position < json:len() + 1) do
        local ch = string.sub(json, position, position);
        position = position + 1;
        if ch == whaitFor then
            return string.sub(json, start, position - 1), position;
        end
    end
    return "", position;
end

function JsonToObject(json)
    local position = 1;
    local result;
    local results;
    while (position < json:len() + 1) do
        local ch = string.sub(json, position, position);
        if ch == "{" then
            result = {};
            position = position + 1;
        elseif ch == "}" then
            if results ~= nil then
                position = position + 1;
                results[#results + 1] = result;
            else
                return result;
            end
        elseif ch == "," then
            position = position + 1;
        elseif ch == "[" then
            position = position + 1;
            results = {};
        elseif ch == "]" then
            return results;
        else
            if result == nil then
                return nil;
            end
            local name = string.match(json, '"([^"]+)":', position);
            local value, new_pos = ReadValue(json, position + name:len() + 3);
            position = new_pos;
            if value == "false" then
                result[name] = false;
            elseif value == "true" then
                result[name] = true;
            else
                if string.sub(value, 1, 1) == "\"" then
                    result[name] = value;
                    value:sub(2, value:len() - 1);
                elseif string.sub(value, 1, 1) == "{" then
                    result[name] = JsonToObject(value);
                else
                    result[name] = tonumber(value);
                end
            end
        end
    end
    return nil;
end

function CountFailedTrades()
    local json = db:get("closed_trades", "");
    local unsortedData = JsonToObject(json);
    if unsortedData == nil then
        return 0, 0;
    end
    local failed = 0;
    local profit = 0;
    local trade = PopLast(unsortedData);
    while (trade ~= nil) do
        if (trade.PL < 0 and profit == 0) then
            failed = failed + 1;
            trade = PopLast(unsortedData);
        elseif trade.PL >= 0 and failed == 0 then
            profit = profit + 1;
            trade = PopLast(unsortedData);
        else
            break;
        end
    end
    return failed, profit;
end

function Update(period, mode)
    local failed, profit = CountFailedTrades();
    if failed ~= 0 then
        core.host:execute("setStatus", "Loss trades: " .. failed);
    elseif profit ~= 0 then
        core.host:execute("setStatus", "Profit trades: " .. profit);
    end
end