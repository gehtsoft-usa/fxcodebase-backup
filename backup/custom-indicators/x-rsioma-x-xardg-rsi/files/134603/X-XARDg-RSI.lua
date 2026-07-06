-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69965

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
    indicator:name("X-XARDg-RSI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addInteger("rsi_period", "RSI Period", "", 20);

    indicator.parameters:addColor("rsi_up_color", "RSI Up Color", "Color", core.colors().Green);
    indicator.parameters:addColor("rsi_dn_color", "RSI Down Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("rsi_width", "RSI Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("rsi_style", "RSI Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("rsi_style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 10);
	indicator.parameters:addDouble("Level2", "2. Level","", -10);
 
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);		
end

local RSIModifier = 0.9;
local SmoothLength = 5;
local source, rsi_indi, buffer, rsi, smooth;
local rsi_up_color, rsi_dn_color;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    rsi_up_color = instance.parameters.rsi_up_color;
    rsi_dn_color = instance.parameters.rsi_dn_color;
    rsi_indi = core.indicators:create("RSI", source, instance.parameters.rsi_period);
    buffer = instance:addInternalStream(0, 0);
    smooth = core.indicators:create("MVA", buffer, SmoothLength);
    rsi = instance:addStream("RSI", core.Line, "RSI", 'RSI', instance.parameters.rsi_up_color, 0, 0);
    rsi:setWidth(instance.parameters.rsi_width);
    rsi:setStyle(instance.parameters.rsi_style);
	
	
	
	rsi:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	rsi:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	
    instance:ownerDrawn(true);
end

function GetLevel()
    for i = source:size() - 1, 0, -1 do
        if rsi[i] > 1 then
            return 1;
        end
        if rsi[i] < -1 then
            return -1;
        end
    end
    return 0;
end

local init = false;
local FONT = 1;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        init = true;
        context:createFont(FONT, "Arial", 0, context:pointsToPixels(20), context.LEFT);
    end
    local level = GetLevel();
    core.host:trace(level);
    if level == -1 then
        local w, h = context:measureText(FONT, "SELLS ONLY - CLOSE ALL BUY TRADES", context.LEFT);
        context:drawText(FONT, "SELLS ONLY - CLOSE ALL BUY TRADES", core.colors().Crimson, 0, context:left(), context:top(), context:left() + w, context:top() + h, context.LEFT);
    elseif level == 1 then
        local w, h = context:measureText(FONT, "BUYS ONLY - CLOSE ALL SELL TRADES", context.LEFT);
        context:drawText(FONT, "BUYS ONLY - CLOSE ALL SELL TRADES", core.colors().Blue, 0, context:left(), context:top(), context:left() + w, context:top() + h, context.LEFT);
    end
end

function Update(period, mode)
    rsi_indi:update(mode);
    buffer[period] = RSIModifier * (rsi_indi.DATA[period] - 50);
    smooth:update(mode);
    rsi[period] = smooth.DATA[period];
    if rsi[period] > 0 then
        rsi:setColor(period, rsi_up_color);
    else
        rsi:setColor(period, rsi_dn_color);
    end
end