-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72469

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

function AddLevel(id, level, use)
    tool.parameters:addBoolean("use_" .. id, "Use " .. id, "", use or false);
    tool.parameters:addDouble("level_" .. id, "Level " .. id, "", level);
    tool.parameters:addColor("level_color" .. id, "Level " .. id .. " Color", "Color", core.colors().Red);
    tool.parameters:addInteger("level_width" .. id, "Level " .. id .. " Width", "Width", 1, 1, 5);
    tool.parameters:addInteger("level_style" .. id, "Level " .. id .. " Style", "Style", core.LINE_SOLID);
    tool.parameters:setFlag("level_style" .. id, core.FLAG_LINE_STYLE);
end

function Init()
    tool:name("Fibonacci Rectangle Triangle");
    tool:description("");
    tool:icon("");
    tool.creationStrategy:setPattern(core.DragClick);
    tool.creationStrategy:setMaxClickCount(0);
    tool.creationStrategy:setNeedParamsAfterPattern(true);
    tool:setTag("group", "Fibonacci");
    tool:setTag("orderInGroup", "1");
    tool:setTag("NonResetableParameters", "start_rate,start_date,end_rate,end_date");
    tool:setTag("requiredPaneType", "hasStreams");

    tool.parameters:addDate("start_date", "Date start", "", 0);
    tool.parameters:setFlag("start_date", core.FLAG_DATETIME);
    tool.parameters:addDate("end_date", "Date end", "", 0);
    tool.parameters:setFlag("end_date", core.FLAG_DATETIME);
    tool.parameters:addDouble("start_rate", "Rate top", "", 0);
    tool.parameters:addDouble("end_rate", "Rate bottom", "", 0);

    AddLevel(1, -0.618);
    AddLevel(2, -0.382);
    AddLevel(3, -0.272);
    AddLevel(4, 0);
    AddLevel(5, 0.236);
    AddLevel(6, 0.382, true);
    AddLevel(7, 0.500, true);
    AddLevel(8, 0.618, true);
    AddLevel(9, 0.764);
    AddLevel(10, 1.0);
    AddLevel(11, 1.272);
    AddLevel(12, 1.618);
    AddLevel(13, 2.618);
    AddLevel(14, 4.236);
    
    tool.parameters:addGroup("Style");
    tool.parameters:addColor("top_color", "Color", "", core.COLOR_UPCANDLE);
    tool.parameters:addInteger("border_width", "Border Width", "", 1, 1, 5);
    tool.parameters:addInteger("border_style", "Border Style", "", core.LINE_SOLID);
    tool.parameters:setFlag("border_style", core.FLAG_LINE_STYLE);
    tool.parameters:addInteger("transparency", "Transparency", "0 - opaque, 100 - transparent", 25, 0, 100);
end

local levels = {};

function CreationStarted(Parameters)
    levels = {};
    for id = 1, 14 do
        if instance.parameters:getBoolean("use_" .. id) then
            local level = {};
            level.value = instance.parameters:getDouble("level_" .. id);
            level.color = instance.parameters:getColor("level_color" .. id)
            level.width = instance.parameters:getColor("level_width" .. id);
            level.style = instance.parameters:getColor("level_style" .. id);
            levels[#levels + 1] = level;
        end
    end
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
        instance.parameters.start_rate = price;
        instance.parameters.start_date = date;
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
end

function Drag(x, y, price, date)    
    instance.parameters.end_rate = price;
    instance.parameters.end_date = date;
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
    end
end

function MoveReferencePointFinished()
end

local start_rate = nil;
local start_period = nil;
local start_rate_start;
local period_1_start;
local period_2_start;
local end_rate_start;
function MoveStart()
    local pane = core.host.Window.CurrentPane;
    local stream = pane.Data:getStream(0);
    
    start_rate = nil;
    start_period = nil;
    start_rate_start = instance.parameters.start_rate;
    period_1_start = core.host:execute("calculatePositionOfDate", stream, instance.parameters.start_date);
    period_2_start = core.host:execute("calculatePositionOfDate", stream, instance.parameters.end_date);
    end_rate_start = instance.parameters.end_rate;
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
end

local init = false;

function get_point_coordinates(date, price, context)
    local x, x1, x2 = context:positionOfDate(date);
    local visible, y = context:pointOfPrice(price);
    return x, y;
end

local TOP_PEN = 1;
local TOP_BRUSH = 2;
local transparency;
function Draw(stage, context)
    if stage == 2 then
        if not init then
            context:createPen(TOP_PEN, context:convertPenStyle(instance.parameters.border_style), instance.parameters.border_width, instance.parameters.top_color);
			context:createPen(11, context:convertPenStyle(instance.parameters.border_style), instance.parameters.border_width, core.rgb(0, 255, 0));
			context:createPen(12, context:convertPenStyle(instance.parameters.border_style), instance.parameters.border_width, core.rgb(255, 0, 0));
            context:createSolidBrush(TOP_BRUSH, instance.parameters.top_color);
            transparency = context:convertTransparency(instance.parameters.transparency);
            for id, level in ipairs(levels) do
                context:createPen(2 + id, context:convertPenStyle(level.style), level.width, level.color);
                level.pen = 2 + id;
            end
            
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
        context:drawRectangle(TOP_PEN, TOP_BRUSH, x1, y1, x2, y2, transparency);
        local range = instance.parameters.end_rate - instance.parameters.start_rate;
		
		 
	    local m= math.min(y1, y2) + ( math.max(y1, y2) - math.min(y1, y2))/2;
	--	m= context:pointOfPrice(m);
		--x1,y1   x2,m      
		context:drawLine (11, x1, y1, x2, m);
		--x1,y2   x2,m     
		context:drawLine (12, x1, y2, x2, m);
        for id, level in ipairs(levels) do
            local _, y = context:pointOfPrice(instance.parameters.start_rate + range * level.value);
            context:drawLine(level.pen, x1, y, x2, y);
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
    instance.parameters.top_color = temp_params.top_color;
    instance.parameters.border_width = temp_params.border_width;
    instance.parameters.border_style = temp_params.border_style;
    instance.parameters.transparency = temp_params.transparency;
    for id = 1, 14 do
        instance.parameters:setBoolean("use_" .. id, temp_params:getBoolean("use_" .. id));
        instance.parameters:setDouble("level_" .. id, temp_params:getDouble("level_" .. id));
        instance.parameters:setColor("level_color" .. id, temp_params:getColor("level_color" .. id));
        instance.parameters:setInteger("level_width" .. id, temp_params:getInteger("level_width" .. id));
        instance.parameters:setInteger("level_style" .. id, temp_params:getInteger("level_style" .. id));
    end
    CreationStarted(instance.parameters);
    Prepare(false);
end
