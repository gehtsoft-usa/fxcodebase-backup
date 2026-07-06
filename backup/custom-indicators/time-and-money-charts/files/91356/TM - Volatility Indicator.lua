-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60063
-- Id: 10657

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
    indicator:name("Volatility Indicator");
    indicator:description("Volatility Indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 25);
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("VI_color", "Color of VI", "Color of VI", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period,HalfPeriod;

local first;
local source = nil;

-- Streams block
local VI = nil;
local yom,yomyom;
local som,varyyom,AvgSom;
local AvgPrice,AvgYomYom;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	HalfPeriod = Period /2 ;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		AvgPrice = core.indicators:create("MVA", source, Period);
		yom  = instance:addInternalStream(0, 0);
		AvgYom = core.indicators:create("MVA", yom, Period*2);
		yomyom	 = instance:addInternalStream(0, 0);
		AvgYomYom = core.indicators:create("MVA", yomyom,  Period*2);
		varyyom  = instance:addInternalStream(0, 0);
		som  = instance:addInternalStream(0, 0);
		AvgSom = core.indicators:create("MVA", som, Period);
		first = AvgPrice.DATA:first();
        VI = instance:addStream("VI", core.Line, name, "VI", instance.parameters.VI_color, AvgSom.DATA:first());
    VI:setPrecision(math.max(2, instance.source:getPrecision()));
		VI:setWidth(instance.parameters.width);
        VI:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not source:hasData(period) then
	return;
	end
	
	AvgPrice:update(mode);
	
	if period < AvgPrice.DATA:first()+HalfPeriod  then
	return;
	end
	

	yom[period] = 100 * ((source[period] - AvgPrice.DATA[period]) /  AvgPrice.DATA[period] );
	yomyom[period]=yom[period]*yom[period];
	
	AvgYom:update(mode);
	
	if period < AvgYom.DATA:first()  then
	return;
	end
	
    local avyom = AvgYom.DATA[period];
	
	AvgYomYom:update(mode);
	
	if period < AvgYomYom.DATA:first()  then
	return;
	end
	
	 varyyom[period] =AvgYomYom.DATA[period] - ( avyom*avyom ) ;
	
	
	
	som[period] = math.sqrt( varyyom[ period] ) ;
	
	
	AvgSom:update(mode);
	
	if period < AvgSom.DATA:first()  then
	return;
	end
	 
	
	
        VI[period] = AvgSom.DATA[period];
    
end

 
