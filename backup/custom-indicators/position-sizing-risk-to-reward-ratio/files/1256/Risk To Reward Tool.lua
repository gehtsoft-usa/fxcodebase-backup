-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=689

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+

function Init()
    tool:name("Risk To Reward");
    tool:description("");
    tool:icon("");
    tool.creationStrategy:setPattern(core.DragClick);
    tool.creationStrategy:setMaxClickCount(1);
    tool.creationStrategy:setNeedParamsAfterPattern(true);
    tool:setTag("group", "Shapes");
    tool:setTag("orderInGroup", "1");
    tool:setTag("NonResetableParameters", "start_rate,start_date,end_rate,end_date");
    tool:setTag("requiredPaneType", "hasStreams");

    tool.parameters:addDate("start_date", "Date start", "", 0);
    tool.parameters:setFlag("start_date", core.FLAG_DATETIME);
    tool.parameters:addDate("end_date", "Date end", "", 0);
    tool.parameters:setFlag("end_date", core.FLAG_DATETIME);
    tool.parameters:addDouble("start_rate", "Rate top", "", 0);
    tool.parameters:addDouble("middle_rate", "Rate middle", "", 0);
    tool.parameters:addDouble("end_rate", "Rate bottom", "", 0);
    
    tool.parameters:addGroup("Style");
    tool.parameters:addColor("top_color", "Top Color", "", core.colors().Green);
    tool.parameters:addColor("bottom_color", "Bottom Color", "", core.colors().Red);
    tool.parameters:addInteger("border_width", "Border Width", "", 1, 1, 5);
    tool.parameters:addInteger("border_style", "Border Style", "", core.LINE_SOLID);
    tool.parameters:setFlag("border_style", core.FLAG_LINE_STYLE);
    tool.parameters:addInteger("transparency", "Transparency", "0 - opaque, 100 - transparent", 80, 0, 100);
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
        instance.parameters.start_rate = price;
        instance.parameters.start_date = date;
        instance.parameters.middle_rate = price;
        instance.parameters.end_rate = price;
        instance.parameters.end_date = date;
    elseif click == 2 then
        instance.parameters.middle_rate = price;
        instance.parameters.start_rate = price;
        instance.parameters.start_date = date;
    else
        instance.parameters.middle_rate = price;
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
    referencePoints:setReferencePoint(1, instance.parameters.start_date, instance.parameters.start_rate, referencePoints.DATE + referencePoints.PRICE, instance.parameters.top_color, instance.parameters.border_width + 1);
    referencePoints:setReferencePoint(2, instance.parameters.end_date, instance.parameters.end_rate, referencePoints.DATE + referencePoints.PRICE, instance.parameters.top_color, instance.parameters.border_width + 1);
    referencePoints:setReferencePoint(3, instance.parameters.start_date, instance.parameters.middle_rate, referencePoints.DATE + referencePoints.PRICE, instance.parameters.bottom_color, instance.parameters.border_width + 1);
end

function Drag(x, y, price, date)    
    instance.parameters.end_rate = price;
    instance.parameters.end_date = date;
    instance.parameters.middle_rate = price;
    UpdateReferencePoints();
end

function DragEnd(x, y, price, date)
    click = click + 1;
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
    elseif movingPointID == 3 then
        local min = math.min(instance.parameters.end_rate, instance.parameters.start_rate);
        local max = math.max(instance.parameters.end_rate, instance.parameters.start_rate);
        instance.parameters.middle_rate = math.min(max, math.max(min, price));
        UpdateReferencePoints();
    end
end

function MoveReferencePointFinished()
end

local start_rate = nil;
local start_period = nil;
local start_rate_start;
local period_1_start;
local end_rate_start;
local middle_rate_start;
local period_2_start;
function MoveStart()
    local pane = core.host.Window.CurrentPane;
    local stream = pane.Data:getStream(0);
    
    start_rate = nil;
    start_period = nil;
    start_rate_start = instance.parameters.start_rate;
    period_1_start = core.host:execute("calculatePositionOfDate", stream, instance.parameters.start_date);
    end_rate_start = instance.parameters.end_rate;
    middle_rate_start = instance.parameters.middle_rate;
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
        instance.parameters.middle_rate = middle_rate_start + rate_diff;
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

local TOP_PEN = 1;
local TOP_BRUSH = 2;
local BOTTOM_PEN = 3;
local BOTTOM_BRUSH = 4;
local FONT = 5;
local transparency;
function Draw(stage, context)
    if stage == 2 then
        if not init then
            context:createPen(TOP_PEN, context:convertPenStyle(instance.parameters.border_style), instance.parameters.border_width, instance.parameters.top_color);
            context:createPen(BOTTOM_PEN, context:convertPenStyle(instance.parameters.border_style), instance.parameters.border_width, instance.parameters.bottom_color);
            context:createSolidBrush(TOP_BRUSH, instance.parameters.top_color);
            context:createSolidBrush(BOTTOM_BRUSH, instance.parameters.bottom_color);
            context:createFont(FONT, "Arial", 0, context:pointsToPixels(12), context.LEFT);
            transparency = context:convertTransparency(instance.parameters.transparency);
            
            init = true;
        end
        local pane = core.host.Window.CurrentPane;
        local stream = pane.Data:getStream(0);
        if last_stream_size ~= stream:size() then
            UpdateReferencePoints();
        end
        
        local x1, y1 = get_point_coordinates(instance.parameters.start_date, instance.parameters.start_rate, context);
        local x2, y2 = get_point_coordinates(instance.parameters.end_date, instance.parameters.end_rate, context);
        local visible, y = context:pointOfPrice(instance.parameters.middle_rate);
        context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
        context:drawRectangle(TOP_PEN, TOP_BRUSH, x1, y1, x2, y, transparency);
        context:drawRectangle(BOTTOM_PEN, BOTTOM_BRUSH, x1, y2, x2, y, transparency);

        local extend = 6;
        local limit = math.abs(instance.parameters.start_rate - instance.parameters.middle_rate) / stream:pipSize();
        local target_text = "Target: " 
            .. win32.formatNumber(instance.parameters.start_rate, false, stream:pipSize()) .. " "
            .. win32.formatNumber(limit, false, 1);
        local w, h = context:measureText(FONT, target_text, context.LEFT);
        context:drawRectangle(TOP_PEN, TOP_BRUSH, x1, y1, x1 + w + extend, y1 + h + extend);
        context:drawText(FONT, target_text, core.COLOR_LABEL, -1, x1 + extend / 2, y1 + extend / 2, x1 + extend / 2 + w, y1 + extend / 2 + h, context.LEFT);

        local stop = math.abs(instance.parameters.middle_rate - instance.parameters.end_rate) / stream:pipSize();
        local stop_text = "Stop: " 
            .. win32.formatNumber(instance.parameters.end_rate, false, stream:pipSize()) .. " "
            .. win32.formatNumber(stop, false, 1);
        local w, h = context:measureText(FONT, stop_text, context.LEFT);
        context:drawRectangle(BOTTOM_PEN, BOTTOM_BRUSH, x1, y2, x1 + w + extend, y2 + h + extend);
        context:drawText(FONT, stop_text, core.COLOR_LABEL, -1, x1 + extend / 2, y2 + extend / 2, x1 + extend / 2 + w, y2 + extend / 2 + h, context.LEFT);

        local pos_text = "Risk/Reward Ratio: " 
            .. win32.formatNumber(stop / limit, false, 2);
        local w, h = context:measureText(FONT, pos_text, context.LEFT);
        context:drawRectangle(TOP_PEN, TOP_BRUSH, x1, y, x1 + w + extend, y + h + extend);
        context:drawText(FONT, pos_text, core.COLOR_LABEL, -1, x1 + extend / 2, y + extend / 2, x1 + extend / 2 + w, y + extend / 2 + h, context.LEFT);
        
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

local temp_params;
function CheckParameters(params)
    temp_params = params;
    return profile:name();
end

function ChangeParameters()
    -- copy all the params because of FXTS2 bug
    instance.parameters.start_rate = temp_params.start_rate;
    instance.parameters.start_date = temp_params.start_date;
    instance.parameters.end_rate = temp_params.end_rate;
    instance.parameters.end_date = temp_params.end_date;
    instance.parameters.middle_rate = temp_params.middle_rate;
    instance.parameters.top_color = temp_params.top_color;
    instance.parameters.bottom_color = temp_params.bottom_color;
    instance.parameters.border_width = temp_params.border_width;
    instance.parameters.border_style = temp_params.border_style;
    instance.parameters.transparency = temp_params.transparency;
    Prepare(false);
end
