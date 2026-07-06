-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=65808

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    tool:name("Triangle tool");
    tool:description("");
    tool:icon("");
    tool.creationStrategy:setPattern(core.DragClick);
    tool.creationStrategy:setMaxClickCount(0);
    tool.creationStrategy:setNeedParamsAfterPattern(true);
    tool:setTag("group", "Shapes");
    tool:setTag("orderInGroup", "1");
    tool:setTag("NonResetableParameters", "start_rate,start_date,x_shift,y_shift");
    tool:setTag("requiredPaneType", "hasStreams");

    tool.parameters:addDouble("start_rate", "Rate start", "", 0);
    tool.parameters:addDate("start_date", "Date start", "", 0);
    tool.parameters:setFlag("start_date", core.FLAG_DATETIME);
    tool.parameters:addInteger("x_shift", "X shift", "", 10);
    tool.parameters:addInteger("y_shift", "Y shift", "", 10);
    tool.parameters:addString("type", "Triangle type", "", "45");
    tool.parameters:addStringAlternative("type", "45-45-90", "", "45");
    tool.parameters:addStringAlternative("type", "30-60-90", "", "30");
    
    tool.parameters:addGroup("Style");
    tool.parameters:addColor("border_color", "Border color", "", core.rgb(132, 130, 132));
    tool.parameters:addInteger("border_width", "Border width", "", 1, 1, 5);
    tool.parameters:addInteger("border_style", "Border style", "", core.LINE_SOLID);
    tool.parameters:setFlag("border_style", core.FLAG_LINE_STYLE);
end

function CreationStarted(Parameters)
end

local initial_x;
local initial_y;
local start_rate;
function Click(x, y, price, date)
    start_rate = price;
    initial_x = x;
    initial_y = y;
    instance.parameters.start_rate = price;
    instance.parameters.start_date = date;
    instance.parameters.x_shift = 10;
    instance.parameters.y_shift = 10;
end

function DoubleClick(x, y, price, date)
end

local last_stream_size = 0;
function UpdateReferencePoints()
    local pane = core.host.Window.CurrentPane;
    local stream = pane.Data:getStream(0);
    last_stream_size = stream:size();
    local referencePoints = core.host.ReferencePoints;
    referencePoints:setReferencePoint(1, instance.parameters.start_date, instance.parameters.start_rate, referencePoints.DATE + referencePoints.PRICE, instance.parameters.border_color, instance.parameters.border_width + 1);
end

function Drag(x, y, price, date)
    instance.parameters.x_shift = x - initial_x;
    instance.parameters.y_shift = y - initial_y;
    
    UpdateReferencePoints();
end

function DragEnd(x, y, price, date)
    initial_x = nil;
    initial_y = nil;
end

function CreationFinished()
end

local movingPointID;
function MoveReferencePointStart(id)
    movingPointID = id;
end

local initial_x_shift;
local initial_y_shift;
function MoveReferencePoint(x, y, price, date)
    if movingPointID == 1 then
        if initial_x == nil then
            initial_x = x;
            initial_y = y;
            initial_x_shift = instance.parameters.x_shift;
            initial_y_shift = instance.parameters.y_shift;
        end
        instance.parameters.start_date = date;
        instance.parameters.start_rate = price;
        instance.parameters.x_shift = initial_x_shift + initial_x - x;
        instance.parameters.y_shift = initial_y_shift + initial_y - y;
        UpdateReferencePoints();
    elseif movingPointID == 2 then
        if initial_x == nil then
            initial_x = x;
            initial_y = y;
            initial_x_shift = instance.parameters.x_shift;
            initial_y_shift = instance.parameters.y_shift;
        end
        instance.parameters.x_shift = initial_x_shift + x - initial_x;
        instance.parameters.y_shift = initial_y_shift + y - initial_y;
        UpdateReferencePoints();
    elseif movingPointID == 3 then
        if initial_x == nil then
            initial_x = x;
            initial_y = y;
            initial_x_shift = instance.parameters.x_shift;
            initial_y_shift = instance.parameters.y_shift;
        end
        if instance.parameters.type == "45" then
            instance.parameters.x_shift = initial_x_shift + initial_y - y;
            instance.parameters.y_shift = initial_y_shift + x - initial_x;
        else
            instance.parameters.x_shift = initial_x_shift + (initial_y - y) / 2;
            instance.parameters.y_shift = initial_y_shift + (x - initial_x) / 2;
        end
        UpdateReferencePoints();
    end
end

function MoveReferencePointFinished()
    initial_x = nil;
    initial_y = nil;
end

local start_rate = nil;
local start_period = nil;
local start_rate_start;
local period_1_start;
function MoveStart()
    local pane = core.host.Window.CurrentPane;
    local stream = pane.Data:getStream(0);
    
    start_rate = nil;
    start_period = nil;
    start_rate_start = instance.parameters.start_rate;
    period_1_start = core.host:execute("calculatePositionOfDate", stream, instance.parameters.start_date);
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
local last_x1;
local last_y1;
local last_x_shit;
local last_y_shift;
function Draw(stage, context)
    if stage == 2 then
        if not init then
            context:createPen(BORDER_LINE, context:convertPenStyle(instance.parameters.border_style), instance.parameters.border_width, instance.parameters.border_color);
            init = true;
        end
        local pane = core.host.Window.CurrentPane;
        local stream = pane.Data:getStream(0);
        if last_stream_size ~= stream:size() then
            UpdateReferencePoints();
        end
        
        local date_start = instance.parameters.start_date;
        local rate_start = instance.parameters.start_rate;
        local x1, y1 = get_point_coordinates(date_start, rate_start, context);
        local x2 = x1 + instance.parameters.x_shift;
        local y2 = y1 + instance.parameters.y_shift;
        local x3, y3;
        if instance.parameters.type == "45" then
            x3 = x1 + instance.parameters.y_shift;
            y3 = y1 - instance.parameters.x_shift;
        else
            x3 = x1 + instance.parameters.y_shift * 2;
            y3 = y1 - instance.parameters.x_shift * 2;
        end
        if last_x1 ~= x1 or last_y1 ~= y1 or last_x_shit ~= instance.parameters.x_shift or last_y_shift ~= instance.parameters.y_shift then
            local referencePoints = core.host.ReferencePoints;
            referencePoints:setReferencePoint(2, x2 - context:left(), y2 - context:top(), referencePoints.LEFT + referencePoints.TOP, instance.parameters.border_color, instance.parameters.border_width + 1);
            referencePoints:setReferencePoint(3, x3 - context:left(), y3 - context:top(), referencePoints.LEFT + referencePoints.TOP, instance.parameters.border_color, instance.parameters.border_width + 1);
            last_x1 = x1;
            last_y1 = y1;
            last_x_shit = instance.parameters.x_shift;
            last_y_shift = instance.parameters.y_shift;
        end

        context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
        local triagnle = ownerdraw_points.new();
        triagnle:add(x1, y1);
        triagnle:add(x2, y2);
        triagnle:add(x3, y3);
        triagnle:add(x1, y1);
        context:drawPolyline(BORDER_LINE, triagnle);
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
