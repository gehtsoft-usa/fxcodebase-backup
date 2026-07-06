-- Id: 12385
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61093

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
    indicator:name("Speed of trade");
    indicator:description("Speed of trade");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addDouble("Multiplier", "Multiplier", "Multiplier", 2);
	
	indicator.parameters:addGroup("Style");		
    indicator.parameters:addColor("SOD_color", "Color of SOD", "Color of SOD", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Average_color", "Color of Average", "Color of Average", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addInteger("Size", "Arrow Size", "Size", 9);
	 indicator.parameters:addColor("UP", "Color of Up Arrow", "Color of Up", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("DN", "Color of Down Arrow", "Color of Down", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Multiplier;
local first;
local source = nil;
local MVA;
-- Streams block
local SOD = nil;
local Average = nil;
local UP, DN, Size, up,down;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Multiplier = instance.parameters.Multiplier;
	Size = instance.parameters.Size;
	UP = instance.parameters.UP;
	DN = instance.parameters.DN;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Multiplier).. ")";
    instance:name(name);

    if (not (nameOnly)) then
        SOD = instance:addStream("SOD", core.Line, name .. ".SOD", "SOD", instance.parameters.SOD_color, first);
    SOD:setPrecision(math.max(2, instance.source:getPrecision()));
		SOD:setWidth(instance.parameters.width1);
        SOD:setStyle(instance.parameters.style1);
		 
		
		MVA = core.indicators:create("MVA", SOD, Period);
        Average = instance:addStream("Average", core.Line, name .. ".Average*Multiplier", "Average*Multiplier", instance.parameters.Average_color, MVA.DATA:first());
    Average:setPrecision(math.max(2, instance.source:getPrecision()));
		Average:setWidth(instance.parameters.width2);
        Average:setStyle(instance.parameters.style2);
	  
		 up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top,  UP, 0);
		 down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom,  DN, 0);
		 core.host:execute ("attachTextToChart", "Up");
		 core.host:execute ("attachTextToChart",  "Dn");
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not source:hasData(period) then
	return;
	end
	SOD[period] = ((source.close[period]-source.open[period])/source.volume[period])*1000000000;
	
	MVA:update(mode);	
    
	if period < MVA.DATA:first() then
	return;
	end
	
	
	
	 
        Average[period] = MVA.DATA[period]*Multiplier;
	
    if SOD[period]  >	Average[period] then 
		if source.close[period]> source.open[period] then
		up:set(period, source.high[period], "\217", source.high[period]);
		end
		if source.close[period]< source.open[period] then
	    down:set(period, source.low[period], "\218", source.low[period]);
		end
	else
	 up:setNoData(period );
	 down:setNoData(period );
	end
    
end

