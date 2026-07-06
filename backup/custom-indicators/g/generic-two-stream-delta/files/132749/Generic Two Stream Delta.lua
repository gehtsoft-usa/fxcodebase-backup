-- More information about this indicator can be found at:
-- http://fxcodebase.com 
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
    indicator:name("Generic Two Stream Delta")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)
  
  
    indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("Index1", "1. Stream Index", "", 1, 1, 100);
	indicator.parameters:addInteger("Index2", "2. Stream Index", "", 2, 1, 100);
    indicator.parameters:addBoolean("Inverse", "Inverse", "Inverse", true);
	
	indicator.parameters:addString("INDICATOR", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR",core.FLAG_INDICATOR);


    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("color", "Line Color", "Line Color", core.rgb(0, 0, 255))
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local Inverse, First, Second;
local Index1, Index2; 
local Oscillator, first, source; 

local Indicator;
function Prepare(nameOnly)
     
    source = instance.source
    first = source:first()
	
	Index1=instance.parameters.Index1-1;
	Index2=instance.parameters.Index2-1;

    local name =
    profile:id() ..  "(" .. source:name()  .. ")"
    instance:name(name)

    if nameOnly then
        return
    end
	
	local iprofile = core.indicators:findIndicator(instance.parameters:getString("INDICATOR"));
	local iparams = instance.parameters:getCustomParameters("INDICATOR");
	
	
	if  iprofile:requiredSource() == core.Tick then			
			Indicator = iprofile:createInstance( source.close, iparams);
	else
			Indicator = iprofile:createInstance(source, iparams);
	end
		

	
	if (Indicator:getStreamCount ()-1) < math.max(Index1, Index2) then
	assert(false, "the source only has" .. (Indicator:getStreamCount ()-1) .. "streams.");
	end
	
	First= Indicator:getStream(Index1);
	Second= Indicator:getStream(Index2);

    Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first );
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));    
end


function Update(period, mode)

    Indicator:update(mode);
    if period < first or not source:hasData(period) then
        return
    end
	
	Oscillator[period]=First[period]-Second[period];
	

 end