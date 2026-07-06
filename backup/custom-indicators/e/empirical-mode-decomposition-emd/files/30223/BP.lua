-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=16189
-- Id: 6370

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("BANDPASS FILTER");
    indicator:description("BANDPASS FILTER");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	 indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "BANDPASS FILTER Period", "", 20);
	indicator.parameters:addDouble("Delta", "Delta", "", 0.5);


	 indicator.parameters:addGroup("Band Pass Filter Style Options");
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("BPwidth", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("BPstyle", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("BPstyle", core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Delta, Beta, Gamma,Alpha;

local Period;
local first;
local source = nil;

-- Streams block
local BP = nil;
local AVG;

-- Routine
function Prepare(nameOnly)   
    Delta = instance.parameters.Delta;
	Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+2;
	
	Beta = math.cos(math.rad(360 / Period));
    Gamma = 1 / math.cos(math.rad(720*Delta / Period));
    Alpha = Gamma - math.sqrt(Gamma*Gamma - 1);
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Delta) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        BP= instance:addInternalStream(first, 0);
        AVG = instance:addStream("BPF", core.Line, name, "BPF", instance.parameters.color, first+ Period*2);
    AVG:setPrecision(math.max(2, instance.source:getPrecision()));
		 AVG:setWidth(instance.parameters.BPwidth);
         AVG:setStyle(instance.parameters.BPstyle);	
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not  source:hasData(period) then
	return;
	end
        BP[period] =  0.5*(1 - Alpha)*(source.median[period] - source.median[period-2]) + Beta*(1 + Alpha)*BP[period-1]- Alpha* BP[period-2];
		
	if period < first + 2* Period then
    return;
    end	
		AVG[period]= mathex.avg(BP, period - 2*Period + 1, period);
		
	
    
end

