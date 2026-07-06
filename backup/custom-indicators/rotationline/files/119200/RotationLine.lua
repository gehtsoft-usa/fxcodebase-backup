-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=66117

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
    tool:name("RotationLine");
    tool:description("RotationLine");
    tool.creationStrategy:setPattern(core.DragClick);
    tool.creationStrategy:setMaxClickCount(0);
    tool.creationStrategy:setNeedParamsAfterPattern(true);
    tool:setTag("group", "Lines");
    tool:setTag("NonResetableParameters", "start_rate,start_date,end_date");
    tool:setTag("requiredPaneType", "hasStreams");

    tool.parameters:addDouble("start_rate", "Start Rate", "The start rate of the line.", 0);
    tool.parameters:addDouble("end_rate", "End Rate", "The end rate of the line.", 0);
    tool.parameters:addDate("start_date", "Start Date", "The date of the line start", 0);
    tool.parameters:setFlag("start_date", core.FLAG_DATETIME);
    tool.parameters:addDate("end_date", "End Rate", "The rate of the line end.", 0);
    tool.parameters:setFlag("end_date", core.FLAG_DATETIME);
        
    tool.parameters:addGroup("Style");
    tool.parameters:addColor("border_color", "Line color", "The color of the line.", core.rgb(132, 130, 132));
    tool.parameters:addInteger("border_width", "Line width", "The width of the line.", 1, 1, 5);
    tool.parameters:addInteger("border_style", "Line style", "The style of the line.", core.LINE_SOLID);
    tool.parameters:setFlag("border_style", core.FLAG_LINE_STYLE);
end

function CreationStarted(Parameters)
end

local pipSize;
function getPipSize()
    if pipSize == nil then
        local pane = core.host.Window.CurrentPane;
        local stream = pane.Data:getStream(0);
        pipSize = stream:pipSize();
    end
    return pipSize;
end

function calculateArrowPointWidth(price)
    return math.abs(price - instance.parameters.start_rate) / getPipSize();
end

local start_date;
function Click(x, y, price, date)
    start_date = date;
    instance.parameters.start_rate = price;
    instance.parameters.end_rate = price;
    instance.parameters.start_date = date;
    instance.parameters.end_date = date;
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
    referencePoints:setReferencePoint(2, instance.parameters.end_date, instance.parameters.end_rate, referencePoints.DATE + referencePoints.PRICE, instance.parameters.border_color, instance.parameters.border_width + 1);   
end

function Drag(x, y, price, date)
    instance.parameters.start_date = math.min(date, start_date);
    instance.parameters.end_date = math.max(date, start_date);
    UpdateReferencePoints();
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

    if instance.parameters.end_date == instance.parameters.start_date then 
        return;
    end
    
    if movingPointID == 1 then
        if instance.parameters.end_date <= date then
            return;
        end
        instance.parameters.start_date = date;
        UpdateReferencePoints();
    elseif movingPointID == 2 then
        if instance.parameters.start_date >= date then
            return;
        end
        instance.parameters.end_date = date;
        UpdateReferencePoints();
    end
end

function MoveReferencePointFinished()
end

local start_rate = nil;
local start_period = nil;
local start_rate_start;
local end_rate_start;
local period_1_start;
local period_2_start;
function MoveStart()
    local pane = core.host.Window.CurrentPane;
    local stream = pane.Data:getStream(0);
    
    start_rate = nil;
    start_period = nil;
    start_rate_start = instance.parameters.start_rate;
    end_rate_start = instance.parameters.end_rate;
    period_1_start = core.host:execute("calculatePositionOfDate", stream, instance.parameters.start_date);
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
        instance.parameters.end_rate = end_rate_start + rate_diff;
        instance.parameters.start_date = core.host:execute("calculateDate", stream, period_1_start + period_diff);
        instance.parameters.end_date = core.host:execute("calculateDate", stream, period_2_start + period_diff);
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

local x1, y1;
local x2, y2;
local scale;

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
        
        local rate_start = instance.parameters.start_rate;
        local rate_end = instance.parameters.end_rate;
        x1, y1 = get_point_coordinates(instance.parameters.start_date, rate_start, context);       
        x2, y2 = get_point_coordinates(instance.parameters.end_date, rate_end, context);
                               
        context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
		context:drawLine(BORDER_LINE, x1, y1, x2, y2);
        context:resetClipRectangle();
    
    
        local precision = stream:getPrecision();
        local eps;
        if precision > 0 then
            eps = math.pow(10, -precision);
        else
            eps = 1;
        end
            
        local __, y11 = get_point_coordinates(instance.parameters.start_date, rate_start, context);       
        local __, y22 = get_point_coordinates(instance.parameters.end_date, rate_start + 100 * eps , context);
        scale =  eps * 100 / math.abs( y22 - y11);
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
    
    core.host:execute("addCommand", 1, "Rotate 90 degrees left");
    core.host:execute("addCommand", 2, "Rotate 90 degrees right");
end

function CheckParameters(params)
    return profile:name();
end

function ChangeParameters()
    Prepare(false);
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
                
        if instance.parameters.end_date == instance.parameters.start_date then
            core.host:trace("Line already rotated")
            return;
        end
        
        instance.parameters.end_date = instance.parameters.start_date;
        instance.parameters.end_rate = instance.parameters.start_rate + scale * math.abs(x2-x1);
        
        UpdateReferencePoints();
    elseif cookie == 2 then
    
        if instance.parameters.end_date == instance.parameters.start_date then
            core.host:trace("Line already rotated")
            return;
        end
       
        instance.parameters.start_date = instance.parameters.end_date;
        instance.parameters.start_rate = instance.parameters.end_rate + scale * math.abs(x2-x1);
        
        UpdateReferencePoints();
    end
end