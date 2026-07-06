-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76267

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 

local Modules = {};

function Init()
    tool:name("Trendline cross trading");
    tool:description("");
    tool:icon("");
    tool.creationStrategy:setPattern(core.DragClick);
    tool.creationStrategy:setMaxClickCount(0);
    tool.creationStrategy:setNeedParamsAfterPattern(true);
    tool:setTag("group", "Lines");
    tool:setTag("orderInGroup", "1");
    tool:setTag("NonResetableParameters", "start_rate,start_date,end_rate,end_date");
    tool:setTag("requiredPaneType", "hasStreams");

    tool.parameters:addDouble("start_rate", "Rate start", "", 0);
    tool.parameters:addDate("start_date", "Date start", "", 0);
    tool.parameters:setFlag("start_date", core.FLAG_DATETIME);
    tool.parameters:addDouble("end_rate", "Rate end", "", 0);
    tool.parameters:addDate("end_date", "Date end", "", 0);
    tool.parameters:setFlag("end_date", core.FLAG_DATETIME);
    
    tool.parameters:addString("account", "Account to trade on", "", "");
    tool.parameters:setFlag("account", core.FLAG_ACCOUNT);
    
    tool.parameters:addGroup("Style");
    tool.parameters:addColor("trend_color", "Color", "", core.rgb(132, 130, 132));
    tool.parameters:addInteger("trend_width", "Width", "", 1, 1, 5);
    tool.parameters:addInteger("trend_style", "Style", "", core.LINE_SOLID);
    tool.parameters:setFlag("trend_style", core.FLAG_LINE_STYLE);

    tool.parameters:addColor("entry_color", "Entry Color", "", core.rgb(132, 130, 132));
    tool.parameters:addInteger("entry_width", "Entry Width", "", 1, 1, 5);
    tool.parameters:addInteger("entry_style", "Entry Style", "", core.LINE_SOLID);
    tool.parameters:setFlag("entry_style", core.FLAG_LINE_STYLE);

    tool.parameters:addString("order_type", "Order type", "", "B");
    tool.parameters:addStringAlternative("order_type", "Buy", "", "B");
    tool.parameters:addStringAlternative("order_type", "Sell", "", "S");
    tool.parameters:addString("Account", "Account to trade on", "", "");
    tool.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    tool.parameters:addString("amount_type", "Amount Units", "", "lots");
    tool.parameters:addStringAlternative("amount_type", "Lots", "", "lots");
    tool.parameters:addStringAlternative("amount_type", "% of equity", "", "equity");
    tool.parameters:addDouble("Amount", "Trade Amount", "", 1, 1, 1000000);
	
    tool.parameters:addBoolean("use_max", "Use Max Trade Amount", "", false);
    tool.parameters:addDouble("max", "Max Trade Amount", "", 10);
	
    tool.parameters:addGroup("Money Management");
    tool.parameters:addBoolean("use_stop", "Set Stop", "", false);
    tool.parameters:addDouble("stop_pips", "Stop, pips", "", 10);
    tool.parameters:addBoolean("use_trailing", "Trailing stop order", "", false);
    tool.parameters:addInteger("trailing", "Trailing in pips", "Use 1 for dynamic and 10 or greater for the fixed trailing", 1);
    tool.parameters:addBoolean("use_limit", "Set Limit", "", false);
    tool.parameters:addDouble("limit_pips", "Limit, pips", "", 20);
    tool.parameters:addString("custom_id", "Custom ID", "", "");
end

local executed = false;
function CreationStarted(Parameters)
end

local start_rate;
local start_date;
local click = 1;
function Click(x, y, price, date)
    if click == 1 then
        start_rate = price;
        start_date = date;
        instance.parameters.start_rate = price;
        instance.parameters.start_date = date;
        instance.parameters.end_rate = price;
        instance.parameters.end_date = date;
    elseif click == 2 then
        instance.parameters.end_rate = price;
        instance.parameters.end_date = date;
    end
    click = click + 1;
    UpdateReferencePoints();
end

function Drag(x, y, price, date)    
    instance.parameters.end_rate = price;
    instance.parameters.end_date = date;
    UpdateReferencePoints();
end

function DragEnd(x, y, price, date)
    click = click + 1;
end

function DoubleClick(x, y, price, date)
end

local last_stream_size = 0;
function UpdateReferencePoints()
    local pane = core.host.Window.CurrentPane;
    local stream = pane.Data:getStream(0);
    last_stream_size = stream:size();
    local referencePoints = core.host.ReferencePoints;
    referencePoints:setReferencePoint(1, instance.parameters.start_date, instance.parameters.start_rate, referencePoints.DATE + referencePoints.PRICE, instance.parameters.trend_color, instance.parameters.trend_width + 1);
    referencePoints:setReferencePoint(2, instance.parameters.end_date, instance.parameters.end_rate, referencePoints.DATE + referencePoints.PRICE, instance.parameters.trend_color, instance.parameters.trend_width + 1);
end

function CreationFinished()
end

local movingPointID;
function MoveReferencePointStart(id)
    movingPointID = id;
end

function MoveReferencePoint(x, y, price, date)
    if movingPointID == 1 then
        instance.parameters.start_date = date;
        instance.parameters.start_rate = price;
        UpdateReferencePoints();
    elseif movingPointID == 2 then
        instance.parameters.end_date = date;
        instance.parameters.end_rate = price;
        UpdateReferencePoints();
    end
end

function MoveReferencePointFinished()
    executed = false;
end

local start_rate = nil;
local start_period = nil;
local start_rate_start;
local period_1_start;
local end_rate_start;
local period_2_start;
function MoveStart()
    local pane = core.host.Window.CurrentPane;
    local stream = pane.Data:getStream(0);
    
    start_rate = nil;
    start_period = nil;
    start_rate_start = instance.parameters.start_rate;
    period_1_start = core.host:execute("calculatePositionOfDate", stream, instance.parameters.start_date);
    end_rate_start = instance.parameters.end_rate;
    period_2_start = core.host:execute("calculatePositionOfDate", stream, instance.parameters.end_date);
end

function Move(x, y, price, date)
    local pane = core.host.Window.CurrentPane;
    local stream = pane.Data:getStream(0);
    if start_rate == nil then
        start_rate = price;
        start_period = core.host:execute("calculatePositionOfDate", stream, date);
    else
        local rate_diff = price - start_rate;
        local period_diff = core.host:execute("calculatePositionOfDate", stream, date) - start_period;
        instance.parameters.start_rate = start_rate_start + rate_diff;
        instance.parameters.start_date = core.host:execute("calculateDate", stream, period_1_start + period_diff);
        instance.parameters.end_rate = end_rate_start + rate_diff;
        instance.parameters.end_date = core.host:execute("calculateDate", stream, period_2_start + period_diff);
        UpdateReferencePoints();
    end
end

function MoveFinished()
    start_rate = nil;
    start_period = nil;
    executed = false;
end

local init = false;

function get_point_coordinates(date, price, context)
    local x, x1, x2 = context:positionOfDate(date);
    local visible, y = context:pointOfPrice(price);
    return x, y;
end

local TREND_LINE = 1;
local ENTRY_LINE = 2;
local FONT_ID = 5;
function Draw(stage, context)
    if stage == 2 then
        if not init then
            context:createPen(TREND_LINE, context:convertPenStyle(instance.parameters.trend_style), instance.parameters.trend_width, instance.parameters.trend_color);
            context:createPen(ENTRY_LINE, context:convertPenStyle(instance.parameters.entry_style), instance.parameters.entry_width, instance.parameters.entry_color);
            init = true;
        end
        local pane = core.host.Window.CurrentPane;
        local stream = pane.Data:getStream(0);
        if last_stream_size ~= stream:size() then
            UpdateReferencePoints();
        end
        
        local x1, y1 = get_point_coordinates(instance.parameters.start_date, instance.parameters.start_rate, context);
        local x2, y2 = get_point_coordinates(instance.parameters.end_date, instance.parameters.end_rate, context);
        context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
        context:drawLine(TREND_LINE, x1, y1, x2, y2);

        context:resetClipRectangle();
    end
end

local TIMER_ID = 1;
local order_type, Account, amount_type, Amount, use_stop, stop_pips, use_trailing, trailing, use_limit, limit_pips, custom_id, offer_id, base_size;
function Prepare(onlyName)
    local name = profile:name();
    instance:name(name);
	
	base_size = nil
    
    order_type = instance.parameters.order_type;
    Account = instance.parameters.Account;
    amount_type = instance.parameters.amount_type;
    Amount = instance.parameters.Amount;
    use_stop = instance.parameters.use_stop;
    stop_pips = instance.parameters.stop_pips;
    use_trailing = instance.parameters.use_trailing;
    trailing = instance.parameters.trailing;
    use_limit = instance.parameters.use_limit;
    limit_pips = instance.parameters.limit_pips;
    custom_id = instance.parameters.custom_id;
	use_max = instance.parameters.use_max;
	max = instance.parameters.max;
	
    if onlyName then
        return;
    end
    
    init = false;
    last_stream_size = 0;
    UpdateReferencePoints();

    core.host:execute("setTimer", TIMER_ID, 1)
end

local temp_params;
function CheckParameters(params)
    temp_params = params;
    return profile:name();
end

function ChangeParameters()
    executed = false;
    -- copy all the params because of FXTS2 bug
    instance.parameters.start_rate = temp_params.start_rate;
    instance.parameters.start_date = temp_params.start_date;
    instance.parameters.end_rate = temp_params.end_rate;
    instance.parameters.end_date = temp_params.end_date;
    instance.parameters.account = temp_params.account;
    instance.parameters.trend_color = temp_params.trend_color;
    instance.parameters.trend_width = temp_params.trend_width;
    instance.parameters.trend_style = temp_params.trend_style;
    instance.parameters.entry_color = temp_params.entry_color;
    instance.parameters.entry_width = temp_params.entry_width;
    instance.parameters.entry_style = temp_params.entry_style;
    instance.parameters.order_type = temp_params.order_type;
    instance.parameters.Account = temp_params.Account;
    instance.parameters.amount_type = temp_params.amount_type;
    instance.parameters.Amount = temp_params.Amount;
    instance.parameters.use_stop = temp_params.use_stop;
    instance.parameters.stop_pips = temp_params.stop_pips;
    instance.parameters.use_trailing = temp_params.use_trailing;
    instance.parameters.trailing = temp_params.trailing;
    instance.parameters.use_limit = temp_params.use_limit;
    instance.parameters.limit_pips = temp_params.limit_pips;
    instance.parameters.custom_id = temp_params.custom_id;
    instance.parameters.use_max = temp_params.use_max;
    instance.parameters.max = temp_params.max;

    Prepare(false);
end

function OpenTrade(side)





    local valuemap = core.valuemap();
    valuemap.OrderType = "OM";
    valuemap.OfferID = offer_id;
    valuemap.AcctID = Account;
    if amount_type == "lots" then
        valuemap.Quantity = Amount * base_size;
    else
        local equity = core.host:findTable("accounts"):find("AccountID", valuemap.AcctID).Equity;
        local used_equity = equity * Amount / 100.0;
        local emr = core.host:getTradingProperty("EMR", instance.bid:instrument(), valuemap.AcctID);
        valuemap.Quantity = math.floor(used_equity / emr) * base_size;
    end
	
    local enum, row;
    local count = 0;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while row ~= nil do
        if row.AccountID == Account 
		and row.OfferID ==  offer_id
		and row.QTXT ==    custom_id
		then
            count = count + 1;
        end

        row = enum:next();
    end
	
	
	if use_max and count >= max then
    return;
    end	
	
    valuemap.BuySell = side;
    valuemap.CustomID = custom_id;
    if use_stop then
        valuemap.PegTypeStop = "O";
        if side == "B" then
            valuemap.PegPriceOffsetPipsStop = -stop_pips;
        else
            valuemap.PegPriceOffsetPipsStop = stop_pips;
        end
        if use_trailing then
            valuemap.TrailStepStop = trailing;
        end
    end
    if use_limit then
        valuemap.PegTypeLimit = "O";
        if side == "B" then
            valuemap.PegPriceOffsetPipsLimit = limit_pips;
        else
            valuemap.PegPriceOffsetPipsLimit = -limit_pips;
        end
    end
    local success, msg = terminal:execute(3, valuemap);
end

function CrossedUpHist(stream, rate_per_bar)
    if stream:size() < 2 then
        return false;
    end
    local current_level = instance.parameters.start_rate + rate_per_bar * (stream:date(NOW) - instance.parameters.start_date);
    local previous_level = instance.parameters.start_rate + rate_per_bar * (stream:date(NOW - 1) - instance.parameters.start_date);
    core.host:trace(stream:tick(NOW) .. " " .. current_level .. " " .. stream:tick(NOW - 1) .. " " .. previous_level);
    return stream:tick(NOW) > current_level and stream:tick(NOW - 1) < previous_level;
end

function CrossedDownHist(stream, rate_per_bar)
    if stream:size() < 2 then
        return false;
    end
    local current_level = instance.parameters.start_rate + rate_per_bar * (stream:date(NOW) - instance.parameters.start_date);
    local previous_level = instance.parameters.start_rate + rate_per_bar * (stream:date(NOW - 1) - instance.parameters.start_date);
    return stream:tick(NOW) < current_level and stream:tick(NOW - 1) > previous_level;
end

function AsyncOperationFinished(cookie, success, message, message1, message2)



    if cookie == TIMER_ID and not executed then
        local pane = core.host.Window.CurrentPane;
        local stream = pane.Data:getStream(0);
        if base_size == nil then
            base_size = core.host:execute("getTradingProperty", "baseUnitSize", stream:instrument(), Account);
            offer_id = core.host:findTable("offers"):find("Instrument", stream:instrument()).OfferID;
        end
        local range_rate = instance.parameters.end_rate - instance.parameters.start_rate;
        local range_date = instance.parameters.end_date - instance.parameters.start_date;
        local rate_per_bar = range_rate / range_date;
        
        if CrossedUpHist(stream, rate_per_bar) then
            OpenTrade(order_type);
            executed = true;
        end
        if CrossedDownHist(stream, rate_per_bar) then
            OpenTrade(order_type);
            executed = true;
        end
    end
end

-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76267

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 