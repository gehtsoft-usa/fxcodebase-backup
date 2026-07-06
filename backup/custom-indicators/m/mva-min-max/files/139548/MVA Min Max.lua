 

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70719

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
 
--

-- initializes the indicator
function Init()
	-- indicator:fail()
	indicator:name("MVA Min Max")
	indicator:description("")
	indicator:requiredSource(core.Tick)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("Period1", "MA Period", "", 14 , 2, 10000)
	indicator.parameters:addInteger("Period2", "Min Max Period", "", 14, 2, 10000)
	indicator.parameters:addDouble("Delta", "Delta (In Pips)", "", 10, 0, 10000000  )
 
	indicator.parameters:addGroup("Line Style")
	indicator.parameters:addColor("clrDU", "Color of the Up line", "", core.rgb(0, 255, 0))
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE)
	indicator.parameters:addColor("clrDN", "Color of the Down line", "", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE)
	indicator.parameters:addColor("clrDM", "Color of the middle line", "", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE)

 
end

local first = 0
local Period1, Period2;
 
local source = nil
local dn = nil
local du = nil
local dm = nil
local Indicator;
local Delta;
-- initializes the instance of the indicator
function Prepare(nameOnly)
	source = instance.source
	Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
	Delta = instance.parameters.Delta;

	local name = profile:id() .. "(" .. source:name() .. "," .. Period1 .. "," .. Period2 .. "," .. Delta.. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end
	
	
	Indicator = core.indicators:create("MVA", source, Period1);


 
	Color = instance.parameters.Color
	Size = instance.parameters.Size
 

	Show = instance.parameters.Show
	ShowLabel = instance.parameters.ShowLabel

	first =   Indicator.DATA:first() ;
	
	 
	dm = instance:addStream("DM", core.Line, name .. ".DM", "DM", instance.parameters.clrDM, first)
	dm:setWidth(instance.parameters.width3)
	dm:setStyle(instance.parameters.style3)
	 

	du = instance:addStream("DU", core.Line, name .. ".DU", "DU", instance.parameters.clrDU, first+Period2)
	du:setWidth(instance.parameters.width1)
	du:setStyle(instance.parameters.style1)
	dn = instance:addStream("DN", core.Line, name .. ".DN", "DN", instance.parameters.clrDN, first+Period2)
	dn:setWidth(instance.parameters.width2)
	dn:setStyle(instance.parameters.style2)
	
 

	 
end
 

-- calculate the value
function Update(period)

    Indicator:update(mode);
	if (period < first) then
		return
	end
	
	dm[period]=Indicator.DATA[period];
	
	if (period < first+Period2) then
		return
	end
	
	
	local min,max=mathex.minmax(dm, period-Period2+1, period);
	
	du[period]=max +Delta*source:pipSize();
	dn[period]=min -Delta*source:pipSize();

	 
end
