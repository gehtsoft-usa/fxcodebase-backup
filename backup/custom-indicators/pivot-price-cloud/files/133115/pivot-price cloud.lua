-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69274

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
    indicator:name("Pivot-Price cloud");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addString("tf", "Timeframe", "", "H1");
    indicator.parameters:setFlag("tf", core.FLAG_PERIODS);

    indicator.parameters:addColor("pivot1_color", "Pivot Up Color", "", core.colors().Green);
    indicator.parameters:addColor("pivot2_color", "Pivot Down Color", "", core.colors().Red);
	
	    indicator.parameters:addInteger("transparency", "Transparency", "", 50, 0, 100);


	 indicator.parameters:addColor("pivot_color", "Pivot Color", "", core.colors().Blue);
	 indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	 
	
end

local source, pivot1, pivot2, p1, p2, line1, line2;
local First;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
	
	First=true;
	
    pivot1 = core.indicators:create("PIVOT", source, instance.parameters.tf, "Pivot", "HIST");

    p1 = instance:addStream("Pivot", core.Line, name .. ".P1", "P1", instance.parameters.pivot_color, 0);
	p1:setWidth(instance.parameters.width);
    p1:setStyle(instance.parameters.style);
	
	
    line1 = instance:addInternalStream(0, 0);
    line2 = instance:addInternalStream(0, 0);

    instance:createChannelGroup("Pivot Channel", "Pivot Channel", line1, line2, instance.parameters.pivot_color, 100 - instance.parameters.transparency);
    core.host:execute("setTimer", 1, 1);
end

local loaded = false;
local Last=nil;
function Update(period, mode)


    if First then
	First=false;
	pivot1:update(core.UpdateAll );
	else
    pivot1:update(mode);
	end
	
	if period < pivot1.P:first()
	or not pivot1.P:hasData(period)
	then
	return;
	end
	

    p1[period] = pivot1.P[period];
    line1[period] = pivot1.P[period];
    line2[period] = source.close[period];
    if line1[period] > line2[period] then
        line1:setColor(period, instance.parameters.pivot1_color);
    else
        line1:setColor(period, instance.parameters.pivot2_color);
    end
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    if pivot1.P:size() ~= 0 then
        if not loaded or p1[NOW] ~= nil or Last~= source:serial(NOW) then
            loaded = true;
			Last= source:serial(NOW);
            instance:updateFrom(0);
			
        end
    else
        loaded = false;
    end
	
	  return core.ASYNC_REDRAW ;
end