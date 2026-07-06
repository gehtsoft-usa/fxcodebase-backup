-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65808

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--|                         https://AppliedMachineLearning.systems   |
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
    tool:name("Triangle tool");
    tool:description("");
    tool:icon("");
    tool.creationStrategy:setPattern(core.Click);
    tool.creationStrategy:setMaxClickCount(3);
    tool.creationStrategy:setNeedParamsAfterPattern(true);
    tool:setTag("group", "Shapes");
    tool:setTag("orderInGroup", "1");
    tool:setTag("NonResetableParameters", "start_rate,start_date,x_shift,y_shift");
    tool:setTag("requiredPaneType", "hasStreams");

    tool.parameters:addDate("start_date_1", "Date start #1", "", 0);
    tool.parameters:setFlag("start_date_1", core.FLAG_DATETIME);
    tool.parameters:addDouble("start_rate_1", "Rate top #1", "", 0);

    tool.parameters:addDate("start_date_2", "Date start #2", "", 0);
    tool.parameters:setFlag("start_date_2", core.FLAG_DATETIME);
    tool.parameters:addDouble("start_rate_2", "Rate top #2", "", 0);
    
    tool.parameters:addDate("start_date_3", "Date start #3", "", 0);
    tool.parameters:setFlag("start_date_3", core.FLAG_DATETIME);
    tool.parameters:addDouble("start_rate_3", "Rate top #3", "", 0);
    
    tool.parameters:addGroup("Style");
    tool.parameters:addColor("border_color", "Border color", "", core.rgb(132, 130, 132));
    tool.parameters:addInteger("border_width", "Border width", "", 1, 1, 5);
    tool.parameters:addInteger("border_style", "Border style", "", core.LINE_SOLID);
    tool.parameters:setFlag("border_style", core.FLAG_LINE_STYLE);
    tool.parameters:addBoolean("fill", "Fill triangle", "", true);
    tool.parameters:addInteger("transparency", "Transparency", "", 50, 0, 100);
end

function CreationStarted(Parameters)
end

local start_rate;
local start_date;
local click = 1;
function Click(x, y, price, date)
    if click == 1 then
        start_rate = price;
        start_date = date;
        instance.parameters.start_rate_1 = price;
        instance.parameters.start_date_1 = date;
        instance.parameters.start_rate_2 = price;
        instance.parameters.start_date_2 = date;
        instance.parameters.start_rate_3 = price;
        instance.parameters.start_date_3 = date;
    elseif click == 2 then
        instance.parameters.start_rate_2 = price;
        instance.parameters.start_date_2 = date;
        instance.parameters.start_rate_3 = price;
        instance.parameters.start_date_3 = date;
    else
        instance.parameters.start_rate_3 = price;
        instance.parameters.start_date_3 = date;
    end
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
    referencePoints:setReferencePoint(1, instance.parameters.start_date_1, instance.parameters.start_rate_1, referencePoints.DATE + referencePoints.PRICE, instance.parameters.border_color, instance.parameters.border_width + 1);
    referencePoints:setReferencePoint(2, instance.parameters.start_date_2, instance.parameters.start_rate_2, referencePoints.DATE + referencePoints.PRICE, instance.parameters.border_color, instance.parameters.border_width + 1);
    referencePoints:setReferencePoint(3, instance.parameters.start_date_3, instance.parameters.start_rate_3, referencePoints.DATE + referencePoints.PRICE, instance.parameters.border_color, instance.parameters.border_width + 1);
end

function Drag(x, y, price, date)
end

function DragEnd(x, y, price, date)
end

function CreationFinished()
end


local movingPointID;
function MoveReferencePointStart(id)
    movingPointID = id;
end

function MoveReferencePoint(x, y, price, date)
    if movingPointID == 1 then
        instance.parameters.start_date_1 = date;
        instance.parameters.start_rate_1 = price;
        UpdateReferencePoints();
    elseif movingPointID == 2 then
        instance.parameters.start_date_2 = date;
        instance.parameters.start_rate_2 = price;
        UpdateReferencePoints();
    elseif movingPointID == 3 then
        instance.parameters.start_date_3 = date;
        instance.parameters.start_rate_3 = price;
        UpdateReferencePoints();
    end
end

function MoveReferencePointFinished()
end



local start_rate = nil;
local start_period = nil;
local start_rate_start_1;
local period_1_start;
local start_rate_start_2;
local period_2_start;
local start_rate_start_3;
local period_3_start;
function MoveStart()
    local pane = core.host.Window.CurrentPane;
    local stream = pane.Data:getStream(0);
    
    start_rate = nil;
    start_period = nil;
    start_rate_start_1 = instance.parameters.start_rate_1;
    period_1_start = core.host:execute("calculatePositionOfDate", stream, instance.parameters.start_date_1);
    start_rate_start_2 = instance.parameters.start_rate_2;
    period_2_start = core.host:execute("calculatePositionOfDate", stream, instance.parameters.start_date_2);
    start_rate_start_3 = instance.parameters.start_rate_3;
    period_3_start = core.host:execute("calculatePositionOfDate", stream, instance.parameters.start_date_3);
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
        instance.parameters.start_rate_1 = start_rate_start_1 + rate_diff;
        instance.parameters.start_date_1 = core.host:execute("calculateDate", stream, period_1_start + period_diff);
        instance.parameters.start_rate_2 = start_rate_start_2 + rate_diff;
        instance.parameters.start_date_2 = core.host:execute("calculateDate", stream, period_2_start + period_diff);
        instance.parameters.start_rate_3 = start_rate_start_3 + rate_diff;
        instance.parameters.start_date_3 = core.host:execute("calculateDate", stream, period_3_start + period_diff);
        UpdateReferencePoints();
    end
end

function MoveFinished()
    start_rate = nil;
    start_period = nil;
end

local init = false;

function get_point_coordinates(date, price, context)
    local x, x1, x2 = context:positionOfDate(date);
    local visible, y = context:pointOfPrice(price);
    return x, y;
end

local BORDER_LINE = 1;
local FILL_BRUSH = 2;
local transparency;
local last_x1;
local last_y1;
local last_x_shit;
local last_y_shift;
function Draw(stage, context)
    if stage == 2 then
        if not init then
            context:createPen(BORDER_LINE, context:convertPenStyle(instance.parameters.border_style), instance.parameters.border_width, instance.parameters.border_color);
            context:createSolidBrush(FILL_BRUSH, instance.parameters.border_color);
            if instance.parameters.fill then
                transparency = context:convertTransparency(instance.parameters.transparency);
            end
            init = true;
        end
        local pane = core.host.Window.CurrentPane;
        local stream = pane.Data:getStream(0);
        if last_stream_size ~= stream:size() then
            UpdateReferencePoints();
        end
        
        local x1, y1 = get_point_coordinates(instance.parameters.start_date_1, instance.parameters.start_rate_1, context);
        local x2, y2 = get_point_coordinates(instance.parameters.start_date_2, instance.parameters.start_rate_2, context);
        local x3, y3 = get_point_coordinates(instance.parameters.start_date_3, instance.parameters.start_rate_3, context);

        context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
        local triangle = ownerdraw_points.new();
        triangle:add(x1, y1);
        triangle:add(x2, y2);
        triangle:add(x3, y3);
        triangle:add(x1, y1);
        if transparency ~= nil then
            context:drawPolygon(BORDER_LINE, FILL_BRUSH, triangle, transparency);
        else
            context:drawPolyline(BORDER_LINE, triangle);
        end
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
    last_stream_size = 0;
    UpdateReferencePoints();
end

function CheckParameters(params)
    return profile:name();
end

function ChangeParameters()
    Prepare(false);
end
