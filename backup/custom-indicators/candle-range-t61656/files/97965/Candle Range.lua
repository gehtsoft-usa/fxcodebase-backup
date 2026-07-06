-- Id: 13353
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61656

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
    indicator:name("Candle Range");
    indicator:description("Candle Range");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addDouble("Level", "Minimum body range", "Minimum body range", 50);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Color of S1", "Color of S1", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Size", "Label Size", "Label Size", 10);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Level;
local font;
local first;
local source = nil;
local Color;
local Size = nil;

-- Routine
function Prepare(nameOnly)
    Level = instance.parameters.Level;
	Size= instance.parameters.Size;
	Color= instance.parameters.Color;
    source = instance.source;
    first = source:first();
	


    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Level) .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	font = core.host:execute("createFont", "Wingdings", Size, false, false);
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not source:hasData(period) then
	return;
	end
	
	local Range= math.abs(source.open[period]-source.close[period]) /( (source.high[period]-source.low[period])/100);
	if Range< Level then
    core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.median[period], core.CR_CHART, core.H_Center, core.V_Top,font, Color, "\108");
    else
	core.host:execute ("removeLabel", source:serial(period))
	end
    
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);
   end

