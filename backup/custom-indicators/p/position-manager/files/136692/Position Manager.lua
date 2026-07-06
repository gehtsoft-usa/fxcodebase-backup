-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70270
--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                           mario.jemic@gmail.com  |
--|                          https://AppliedMachineLearning.systems  |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                                  Patreon: https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Position Manager");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addString("Account", "Account to trade on", "", "")
    indicator.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    indicator.parameters:addDouble("risk", "Risk %age of Equity", "", 1);
    indicator.parameters:addString("order_type", "Entry Type", "", "instant");
    indicator.parameters:addStringAlternative("order_type", "Instant", "", "instant");
    indicator.parameters:addStringAlternative("order_type", "Pending", "", "pending");
    indicator.parameters:addDouble("entry_rate", "Entry Order Rate", "", 0)
    indicator.parameters:setFlag("entry_rate", core.FLAG_PRICE)
    indicator.parameters:addString("side", "Side", "", "B");
    indicator.parameters:addStringAlternative("side", "Buy", "", "B");
    indicator.parameters:addStringAlternative("side", "Sell", "", "S");

    indicator.parameters:addString("stop_type", "Stop Type", "", "fixed");
    indicator.parameters:addStringAlternative("stop_type", "Fixed, pips", "", "fixed");
    indicator.parameters:addStringAlternative("stop_type", "ATR", "", "atr");
    indicator.parameters:addInteger("stop_value", "Stop Value", "Or ATR Peroid", 10);
    indicator.parameters:addDouble("stop_mult", "Stop ATR Multiplier", "", 1.0);

    indicator.parameters:addString("limit_type", "Limit Type", "", "fixed");
    indicator.parameters:addStringAlternative("limit_type", "Fixed, pips", "", "fixed");
    indicator.parameters:addStringAlternative("limit_type", "ATR", "", "atr");
    indicator.parameters:addInteger("limit_value", "Limit Value", "Or ATR Peroid", 10);
    indicator.parameters:addDouble("limit_mult", "Limit ATR Multiplier", "", 1.0);

    indicator.parameters:addColor("main_color", "Main Line Color", "Color", core.colors().Blue);
    indicator.parameters:addInteger("main_width", "Main Line Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("main_style", "Main Line Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("main_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("stop_color", "Stop Line Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("stop_width", "Stop Line Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("stop_style", "Stop Line Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("stop_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("limit_color", "Limit Line Color", "Color", core.colors().Green);
    indicator.parameters:addInteger("limit_width", "Limit Line Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("limit_style", "Limit Line Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("limit_style", core.FLAG_LINE_STYLE);
end
local MOVE_STOP = 1;
local MOVE_LIMIT = 2;
local MOVE_ENTRY = 3;
local EXECUTE = 4;

local source, equity, risk, order_type, entry_rate, stop_type, stop_value, stop_mult, limit_type, limit_value, limit_mult, side;
local limit_atr, stop_atr, ask, bid, stop_override, limit_override;
function Prepare(nameOnly)
    source = instance.source;
    equity = instance.parameters.equity;
    risk = instance.parameters.risk;
    entry_rate = instance.parameters.entry_rate;
    order_type = instance.parameters.order_type;
    stop_type = instance.parameters.stop_type;
    stop_value = instance.parameters.stop_value;
    stop_mult = instance.parameters.stop_mult;
    limit_type = instance.parameters.limit_type;
    limit_value = instance.parameters.limit_value;
    limit_mult = instance.parameters.limit_mult;
    side = instance.parameters.side;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    instance:ownerDrawn(true);
    if stop_type == "atr" then
        stop_atr = core.indicators:create("ATR", source, stop_value);
    end
    if limit_type == "atr" then
        limit_atr = core.indicators:create("ATR", source, limit_value);
    end
    ask = core.host:execute("getAskPrice");
    bid = core.host:execute("getBidPrice");
    core.host:execute("addCommand", MOVE_STOP, "Move stop", "Move stop")
    core.host:execute("addCommand", MOVE_LIMIT, "Move limit", "Move limit")
    core.host:execute("addCommand", MOVE_ENTRY, "Move entry rate", "Move entry rate")
    core.host:execute("addCommand", EXECUTE, "Execute", "Execute")
end

local lot_size, open_price, stop, limit, Offer;

local init = false;
local main_pen = 1;
local stop_pen = 2;
local limit_pen = 3;
local FONT_ID = 4;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        context:createPen(main_pen, context:convertPenStyle(instance.parameters.main_style), instance.parameters.main_width, instance.parameters.main_color);
        context:createPen(stop_pen, context:convertPenStyle(instance.parameters.stop_style), instance.parameters.stop_width, instance.parameters.stop_color);
        context:createPen(limit_pen, context:convertPenStyle(instance.parameters.limit_style), instance.parameters.limit_width, instance.parameters.limit_color);
        context:createFont(FONT_ID, "Arial", 0, context:pointsToPixels(10), context.LEFT);
        init = true;
    end
    open_price = entry_rate;
    if order_type == "instant" then
        if side == "B" then
            open_price = ask[NOW];
        else
            open_price = bid[NOW];
        end
    end
    if stop_type == "atr" then
        if side == "B" then
            stop = open_price - stop_atr.DATA[NOW] * stop_mult;
        else
            stop = open_price + stop_atr.DATA[NOW] * stop_mult;
        end
    else
        if side == "B" then
            stop = open_price - stop_value * source:pipSize();
        else
            stop = open_price + stop_value * source:pipSize();
        end
    end
    if stop_override ~= nil then
        stop = stop_override;
    end
    if limit_type == "atr" then
        if side == "B" then
            limit = open_price + limit_atr.DATA[NOW] * limit_mult;
        else
            limit = open_price - limit_atr.DATA[NOW] * limit_mult;
        end
    else
        if side == "B" then
            limit = open_price + limit_value * source:pipSize();
        else
            limit = open_price - limit_value * source:pipSize();
        end
    end
    if limit_override ~= nil then
        limit = limit_override;
    end
    local visible, y = context:pointOfPrice(open_price);

    Offer = core.host:findTable("offers"):find("Instrument", source:instrument());
    local equity = core.host:findTable("accounts"):find("AccountID", instance.parameters.Account).Equity;
    local affordable_loss = equity * risk / 100.0;
    local stopVal = math.abs(stop - open_price) / Offer.PointSize;
    local possible_loss = Offer.PipCost * stopVal;
    local bus = core.host:execute("getTradingProperty", "baseUnitSize", source:instrument(), instance.parameters.Account);
    lot_size = math.floor(affordable_loss / possible_loss) * bus;

    if visible then
        context:drawLine(main_pen, context:left(), y, context:right(), y);
        local label = "Lot size: " .. lot_size;
        local W, H = context:measureText(FONT_ID, label, context.LEFT);
        context:drawText(FONT_ID, label, core.COLOR_LABEL, -1, context:right() - W, y - H, context:right(), y, context.LEFT);
    end
    
    visible, y = context:pointOfPrice(stop);
    if visible then
        context:drawLine(stop_pen, context:left(), y, context:right(), y);
    end
    visible, y = context:pointOfPrice(limit);
    if visible then
        context:drawLine(limit_pen, context:left(), y, context:right(), y);
    end
end

function Update(period, mode)
    if stop_atr ~= nil then
        stop_atr:update(mode);
    end
    if limit_atr ~= nil then
        limit_atr:update(mode);
    end
end

local pattern = "([^;]*);([^;]*)";

function Parse(message)
    local level, date;
    level, date = string.match(message, pattern, 0);
    
    if level == nil or date == nil then
        return nil, nil;
    end
    
    return tonumber(date),tonumber(level) ;
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == MOVE_STOP then
        local date, rate = Parse(message);
        stop_override = rate;
    elseif cookie == MOVE_LIMIT then
        local date, rate = Parse(message);
        limit_override = rate;
    elseif cookie == MOVE_ENTRY then
        local date, rate = Parse(message);
        entry_rate = rate;
    elseif cookie == EXECUTE then
        if order_type == "instant" then
            local valuemap = core.valuemap();
            valuemap.OrderType = "OM";
            valuemap.OfferID = Offer.OfferID;
            valuemap.AcctID = instance.parameters.Account;
            valuemap.Quantity = lot_size;
            valuemap.BuySell = side;
            valuemap.RateStop = stop;
            valuemap.RateLimit = limit;
            local success, msg = terminal:execute(200, valuemap);
            if not success then
                core.host:trace(tostring(msg));
            end
        else
            local valuemap = core.valuemap();
            valuemap.OfferID = Offer.OfferID;
            valuemap.AcctID = instance.parameters.Account;
            valuemap.Quantity = lot_size;
            valuemap.BuySell = side;
            valuemap.RateStop = stop;
            valuemap.RateLimit = limit;
            if side == "B" then 
                valuemap.OrderType = Offer.Ask > open_price and "LE" or "SE"; 
            else 
                valuemap.OrderType = Offer.Bid > open_price and "SE" or "LE"; 
            end 
            valuemap.Rate = open_price;
            success, msg = terminal:execute(200, valuemap)
            if not success then
                core.host:trace(tostring(msg));
            end
        end
    else
        if not success then
            core.host:trace(tostring(msg));
        end
    end
end

