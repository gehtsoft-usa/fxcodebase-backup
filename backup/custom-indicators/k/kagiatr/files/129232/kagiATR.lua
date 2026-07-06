-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69020

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
    indicator:name("Kagi");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.View);

    indicator.parameters:addGroup("Price");
    indicator.parameters:addString("instrument", "Instrument", "", "EUR/USD");
    indicator.parameters:setFlag("instrument", core.FLAG_INSTRUMENTS);
    indicator.parameters:addString("frame", "Timeframe", "", "H1");
    indicator.parameters:setFlag("frame", core.FLAG_BARPERIODS);
    indicator.parameters:addBoolean("type", "Price type", "", true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);
    indicator.parameters:addInteger("atr_period", "ATR period", "", 100, 1, 1000);

    indicator.parameters:addGroup("Range");
    indicator.parameters:addDate("from", "From", "", -1000);
    indicator.parameters:addDate("to", "To", "", 0);
    indicator.parameters:setFlag("to", core.FLAG_DATE_OR_NULL);

    indicator.parameters:addGroup("Styling");
    indicator.parameters:addColor("up_color", "Up color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("up_width", "Up width", "", 3, 1, 5);
    indicator.parameters:addColor("dn_color", "Down color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("dn_width", "Down width", "", 1, 1, 5);
end

local loading;
local instrument;
local frame;
local history;
local open, close;
local offer;
local offset;
local init;
local up_color, up_width, dn_color, dn_width;
local atr;

-- initializes the instance of the indicator
function Prepare(onlyName)
    instrument = instance.parameters.instrument;
    frame = instance.parameters.frame;
    up_color = instance.parameters.up_color;
    up_width = instance.parameters.up_width;
    dn_color = instance.parameters.dn_color;
    dn_width = instance.parameters.dn_width;
    atr_period = instance.parameters.atr_period;

    local name = profile:id() .. "(" .. instrument .. "." .. frame .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end
    
    instance:ownerDrawn(true);

    -- check whether the instrument is available
    local offers = core.host:findTable("offers");
    local enum = offers:enumerator();
    local row;

    row = enum:next();
    while row ~= nil do
        if row.Instrument == instrument then
            break;
        end
        row = enum:next();
    end

    assert(row ~= nil, "Instrument not found");

    offer = row.OfferID;

    instance:initView(instrument, row.Digits, row.PointSize, false, instance.parameters.to == 0);
    init = false;

    loading = true;
    history = core.host:execute("getHistory", 1000, instrument, frame, instance.parameters.from, instance.parameters.to, instance.parameters.type);
    atr = core.indicators:create("ATR", history, atr_period);
    if instance.parameters.to == 0 then
        core.host:execute("subscribeTradeEvents", 2000, "offers");
    end
    core.host:execute("setStatus", "Loading...");

    open = instance:addStream("open", core.Dot, name .. ".open", "open", up_color, 0, 0);
    close = instance:addStream("close", core.Dot, name .. ".close", "close", up_color, 0, 0);
    open:setVisible(false);
    close:setVisible(false); 
end

function Update(period, mode)
    -- shall never be called, ignore the call
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    atr:update(core.UpdateLast);
    if cookie == 1000 then
        if success then
            handleHistory();
            core.host:execute("setStatus", "");
        else
            core.host:trace("The indicator could not get the history");        
        end
    elseif cookie == 2000 then
        if message == offer then
            handleUpdate();
        end
    end
end

function calcValue(current, i)
    local source = history.close;
    if close[current] > open[current] then
        if source[i] > close[current] then
            close[current] = source[i];
        end
        if source[i] < close[current] - atr.DATA[i] then
            current = current + 1;
            instance:addViewBar(source:date(i));
            open[current] = close[current - 1];
            close[current] = source[i];
        end
    end
    
    if close[current] < open[current] then
        if source[i] < close[current] then
            close[current] = source[i];
        end
        if source[i] > close[current] + atr.DATA[i] then
            current = current + 1;
            instance:addViewBar(source:date(i));
            open[current] = close[current - 1];
            close[current] = source[i];
        end
    end
    return current;
end

function handleHistory()
    local s = history:size() - 1;
    local i;
    local current = open:size() - 1;
    local source = history.close;
    instance:addViewBar(source:date(0));
    open[current + 1] = source[0];

    for i = 1, s, 1 do        
        if current == -1 then
            if source[i] > open[current + 1] + atr.DATA[i] then
                current = current + 1;
                close[current] = source[i];
            end
            if source[i] < open[current] - atr.DATA[i] then
                current = current + 1;
                close[current] = source[i];
            end
        else 
            current = calcValue(current, i);
        end 
    end
    loading = false;
end

function handleUpdate()
    if not loading and history:size() > 0 then
        calcValue(open:size() - 1, history:size() - 1);
    end 
end

local UP_LINE_STYLE_ID = 1;
local DN_LINE_STYLE_ID = 2;

function isSwitchToUp(index)
    return index > 0 and open:hasData(index - 1) and open[index - 1] < close[index];
end

function isSwitchToDown(index)
    return index > 0 and open:hasData(index - 1) and open[index - 1] > close[index];
end

function drawSection(context, current_color, open_price, close_price, x, x1, prevx, connectWithLastBar)
    m1, p1 = context:pointOfPrice(open_price);
    m2, p2 = context:pointOfPrice(close_price);
    
    context:drawLine(current_color, x, p1, x, p2);
    
    if connectWithLastBar then
        if prevx == nil then
            context:drawLine(current_color, 2 * x1 - x, p1, x, p1);
        else
            context:drawLine(current_color, prevx, p1, x, p1);
        end
    end
end

function gerDirectionBefor(index)
    for i = index, 0, -1 do
        if open[i] < close[i] then
            if isSwitchToUp(i) then
                return UP_LINE_STYLE_ID;
            end
        else
            if isSwitchToDown(i) then
                return DN_LINE_STYLE_ID;
            end
        end
    end
    
    return UP_LINE_STYLE_ID;
end

function Draw(stage, context)
    if stage == 0 then
        if not init then
            context:createPen(UP_LINE_STYLE_ID, context.SOLID, up_width, up_color);
            context:createPen(DN_LINE_STYLE_ID, context.SOLID, dn_width, dn_color);
            init = true;
        end
        
        local m1, p1;
        local m2, p2;
        local prevx;
        
        local firstBar = context:firstBar();
        local connectWithLastBar;
        local current_color = gerDirectionBefor(firstBar);
    
        context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
        context:startEnumeration();
        while true do
            index, x, x1, x2, c1, c2 = context:nextBar();
            if index == -1 or index == nil then
                break;
            end
            if index ~= firstBar then
                connectWithLastBar = true;
            else
                connectWithLastBar = false;
            end
            
            local open_price = open[index];
            local close_price = close[index];
            if open_price < close_price then
                if current_color ~= UP_LINE_STYLE_ID and isSwitchToUp(index) then
                    drawSection(context, current_color, open_price, open[index - 1], x, x1, prevx, connectWithLastBar);
                    current_color = UP_LINE_STYLE_ID;
                    open_price = open[index - 1];
                    connectWithLastBar = false;
                end
            else
                if current_color ~= DN_LINE_STYLE_ID and isSwitchToDown(index) then
                    drawSection(context, current_color, open_price, open[index - 1], x, x1, prevx, connectWithLastBar);
                    current_color = DN_LINE_STYLE_ID;
                    open_price = open[index - 1];
                    connectWithLastBar = false;
                end
            end
            drawSection(context, current_color, open_price, close_price, x, x1, prevx, connectWithLastBar);
            prevx = x;
        end
        context:resetClipRectangle();
    end
end

function ReleaseInstance()
    if instance.parameters.to == 0 then
        core.host:execute("unsubscribeTradeEvents", "offers");
    end
end