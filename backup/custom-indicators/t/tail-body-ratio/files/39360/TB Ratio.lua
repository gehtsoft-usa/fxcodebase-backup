-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22809&p=39360#p39360

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
    indicator:name("Tail / Body Ratio");
    indicator:description("Tail / Body Ratio");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("Multiplier", "Multiplier", "Multiplier", 1);
	
	indicator.parameters:addString("Type", "Type of signal", "", "B");
    indicator.parameters:addStringAlternative("Type", "Tail / Body", "", "B");
    indicator.parameters:addStringAlternative("Type", "Tail / Candle", "", "C");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Top", "Top Color", " ", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Bottom", "Bottom Color", " ", core.rgb(0, 255, 0));
	 indicator.parameters:addDouble("Size", "Font Size", "", 10);
	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Multiplier;

local first;
local source = nil;
local Type;
-- Streams block
local down, up ;
local Size;
-- Routine
function Prepare(nameOnly)
    Multiplier = instance.parameters.Multiplier;
	Type = instance.parameters.Type;
	Size = instance.parameters.Size;
    source = instance.source;
    first = source:first();
	


    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Multiplier) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
      down = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Bottom, 0);
       up = instance:createTextOutput ("Down", "Down", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Top, 0);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period >= first and source:hasData(period) then
	
	local Bar= math.abs(source.open[period]- source.close[period]);
	local Up= source.high[period]-math.max(source.open[period],source.close[period]);
	local Down= math.min(source.open[period],source.close[period])-source.low[period];
	
	up:setNoData (period);
	down:setNoData (period);
	
	if Type ==  "B" then
		 if (Bar * Multiplier) < Up then
		 up:set(period, source.high[period], "\226");
		 end
		 
		 if (Bar * Multiplier) < Down then 
		  down:set(period, source.low[period], "\225");
		 end
     else
	      if ((Bar+Down) * Multiplier) < Up then
		 up:set(period, source.high[period], "\226");
		 end
		 
		 if ((Bar+Up) * Multiplier) < Down then 
		  down:set(period, source.low[period], "\225");
		 end
     end	 
	 
		 
    end
end

