--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Trend Line Helper");
    indicator:description("Trend Line Helper");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("1. Point");	
	indicator.parameters:addDouble("Level1", "1. Point Level", "", 0);
	
	indicator.parameters:addDate ("Date1", "1. Point Date", "Date", 0);
	indicator.parameters:setFlag ("Date1",core.FLAG_DATETIME);
	
	indicator.parameters:addGroup("2. Point");
	indicator.parameters:addDouble("Level2", "2. Point Level", "", 0);
	
	indicator.parameters:addDate ("Date2", "2. Point Date", "Date", 0);
	indicator.parameters:setFlag ("Date2",core.FLAG_DATETIME);
	
	indicator.parameters:addBoolean("Extend" , "Extend", "Extend",true);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("color1", "Color of Line", "Color of Line", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("color2", "Color of Line Extend", "Color of Line", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Level={};
local Date={};
-- Streams block
local Line = nil;
local Extend;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	Level[1]= instance.parameters.Level1;
	Level[2]= instance.parameters.Level2;
	
	Date[1]= instance.parameters.Date1;
	Date[2]= instance.parameters.Date2;
	
	Extend= instance.parameters.Extend;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color1, first);
		Line:setWidth(instance.parameters.width);
        Line:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
	if period < source:size()-1 then
		return;
	end
	
	local p1 = core.host:execute("calculatePositionOfDate", source, Date[1]);
	local p2 = core.host:execute("calculatePositionOfDate", source, Date[2]);
	local last = source:size() - 1;
	if p1 > p2 then
		Temp=p1;
		p1= p2;
		p2=Temp;
		Start= Level[2];
		Stop=Level[1];
	else
		Start= Level[1];
		Stop=Level[2];
	end
	
	core.host:execute ("setStatus", p1.. " / ".. p2)
	core.drawLine(Line, core.range(p1, p2), Start, p1, Stop, p2, instance.parameters.color1);
	
	if Extend then
		a = (Stop - Start) / (p2 - p1);
		b = Start - a * p1;
		
		Level[3] = a * first + b; 
		Level[4] = a * p1 + b; 
		Level[5] = a * p2 + b; 
		Level[6] = a * (source:size() - 1) + b; 
		core.drawLine(Line, core.range(first, p1)          , Level[3], first, Level[4], p1               , instance.parameters.color2);
		core.drawLine(Line, core.range(p2, source:size()-1), Level[5], p2   , Level[6], source:size() - 1, instance.parameters.color2);
	end    
end
