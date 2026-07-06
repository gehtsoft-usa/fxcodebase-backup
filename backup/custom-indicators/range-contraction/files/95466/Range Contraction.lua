-- Id: 12337
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61062

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Range Contraction");
    indicator:description("Range Contraction");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
   

 
	
	indicator.parameters:addGroup("Calculation");
	 indicator.parameters:addDouble("Threshold", "Threshold", "Threshold", 50);
	 indicator.parameters:addBoolean("On", "Range Contraction", "", true);
	 indicator.parameters:addBoolean("Flag", "Previous Period", "", false); 
	 
	 
	indicator.parameters:addGroup("Line Style");
    indicator.parameters:addColor("RangeContraction_color", "Color of RangeContraction", "Color of RangeContraction", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
 
    indicator.parameters:addInteger("Size", "Font Size", "", 12, 4, 20);
    indicator.parameters:addColor("Color", "Color of Range Contraction", "", core.rgb(0,255,0));
	
	indicator.parameters:addGroup("Threshold Style");	
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);


end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local On, Size, Color;
local Flag;
local first;
local source = nil;
local Threshold;
-- Streams block
local RangeContraction = nil;
local Contraction;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	On= instance.parameters.On;
	Flag= instance.parameters.Flag;
	Size= instance.parameters.Size;
	Color= instance.parameters.Color;
    first = source:first()+2;
    Threshold= instance.parameters.Threshold;
    local name = profile:id() .. "(" .. source:name() .. ", " .. Threshold.. ")";
    instance:name(name);

    if (not (nameOnly)) then
        RangeContraction = instance:addStream("RangeContraction", core.Line, name, "RangeContraction", instance.parameters.RangeContraction_color, first);
    RangeContraction:setPrecision(math.max(2, instance.source:getPrecision()));
		RangeContraction:setWidth(instance.parameters.width);
        RangeContraction:setStyle(instance.parameters.style);
		RangeContraction:addLevel(Threshold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		if On then
		Contraction = instance:createTextOutput("Contraction", "Contraction", "Wingdings", Size, core.H_Center, core.V_Top, Color, 0);
		core.host:execute ("attachTextToChart", "Contraction")
		end
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

   
 
    
    if period < first or not source:hasData(period) then
	return;
	end
	
	 if Flag then
	  RangeContraction[period] = (source.high[period-1]-source.low[period-1])/ ((source.high[period-2]-source.low[period-2])/100);
	 else
        RangeContraction[period] = (source.high[period]-source.low[period])/ ((source.high[period-1]-source.low[period-1])/100);
	end	
		
	if not On then
    return;
    end
 
    if   RangeContraction[period]	<Threshold then
	 Contraction:set(period, source.high[period],  "\108","Contraction");
	else
	Contraction:setNoData (period);
	end
    
end

