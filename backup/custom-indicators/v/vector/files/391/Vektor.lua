-- Id: 1059
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=257

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
    indicator:name("Vector");
    indicator:description("Vector");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addColor("clrWP", "Slow Vector Color","Slow Vector Color", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("clrWN", "Fast Vector Color", "Fast Vector Color", core.rgb(0, 255, 0));
	 
	indicator.parameters:addGroup("Zero Line");	
    
	 indicator.parameters:addColor("zero_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("zero_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("zero_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("zero_style", core.FLAG_LEVEL_STYLE);


end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

-- Streams block
local SI = nil;
local IS = nil;

local init = false;
 
function Draw(stage, context)
    if stage ~= 2 then    
	return;
	end
	
		context:createPen (1, context:convertPenStyle (instance.parameters.zero_style), instance.parameters.zero_width, instance.parameters.zero_color);
	visible, y =context:pointOfPrice (0);
	context:drawLine (1,context:left (), y , context:right (), y  );

end



-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first() + 16;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    SI = instance:addStream("WP", core.Bar, name, "WP", instance.parameters.clrWP, first);
    SI:setPrecision(math.max(2, instance.source:getPrecision()));
	IS = instance:addStream("WN", core.Bar, name, "WN", instance.parameters.clrWN, first);
    IS:setPrecision(math.max(2, instance.source:getPrecision()));
	
	
    instance:ownerDrawn(true);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
   if period < first  or not source:hasData(period) then
	return;
	end
       
		
		SI[period]=((source.close[period] - source.close[period-2]) + (source.close[period] - source.close[period-4]) +(source.close[period] - source.close[period-8])+ (source.close[period] - source.close[period-16]))/4;

		IS[period]=(0.5*(source.close[period] - source.close[period-2]) + 0.25*(source.close[period] - source.close[period-4]) + 0.125*(source.close[period] - source.close[period-8])+ 0.0625*(source.close[period] - source.close[period-16]));

 
end
