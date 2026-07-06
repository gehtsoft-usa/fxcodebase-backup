-- Id: 18004
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64603

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("CSV Lines Helper Tool");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");

	indicator.parameters:addFile("input_file", "CSV File", "", "");
	indicator.parameters:addString("input_file_separator", "CSV File Separator", "", ",");
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("color_extended", "Extended Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width_extended", "Extended Line Width", "", 1, 1, 5);
	indicator.parameters:addInteger("style_extended", "Extended Line Style", "", core.LINE_DASH);
	indicator.parameters:setFlag("style_extended", core.FLAG_LINE_STYLE);
end

local first;
local source;
local Source;
local loading;
local lines;
local color;
local width;
local style;
local color_extended;
local width_extended;
local style_extended;

function Prepare(onlyName)
	source = instance.source; 
	first = source:first();
    local name;
    name = profile:id() .. "(" .. instance.source:name()  .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end
	
	lines = parseFile(instance.parameters.input_file, instance.parameters.input_file_separator);
	color = instance.parameters.color;
	width = instance.parameters.width;
	style = instance.parameters.style;
	color_extended = instance.parameters.color_extended;
	width_extended = instance.parameters.width_extended;
	style_extended = instance.parameters.style_extended;
	instance:ownerDrawn(true);
end

function todate(str)
	-- dd/mm/yyyy hh:mm
	local _day, _month, _year, _hour, _minute = string.match(str, '(%d+)/(%d+)/(%d+) (%d+):(%d+)');
	local date = {year = _year, month = _month, day = _day, hour = _hour, min = _minute, sec = 0};
	return core.tableToDate(date);
end

function parseFile(file, separator)
	local f = io.open(file, "r");
	if (f == nil) then
		return {};
	end
	f:close();
	local new_lines = {};
	for line in io.lines(file) do 
		local values, values_count = core.parseCsv(line, separator);
		if values_count >= 4 then
			local line = {};
			line.rate_1 = tonumber(values[1]);
			line.rate_2 = tonumber(values[3]);
			line.date_1 = todate(values[0]);
			line.date_2 = todate(values[2]);
			new_lines[#new_lines + 1] = line;
		else
			core.host:trace("Impossible to parse line: " .. line);
		end
	end
	
	return new_lines;
end

function Update(period)     
end 

local main_pen = 1;
local extended_pen = 2;
local init = false;
function Draw(stage, context)
    if stage ~= 2 
	or loading
	then
	return;
	end
	if not init then
		context:createPen(main_pen, context:convertPenStyle(style), width, color);
		context:createPen(extended_pen, context:convertPenStyle(style_extended), width_extended, color_extended);
		init = true;
	end
	local y = {};
	
	for key, value in pairs(lines) do
		local index_1 = core.findDate(source, value.date_1, false);
		local index_2 = core.findDate(source, value.date_2, false);
		x_1 = context:positionOfBar(index_1);
		x_2 = context:positionOfBar(index_2);
		visible, y_1 = context:pointOfPrice(value.rate_1);
		visible, y_2 = context:pointOfPrice(value.rate_2);
		 
		context:drawLine(main_pen, x_1, y_1, x_2, y_2);
		
		local a = (y_2 - y_1) / (x_2 - x_1);
		local b = y_1 - a * x_1;
		if (x_1 > x_2) then
			context:drawLine(extended_pen, context:left(), context:left() * a + b, x_2, y_2);
		else
			context:drawLine(extended_pen, context:right(), context:right() * a + b, x_2, y_2);
		end
    end
end