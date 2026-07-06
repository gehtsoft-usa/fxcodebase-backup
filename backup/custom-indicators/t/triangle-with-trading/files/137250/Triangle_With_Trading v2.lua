-- Id: 19776
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67122

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

-- START OF CUSTOMIZATION SECTION
-- Number of positions to open with individual set of stop/limit parameters.
local PositionsCount = 1;

local INDICATOR_VERSION = "2";
-- END OF CUSTOMIZATION SECTION

local Modules = {};
local EntryActions = {};
local ExitActions = {};

-- START OF USER DEFINED SECTION
local lines_top = {};
local lines_bottom = {};
local executed_up = {};
local executed_down = {};
local pp;

function CreateCustomActions()
    local action1, isEntry1 = CreateAction(1);
    action1.IsPass = function (source, period) 
        for _, line in pairs(lines_top) do
            if executed_up[line.date1] ~= true and line:crossesOver(source.close, period) and pp.DATA[period] > source.close[period] then
                executed_up[line.date1] = true;
                return true;
            end
        end
        return false;
    end
    if isEntry1 then
        EntryActions[#EntryActions + 1] = action1;
    else
        ExitActions[#ExitActions + 1] = action1;
    end
    local action2, isEntry2 = CreateAction(2);
    action2.IsPass = function (source, period) 
        for _, line in pairs(lines_top) do
            if executed_up[line.date1] ~= true and line:crossesUnder(source.close, period) and pp.DATA[period] > source.close[period] then
                executed_up[line.date1] = true;
                return true;
            end
        end
        return false;
    end
    if isEntry2 then
        EntryActions[#EntryActions + 1] = action2;
    else
        ExitActions[#ExitActions + 1] = action2;
    end
    local action3, isEntry3 = CreateAction(3);
    action3.IsPass = function (source, period)
        for _, line in pairs(lines_bottom) do
            if executed_down[line.date1] ~= true and line:crossesOver(source.close, period) and pp.DATA[period] < source.close[period] then
                executed_down[line.date1] = true;
                return true;
            end
        end
        return false;
    end
    if isEntry3 then
        EntryActions[#EntryActions + 1] = action3;
    else
        ExitActions[#ExitActions + 1] = action3;
    end
    local action4, isEntry4 = CreateAction(4);
    action4.IsPass = function (source, period)
        for _, line in pairs(lines_bottom) do
            if executed_down[line.date1] ~= true and line:crossesUnder(source.close, period) and pp.DATA[period] < source.close[period] then
                executed_down[line.date1] = true;
                return true;
            end
        end
        return false;
    end
    if isEntry4 then
        EntryActions[#EntryActions + 1] = action4;
    else
        ExitActions[#ExitActions + 1] = action4;
    end
end

function Init()
    indicator:name("Triangle")
    indicator:description("Triangle")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
    indicator:setTag("Version", INDICATOR_VERSION)

    indicator.parameters:addString("k1", "Triangle", "Triangle  Y/N", "Yes")
    indicator.parameters:addStringAlternative("k1", "Yes", "Triangle Yes", "Yes")
    indicator.parameters:addStringAlternative("k1", "No", "Triangle No", "No")

    indicator.parameters:addString("k2", "Expanding Triangle", "Expanding Triangle  Y/N", "No")
    indicator.parameters:addStringAlternative("k2", "Yes", "Expanding Triangle Yes", "Yes")
    indicator.parameters:addStringAlternative("k2", "No", "Expanding Triangle No", "No")

    indicator.parameters:addString("k5", "Wedges", "Up Wedges  Y/N", "No")
    indicator.parameters:addStringAlternative("k5", "Yes", "Wedges  Yes", "Yes")
    indicator.parameters:addStringAlternative("k5", "No", "Wedges  No", "No")

    indicator.parameters:addString("k6", "Down Wedges", "Wedges  Y/N", "No")
    indicator.parameters:addStringAlternative("k6", "Yes", "Wedges  Yes", "Yes")
    indicator.parameters:addStringAlternative("k6", "No", "Wedges  No", "No")

    indicator.parameters:addInteger("x", "Max. Base / Side Ratio", "Max. Base / Side Ratio", 5)
    indicator.parameters:addInteger("y", "Max. Side / Side Ratio", "Max. Side / Side Ratio", 5)

    indicator.parameters:addInteger("frame", "Frame Size", "Frame Size", 50)
    indicator.parameters:addColor("top_color", "Color of Top", "Color of Top", core.rgb(0, 255, 0))
    indicator.parameters:addColor("bottom_color", "Color of Bottom", "Color of Bottom", core.rgb(0, 0, 255))
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)

    AddAction(1, "Up Line CrossOver");
    AddAction(2, "Up Line CrossUnder");
    AddAction(3, "Down Line CrossOver");
    AddAction(4, "Down Line CrossUnder");

    trading:Init(indicator.parameters, PositionsCount);
    indicator.parameters:addGroup("Alerts");
    signaler:Init(indicator.parameters);
end

function CreateAction(id)
    local actionType = instance.parameters:getString("Action" .. id);
    local action = {};
    if actionType == "NO" then
        action.Execute = DisabledAction;
    elseif actionType == "SELL" then
        action.Execute = GoShort;
    elseif actionType == "BUY" then
        action.Execute = GoLong;
    elseif actionType == "CLOSE" then
        action.Execute = CloseAll;
    end

    return action, actionType ~= "CLOSE";
end

function AddAction(id, name)
    indicator.parameters:addString("Action" .. id, name, "", "NO")
    indicator.parameters:addStringAlternative("Action" .. id, "No Action", "", "NO")
    indicator.parameters:addStringAlternative("Action" .. id, "Sell", "", "SELL")
    indicator.parameters:addStringAlternative("Action" .. id, "Buy", "", "BUY")
    indicator.parameters:addStringAlternative("Action" .. id, "Close Position", "", "CLOSE")
end

local first = nil
local source = nil
local candlesize = nil

local k1 = nil
local k2 = nil
local k5 = nil
local k6 = nil
local base1 = 0
local base2 = 0

local LastAlertTime

-- Streams block
local dummy = nil

--Variable
local upy = nil
local downy = nil
local style, width
-- Routine

local buy_positions = {};
local sell_positions = {};
local last_serial;

function Prepare(nameOnly)
    for _, module in pairs(Modules) do module:Prepare(nameOnly); end
    style = instance.parameters.style
    frame = instance.parameters.frame
    width = instance.parameters.width
    k1 = instance.parameters.k1
    k2 = instance.parameters.k2
    k3 = instance.parameters.k3
    k4 = instance.parameters.k4
    k5 = instance.parameters.k5
    k6 = instance.parameters.k6
    base1 = instance.parameters.x
    base2 = instance.parameters.y

    source = instance.source
    first = source:first()

    local name = profile:id() .. "(" .. source:name() .. ", " .. frame .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    CreateCustomActions();

    local s, e
    s, e = core.getcandle(source:barSize(), core.now(), 0)
    -- remember size of the candle to calculate the date for the lines which ends after the end of the chart
    candlesize = e - s

    upy = instance:addInternalStream(0, 0)
    downy = instance:addInternalStream(0, 0)

    -- add an extent to make the output streams longer than the source to be able draw into the future
    dummy = instance:addStream("D", core.Dot, name, "D", instance.parameters.top_color, first, 300)
    local profile = core.indicators:findIndicator("PIVOT-PRICE CLOUD");
    assert(profile ~= nil, "Please, download and install " .. "PIVOT-PRICE CLOUD" .. ".LUA indicator");
    pp = core.indicators:create("PIVOT-PRICE CLOUD", source)

    if PositionsCount == 1 then
        buy_positions[#buy_positions + 1] = CreatePositionStrategy(source, "B", "");
        sell_positions[#sell_positions + 1] = CreatePositionStrategy(source, "S", "");
    else
        for i = 1, PositionsCount do
            if instance.parameters:getBoolean("use_position_" .. i) then
                buy_positions[#buy_positions + 1] = CreatePositionStrategy(source, "B", "_" .. i);
                sell_positions[#sell_positions + 1] = CreatePositionStrategy(source, "S", "_" .. i);
            end
        end
    end
end

function CreatePositionStrategy(source, side, id)
    local position_strategy = {};
    position_strategy.StopType = instance.parameters:getString("stop_type" .. id);
    position_strategy.LimitType = instance.parameters:getString("limit_type" .. id);
    assert(position_strategy.LimitType ~= "stop" or position_strategy.StopType == "pips", "To use limit based on stop you need to set stop in pips");

    position_strategy.Side = side;
    position_strategy.Source = source;
    position_strategy.Amount = instance.parameters:getInteger("amount" .. id);
    position_strategy.Stop = instance.parameters:getDouble("stop" .. id);
    if position_strategy.StopType == "atr" then
        position_strategy.StopATR = core.indicators:create("ATR", source, position_strategy.Stop);
    end
    if instance.parameters:getBoolean("use_trailing" .. id) then
        position_strategy.Trailing = instance.parameters:getInteger("trailing" .. id);
    end
    position_strategy.Limit = instance.parameters:getDouble("limit" .. id);
    if position_strategy.LimitType == "atr" then
        position_strategy.LimitATR = core.indicators:create("ATR", source, position_strategy.Limit);
    end
    position_strategy.AtrStopMult = instance.parameters:getDouble("atr_stop_mult" .. id);
    position_strategy.AtrLimitMult = instance.parameters:getDouble("atr_limit_mult" .. id);
    position_strategy.TrailingLimitType = instance.parameters:getString("TRAILING_LIMIT_TYPE" .. id);
    position_strategy.TrailingLimitTrigger = instance.parameters:getDouble("TRAILING_LIMIT_TRIGGER" .. id);
    position_strategy.TrailingLimitStep = instance.parameters:getDouble("TRAILING_LIMIT_STEP" .. id);

    position_strategy.UseBreakeven = instance.parameters:getBoolean("use_breakeven" .. id);
    position_strategy.BreakevenWhen = instance.parameters:getDouble("breakeven_when" .. id);
    position_strategy.BreakevenTo = instance.parameters:getDouble("breakeven_to" .. id);
    position_strategy.BreakevenTrailing = instance.parameters:getString("breakeven_trailing");
    position_strategy.BreakevenTrailingValue = instance.parameters:getInteger("trailing" .. id);
    if instance.parameters:getBoolean("breakeven_close" .. id) then
        position_strategy.BreakevenCloseAmount = instance.parameters:getDouble("breakeven_close_amount" .. id);
    end
    if position_strategy.UseBreakeven and tick_source == nil then
        tick_source = ExtSubscribe(TICKS_SOURCE_ID, position_strategy.Source.close:instrument(), "t1", true, "tick");
    end

    function position_strategy:Open(period)
        local command = trading:MarketOrder(position_strategy.Source.close:instrument())
            :SetSide(self.Side)
            :SetAccountID(instance.parameters.account)
            :SetAmount(self.Amount)
            :SetCustomID(custom_id);
        local stop_value;
        if self.StopType == "pips" then
            stop_value = self.Stop;
            command = command:SetPipStop(nil, self.Stop, self.Trailing);
        end
        if self.LimitType == "pips" then
            command = command:SetPipLimit(nil, self.Limit);
        elseif self.LimitType == "stop" then
            command = command:SetPipLimit(nil, stop_value * self.Limit);
        end
        local result = command:Execute();
        if self.StopType == "atr" then
            self.StopATR:update(core.UpdateLast);
            breakeven:CreateIndicatorTrailingController()
                :SetRequestID(result.RequestID)
                :SetTrailingTarget(breakeven.STOP_ID)
                :SetIndicatorStream(self.StopATR.DATA, self.AtrStopMult, true);
        end
        if self.LimitType == "atr" then
            self.LimitATR:update(core.UpdateLast);
            breakeven:CreateIndicatorTrailingController()
                :SetRequestID(result.RequestID)
                :SetTrailingTarget(breakeven.LIMIT_ID)
                :SetIndicatorStream(self.LimitATR.DATA, self.AtrLimitMult, true);
        end
        if self.UseBreakeven then
            local controller = breakeven:CreateController()
                :SetRequestID(result.RequestID)
                :SetWhen(self.BreakevenWhen)
                :SetTo(self.BreakevenTo);
            if self.BreakevenTrailing == "set" then
                controller:SetTrailing(self.BreakevenTrailingValue);
            end
            if self.BreakevenCloseAmount ~= nil then
                controller:SetPartialClose(self.BreakevenCloseAmount);
            end
        end
        self:CreateTrailingLimit(result);
    end
    function position_strategy:CreateTrailingLimit(result)
        if self.TrailingLimitType == "Unfavorable" then
            breakeven:CreateTrailingLimitController()
                :SetDirection(-1)
                :SetTrigger(self.TrailingLimitTrigger)
                :SetStep(self.TrailingLimitStep)
                :SetRequestID(result.RequestID);
        elseif self.TrailingLimitType == "Favorable" then
            breakeven:CreateTrailingLimitController()
                :SetDirection(1)
                :SetTrigger(self.TrailingLimitTrigger)
                :SetStep(self.TrailingLimitStep)
                :SetRequestID(result.RequestID);
        end
    end
    return position_strategy;
end

function DoCloseOnOpposite(side)
    if instance.parameters.close_on_opposite then
        local it = trading:FindTrade():WhenSide(trading:getOppositeSide(side))
        if UseOwnPositionsOnly then
            it:WhenCustomID(custom_id);
        end
        it:Do(function (trade) trading:Close(trade); end);
    end
end

function DisabledAction(source, period) return false; end

function CloseAll(source, period)
    local closedCount = 0;
    if instance.parameters.allow_trade then
        local it = trading:FindTrade();
        if UseOwnPositionsOnly then
            it:WhenCustomID(custom_id);
        end
        closedCount = it:Do(function (trade) trading:Close(trade); end);
    end
    if closedCount > 0 then
        signaler:Signal("Close all for " .. source.close:instrument(), source);
    end
end

function CloseLong(source, period)
    local closedCount = 0;
    if instance.parameters.allow_trade then
        local it = trading:FindTrade():WhenSide("B");
        if UseOwnPositionsOnly then
            it:WhenCustomID(custom_id);
        end
        closedCount = it:Do(function (trade) trading:Close(trade); end);
    end
    if closedCount > 0 then
        signaler:Signal("Close long for " .. source.close:instrument(), source);
    end
end

function CloseShort(source, period)
    local closedCount = 0;
    if instance.parameters.allow_trade then
        local it = trading:FindTrade():WhenSide("S");
        if UseOwnPositionsOnly then
            it:WhenCustomID(custom_id);
        end
        closedCount = it:Do(function (trade) trading:Close(trade); end);
    end
    if closedCount > 0 then
        signaler:Signal("Close short for " .. source.close:instrument(), source);
    end
end

function IsPositionLimitHit(side, side_limit)
    if not instance.parameters.position_cap then
        return false;
    end
    local sideIt = trading:FindTrade();
    local allIt = trading:FindTrade();
    if UseOwnPositionsOnly then
        sideIt:WhenCustomID(custom_id);
        allIt:WhenCustomID(custom_id)
    end
    local side_positions = sideIt:Count();
    local positions = allIt:Count();
    return positions >= instance.parameters.no_of_positions or side_positions >= side_limit;
end

function GoLong(source, period)
    if instance.parameters.allow_trade then
        DoCloseOnOpposite("B");
        if IsPositionLimitHit("B", instance.parameters.no_of_buy_position) then
            signaler:Signal("Positions limit has been reached", source);
            return;
        end
        for _, position in ipairs(buy_positions) do
            position:Open(period);
        end
    end
    signaler:Signal("Buy " .. source.close:instrument(), source);
    last_serial = source:serial(period);
end

function GoShort(source, period)
    if instance.parameters.allow_trade then
        DoCloseOnOpposite("S");
        if IsPositionLimitHit("S", instance.parameters.no_of_sell_position) then
            signaler:Signal("Positions limit has been reached", source);
            return;
        end
        for _, position in ipairs(sell_positions) do
            position:Open(period);
        end
    end
    signaler:Signal("Sell " .. source.close:instrument(), source);
    last_serial = source:serial(period);
end

local last_period = -1

-- update
function Update(period)
    pp:update(core.UpdateLast);
    for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(nil, source, period); end end
    -- detect restart
    if last_period > period then
        core.host:execute("removeAll")
    end
    last_period = period

    if period >= 6 then
        fractal(period)
    end
    if period >= frame then
        Draw(period, frame)
    end

    if period < source:size() - 1 then
        return;
    end
    for _, action in ipairs(EntryActions) do
        if action.IsPass(source, period) and (not action.ActOnSwitch or not action.IsPass(source, period - 1)) then
            action.Execute(source, period);
        end
    end

    for _, action in ipairs(ExitActions) do
        if action.IsPass(source, period) and (not action.ActOnSwitch or not action.IsPass(source, period - 1)) then
            action.Execute(source, period);
        end
    end
end

--distance between two points
function Distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
end

-- calculate fractals
function fractal(p)
    upy[p] = 0
    downy[p] = 0

    curr = source.high[p - 2]

    if
        (curr >= source.high[p - 4] and curr >= source.high[p - 3] and curr >= source.high[p - 1] and
            curr >= source.high[p])
     then
        upy[p - 2] = source.high[p - 2]
    end

    curr = source.low[p - 2]
    if (curr <= source.low[p - 4] and curr <= source.low[p - 3] and curr <= source.low[p - 1] and curr <= source.low[p]) then
        downy[p - 2] = source.low[p - 2]
    end

    upy[p - 1] = 0
    downy[p - 1] = 0
    upy[p] = 0
    downy[p] = 0
end

-- get line equation coefficients
function getline(x1, y1, x2, y2)
    local a, b

    a = ((y2 - y1) / (x2 - x1))
    b = (y1 - a * x1)
    return a, b
end

-- get line intersection point
function intersect(a1, b1, a2, b2)
    local x, y

    -- collinear
    if a1 == a2 then
        return nil, nil
    end

    x = (b2 - b1) / (a1 - a2)
    y = a1 * x + b1
    return x, y
end

local line_id = 0

-- draws line based on two fractals and the point of the intersection
function drawline(x1, y1, x2, y2, ix, iy, color, isTop)
    -- line's coordinates
    local lx1, lx2, ly1, ly2

    -- case 1
    -- intesection is before x1
    if ix < x1 then
        -- intesection is between x1 and x2
        lx1 = ix
        ly1 = iy
        lx2 = x2
        ly2 = y2
    elseif ix >= x1 and ix <= x2 then
        -- intesection is after x2
        lx1 = x1
        ly1 = y1
        lx2 = x2
        ly2 = y2
    else
        lx1 = x1
        ly1 = y1
        lx2 = ix
        ly2 = iy
    end

    -- if line is out of the chart area - adjust it to the chart borders
    if lx1 < 0 or lx2 >= dummy:size() then
        local a, b
        a, b = getline(lx1, ly1, lx2, ly2)
        if lx1 < 0 then
            lx1 = 0
        end
        if lx2 >= dummy:size() then
            lx2 = dummy:size() - 1
        end
        ly1 = a * lx1 + b
        ly2 = a * lx2 + b
    end

    -- get dates instead of number of the periods
    local date1, date2
    date1 = source:date(lx1)
    if lx2 >= source:size() then
        date2 = source:date(source:size() - 1) + candlesize * (lx2 - source:size() + 1)
    else
        date2 = source:date(lx2)
    end

    core.host:execute("drawLine", line_id, date1, ly1, date2, ly2, color, style, width)
    local line;
    local newLine = false;
    if isTop then
        line = lines_top[date1];
        if line == nil then
            line = {};
            lines_top[date1] = line;
            newLine = true;
        end
    else
        line = lines_bottom[date1];
        if line == nil then
            line = {};
            lines_bottom[date1] = line;
            newLine = true;
        end
    end
    line.date1 = date1;
    line.y1 = ly1;
    line.date2 = date2;
    line.y2 = ly2;
    if newLine then
        function line:crossesOver(source, period)
            local x1 = core.findDate(source, self.date1, false);
            local x2 = core.findDate(source, self.date2, false);
            if (x1 < period and x2 < period) then
                return false;
            end
            local y1 = self.y1;
            local y2 = self.y2;
            if x1 > x2 then
                local temp = x1;
                x1 = x2;
                x1 = temp;
                temp = y1;
                y1 = y2;
                y2 = temp;
            end
            local a, c = math2d.lineEquation(x1, y1, x2, y2);
            if a == nil then
                return false;
            end
            local y_current = a * period + c;
            local y_previous = a * (period - 1) + c;
            return y_current < source[period] and y_previous >= source[period - 1];
        end
        function line:crossesUnder(source, period)
            local x1 = core.findDate(source, self.date1, false);
            local x2 = core.findDate(source, self.date2, false);
            if (x1 < period and x2 < period) then
                return false;
            end
            local y1 = self.y1;
            local y2 = self.y2;
            if x1 > x2 then
                local temp = x1;
                x1 = x2;
                x1 = temp;
                temp = y1;
                y1 = y2;
                y2 = temp;
            end
            local a, c = math2d.lineEquation(x1, y1, x2, y2);
            if a == nil then
                return false;
            end
            local y_current = a * period + c;
            local y_previous = a * (period - 1) + c;
            return y_current > source[period] and y_previous <= source[period - 1];
        end
    end
    line_id = line_id + 1
end

-- find last two up and down fractals
function Draw(period, frame)
    local i, f
    -- x (period) and y (price) coordinates of two last fractals
    local hx1, hy1, hx2, hy2
    local lx1, ly1, lx2, ly2

    hy1 = nil
    hy2 = nil
    ly1 = nil
    ly2 = nil
    f = 0

    for i = period, period - frame + 1, -1 do
        if upy[i] ~= 0 then
            if hy1 == nil then
                hy1 = upy[i]
                hx1 = i
                f = f + 1
            elseif hy2 == nil then
                hy2 = upy[i]
                hx2 = i
                f = f + 1
            end
        end
        if downy[i] ~= 0 then
            if ly1 == nil then
                ly1 = downy[i]
                lx1 = i
                f = f + 1
            elseif ly2 == nil then
                ly2 = downy[i]
                lx2 = i
                f = f + 1
            end
        end
        -- all four points are found
        if f == 4 then
            break
        end
    end

    -- if all four points has been found
    if f == 4 then
        -- intersection point
        local ix, iy = nil
        -- a and b coefficients of the y = a * x + b line quation
        -- x2 always < x1
        local a1, b1, a2, b2
        a1, b1 = getline(hx2, hy2, hx1, hy1)
        a2, b2 = getline(lx2, ly2, lx1, ly1)

        ix, iy = intersect(a1, b1, a2, b2)
        if ix == nil then
            -- collinear
            return
        else
            local ls = Distance(lx2, ly2, ix, iy)
            local bs = Distance(hx2, hy2, lx2, ly2)
            local hs = Distance(hx2, hy2, ix, iy)

            if ls / bs > base1 or hs / bs > base1 then
                return
            end

            if bs > ls or bs > hs then
                return
            end

            if ls / hs > base2 or hs / ls > base2 then
                return
            end

            --Triangle
            if ix > hx1 and ix > lx1 and iy <= hy1 and iy >= ly1 and k1 == "No" then
                return
            end

            --Expanding Triangle
            if ix < hx1 and ix < lx1 and iy <= hy1 and iy >= ly1 and k2 == "No" then
                return
            end

            --Up Wedges
            if iy > hy1 and iy > ly1 and ix > hx1 and ix > lx1 and k5 == "No" then
                return
            end

            -- Down Wedges
            if iy < hy1 and iy < ly1 and ix > hx1 and ix > lx1 and k6 == "No" then
                return
            end

            -- Expanding Down Wedges
            if iy < hy1 and iy < ly1 and ix < hx1 and ix < lx1 then
                return
            end

            -- Expanding Up Wedges
            if iy > hy1 and iy > ly1 and ix < hx1 and ix < lx1 then
                return
            end

            drawline(hx2, hy2, hx1, hy1, ix, iy, instance.parameters.top_color, true)
            drawline(lx2, ly2, lx1, ly1, ix, iy, instance.parameters.bottom_color, false)

            if period == source:size() - 1 then
                signaler:Signal("A new triangle has formed.", source);
            end
        end
    end
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end
end

trading = {};
trading.Name = "Trading";
trading.Version = "4.15";
trading.Debug = false;
trading.AddAmountParameter = true;
trading.AddStopParameter = true;
trading.AddLimitParameter = true;
trading._ids_start = nil;
trading._signaler = nil;
trading._account = nil;
trading._all_modules = {};
trading._request_id = {};
trading._waiting_requests = {};
trading._used_stop_orders = {};
trading._used_limit_orders = {};
function trading:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function trading:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end

function trading:AddPositionParameters(parameters, id)
    if self.AddAmountParameter then
        parameters:addInteger("amount" .. id, "Trade Amount in Lots", "", 1);
    end
    if self.AddStopParameter then
        parameters:addString("stop_type" .. id, "Stop Order", "", "no");
        parameters:addStringAlternative("stop_type" .. id, "No stop", "", "no");
        parameters:addStringAlternative("stop_type" .. id, "In Pips", "", "pips");
        parameters:addStringAlternative("stop_type" .. id, "ATR", "", "atr");
        parameters:addDouble("stop" .. id, "Stop Value", "In pips or ATR period", 30);
        parameters:addDouble("atr_stop_mult" .. id, "ATR Stop Multiplicator", "", 2.0);
        parameters:addBoolean("use_trailing" .. id, "Trailing stop order", "", false);
        parameters:addInteger("trailing" .. id, "Trailing in pips", "Use 1 for dynamic and 10 or greater for the fixed trailing", 1);
    end
    if self.AddLimitParameter then
        parameters:addString("limit_type" .. id, "Limit Order", "", "no");
        parameters:addStringAlternative("limit_type" .. id, "No limit", "", "no");
        parameters:addStringAlternative("limit_type" .. id, "In Pips", "", "pips");
        parameters:addStringAlternative("limit_type" .. id, "ATR", "", "atr");
        parameters:addStringAlternative("limit_type" .. id, "Multiplicator of stop", "", "stop");
        parameters:addDouble("limit" .. id, "Limit Value", "In pips or ATR period", 30);
        parameters:addDouble("atr_limit_mult" .. id, "ATR Limit Multiplicator", "", 2.0);
        parameters:addString("TRAILING_LIMIT_TYPE" .. id, "Trailing Limit", "", "Off");
        parameters:addStringAlternative("TRAILING_LIMIT_TYPE" .. id, "Off", "", "Off");
        parameters:addStringAlternative("TRAILING_LIMIT_TYPE" .. id, "Favorable", "moves limit up for long/buy positions, vice versa for short/sell", "Favorable");
        parameters:addStringAlternative("TRAILING_LIMIT_TYPE" .. id, "Unfavorable", "moves limit down for long/buy positions, vice versa for short/sell", "Unfavorable");
        parameters:addDouble("TRAILING_LIMIT_TRIGGER" .. id, "Trailing Limit Trigger in Pips", "", 0);
        parameters:addDouble("TRAILING_LIMIT_STEP" .. id, "Trailing Limit Step in Pips", "", 10);
    end
    parameters:addBoolean("use_breakeven" .. id, "Use Breakeven", "", false);
    parameters:addDouble("breakeven_when" .. id, "Breakeven Activation Value, in pips", "", 10);
    parameters:addDouble("breakeven_to" .. id, "Breakeven To, in pips", "", 0);
    parameters:addString("breakeven_trailing" .. id, "Trailing after breakeven", "", "default");
    parameters:addStringAlternative("breakeven_trailing" .. id, "Do not change", "", "default");
    parameters:addStringAlternative("breakeven_trailing" .. id, "Set trailing", "", "set");
    parameters:addBoolean("breakeven_close" .. id, "Partial close on breakeven", "", false);
    parameters:addDouble("breakeven_close_amount" .. id, "Partial close amount, %", "", 50);
end

function trading:Init(parameters, count)
    parameters:addBoolean("allow_trade", "Allow strategy to trade", "", true);
    parameters:setFlag("allow_trade", core.FLAG_ALLOW_TRADE);
    parameters:addString("account", "Account to trade on", "", "");
    parameters:setFlag("account", core.FLAG_ACCOUNT);
    parameters:addBoolean("close_on_opposite", "Close on Opposite", "", true);
    parameters:addBoolean("position_cap", "Position Cap", "", false);
    parameters:addInteger("no_of_positions", "Max # of open positions", "", 1);
    parameters:addInteger("no_of_buy_position", "Max # of buy positions", "", 1);
    parameters:addInteger("no_of_sell_position", "Max # of sell positions", "", 1);
    
    if count == nil or count == 1 then
        parameters:addGroup("Position");
        self:AddPositionParameters(parameters, "");
    else
        for i = 1, count do
            parameters:addGroup("Position #" .. i);
            parameters:addBoolean("use_position_" .. i, "Open position #" .. i, "", i == 1);
            self:AddPositionParameters(parameters, "_" .. i);
        end
    end
end

function trading:Prepare(name_only)
    if name_only then return; end
end

function trading:ExtUpdate(id, source, period)
end

function trading:OnNewModule(module)
    if module.Name == "Signaler" then self._signaler = module; end
    self._all_modules[#self._all_modules + 1] = module;
end

function trading:AsyncOperationFinished(cookie, success, message, message1, message2)
    local res = self._waiting_requests[cookie];
    if res ~= nil then
        res.Finished = true;
        res.Success = success;
        res.Error = not success and message or nil;
        if not success then
            if self._signaler ~= nil then
                self._signaler:Signal(res.Error);
            else
                self:trace(res.Error);
            end
        end
        self._waiting_requests[cookie] = nil;
    elseif cookie == self._order_update_id then
        for _, order in ipairs(self._monitored_orders) do
            if order.RequestID == message2 then
                order.FixStatus = message1;
            end
        end
    elseif cookie == self._ids_start + 2 then
        if not success then
            if self._signaler ~= nil then
                self._signaler:Signal("Close order failed: " .. message);
            else
                self:trace("Close order failed: " .. message);
            end
        end
    end
end

function trading:getOppositeSide(side) if side == "B" then return "S"; end return "B"; end

function trading:getId()
    for id = self._ids_start, self._ids_start + 100 do
        if self._waiting_requests[id] == nil then return id; end
    end
    return self._ids_start;
end

function trading:CreateStopOrder(trade, stop_rate, trailing)
    local valuemap = core.valuemap();
    valuemap.Command = "CreateOrder";
    valuemap.OfferID = trade.OfferID;
    valuemap.Rate = stop_rate;
    if trade.BS == "B" then
        valuemap.BuySell = "S";
    else
        valuemap.BuySell = "B";
    end

    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        valuemap.OrderType = "S";
        valuemap.AcctID  = trade.AccountID;
        valuemap.TradeID = trade.TradeID;
        valuemap.Quantity = trade.Lot;
        valuemap.TrailUpdatePips = trailing;
    else
        valuemap.OrderType = "SE"
        valuemap.AcctID  = trade.AccountID;
        valuemap.NetQtyFlag = "Y"
    end

    local id = self:getId();
    local success, msg = terminal:execute(id, valuemap);
    if not(success) then
        local message = "Failed create stop " .. msg;
        self:trace(message);
        if self._signaler ~= nil then
            self._signaler:Signal(message);
        end
        local res = {};
        res.Finished = true;
        res.Success = false;
        res.Error = message;
        return res;
    end
    local res = {};
    res.Finished = false;
    res.RequestID = msg;
    self._waiting_requests[id] = res;
    self._request_id[trade.TradeID] = msg;
    return res;
end

function trading:CreateLimitOrder(trade, limit_rate)
    local valuemap = core.valuemap();
    valuemap.Command = "CreateOrder";
    valuemap.OfferID = trade.OfferID;
    valuemap.Rate = limit_rate;
    if trade.BS == "B" then
        valuemap.BuySell = "S";
    else
        valuemap.BuySell = "B";
    end
    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        valuemap.OrderType = "L";
        valuemap.AcctID  = trade.AccountID;
        valuemap.TradeID = trade.TradeID;
        valuemap.Quantity = trade.Lot;
    else
        valuemap.OrderType = "LE"
        valuemap.AcctID  = trade.AccountID;
        valuemap.NetQtyFlag = "Y"
    end
    local success, msg = terminal:execute(200, valuemap);
    if not(success) then
        terminal:alertMessage(trade.Instrument, limit_rate, "Failed create limit " .. msg, core.now());
    else
        self._request_id[trade.TradeID] = msg;
    end
end

function trading:ChangeOrder(order, rate, trailing)
    local min_change = core.host:findTable("offers"):find("Instrument", order.Instrument).PointSize;
    if math.abs(rate - order.Rate) > min_change then
        self:trace(string.format("Changing an order to %s", tostring(rate)));
        -- stop exists
        local valuemap = core.valuemap();
        valuemap.Command = "EditOrder";
        valuemap.AcctID  = order.AccountID;
        valuemap.OrderID = order.OrderID;
        valuemap.TrailUpdatePips = trailing;
        valuemap.Rate = rate;
        local id = self:getId();
        local success, msg = terminal:execute(id, valuemap);
        if not(success) then
            local message = "Failed change order " .. msg;
            self:trace(message);
            if self._signaler ~= nil then
                self._signaler:Signal(message);
            end
            local res = {};
            res.Finished = true;
            res.Success = false;
            res.Error = message;
            return res;
        end
        local res = {};
        res.Finished = false;
        res.RequestID = msg;
        self._waiting_requests[id] = res;
        return res;
    end
    local res = {};
    res.Finished = true;
    res.Success = true;
    return res;
end

function trading:IsLimitOrderType(order_type) return order_type == "L" or order_type == "LE" or order_type == "LT" or order_type == "LTE"; end

function trading:IsStopOrderType(order_type) return order_type == "S" or order_type == "SE" or order_type == "ST" or order_type == "STE"; end

function trading:FindLimitOrder(trade)
    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        local order_id;
        if trade.LimitOrderID ~= nil and trade.LimitOrderID ~= "" then
            order_id = trade.LimitOrderID;
            self:trace("Using limit order id from the trade");
        elseif self._request_id[trade.TradeID] ~= nil then
            self:trace("Searching limit order by request id: " .. tostring(self._request_id[trade.TradeID]));
            local order = core.host:findTable("orders"):find("RequestID", self._request_id[trade.TradeID]);
            if order ~= nil then
                order_id = order.OrderID;
                self._request_id[trade.TradeID] = nil;
            end
        end
        -- Check that order is stil exist
        if order_id ~= nil then return core.host:findTable("orders"):find("OrderID", order_id); end
    else
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if row.ContingencyType == 3 and IsLimitOrderType(row.Type) and self._used_limit_orders[row.OrderID] ~= true then
                self._used_limit_orders[row.OrderID] = true;
                return row;
            end
            row = enum:next();
        end
    end
    return nil;
end

function trading:FindStopOrder(trade)
    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        local order_id;
        if trade.StopOrderID ~= nil and trade.StopOrderID ~= "" then
            order_id = trade.StopOrderID;
            self:trace("Using stop order id from the trade");
        elseif self._request_id[trade.TradeID] ~= nil then
            self:trace("Searching stop order by request id: " .. tostring(self._request_id[trade.TradeID]));
            local order = core.host:findTable("orders"):find("RequestID", self._request_id[trade.TradeID]);
            if order ~= nil then
                order_id = order.OrderID;
                self._request_id[trade.TradeID] = nil;
            end
        end
        -- Check that order is stil exist
        if order_id ~= nil then return core.host:findTable("orders"):find("OrderID", order_id); end
    else
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if row.ContingencyType == 3 and self:IsStopOrderType(row.Type) and self._used_stop_orders[row.OrderID] ~= true then
                self._used_stop_orders[row.OrderID] = true;
                return row;
            end
            row = enum:next();
        end
    end
    return nil;
end

function trading:MoveStop(trade, stop_rate, trailing)
    local order = self:FindStopOrder(trade);
    if order == nil then
        if trailing == 0 then
            trailing = nil;
        end
        return self:CreateStopOrder(trade, stop_rate, trailing);
    else
        if trailing == 0 then
            if order.TrlMinMove ~= 0 then
                trailing = order.TrlMinMove
            else
                trailing = nil;
            end
        end
        return self:ChangeOrder(order, stop_rate, trailing);
    end
end

function trading:MoveLimit(trade, limit_rate)
    self:trace("Searching for a limit");
    local order = self:FindLimitOrder(trade);
    if order == nil then
        self:trace("Limit order not found, creating a new one");
        return self:CreateLimitOrder(trade, limit_rate);
    else
        return self:ChangeOrder(order, limit_rate);
    end
end

function trading:RemoveStop(trade)
    self:trace("Searching for a stop");
    local order = self:FindStopOrder(trade);
    if order == nil then self:trace("No stop"); return nil; end
    self:trace("Deleting order");
    return self:DeleteOrder(order);
end

function trading:RemoveLimit(trade)
    self:trace("Searching for a limit");
    local order = self:FindLimitOrder(trade);
    if order == nil then self:trace("No limit"); return nil; end
    self:trace("Deleting order");
    return self:DeleteOrder(order);
end

function trading:DeleteOrder(order)
    self:trace(string.format("Deleting order %s", order.OrderID));
    local valuemap = core.valuemap();
    valuemap.Command = "DeleteOrder";
    valuemap.OrderID = order.OrderID;

    local id = self:getId();
    local success, msg = terminal:execute(id, valuemap);
    if not(success) then
        local message = "Delete order failed: " .. msg;
        self:trace(message);
        if self._signaler ~= nil then
            self._signaler:Signal(message);
        end
        local res = {};
        res.Finished = true;
        res.Success = false;
        res.Error = message;
        return res;
    end
    local res = {};
    res.Finished = false;
    res.RequestID = msg;
    self._waiting_requests[id] = res;
    return res;
end

function trading:GetCustomID(qtxt)
    if qtxt == nil then
        return nil;
    end
    local metadata = self:GetMetadata(qtxt);
    if metadata == nil then
        return qtxt;
    end
    return metadata.CustomID;
end

function trading:FindOrder()
    local search = {};
    function search:WhenCustomID(custom_id) self.CustomID = custom_id; return self; end
    function search:WhenSide(bs) self.Side = bs; return self; end
    function search:WhenInstrument(instrument) self.Instrument = instrument; return self; end
    function search:WhenAccountID(account_id) self.AccountID = account_id; return self; end
    function search:WhenRate(rate) self.Rate = rate; return self; end
    function search:WhenOrderType(orderType) self.OrderType = orderType; return self; end
    function search:Do(action)
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        local count = 0
        while (row ~= nil) do
            if self:PassFilter(row) then
                if action(row) then
                    count = count + 1;
                end
            end
            row = enum:next();
        end
        return count;
    end
    function search:PassFilter(row)
        return (row.Instrument == self.Instrument or not self.Instrument)
            and (row.BS == self.Side or not self.Side)
            and (row.AccountID == self.AccountID or not self.AccountID)
            and (trading:GetCustomID(row.QTXT) == self.CustomID or not self.CustomID)
            and (row.Rate == self.Rate or not self.Rate)
            and (row.Type == self.OrderType or not self.OrderType);
    end
    function search:All()
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        local orders = {};
        while (row ~= nil) do
            if self:PassFilter(row) then orders[#orders + 1] = row; end
            row = enum:next();
        end
        return orders;
    end
    function search:First()
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then return row; end
            row = enum:next();
        end
        return nil;
    end
    return search;
end

function trading:FindTrade()
    local search = {};
    function search:WhenCustomID(custom_id) self.CustomID = custom_id; return self; end
    function search:WhenSide(bs) self.Side = bs; return self; end
    function search:WhenInstrument(instrument) self.Instrument = instrument; return self; end
    function search:WhenAccountID(account_id) self.AccountID = account_id; return self; end
    function search:WhenOpen(open) self.Open = open; return self; end
    function search:WhenOpenOrderReqID(open_order_req_id) self.OpenOrderReqID = open_order_req_id; return self; end
    function search:Do(action)
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        local count = 0
        while (row ~= nil) do
            if self:PassFilter(row) then
                if action(row) then
                    count = count + 1;
                end
            end
            row = enum:next();
        end
        return count;
    end
    function search:PassFilter(row)
        return (row.Instrument == self.Instrument or not self.Instrument)
            and (row.BS == self.Side or not self.Side)
            and (row.AccountID == self.AccountID or not self.AccountID)
            and (trading:GetCustomID(row.QTXT) == self.CustomID or not self.CustomID)
            and (row.Open == self.Open or not self.Open)
            and (row.OpenOrderReqID == self.OpenOrderReqID or not self.OpenOrderReqID);
    end
    function search:All()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        local trades = {};
        while (row ~= nil) do
            if self:PassFilter(row) then trades[#trades + 1] = row; end
            row = enum:next();
        end
        return trades;
    end
    function search:Any()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then 
                return true;
            end
            row = enum:next();
        end
        return false;
    end
    function search:Count()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        local count = 0;
        while (row ~= nil) do
            if self:PassFilter(row) then count = count + 1; end
            row = enum:next();
        end
        return count;
    end
    function search:First()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then return row; end
            row = enum:next();
        end
        return nil;
    end
    return search;
end

function trading:FindClosedTrade()
    local search = {};
    function search:WhenCustomID(custom_id) self.CustomID = custom_id; return self; end
    function search:WhenSide(bs) self.Side = bs; return self; end
    function search:WhenInstrument(instrument) self.Instrument = instrument; return self; end
    function search:WhenAccountID(account_id) self.AccountID = account_id; return self; end
    function search:WhenOpenOrderReqID(open_order_req_id) self.OpenOrderReqID = open_order_req_id; return self; end
    function search:WhenTradeIDRemain(trade_id_remain) self.TradeIDRemain = trade_id_remain; return self; end
    function search:PassFilter(row)
        if self.TradeIDRemain ~= nil and row.TradeIDRemain ~= self.TradeIDRemain then return false; end
        return (row.Instrument == self.Instrument or not self.Instrument)
            and (row.BS == self.Side or not self.Side)
            and (row.AccountID == self.AccountID or not self.AccountID)
            and (trading:GetCustomID(row.QTXT) == self.CustomID or not self.CustomID)
            and (row.OpenOrderReqID == self.OpenOrderReqID or not self.OpenOrderReqID);
    end
    function search:Any()
        local enum = core.host:findTable("closed trades"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then
                return true;
            end
            row = enum:next();
        end
        return false;
    end
    function search:All()
        local enum = core.host:findTable("closed trades"):enumerator();
        local row = enum:next();
        local trades = {};
        while (row ~= nil) do
            if self:PassFilter(row) then trades[#trades + 1] = row; end
            row = enum:next();
        end
        return trades;
    end
    function search:First()
        local enum = core.host:findTable("closed trades"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then return row; end
            row = enum:next();
        end
        return nil;
    end
    return search;
end

function trading:ParialClose(trade, amount)
    -- not finished
    local account = core.host:findTable("accounts"):find("AccountID", trade.AccountID);
    local id = self:getId();
    if account.Hedging == "Y" then
        local valuemap = core.valuemap();
        valuemap.BuySell = trade.BS == "B" and "S" or "B";
        valuemap.OrderType = "CM";
        valuemap.OfferID = trade.OfferID;
        valuemap.AcctID = trade.AccountID;
        valuemap.TradeID = trade.TradeID;
        valuemap.Quantity = math.min(amount, trade.Lot);
        local success, msg = terminal:execute(id, valuemap);
        if success then
            local res = trading:ClosePartialSuccessResult(msg);
            self._waiting_requests[id] = res;
            return res;
        end
        return trading:ClosePartialFailResult(msg);
    end

    local valuemap = core.valuemap();
    valuemap.OrderType = "OM";
    valuemap.OfferID = trade.OfferID;
    valuemap.AcctID = trade.AccountID;
    valuemap.Quantity = math.min(amount, trade.Lot);
    valuemap.BuySell = trading:getOppositeSide(trade.BS);
    local success, msg = terminal:execute(id, valuemap);
    if success then
        local res = trading:ClosePartialSuccessResult(msg);
        self._waiting_requests[id] = res;
        return res;
    end
    return trading:ClosePartialFailResult(msg);
end

function trading:ClosePartialSuccessResult(msg)
    local res = {};
    if msg ~= nil then res.Finished = false; else res.Finished = true; end
    res.RequestID = msg;
    function res:ToJSON()
        return trading:ObjectToJson(self);
    end
    return res;
end
function trading:ClosePartialFailResult(message)
    local res = {};
    res.Finished = true;
    res.Success = false;
    res.Error = message;
    return res;
end

function trading:Close(trade)
    local valuemap = core.valuemap();
    valuemap.BuySell = trade.BS == "B" and "S" or "B";
    valuemap.OrderType = "CM";
    valuemap.OfferID = trade.OfferID;
    valuemap.AcctID = trade.AccountID;
    valuemap.TradeID = trade.TradeID;
    valuemap.Quantity = trade.Lot;
    local success, msg = terminal:execute(self._ids_start + 3, valuemap);
    if not(success) then
        if self._signaler ~= nil then self._signaler:Signal("Close failed: " .. msg); end
        return false;
    end

    return true;
end

function trading:ObjectToJson(obj)
    local json = {};
    function json:AddStr(name, value)
        local separator = "";
        if self.str ~= nil then separator = ","; else self.str = ""; end
        self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value));
    end
    function json:AddNumber(name, value)
        local separator = "";
        if self.str ~= nil then separator = ","; else self.str = ""; end
        self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0);
    end
    function json:AddBool(name, value)
        local separator = "";
        if self.str ~= nil then separator = ","; else self.str = ""; end
        self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false");
    end
    function json:ToString() return "{" .. (self.str or "") .. "}"; end
    
    local first = true;
    for idx,t in pairs(obj) do
        local stype = type(t)
        if stype == "number" then json:AddNumber(idx, t);
        elseif stype == "string" then json:AddStr(idx, t);
        elseif stype == "boolean" then json:AddBool(idx, t);
        elseif stype == "function" or stype == "table" then --do nothing
        else core.host:trace(tostring(idx) .. " " .. tostring(stype));
        end
    end
    return json:ToString();
end

function trading:CreateEntryOrderSuccessResult(msg)
    local res = {};
    if msg ~= nil then res.Finished = false; else res.Finished = true; end
    res.RequestID = msg;
    function res:IsOrderExecuted()
        return self.FixStatus ~= nil and self.FixStatus == "F";
    end
    function res:GetOrder()
        if self._order == nil then
            self._order = core.host:findTable("orders"):find("RequestID", self.RequestID);
            if self._order == nil then return nil; end
        end
        if not self._order:refresh() then return nil; end
        return self._order;
    end
    function res:GetTrade()
        if self._trade == nil then
            self._trade = core.host:findTable("trades"):find("OpenOrderReqID", self.RequestID);
            if self._trade == nil then return nil; end
        end
        if not self._trade:refresh() then return nil; end
        return self._trade;
    end
    function res:GetClosedTrade()
        if self._closed_trade == nil then
            self._closed_trade = core.host:findTable("closed trades"):find("OpenOrderReqID", self.RequestID);
            if self._closed_trade == nil then return nil; end
        end
        if not self._closed_trade:refresh() then return nil; end
        return self._closed_trade;
    end
    function res:ToJSON()
        return trading:ObjectToJson(self);
    end
    return res;
end
function trading:CreateEntryOrderFailResult(message)
    local res = {};
    res.Finished = true;
    res.Success = false;
    res.Error = message;
    function res:GetOrder() return nil; end
    function res:GetClosedTrade() return nil; end
    function res:IsOrderExecuted() return false; end
    return res;
end

function trading:EntryOrder(instrument)
    local builder = {};
    builder.Offer = core.host:findTable("offers"):find("Instrument", instrument);
    builder.Instrument = instrument;
    builder.Parent = self;
    builder.valuemap = core.valuemap();
    builder.valuemap.Command = "CreateOrder";
    builder.valuemap.OfferID = builder.Offer.OfferID;
    builder.valuemap.AcctID = self._account;
    function builder:_GetBaseUnitSize() if self._base_size == nil then self._base_size = core.host:execute("getTradingProperty", "baseUnitSize", self.Instrument, self.valuemap.AcctID); end return self._base_size; end

    function builder:SetAccountID(accountID) self.valuemap.AcctID = accountID; return self; end
    function builder:SetAmount(amount) self.valuemap.Quantity = amount * self:_GetBaseUnitSize(); return self; end
    function builder:SetPercentOfEquityAmount(percent) self._PercentOfEquityAmount = percent; return self; end
    function builder:SetSide(buy_sell) self.valuemap.BuySell = buy_sell; return self; end
    function builder:SetRate(rate) if self.valuemap.BuySell == "B" then self.valuemap.OrderType = self.Offer.Ask > rate and "LE" or "SE"; else self.valuemap.OrderType = self.Offer.Bid > rate and "SE" or "LE"; end self.valuemap.Rate = rate; return self; end
    function builder:SetPipLimit(limit_type, limit) self.valuemap.PegTypeLimit = limit_type or "M"; self.valuemap.PegPriceOffsetPipsLimit = self.valuemap.BuySell == "B" and limit or -limit; return self; end
    function builder:SetLimit(limit) self.valuemap.RateLimit = limit; return self; end
    function builder:SetPipStop(stop_type, stop, trailing_stop) self.valuemap.PegTypeStop = stop_type or "O"; self.valuemap.PegPriceOffsetPipsStop = self.valuemap.BuySell == "B" and -stop or stop; self.valuemap.TrailStepStop = trailing_stop; return self; end
    function builder:SetStop(stop, trailing_stop) self.valuemap.RateStop = stop; self.valuemap.TrailStepStop = trailing_stop; return self; end
    function builder:UseDefaultCustomId() self.valuemap.CustomID = self.Parent.CustomID; return self; end
    function builder:SetCustomID(custom_id) self.valuemap.CustomID = custom_id; return self; end
    function builder:GetValueMap() return self.valuemap; end
    function builder:AddMetadata(id, val) if self._metadata == nil then self._metadata = {}; end self._metadata[id] = val; return self; end
    function builder:Execute()
        local desc = string.format("Creating %s %s for %s at %f", self.valuemap.BuySell, self.valuemap.OrderType, self.Instrument, self.valuemap.Rate);
        if self._metadata ~= nil then
            self._metadata.CustomID = self.valuemap.CustomID;
            self.valuemap.CustomID = trading:ObjectToJson(self._metadata);
        end
        if self.valuemap.RateStop ~= nil then
            desc = desc .. " stop " .. self.valuemap.RateStop;
        end
        if self.valuemap.RateLimit ~= nil then
            desc = desc .. " limit " .. self.valuemap.RateLimit;
        end
        self.Parent:trace(desc);
        if self._PercentOfEquityAmount ~= nil then
            local equity = core.host:findTable("accounts"):find("AccountID", self.valuemap.AcctID).Equity;
            local affordable_loss = equity * self._PercentOfEquityAmount / 100.0;
            local stop = math.abs(self.valuemap.RateStop - self.valuemap.Rate) / self.Offer.PointSize;
            local possible_loss = self.Offer.PipCost * stop;
            self.valuemap.Quantity = math.floor(affordable_loss / possible_loss) * self:_GetBaseUnitSize();
        end

        for _, module in pairs(self.Parent._all_modules) do
            if module.BlockOrder ~= nil and module:BlockOrder(self.valuemap) then
                self.Parent:trace("Creation of order blocked by " .. module.Name);
                return trading:CreateEntryOrderFailResult("Creation of order blocked by " .. module.Name);
            end
        end
        for _, module in pairs(self.Parent._all_modules) do
            if module.OnOrder ~= nil then module:OnOrder(self.valuemap); end
        end
        local id = self.Parent:getId();
        local success, msg = terminal:execute(id, self.valuemap);
        if not(success) then
            local message = "Open order failed: " .. msg;
            self.Parent:trace(message);
            if self.Parent._signaler ~= nil then self.Parent._signaler:Signal(message); end
            return trading:CreateEntryOrderFailResult(message);
        end
        local res = trading:CreateEntryOrderSuccessResult(msg);
        self.Parent._waiting_requests[id] = res;
        return res;
    end
    return builder;
end

function trading:StoreMarketOrderResults(res)
    local str = "[";
    for i, t in ipairs(res) do
        local json = t:ToJSON();
        if str == "[" then str = str .. json; else str = str .. "," .. json; end
    end
    return str .. "]";
end
function trading:RestoreMarketOrderResults(str)
    local results = {};
    local position = 2;
    local result;
    while (position < str:len()) do
        local ch = string.sub(str, position, position);
        if ch == "{" then
            result = trading:CreateMarketOrderSuccessResult();
            position = position + 1;
        elseif ch == "}" then
            results[#results + 1] = result;
            result = nil;
            position = position + 1;
        elseif ch == "," then
            position = position + 1;
        else
            local name, value = string.match(str, '"([^"]+)":("?[^,}]+"?)', position);
            if value == "false" then
                result[name] = false;
                position = position + name:len() + 8;
            elseif value == "true" then
                result[name] = true;
                position = position + name:len() + 7;
            else
                if string.sub(value, 1, 1) == "\"" then
                    result[name] = value;
                    value:sub(2, value:len() - 1);
                    position = position + name:len() + 3 + value:len();
                else
                    result[name] = tonumber(value);
                    position = position + name:len() + 3 + value:len();
                end
            end
        end
    end
    return results;
end
function trading:CreateMarketOrderSuccessResult(msg)
    local res = {};
    if msg ~= nil then res.Finished = false; else res.Finished = true; end
    res.RequestID = msg;
    function res:GetTrade()
        if self._trade == nil then
            self._trade = core.host:findTable("trades"):find("OpenOrderReqID", self.RequestID);
            if self._trade == nil then return nil; end
        end
        if not self._trade:refresh() then return nil; end
        return self._trade;
    end
    function res:GetClosedTrade()
        if self._closed_trade == nil then
            self._closed_trade = core.host:findTable("closed trades"):find("OpenOrderReqID", self.RequestID);
            if self._closed_trade == nil then return nil; end
        end
        if not self._closed_trade:refresh() then return nil; end
        return self._closed_trade;
    end
    function res:ToJSON()
        local json = {};
        function json:AddStr(name, value)
            local separator = "";
            if self.str ~= nil then separator = ","; else self.str = ""; end
            self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value));
        end
        function json:AddNumber(name, value)
            local separator = "";
            if self.str ~= nil then separator = ","; else self.str = ""; end
            self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0);
        end
        function json:AddBool(name, value)
            local separator = "";
            if self.str ~= nil then separator = ","; else self.str = ""; end
            self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false");
        end
        function json:ToString() return "{" .. (self.str or "") .. "}"; end
        
        local first = true;
        for idx,t in pairs(self) do
            local stype = type(t)
            if stype == "number" then json:AddNumber(idx, t);
            elseif stype == "string" then json:AddStr(idx, t);
            elseif stype == "boolean" then json:AddBool(idx, t);
            elseif stype == "function" or stype == "table" then --do nothing
            else core.host:trace(tostring(idx) .. " " .. tostring(stype));
            end
        end
        return json:ToString();
    end
    return res;
end
function trading:CreateMarketOrderFailResult(message)
    local res = {};
    res.Finished = true;
    res.Success = false;
    res.Error = message;
    function res:GetTrade() return nil; end
    return res;
end

function trading:MarketOrder(instrument)
    local builder = {};
    local offer = core.host:findTable("offers"):find("Instrument", instrument);
    builder.Instrument = instrument;
    builder.Parent = self;
    builder.valuemap = core.valuemap();
    builder.valuemap.Command = "CreateOrder";
    builder.valuemap.OrderType = "OM";
    builder.valuemap.OfferID = offer.OfferID;
    builder.valuemap.AcctID = self._account;
    function builder:SetAccountID(accountID) self.valuemap.AcctID = accountID; return self; end
    function builder:SetAmount(amount)
        local base_size = core.host:execute("getTradingProperty", "baseUnitSize", self.Instrument, self.valuemap.AcctID);
        self.valuemap.Quantity = amount * base_size;
        return self;
    end
    function builder:SetSide(buy_sell) self.valuemap.BuySell = buy_sell; return self; end
    function builder:SetPipLimit(limit_type, limit)
        self.valuemap.PegTypeLimit = limit_type or "O";
        self.valuemap.PegPriceOffsetPipsLimit = self.valuemap.BuySell == "B" and limit or -limit;
        return self;
    end
    function builder:SetLimit(limit) self.valuemap.RateLimit = limit; return self; end
    function builder:SetPipStop(stop_type, stop, trailing_stop)
        self.valuemap.PegTypeStop = stop_type or "O";
        self.valuemap.PegPriceOffsetPipsStop = self.valuemap.BuySell == "B" and -stop or stop;
        self.valuemap.TrailStepStop = trailing_stop;
        return self;
    end
    function builder:SetStop(stop, trailing_stop) self.valuemap.RateStop = stop; self.valuemap.TrailStepStop = trailing_stop; return self; end
    function builder:SetCustomID(custom_id) self.valuemap.CustomID = custom_id; return self; end
    function builder:GetValueMap() return self.valuemap; end
    function builder:AddMetadata(id, val) if self._metadata == nil then self._metadata = {}; end self._metadata[id] = val; return self; end
    function builder:Execute()
        self.Parent:trace(string.format("Creating %s OM for %s", self.valuemap.BuySell, self.Instrument));
        if self._metadata ~= nil then
            self._metadata.CustomID = self.valuemap.CustomID;
            self.valuemap.CustomID = trading:ObjectToJson(self._metadata);
        end
        for _, module in pairs(self.Parent._all_modules) do
            if module.BlockOrder ~= nil and module:BlockOrder(self.valuemap) then
                self.Parent:trace("Creation of order blocked by " .. module.Name);
                return trading:CreateMarketOrderFailResult("Creation of order blocked by " .. module.Name);
            end
        end
        for _, module in pairs(self.Parent._all_modules) do
            if module.OnOrder ~= nil then
                module:OnOrder(self.valuemap);
            end
        end
        local id = self.Parent:getId();
        local success, msg = terminal:execute(id, self.valuemap);
        if not(success) then
            local message = "Open order failed: " .. msg;
            self.Parent:trace(message);
            if self.Parent._signaler ~= nil then
                self.Parent._signaler:Signal(message);
            end
            return trading:CreateMarketOrderFailResult(message);
        end
        local res = trading:CreateMarketOrderSuccessResult(msg);
        self.Parent._waiting_requests[id] = res;
        return res;
    end
    return builder;
end

function trading:JsonToObject(json)
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
            local name, value = string.match(json, '"([^"]+)":("?[^,}]+"?)', position);
            if value == "false" then
                result[name] = false;
                position = position + name:len() + 8;
            elseif value == "true" then
                result[name] = true;
                position = position + name:len() + 7;
            else
                if string.sub(value, 1, 1) == "\"" then
                    result[name] = value;
                    value:sub(2, value:len() - 1);
                    position = position + name:len() + 3 + value:len();
                else
                    result[name] = tonumber(value);
                    position = position + name:len() + 3 + value:len();
                end
            end
        end
    end
    return nil;
end

function trading:GetMetadata(qtxt)
    if qtxt == "" then
        return nil;
    end
    local position = 1;
    local result;
    while (position < qtxt:len() + 1) do
        local ch = string.sub(qtxt, position, position);
        if ch == "{" then
            result = {};
            position = position + 1;
        elseif ch == "}" then
            return result;
        elseif ch == "," then
            position = position + 1;
        else
            if result == nil then
                return nil;
            end
            local name, value = string.match(qtxt, '"([^"]+)":("?[^,}]+"?)', position);
            if value == "false" then
                result[name] = false;
                position = position + name:len() + 8;
            elseif value == "true" then
                result[name] = true;
                position = position + name:len() + 7;
            else
                if string.sub(value, 1, 1) == "\"" then
                    result[name] = value;
                    value:sub(2, value:len() - 1);
                    position = position + name:len() + 3 + value:len();
                else
                    result[name] = tonumber(value);
                    position = position + name:len() + 3 + value:len();
                end
            end
        end
    end
    return nil;
end

function trading:GetTradeMetadata(trade)
    return self:GetMetadata(trade.QTXT);
end
trading:RegisterModule(Modules);

breakeven = {};
-- public fields
breakeven.Name = "Breakeven";
breakeven.Version = "1.13";
breakeven.Debug = false;
--private fields
breakeven._moved_stops = {};
breakeven._request_id = nil;
breakeven._used_stop_orders = {};
breakeven._ids_start = nil;
breakeven._trading = nil;
breakeven._controllers = {};

function breakeven:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function breakeven:OnNewModule(module)
    if module.Name == "Trading" then self._trading = module; end
    if module.Name == "Tables monitor" then
        module:ListenCloseTrade(self.OnClosedTrade);
    end
end
function breakeven:OnClosedTrade(closed_trade)
    for _, controller in ipairs(self._controllers) do
        if controller.TradeID == closed_trade.TradeID then
            controller._trade = core.host:findTable("trades"):find("TradeID", closed_trade.TradeIDRemain);
        elseif controller.TradeID == closed_trade.TradeIDRemain then
            controller._executed = true;
            controller._close_percent = nil;
        end
    end
end
function breakeven:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end

function breakeven:Init(parameters)
end

function breakeven:Prepare(nameOnly)
end

function breakeven:ExtUpdate(id, source, period)
    for _, controller in ipairs(self._controllers) do
        controller:DoBreakeven();
    end
end

function breakeven:round(num, idp)
    if idp and idp > 0 then
        local mult = 10 ^ idp
        return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end

function breakeven:CreateBaseController()
    local controller = {};
    controller._parent = self;
    controller._executed = false;
    function controller:SetTrade(trade)
        self._trade = trade;
        self.TradeID = trade.TradeID;
        return self;
    end
    function controller:GetOffer()
        if self._offer == nil then
            self._offer = core.host:findTable("offers"):find("Instrument", self._trade.Instrument);
        end
        return self._offer;
    end
    function controller:SetRequestID(trade_request_id)
        self._request_id = trade_request_id;
        return self;
    end
    function controller:GetTrade()
        if self._trade == nil then
            self._trade = core.host:findTable("trades"):find("OpenOrderReqID", self._request_id);
            if self._trade == nil then
                return nil;
            end
            self._initial_limit = self._trade.Limit;
            self._initial_stop = self._trade.Stop;
        end
        return self._trade;
    end
    return controller;
end

breakeven.STOP_ID = 1;
breakeven.LIMIT_ID = 2;

function breakeven:CreateIndicatorTrailingController()
    local controller = self:CreateBaseController();
    function controller:SetTrailingTarget(id)
        self._target_id = id;
        return self;
    end
    function controller:MoveUpOnly()
        self._up_only = true;
        return self;
    end
    function controller:SetMinProfit(min_profit)
        self._min_profit = min_profit;
        return self;
    end
    function controller:SetIndicatorStream(stream, multiplicator, is_distance)
        self._stream = stream;
        self._stream_in_distance = is_distance;
        self._stream_multiplicator = multiplicator;
        return self;
    end
    function controller:DoBreakeven()
        if self._executed then
            return false;
        end
        local trade = self:GetTrade();
        if trade == nil or (self._move_command ~= nil and not self._move_command.Finished) then
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        if not self._stream:hasData(NOW) then
            return true;
        end
        if self._target_id == breakeven.STOP_ID then
            local new_level;
            if self._stream_in_distance then
                if trade.BS == "B" then
                    new_level = breakeven:round(trade.Open - self._stream:tick(NOW) * self._stream_multiplicator, self:GetOffer().Digits);
                else
                    new_level = breakeven:round(trade.Open + self._stream:tick(NOW) * self._stream_multiplicator, self:GetOffer().Digits);
                end
            else
                new_level = breakeven:round(self._stream:tick(NOW), self:GetOffer().Digits);
            end
            if self._min_profit ~= nil then
                if trade.BS == "B" then
                    if (new_level - trade.Open) / self:GetOffer().PointSize < self._min_profit then
                        return true;
                    end
                else
                    if (trade.Open - new_level) / self:GetOffer().PointSize < self._min_profit then
                        return true;
                    end
                end
            end
            if self._up_only then
                if trade.BS == "B" then
                    if trade.Stop >= new_level then
                        return true;
                    end
                else
                    if trade.Stop <= new_level then
                        return true;
                    end
                end
                return true;
            end
            if trade.Stop ~= new_level then
                self._move_command = self._parent._trading:MoveStop(trade, new_level);
            end
        else
            assert(self._up_only == nil, "Not implemented!!!");
            local new_level;
            if self._stream_in_distance then
                if trade.BS == "B" then
                    new_level = breakeven:round(trade.Open + self._stream:tick(NOW) * self._stream_multiplicator, self:GetOffer().Digits);
                else
                    new_level = breakeven:round(trade.Open - self._stream:tick(NOW) * self._stream_multiplicator, self:GetOffer().Digits);
                end
            else
                new_level = breakeven:round(self._stream:tick(NOW), self:GetOffer().Digits);
            end
            if self._min_profit ~= nil then
                if trade.BS == "B" then
                    if (trade.Open - new_level) / self:GetOffer().PointSize < self._min_profit then
                        return true;
                    end
                else
                    if (new_level - trade.Open) / self:GetOffer().PointSize < self._min_profit then
                        return true;
                    end
                end
            end
            if trade.Limit ~= new_level then
                self._move_command = self._parent._trading:MoveLimit(trade, self._stream:tick(NOW));
            end
        end
        return true;
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end

function breakeven:CreateTrailingLimitController()
    local controller = self:CreateBaseController();
    function controller:SetDirection(direction)
        self._direction = direction;
        return self;
    end
    function controller:SetTrigger(trigger)
        self._trigger = trigger;
        return self;
    end
    function controller:SetStep(step)
        self._step = step;
        return self;
    end
    function controller:DoBreakeven()
        if self._executed then
            return false;
        end
        local trade = self:GetTrade();
        if trade == nil or (self._move_command ~= nil and not self._move_command.Finished) then
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        if self._direction == 1 then
            if trade.PL >= self._trigger then
                local offer = self:GetOffer();
                local target_limit;
                if trade.BS == "B" then
                    target_limit = self._initial_limit + self._step * offer.PointSize; 
                else
                    target_limit = self._initial_limit - self._step * offer.PointSize; 
                end
                self._initial_limit = target_limit;
                self._trigger = self._trigger + self._step;
                self._move_command = self._parent._trading:MoveLimit(trade, target_limit);
                return true;
            end
        elseif self._direction == -1 then
            if trade.PL <= -self._trigger then
                local offer = self:GetOffer();
                local target_limit;
                if trade.BS == "B" then
                    target_limit = self._initial_limit - self._step * offer.PointSize; 
                else
                    target_limit = self._initial_limit + self._step * offer.PointSize; 
                end
                self._initial_limit = target_limit;
                self._trigger = self._trigger + self._step;
                self._move_command = self._parent._trading:MoveLimit(trade, target_limit);
                return true;
            end
        else
            core.host:trace("No direction is set for the trailing limit");
        end
        return true;
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end

function breakeven:CreateController()
    local controller = self:CreateBaseController();
    controller._trailing = 0;
    function controller:SetWhen(when)
        self._when = when;
        return self;
    end
    function controller:SetTo(to)
        self._to = to;
        return self;
    end
    function controller:SetTrailing(trailing)
        self._trailing = trailing
        return self;
    end
    function controller:SetPartialClose(amountPercent)
        self._close_percent = amountPercent;
        return self;
    end
    function controller:getTo()
        local trade = self:GetTrade();
        local offer = self:GetOffer();
        if trade.BS == "B" then
            return offer.Bid - (trade.PL - self._to) * offer.PointSize;
        else
            return offer.Ask + (trade.PL - self._to) * offer.PointSize;
        end
    end
    function controller:DoPartialClose()
        local trade = self:GetTrade();
        if trade == nil then
            return true;
        end
        if not trade:refresh() then
            self._close_percent = nil;
            return false;
        end
        local base_size = core.host:execute("getTradingProperty", "baseUnitSize", trade.Instrument, trade.AccountID);
        local to_close = breakeven:round(trade.Lot * self._close_percent / 100.0 / base_size) * base_size;
        trading:ParialClose(trade, to_close);
        self._close_percent = nil;
        return true;
    end
    function controller:DoBreakeven()
        if self._executed then
            if self._close_percent ~= nil then
                if self._command ~= nil and self._command.Finished or self._command == nil then
                    self._close_percent = nil;
                    return self:DoPartialClose();
                end
            end
            return false;
        end
        local trade = self:GetTrade();
        if trade == nil then
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        if trade.PL >= self._when then
            if self._to ~= nil then
                self._command = self._parent._trading:MoveStop(trade, self:getTo(), self._trailing);
            end
            self._executed = true;
            return false;
        end
        return true;
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end

function breakeven:RestoreTrailingOnProfitController(controller)
    controller._parent = self;
    function controller:SetProfitPercentage(profit_pr, min_profit)
        self._profit_pr = profit_pr;
        self._min_profit = min_profit;
        return self;
    end
    function controller:GetClosedTrade()
        if self._closed_trade == nil then
            self._closed_trade = core.host:findTable("closed trades"):find("OpenOrderReqID", self._request_id);
            if self._closed_trade == nil then return nil; end
        end
        if not self._closed_trade:refresh() then return nil; end
        return self._closed_trade;
    end
    function controller:getStopPips(trade)
        local stop = trading:FindStopOrder(trade);
        if stop == nil then
            return nil;
        end
        local offer = self:GetOffer();
        if trade.BS == "B" then
            return (stop.Rate - trade.Open) / offer.PointSize;
        else
            return (trade.Open - stop.Rate) / offer.PointSize;
        end
    end
    function controller:DoBreakeven()
        if self._executed then
            return false;
        end
        if self._move_command ~= nil and not self._move_command.Finished then
            return true;
        end
        local trade = self:GetTrade();
        if trade == nil then
            if self:GetClosedTrade() ~= nil then
                self._executed = true;
            end
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        if trade.PL < self._min_profit then
            return true;
        end
        local new_stop = trade.PL * (self._profit_pr / 100);
        local current_stop = self:getStopPips(trade);
        if current_stop == nil or current_stop < new_stop then
            local offer = self:GetOffer();
            if trade.BS == "B" then
                if not trailing_mark:hasData(NOW) then
                    trailing_mark[NOW] = trade.Close;
                end
                self._move_command = self._parent._trading:MoveStop(trade, trade.Open + new_stop * offer.PointSize);
                core.host:trace("Moving stop for " .. trade.TradeID .. " to " .. trade.Open + new_stop * offer.PointSize);
            else
                if not trailing_mark:hasData(NOW) then
                    trailing_mark[NOW] = trade.Close;
                end
                self._move_command = self._parent._trading:MoveStop(trade, trade.Open - new_stop * offer.PointSize);
                core.host:trace("Moving stop for " .. trade.TradeID .. " to " .. trade.Open - new_stop * offer.PointSize);
            end
            return true;
        end
        return true;
    end
end

function breakeven:CreateTrailingOnProfitController()
    local controller = self:CreateBaseController();
    controller._trailing = 0;
    self:RestoreTrailingOnProfitController(controller);
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end
breakeven:RegisterModule(Modules);

tables_monitor = {};
tables_monitor.Name = "Tables monitor";
tables_monitor.Version = "1.0";
tables_monitor.Debug = false;
tables_monitor._ids_start = nil;
tables_monitor._new_trade_id = nil;
tables_monitor._trade_listeners = {};
tables_monitor._closed_trade_listeners = {};
function tables_monitor:ListenTrade(func)
    self._trade_listeners[#self.tables_monitor + 1] = func;
end
function tables_monitor:ListenCloseTrade(func)
    self._closed_trade_listeners[#self._closed_trade_listeners + 1] = func;
end
function tables_monitor:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function tables_monitor:Init(parameters) end
function tables_monitor:Prepare(name_only)
    if name_only then return; end
    self._new_trade_id = self._ids_start;
    self._ids_start = self._ids_start + 1;
    core.host:execute("subscribeTradeEvents", self._new_trade_id, "trades");
end
function tables_monitor:OnNewModule(module) end
function tables_monitor:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end
function tables_monitor:ReleaseInstance() end
function tables_monitor:AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == self._new_trade_id then
        local trade_id = message;
        local close_trade = success;
        if close_trade then
            local closed_trade = core.host:findTable("closed trades"):find("TradeID", trade_id);
            if closed_trade ~= nil then
                for _, callback in ipairs(self._closed_trade_listeners) do
                    callback(breakeven, closed_trade);
                end
            end
        else
            local trade = core.host:findTable("trades"):find("TradeID", message);
            if trade ~= nil then
                for _, callback in ipairs(self._trade_listeners) do
                    callback(trade);
                end
            end
        end
    end
end
function tables_monitor:ExtUpdate(id, source, period) end
function tables_monitor:BlockTrading(id, source, period) return false; end
function tables_monitor:BlockOrder(order_value_map) return false; end
function tables_monitor:OnOrder(order_value_map) end
tables_monitor:RegisterModule(Modules);

signaler = {};
signaler.Name = "Signaler";
signaler.Debug = false;
signaler.Version = "1.5";

signaler._show_alert = nil;
signaler._sound_file = nil;
signaler._recurrent_sound = nil;
signaler._email = nil;
signaler._ids_start = nil;
signaler._advanced_alert_timer = nil;
signaler._tz = nil;
signaler._alerts = {};

function signaler:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function signaler:OnNewModule(module) end
function signaler:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end

function signaler:ToJSON(item)
    local json = {};
    function json:AddStr(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value));
    end
    function json:AddNumber(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0);
    end
    function json:AddBool(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false");
    end
    function json:ToString()
        return "{" .. (self.str or "") .. "}";
    end
    
    local first = true;
    for idx,t in pairs(item) do
        local stype = type(t)
        if stype == "number" then
            json:AddNumber(idx, t);
        elseif stype == "string" then
            json:AddStr(idx, t);
        elseif stype == "boolean" then
            json:AddBool(idx, t);
        elseif stype == "function" or stype == "table" then
            --do nothing
        else
            core.host:trace(tostring(idx) .. " " .. tostring(stype));
        end
    end
    return json:ToString();
end

function signaler:ArrayToJSON(arr)
    local str = "[";
    for i, t in ipairs(self._alerts) do
        local json = self:ToJSON(t);
        if str == "[" then
            str = str .. json;
        else
            str = str .. "," .. json;
        end
    end
    return str .. "]";
end

function signaler:AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == self._advanced_alert_timer and #self._alerts > 0 and (self.last_req == nil or not self.last_req:loading()) then
        if self._advanced_alert_key == nil then
            return;
        end

        local data = self:ArrayToJSON(self._alerts);
        self._alerts = {};
        
        self.last_req = http_lua.createRequest();
        local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
            self._advanced_alert_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
        self.last_req:setRequestHeader("Content-Type", "application/json");
        self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

        self.last_req:start("http://profitrobots.com/api/v1/notification", "POST", query);
    end
end

function signaler:FormatEmail(source, period, message)
    --format email subject
    local subject = message .. "(" .. source:instrument() .. ")";
    --format email text
    local delim = "\013\010";
    local signalDescr = "Signal: " .. (self.StrategyName or "");
    local symbolDescr = "Symbol: " .. source:instrument();
    local messageDescr = "Message: " .. message;
    local ttime = core.dateToTable(core.host:execute("convertTime", core.TZ_EST, self._ToTime, source:date(period)));
    local dateDescr = string.format("Time:  %02i/%02i %02i:%02i", ttime.month, ttime.day, ttime.hour, ttime.min);
    local priceDescr = "Price: " .. source[period];
    local text = "You have received this message because the following signal alert was received:"
        .. delim .. signalDescr .. delim .. symbolDescr .. delim .. messageDescr .. delim .. dateDescr .. delim .. priceDescr;
    return subject, text;
end

function signaler:Signal(message, source)
    if source == nil then
        source = instance.bid;
        if instance.bid == nil then
            local pane = core.host.Window.CurrentPane;
            source = pane.Data:getStream(0);
        else
            source = instance.bid;
        end
    end
    if self._show_alert then
        terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW));
    end

    if self._sound_file ~= nil then
        terminal:alertSound(self._sound_file, self._recurrent_sound);
    end

    if self._email ~= nil then
        terminal:alertEmail(self._email, profile:id().. " : " .. message, self:FormatEmail(source, NOW, message));
    end

    if self._advanced_alert_key ~= nil then
        self:AlertTelegram(message, source:instrument(), source:barSize());
    end

    if self._signaler_debug_alert then
        core.host:trace(message);
    end

    if self._show_popup then
        local subject, text = self:FormatEmail(source, NOW, message);
        core.host:execute("prompt", self._ids_start + 2, subject, text);
    end

    if self._dde_alerts then
        dde_server:set(self.dde_topic, self.dde_alerts, message);
    end
end

function signaler:AlertTelegram(message, instrument, timeframe)
    if core.host.Trading:getTradingProperty("isSimulation") then
        return;
    end
    local alert = {};
    alert.Text = message or "";
    alert.Instrument = instrument or "";
    alert.TimeFrame = timeframe or "";
    self._alerts[#self._alerts + 1] = alert;
end

function signaler:Init(parameters)
    parameters:addInteger("signaler_ToTime", "Convert the date to", "", 6)
    parameters:addIntegerAlternative("signaler_ToTime", "EST", "", 1)
    parameters:addIntegerAlternative("signaler_ToTime", "UTC", "", 2)
    parameters:addIntegerAlternative("signaler_ToTime", "Local", "", 3)
    parameters:addIntegerAlternative("signaler_ToTime", "Server", "", 4)
    parameters:addIntegerAlternative("signaler_ToTime", "Financial", "", 5)
    parameters:addIntegerAlternative("signaler_ToTime", "Display", "", 6)
    
    parameters:addBoolean("signaler_show_alert", "Show Alert", "", true);
    parameters:addBoolean("signaler_play_sound", "Play Sound", "", false);
    parameters:addFile("signaler_sound_file", "Sound File", "", "");
    parameters:setFlag("signaler_sound_file", core.FLAG_SOUND);
    parameters:addBoolean("signaler_recurrent_sound", "Recurrent Sound", "", true);
    parameters:addBoolean("signaler_send_email", "Send Email", "", false);
    parameters:addString("signaler_email", "Email", "", "");
    parameters:setFlag("signaler_email", core.FLAG_EMAIL);
    if indicator ~= nil and strategy == nil then
        parameters:addBoolean("signaler_show_popup", "Show Popup", "", false);
    end
    parameters:addBoolean("signaler_debug_alert", "Print Into Log", "", false);
    parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram message or Channel post", false);
    parameters:addString("advanced_alert_key", "Advanced Alert Key", "You can get it via @profit_robots_bot Telegram bot", "");
    if DDEAlertsSupport then
        parameters:addBoolean("signaler_dde_export", "DDE Export", "You can export the alert into the Excel or any other application with DDE support (=Service Name|DDE Topic!Alerts)", false);
        parameters:addString("signaler_dde_service", "Service Name", "The service name must be unique amoung all running instances of the strategy", "TS2ALERTS");
        parameters:addString("signaler_dde_topic", "DDE Topic", "", "");
    end
end

function signaler:Prepare(name_only)
    self._ToTime = instance.parameters.signaler_ToTime
    if self._ToTime == 1 then
        self._ToTime = core.TZ_EST
    elseif self._ToTime == 2 then
        self._ToTime = core.TZ_UTC
    elseif self._ToTime == 3 then
        self._ToTime = core.TZ_LOCAL
    elseif self._ToTime == 4 then
        self._ToTime = core.TZ_SERVER
    elseif self._ToTime == 5 then
        self._ToTime = core.TZ_FINANCIAL
    elseif self._ToTime == 6 then
        self._ToTime = core.TZ_TS
    end
    self._dde_alerts = instance.parameters.signaler_dde_export;
    if self._dde_alerts then
        assert(instance.parameters.signaler_dde_topic ~= "", "You need to specify the DDE topic");
        require("ddeserver_lua");
        self.dde_server = ddeserver_lua.new(instance.parameters.signaler_dde_service);
        self.dde_topic = self.dde_server:addTopic(instance.parameters.signaler_dde_topic);
        self.dde_alerts = self.dde_server:addValue(self.dde_topic, "Alerts");
    end

    if instance.parameters.signaler_play_sound then
        self._sound_file = instance.parameters.signaler_sound_file;
        assert(self._sound_file ~= "", "Sound file must be chosen");
    end
    self._show_alert = instance.parameters.signaler_show_alert;
    self._recurrent_sound = instance.parameters.signaler_recurrent_sound;
    self._show_popup = instance.parameters.signaler_show_popup;
    self._signaler_debug_alert = instance.parameters.signaler_debug_alert;
    if instance.parameters.signaler_send_email then
        self._email = instance.parameters.signaler_email;
        assert(self._email ~= "", "E-mail address must be specified");
    end
    --do what you usually do in prepare
    if name_only then
        return;
    end

    if instance.parameters.advanced_alert_key ~= "" and instance.parameters.use_advanced_alert then
        self._advanced_alert_key = instance.parameters.advanced_alert_key;
        require("http_lua");
        self._advanced_alert_timer = self._ids_start + 1;
        core.host:execute("setTimer", self._advanced_alert_timer, 1);
    end
end

function signaler:ReleaseInstance()
    if self.dde_server ~= nil then
        self.dde_server:close();
    end
end

signaler:RegisterModule(Modules);