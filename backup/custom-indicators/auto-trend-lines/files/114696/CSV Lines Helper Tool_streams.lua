
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=647&sid=08ab4875f1b7dcdac5560651dde3697d&start=50

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


function Init()
    indicator:name("CSV Lines Helper Tool (streams)");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");

	indicator.parameters:addFile("input_file_1", "CSV File (1)", "", "");
	indicator.parameters:addString("input_file_1_separator", "CSV File Separator (1)", "", ",");
	indicator.parameters:addString("input_file_1_ID", "ID for streams (1)", "", "up");
	indicator.parameters:addFile("input_file_2", "CSV File (2)", "", "");
	indicator.parameters:addString("input_file_2_separator", "CSV File Separator (2)", "", ",");
	indicator.parameters:addString("input_file_2_ID", "ID for streams (2)", "", "down");
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local first;
local source;
local loading;
local lines = {};

function Prepare(nameOnly)
	source = instance.source; 
	first = source:first();
    local name;
    name = profile:id() .. "(" .. instance.source:name()  .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
	lines[#lines + 1] = parseFile(instance.parameters.input_file_1, instance.parameters.input_file_1_separator, instance.parameters.input_file_1_ID);
	lines[#lines + 1] = parseFile(instance.parameters.input_file_2, instance.parameters.input_file_2_separator, instance.parameters.input_file_2_ID);
end

function todate(str)
	local _month, _day, _year, _hour, _minute = string.match(str, '(%d+)/(%d+)/(%d+) (%d+):(%d+)');
	local date = {year = _year, month = _month, day = _day, hour = _hour, min = _minute, sec = 0};
	return core.tableToDate(date);
end

function parseFile(file, separator, id)
	local f = io.open(file, "r");
	if (f == nil) then
		return {};
	end
	f:close();
	local new_lines = {};
	for str_line in io.lines(file) do 
		local values, values_count = core.parseCsv(str_line, separator);
		if values_count >= 4 then
			local line = {};
			line.rate_1 = tonumber(values[1]);
			line.rate_2 = tonumber(values[3]);
			line.date_1 = todate(values[0]);
			line.date_2 = todate(values[2]);
			line.id = string.format("%s_%s", id, tostring(#new_lines + 1));
			line.output = instance:addStream(line.id, core.Line, line.id, line.id, instance.parameters.color, 0);
    		line.output:setWidth(instance.parameters.width);
		    line.output:setStyle(instance.parameters.style);
			new_lines[#new_lines + 1] = line;
		else
			core.host:trace("Impossible to parse line: " .. line);
		end
	end
	
	return new_lines;
end

local linesDrawn = {};
function Update(period, mode)
	if mode ~= core.UpdateLast then
		return;
	else
		linesDrawn = {};
	end
	for _, lines_from_file in pairs(lines) do
		for _, value in pairs(lines_from_file) do
			if linesDrawn[value.id] == nil then 
				local x_1 = core.findDate(source, value.date_1, false);
				local x_2 = core.findDate(source, value.date_2, false);
				local y_1 = value.rate_1;
				local y_2 = value.rate_2;
				if x_1 ~= -1 and x_2 ~= -1 then 
					linesDrawn[value.id] = true;	

					drawline(x_1, y_1, x_2, y_2, value.output);
				end
			elseif value.output:size() > 2 and value.output[period - 1] ~= nil and value.output[period - 2] ~= nil then
				value.output[period] = value.output[period - 1] - (value.output[period - 2] - value.output[period - 1]);
			end
		end
	end
end 

-- draws line based on two fractals 
function drawline(x1, y1, x2, y2, output)
    x1 = correctIndexIfNeed(x1);
    x2 = correctIndexIfNeed(x2);
	core.drawLine(output, core.range(x1, x2), y1, x1, y2, x2);
	local max_period = math.max(x1, x2);
	if max_period >= 1 then
		local diff = output[max_period - 1] - output[max_period];
		for i = max_period + 1, output:size() - 1 do
			output[i] = output[i - 1] - diff;
		end
	end
end

function correctIndexIfNeed(x)
    if x >= source:size() then
        x = source:size() - 1;
    end
    
    if x < 0 then
        x = 0
    end

    return x;
end