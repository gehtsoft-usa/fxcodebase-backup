
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
    indicator.parameters:addInteger("size_extended", "Size of Extended Bars", "", 10, 0, 100);
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
local size_extended;
local line_id = 1;

function Prepare(nameOnly)
	source = instance.source; 
	first = source:first();
    local name;
    name = profile:id() .. "(" .. instance.source:name()  .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
	lines = parseFile(instance.parameters.input_file, instance.parameters.input_file_separator);
	color = instance.parameters.color;
	width = instance.parameters.width;
	style = instance.parameters.style;
	color_extended = instance.parameters.color_extended;
	width_extended = instance.parameters.width_extended;
	style_extended = instance.parameters.style_extended;
    size_extended = instance.parameters.size_extended;
end

function todate(str)
	-- dd/mm/yyyy hh:mm
	--local _day, _month, _year, _hour, _minute = string.match(str, '(%d+)/(%d+)/(%d+) (%d+):(%d+)');
	local _month, _day, _year, _hour, _minute = string.match(str, '(%d+)/(%d+)/(%d+) (%d+):(%d+)');
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

local linesDrawn = {};
function Update(period)   
	for key, value in pairs(lines) do
	
		if linesDrawn[key] == nil then 
		
			local x_1 = core.findDate(source, value.date_1, false);
			local x_2 = core.findDate(source, value.date_2, false);
			local y_1 = value.rate_1;
			local y_2 = value.rate_2;
	 
			if x_1 ~= -1 and x_2 ~= -1 then 
				linesDrawn[key] = true;	

				drawline(x_1, y_1, x_2, y_2, color, style, width);
				
				local a = (y_2 - y_1) / (x_2 - x_1);
				local b = y_1 - a * x_1;
									   
				if (x_1 > x_2) then
					 local x_3 = x_2 - size_extended;                
					 drawline(x_3, x_3 * a + b, x_2, y_2, color_extended, style_extended, width_extended);
				else
					 local x_3 = x_2 + size_extended;                
					 drawline(x_2, y_2, x_3, x_3 * a + b, color_extended, style_extended, width_extended);
				end
			end
		end
	end 
end 

-- draws line based on two fractals 
function drawline(x1, y1, x2, y2, color, style, width)

    local date1=0;
    local date2=0;
 
    x1 = correctIndexIfNeed(x1);
    x2 = correctIndexIfNeed(x2);
       
    date1 = source:date(x1);
    date2 = source:date(x2);

    core.host:execute("drawLine", line_id, date1, y1, date2, y2, color, style, width);
        line_id = line_id + 1;	
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