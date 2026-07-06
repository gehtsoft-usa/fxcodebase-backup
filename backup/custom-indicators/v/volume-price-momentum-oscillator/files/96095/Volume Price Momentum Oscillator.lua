-- Id: 12581

-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=61222

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
    indicator:name("Volume Price Momentum Oscillator");
    indicator:description("Volume  Price Momentum Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 3);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("VPMO_color", "Color of VPMO", "Color of VPMO", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
 
local source = nil;
local EMA;
-- Streams block
local VPMO = nil;
local vpmo;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
   

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    vpmo  = instance:addInternalStream(0, 0);
	
	assert( source:supportsVolume () , "The source that includes data volume is required.");
	
	
	EMA = core.indicators:create("EMA", vpmo, Period);
	
    if (not (nameOnly)) then
        VPMO = instance:addStream("VPMO", core.Line, name, "VPMO", instance.parameters.VPMO_color, EMA.DATA:first());
    VPMO:setPrecision(math.max(2, instance.source:getPrecision()));
		VPMO:setWidth(instance.parameters.width);
        VPMO:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
 
	vpmo[period]=source.volume[period]*(source.close[period]-source.close[period-1]);
	EMA:update(mode);
	
	if period < EMA.DATA:first() or not source:hasData(period) then
	return;
	end
	
	VPMO[period] = EMA.DATA[period];
    
end

