-- Id: 6288
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15639

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
    indicator:name("Bar Height Label");
    indicator:description("Shows Candle / Body Height in Pips");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");  
    indicator.parameters:addString("Type", "Body", "", "Body");
    indicator.parameters:addStringAlternative("Type", "Body", "", "Body");   
	indicator.parameters:addStringAlternative("Type", "Candle", "", "Candle");
	indicator.parameters:addStringAlternative("Type", "Open/Close + 2 x Wicks ", "", "Open/Close + 2 x Wicks");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 7);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Type;
local first;
local source = nil;
 local font;
 local ArrowSize;
 local id =0;
 local Label;
 local LAST = nil;
 
-- Streams block

-- Routine
function Prepare(nameOnly)
    Label = instance.parameters.Label;
    ArrowSize = instance.parameters.ArrowSize;
    Type = instance.parameters.Type;
    source = instance.source;
    first = source:first();
	id=0;
	LAST = nil;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Type) .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    font = core.host:execute("createFont", "Arial", ArrowSize, true, false);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not  source:hasData(period) then
	id=0;
	return;
	end
	
	if source:serial(period) ~= LAST then
	id = id+1;
	LAST = source:serial(period);
	end
	     if Type == "Body" then
		 core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top,
                                                font, Label, string.format("%." .. 2 .. "f",  math.abs(source.close[period] - source.open[period] ) / source:pipSize()));
         elseif Type == "Candle" then		
		core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top,
                                                font, Label,  string.format("%." .. 2 .. "f",  math.abs(source.high[period] - source.low[period] ) / source:pipSize()));
         else
		 local Temp = source.high[period] -source.low[period]  +  (source.high[period] - math.max(source.close[period],source.open[period] ) )
		 +  ( math.min(source.close[period],source.open[period] ) - source.low[period]  );
        core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top,
                                                font, Label,  string.format("%." .. 2 .. "f",  Temp / source:pipSize()));		 
		 end
		 
    end

	
function ReleaseInstance()
       core.host:execute("deleteFont", font);      
end

