-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=70197

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                           mario.jemic@gmail.com  |
--|                          https://AppliedMachineLearning.systems  |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                                  Patreon: https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Timezone Pivots");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addString("StartTime", "Start Time for Trading", "", "00:00:00");
    indicator.parameters:addDouble("offset", "Offset", "", 100);

    indicator.parameters:addColor("up_color", "Top Color", "Color", core.colors().Green);
    indicator.parameters:addInteger("up_width", "Top Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("up_style", "Top Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("up_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("down_color", "Bottom Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("down_width", "Bottom Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("down_style", "Bottom Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("down_style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("central_color", "Central Color", "Color", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("central_width", "Central Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("central_style", "Central Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("central_style", core.FLAG_LINE_STYLE);


    indicator.parameters:addBoolean("Show", "Show Cloud", "", false);
    indicator.parameters:addColor("channel_color", "Channel Color", "", core.colors().Blue)
    indicator.parameters:addInteger("transparency", "Transparency", "", 50, 0, 100);
end

function ParseTime(time)
    local pos = string.find(time, ":");
    if pos == nil then
        return nil, false;
    end
    local h = tonumber(string.sub(time, 1, pos - 1));
    time = string.sub(time, pos + 1);
    pos = string.find(time, ":");
    if pos == nil then
        return nil, false;
    end
    local m = tonumber(string.sub(time, 1, pos - 1));
    local s = tonumber(string.sub(time, pos + 1));
    return (h / 24.0 +  m / 1440.0 + s / 86400.0),                          -- time in ole format
           ((h >= 0 and h < 24 and m >= 0 and m < 60 and s >= 0 and s < 60) or (h == 24 and m == 0 and s == 0)); -- validity flag
end

local source, up, down, start, offset,Show;
function Prepare(nameOnly)
    source = instance.source;
	
	Show= instance.parameters.Show;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end

    start = ParseTime(instance.parameters.StartTime);
    offset = instance.parameters.offset;
    up = instance:addStream("Up", core.Line, "Top", "Top", instance.parameters.up_color, 0, 0);
    up:setWidth(instance.parameters.up_width);
    up:setStyle(instance.parameters.up_style);
    down = instance:addStream("Down", core.Line, "Bottom", "Bottom", instance.parameters.down_color, 0, 0);
    down:setWidth(instance.parameters.down_width);
    down:setStyle(instance.parameters.down_style);
	
	central = instance:addStream("Central", core.Line, "Central", "Central", instance.parameters.central_color, 0, 0);
    central:setWidth(instance.parameters.central_width);
    central:setStyle(instance.parameters.central_style);
	
	if Show then
    instance:createChannelGroup("up-down", "Ch", up, down, instance.parameters.channel_color, instance.parameters.transparency, true);
	end
end

function Update(period, mode)
    local start_date = math.floor(source:date(period)) + start;
    local index = core.findDate(source, start_date, false);
    if index < 0 then
        return;
    end
    up[period] = source.close[index] + offset * source:pipSize();
    down[period] = source.close[index] - offset * source:pipSize();
	central[period] = down[period] +(up[period] - down[period])/2;
	
end
