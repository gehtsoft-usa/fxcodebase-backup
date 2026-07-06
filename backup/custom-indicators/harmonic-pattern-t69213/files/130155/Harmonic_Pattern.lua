-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69213

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
    tool:name("Harmonic Pattern");
    tool:description("");
    tool:icon("");
    tool.creationStrategy:setPattern(core.Click);
    tool.creationStrategy:setMaxClickCount(5);
    tool.creationStrategy:setNeedParamsAfterPattern(true);
    tool:setTag("group", "Shapes");
    tool:setTag("orderInGroup", "1");
    tool:setTag("NonResetableParameters", "rate_x,date_x,rate_a,date_a,rate_b,date_b,rate_c,date_c,rate_d,date_d");
    tool:setTag("requiredPaneType", "hasStreams");

    tool.parameters:addDouble("rate_x", "Rate X", "", 0);
    tool.parameters:addDate("date_x", "Date X", "", 0);
    tool.parameters:setFlag("date_x", core.FLAG_DATETIME);

    tool.parameters:addDouble("rate_a", "Rate A", "", 0);
    tool.parameters:addDate("date_a", "Date A", "", 0);
    tool.parameters:setFlag("date_a", core.FLAG_DATETIME);

    tool.parameters:addDouble("rate_b", "Rate B", "", 0);
    tool.parameters:addDate("date_b", "Date B", "", 0);
    tool.parameters:setFlag("date_b", core.FLAG_DATETIME);

    tool.parameters:addDouble("rate_c", "Rate C", "", 0);
    tool.parameters:addDate("date_c", "Date C", "", 0);
    tool.parameters:setFlag("date_c", core.FLAG_DATETIME);

    tool.parameters:addDouble("rate_d", "Rate D", "", 0);
    tool.parameters:addDate("date_d", "Date D", "", 0);
    tool.parameters:setFlag("date_d", core.FLAG_DATETIME);
    
    tool.parameters:addGroup("Style");
    tool.parameters:addColor("main_color", "Color", "Color", core.colors().Red);
    tool.parameters:addInteger("main_width", "Width", "Width", 1, 1, 5);
    tool.parameters:addInteger("main_style", "Style", "Style", core.LINE_SOLID);
    tool.parameters:setFlag("main_style", core.FLAG_LINE_STYLE);
end

function CreatePointController(index, date_id, rate_id, color, width)
    local controller = {};
    controller.index = index;
    controller.date_id = date_id;
    controller.rate_id = rate_id;
    controller.color = color;
    controller.width = width;
    function controller:UpdatePoint(date, rate)
        instance.parameters:setDate(self.date_id, date);
        instance.parameters:setDouble(self.rate_id, rate);

        local referencePoints = core.host.ReferencePoints;
        referencePoints:setReferencePoint(self.index, date, rate, referencePoints.DATE + referencePoints.PRICE, self.color, self.width + 1);
    end
    function controller:MoveStart()
        local pane = core.host.Window.CurrentPane;
        local stream = pane.Data:getStream(0);
        self.initial_rate = instance.parameters:getDouble(self.rate_id);
        self.initial_period = core.host:execute("calculatePositionOfDate", stream, instance.parameters:getDate(self.date_id));
    end
    function controller:Move(rate_diff, period_diff)
        local pane = core.host.Window.CurrentPane;
        local stream = pane.Data:getStream(0);
        local new_date = core.host:execute("calculateDate", stream, self.initial_period + period_diff)
        local new_rate = self.initial_rate + rate_diff;
        self:UpdatePoints(new_date, new_rate);
    end
    function controller:GetXY(context)
        local x, x1, x2 = context:positionOfDate(instance.parameters:getDate(self.date_id));
        local visible, y = context:pointOfPrice(instance.parameters:getDouble(self.rate_id));
        return x, y;
    end
    return controller;
end

local points = {};

function CreationStarted()
    points[1] = CreatePointController(1, "date_x", "rate_x", instance.parameters.main_color, instance.parameters.main_width);
    points[2] = CreatePointController(2, "date_a", "rate_a", instance.parameters.main_color, instance.parameters.main_width);
    points[3] = CreatePointController(3, "date_b", "rate_b", instance.parameters.main_color, instance.parameters.main_width);
    points[4] = CreatePointController(4, "date_c", "rate_c", instance.parameters.main_color, instance.parameters.main_width);
    points[5] = CreatePointController(5, "date_d", "rate_d", instance.parameters.main_color, instance.parameters.main_width);
end

local click = 1;
function Click(x, y, price, date)
    if click == 1 then
        points[1]:UpdatePoint(date, price);
    end
    if click <= 2 then
        points[2]:UpdatePoint(date, price);
    end 
    if click <= 3 then
        points[3]:UpdatePoint(date, price);
    end
    if click <= 4 then
        points[4]:UpdatePoint(date, price);
    end
    if click <= 5 then
        points[5]:UpdatePoint(date, price);
    end
    click = click + 1;
end

function DoubleClick(x, y, price, date)
end

function CreationFinished()
end

local movingPointID;
function MoveReferencePointStart(id)
    movingPointID = id;
end

function MoveReferencePoint(x, y, price, date)
    points[movingPointID]:UpdatePoint(date, price);
end

function MoveReferencePointFinished()
end

local start_rate = nil;
local start_period = nil;
function MoveStart()
    start_rate = nil;
    start_period = nil;
    for i, point in ipairs(points) do
        point:MoveStart();
    end
end

function Move(x, y, price, date)
    local pane = core.host.Window.CurrentPane;
    local stream = pane.Data:getStream(0);
    if start_period == nil then
        start_rate = price;
        start_period = core.host:execute("calculatePositionOfDate", stream, date);
    else
        local rate_diff = price - start_rate;
        local period_diff = core.host:execute("calculatePositionOfDate", stream, date) - start_period;
        for i, point in ipairs(points) do
            point:Move(rate_diff, period_diff);
        end
    end
end

function MoveFinished()
    start_rate = nil;
    start_period = nil;
end

local init = false;

local MAIN_LINE = 1;
local last_x1;
local last_y1;
local last_x_shit;
local last_y_shift;
function Draw(stage, context)
    if stage == 2 then
        if not init then
            context:createPen(MAIN_LINE, context:convertPenStyle(instance.parameters.main_style), instance.parameters.main_width, instance.parameters.main_color);
            init = true;
        end
        context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
        local x_x, x_y = points[1]:GetXY(context);
        local a_x, a_y = points[2]:GetXY(context);
        local b_x, b_y = points[3]:GetXY(context);
        local c_x, c_y = points[4]:GetXY(context);
        local d_x, d_y = points[5]:GetXY(context);

        local triagnle = ownerdraw_points.new();
        triagnle:add(x_x, x_y);
        triagnle:add(b_x, b_y);
        triagnle:add(d_x, d_y);
        triagnle:add(x_x, x_y);
        context:drawPolyline(MAIN_LINE, triagnle);

        triagnle = ownerdraw_points.new();
        triagnle:add(c_x, c_y);
        triagnle:add(b_x, b_y);
        triagnle:add(d_x, d_y);
        triagnle:add(c_x, c_y);
        context:drawPolyline(MAIN_LINE, triagnle);

        triagnle = ownerdraw_points.new();
        triagnle:add(c_x, c_y);
        triagnle:add(a_x, a_y);
        triagnle:add(b_x, b_y);
        triagnle:add(c_x, c_y);
        context:drawPolyline(MAIN_LINE, triagnle);

        triagnle = ownerdraw_points.new();
        triagnle:add(x_x, x_y);
        triagnle:add(a_x, a_y);
        triagnle:add(b_x, b_y);
        triagnle:add(x_x, x_y);
        context:drawPolyline(MAIN_LINE, triagnle);

        context:resetClipRectangle();
    end
end

function Prepare(onlyName)
    local name = profile:name();
    instance:name(name);
    
    if onlyName then
        return;
    end
    
    init = false;
end

function CheckParameters(params)
    return profile:name();
end

function ChangeParameters()
    Prepare(false);
end
