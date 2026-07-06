-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69913

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

-- 2D chart template
-- You need to create parameters for the indicators in function CreateParameters and create indicators in function CreateIndicators. 

local Modules = {};

-- USER DEFINITIONS SECTION
local indi_name = "2d SSD RSI Clock";
local indi_version = "1";

local axis_shift = 10; -- distance between the edge of the chart and axis

local x_indi = "SSD"; -- ID of the indicator to use
local x_stream = 0; -- index of the stream to use
local x_min = 0; -- min value on the axis
local x_max = 100; -- max value on the axis
local x_sections = 5; -- number of sections/notches on the axis
local x_digits = 0; -- number of digits after the point for the values on the axis
local x_levels = { 80, 20 }; -- static lines on the axis (OB/OS)

local y_indi = "RSI"; -- ID of the indicator to use
local y_stream = 0; -- index of the stream to use
local y_min = 0; -- min value on the axis
local y_max = 100; -- max value on the axis
local y_sections = 5; -- number of sections/notches on the axis
local y_digits = 0; -- number of digits after the point for the values on the axis
local y_levels = { 70, 30 }; -- static lines on the axis (OB/OS)

local points_count = 5; -- the length of the history on the chart

function CreateIndicators(source)
    local indicators = {};

    local indi = core.indicators:findIndicator(x_indi);
    assert(indi ~= nil, "Please download and install " .. x_indi .. ".lua indicator");
    local p = indi:parameters();
    indicators[#indicators + 1] = indi:createInstance(source, p);
    local indi = core.indicators:findIndicator(y_indi);
    assert(indi ~= nil, "Please download and install " .. y_indi .. ".lua indicator");
    local p = indi:parameters();
    indicators[#indicators + 1] = indi:createInstance(source, p);

    return indicators;
end

function CreateParameters()
end

-- ENF OF USER DEFINITIONS SECTION

function Init()
    indicator:name(indi_name .. " v." .. indi_version);
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("Version", indi_version)

    CreateParameters();
	
	 
	 local color={  core.rgb(255, 0, 0)    , core.rgb(0, 255, 0)    ,   core.rgb(0, 0, 255)  ,  core.rgb(0, 0, 0)     , core.rgb(128, 128, 128), 
	                core.rgb(128, 128, 128), core.rgb(128, 128, 128), core.rgb(128, 128, 128), core.rgb(128, 128, 128), core.rgb(128, 128, 128),
	                core.rgb(128, 128, 128), core.rgb(128, 128, 128), core.rgb(128, 128, 128), core.rgb(128, 128, 128), core.rgb(128, 128, 128),
	                core.rgb(128, 128, 128), core.rgb(128, 128, 128), core.rgb(128, 128, 128), core.rgb(128, 128, 128), core.rgb(128, 128, 128)
	}; 
	
	--[[local color={
	0,0,0,0,0
	,0,0,0,0,0
	,0,0,0,0,0
	,0,0,0,0,0
	
	};]]

    indicator.parameters:addGroup("Instruments");
    for i = 1, 20, 1 do
        Add(i, color[i]);
    end
    indicator.parameters:addColor("axis_color", "Axis color", "", core.colors().Black)
    indicator.parameters:addColor("levels_color", "Levels Color", "Color", core.colors().Black);
    indicator.parameters:addInteger("levels_width", "Levels Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("levels_style", "Levels Style", "Style", core.LINE_DOT);
    indicator.parameters:setFlag("levels_style", core.FLAG_LINE_STYLE);
end

function Add(id, color)
    local Init = {"EUR/USD", "USD/JPY", "GBP/USD", "USD/CHF", "EUR/CHF"
                , "AUD/USD", "USD/CAD", "NZD/USD", "EUR/GBP", "EUR/JPY"
                , "GBP/JPY", "CHF/JPY", "GBP/CHF", "EUR/AUD", "EUR/CAD"
                , "AUD/CAD", "AUD/JPY", "CAD/JPY", "NZD/JPY", "GBP/CAD"
            };
    indicator.parameters:addBoolean("use_pair" .. id, "Use This Slot", "", id <= 5);
    indicator.parameters:addString("Pair" .. id, "Pair", "", Init[id]);
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
    indicator.parameters:addColor("color" .. id, "Color", "", color );
end

local items = {};
local instruments = {};

local TIMER_ID = 1;
local last_id = 1;

function PrepareInstrument(instrument, color)
    local symbol = {};
    symbol.Pair = instrument;
    symbol.Point = core.host:findTable("offers"):find("Instrument", symbol.Pair).PointSize;
    symbol.Color = color;
    symbol.SymbolIndex = #instruments + 1;
    symbol.LoadingId = last_id + 1;
    symbol.LoadedId = last_id + 2;
    function symbol:DoLoad()
        self.Source = core.host:execute("getSyncHistory", self.Pair, instance.source:barSize(), instance.source:isBid(), 300, self.LoadedId, self.LoadingId);
        self.Indicators = CreateIndicators(self.Source);
    end
    last_id = last_id + 2;
    items[#items + 1] = symbol;
    instruments[#instruments + 1] = instrument;
end

local timer_handle;

function Prepare(nameOnly)
    instance:name(indi_name);
    if nameOnly then
        return;
    end

    for i = 1, 20, 1 do
        if instance.parameters:getBoolean("use_pair" .. i) then
            PrepareInstrument(instance.parameters:getString("Pair" .. i), instance.parameters:getColor("color" .. i));
        end
    end
    timer_handle = core.host:execute("setTimer", TIMER_ID, 1);
    core.host:execute("setStatus", "Loading");
    instance:ownerDrawn(true);
end

local init = false;
local FONT_TEXT = 2;
local AXIS_PEN = 1;
local LEVELS_PEN = 3;
local LAST_PEN = 3;

function Draw(stage, context) 
    if stage ~= 2 then
        return;
    end
    if not init then
        context:createFont(FONT_TEXT, "Arial", 0, context:pointsToPixels(8), 0)
        for i, instrument in ipairs(items) do
            context:createPen(LAST_PEN + i * 2 - 1, context.SOLID, 1, instrument.Color);
            context:createSolidBrush(LAST_PEN + i * 2, instrument.Color);
        end
        context:createPen(LEVELS_PEN, context:convertPenStyle(instance.parameters.levels_style), instance.parameters.levels_width, instance.parameters.levels_color);
        context:createPen(AXIS_PEN, context.SOLID, 1, instance.parameters.axis_color);
        init = true;
    end
    local width = context:right() - context:left() - axis_shift * 2;
    local height = context:bottom() - context:top() - axis_shift * 2;
    local x_center = (context:left() + context:right()) / 2;
    local y_center = (context:top() + context:bottom()) / 2;
    local left = context:left() + axis_shift;
    local top = context:top() + axis_shift;
    context:drawLine(AXIS_PEN, x_center, top, x_center, context:bottom() - axis_shift);
    context:drawLine(AXIS_PEN, left, y_center, context:right() - axis_shift, y_center);
    for i, level in ipairs(x_levels) do
        local x = left + level / (x_max - x_min) * width;
        context:drawLine(LEVELS_PEN, x, context:top(), x, context:bottom());
    end
    for i, level in ipairs(y_levels) do
        local y = top + level / (y_max - y_min) * height;
        context:drawLine(LEVELS_PEN, context:left(), y, context:right(), y);
    end
    local x_step = (x_max - x_min) / x_sections
    for i = 0, x_sections do
        local value = x_step * i;
        local x = left + value / (x_max - x_min) * width;
        context:drawLine(AXIS_PEN, x, y_center - 2, x, y_center + 3);
        local text = win32.formatNumber(value, false, x_digits);
        local w, h = context:measureText(FONT_TEXT, text, context.CENTER);
        context:drawText(FONT_TEXT, text, instance.parameters.axis_color, -1, x - w / 2, y_center - h - 2, x + w / 2, y_center - 2, context.CENTER);
    end
    local y_step = (y_max - y_min) / y_sections;
    for i = 0, y_sections do
        local value = y_step * i;
        local y = top + value / (y_max - y_min) * height;
        context:drawLine(AXIS_PEN, x_center - 2, y, x_center + 3, y);
        local text = win32.formatNumber(value, false, y_digits);
        local w, h = context:measureText(FONT_TEXT, text, context.VCENTER);
        context:drawText(FONT_TEXT, text, instance.parameters.axis_color, -1, x_center + 3, y - h / 2, x_center + 3 + w, y + h / 2, context.CENTER);
    end
    for i, item in ipairs(items) do
        if item.Indicators ~= nil
            and item.Indicators[1]:getStream(x_stream):size() > 0 
            and item.Indicators[2]:getStream(y_stream):size() > 0
        then
            local last_x, last_y;
            for ii = 0, points_count - 1 do
                local x_val = item.Indicators[1]:getStream(x_stream):tick(NOW - ii);
                local y_val = item.Indicators[2]:getStream(y_stream):tick(NOW - ii);
                local x = left + (x_min + x_val) / (x_max - x_min) * width;
                local y = top + (y_min + y_val) / (y_max - y_min) * height;
                if ii == 0 then
                    context:drawRectangle(LAST_PEN + i * 2 - 1, LAST_PEN + i * 2, x - 2, y - 2, x + 3, y + 3);
                    local w, h = context:measureText(FONT_TEXT, item.Pair, context.VCENTER);
                    context:drawText(FONT_TEXT, item.Pair, item.Color, -1, x - w / 2, y - 2 - h, x + w / 2, y - 2, context.CENTER);
                else
                    local transparency = (ii - 1) / (points_count - 1) * 255;
                    context:drawRectangle(LAST_PEN + i * 2 - 1, LAST_PEN + i * 2, x - 1, y - 1, x + 2, y + 2, transparency);
                    context:drawLine(LAST_PEN + i * 2 - 1, last_x, last_y, x, y, transparency);
                end
                last_x = x;
                last_y = y;
            end
        end
    end
end

function Update(period, mode)
    for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(nil, nil, nil); end end
end

function UpdateData()
    for _, symbol in ipairs(items) do
        if symbol.Indicators ~= nil then
            for i, indicator in ipairs(symbol.Indicators) do
                indicator:update(core.UpdateLast);
            end
        end
    end
end

local loading_finished = false;
function AsyncOperationFinished(cookie, success, message, message1, message2)
    for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end
    if cookie == TIMER_ID then
        UpdateData();
        if not loading_finished then
            for _, symbol in ipairs(items) do
                symbol:DoLoad();
            end
            core.host:execute("setStatus", "");
            loading_finished = true;
        end
    else
        for _, symbol in ipairs(items) do
            if cookie == symbol.LoadingId then
                symbol.Loading = true;
                return;
            elseif cookie == symbol.LoadedId then
                symbol.Loading = false;
                return;
            end
        end
    end
end
