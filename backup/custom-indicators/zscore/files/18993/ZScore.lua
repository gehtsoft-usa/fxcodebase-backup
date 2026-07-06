-- Id: 5143
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=8619

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
    indicator:name("ZScore");
    indicator:description("ZScore");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PERIOD", "Period", "Period", 20);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("ZScore_color", "Color of ZScore", "Color of ZScore", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("Width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style", "Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE);		
	
	 indicator.parameters:addGroup("Levels");

    indicator.parameters:addDouble("overbought", "Overbought Level","", 2);
    indicator.parameters:addDouble("oversold", "Oversold Level", "", -2 );
    indicator.parameters:addInteger("level_overboughtsold_width", "Over Bought / Over Sold Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Over Bought / Over Sold Line Style", "", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "Over Bought / Over Sold  Line Color", "", core.rgb(255, 255, 0));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local PERIOD;

local first;
local source = nil;

-- Streams block
local ZScore = nil;
local  MVA;
-- Routine
function Prepare(nameOnly)
    PERIOD = instance.parameters.PERIOD;
    source = instance.source;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(PERIOD) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        MVA = core.indicators:create("MVA", source,PERIOD ); 
        first = math.max(MVA.DATA:first() , source:first()+ PERIOD-1);
    
        ZScore = instance:addStream("ZScore", core.Line, name, "ZScore", instance.parameters.ZScore_color, first);
    ZScore:setPrecision(math.max(2, instance.source:getPrecision()));
		ZScore:setWidth(instance.parameters.Width);
        ZScore:setStyle(instance.parameters.Style);
		
		ZScore:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
        ZScore:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not  source:hasData(period) then
	return;
    end	

     MVA:update(mode); 	
	 
	ZScore[period] = (source[period] - MVA.DATA[period])/ mathex.stdev (source, period -PERIOD+1 , period);
    
	
end

