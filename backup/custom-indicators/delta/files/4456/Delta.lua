-- Id: 1600
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2156

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
    indicator:name("Delta");
    indicator:description("Delta");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addColor("Price_color", "Color of Price", "Color of Price", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Delta_color", "Color of Delta", "Color of Delta", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("Arrow Style");	
	indicator.parameters:addBoolean("Show", "Show Arrows", "Show", true);
	indicator.parameters:addInteger("Size", "Size", "", 5);
	indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

-- Streams block
local Price = nil;
local Delta = nil;

local ROW;
local Show, Up, Down;
local font,Size;
-- Routine
function Prepare(nameOnly)
    
    source = instance.source;
    first = source:first();
	Show=instance.parameters.Show;
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Size=instance.parameters.Size;
	
    local name = profile:id() .. "(" .. source:name()  .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	font = core.host:execute("createFont", "Wingdings", Size, false, false);

    
	ROW= instance:addInternalStream(first, 0);
    Price = instance:addStream("Price", core.Line, name .. ".Price", "Price", instance.parameters.Price_color, first+1);
    Price:setPrecision(math.max(2, instance.source:getPrecision()));
	Price:setWidth(instance.parameters.width1);
    Price:setStyle(instance.parameters.style1);
    Delta = instance:addStream("Delta", core.Line, name .. ".Delta", "Delta", instance.parameters.Delta_color, first+1);
    Delta:setPrecision(math.max(2, instance.source:getPrecision()));
	Delta:setWidth(instance.parameters.width2);
    Delta:setStyle(instance.parameters.style2);
end


function ReleaseInstance()
       core.host:execute("deleteFont", font);

end	   
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
	if period < first or not  source:hasData(period) then
	return;
	end
	
	ROW[period]=(source.close[period]+source.open[period]+source.high[period]+source.low[period])/4;
	
			 
	if period < first+1 then
	return;
	end		
			   local DIV = math.log10(ROW[period-1]/ROW[period]);
			
				 Price[period] = ROW[period];		
			   
				 Delta[period] =  ROW[period] + DIV;
		 
		
	if Show then   
		if Price[period]> Delta[period]
		and Price[period-1]<= Delta[period-1]
		then
		core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, Price[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, Up, "\225");						 
		elseif Price[period]< Delta[period]
		and Price[period-1]>= Delta[period-1]
		then
		 core.host:execute("drawLabel1",  source:serial(period), source:date(period), core.CR_CHART, Price[period], core.CR_CHART, core.H_Center, core.V_Top,font, Down, "\226");
		else
		core.host:execute ("removeLabel", source:serial(period));
		end
    end 
end


