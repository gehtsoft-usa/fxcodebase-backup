-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27289
-- Id: 8002

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
    indicator:name("Relative Spread ");
    indicator:description("Relative Spread");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	 indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period1", "Smoothing", "Period", 20);
	indicator.parameters:addInteger("Period2", "Range Period", "Period", 20);
	
	 indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("RS_color", "Color of RS", "Color of RS", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period1, Period2;

local first;
local source = nil;
local bid, ask;
-- Streams block
local RS = nil;
local Spread;
local AVG1;
local AVG2;
-- Routine
function Prepare(nameOnly)
    Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
    source = instance.source;
    

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period1)  .. ", " .. tostring(Period2).. ")";
    instance:name(name);
	
    if (not (nameOnly)) then
        if source:isBid() then
         bid = source;
         ask = core.host:execute("getAskPrice");
        else
         ask = source;
         bid = core.host:execute("getBidPrice");
        end
        
        Spread = instance:addInternalStream(source:first(), 0);
        AVG1 = core.indicators:create("MVA", ask.close, Period1);
        AVG2 = core.indicators:create("MVA", bid.close, Period1);
        
        first = AVG1.DATA:first();
        RS = instance:addStream("RS", core.Line, name, "RS", instance.parameters.RS_color, first+Period2);
    RS:setPrecision(math.max(2, instance.source:getPrecision()));
		RS:setWidth(instance.parameters.width);
        RS:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   
	
	AVG1:update(mode);
	AVG2:update(mode);
	
	if period < first  then
	return;
	end	
		
	Spread[period]=(AVG1.DATA[period]-AVG2.DATA[period]);
	
	if period < first +Period2 then
	return;
	end
		
	local min, max = mathex.minmax ( Spread, period-Period2+1, period);

	

    RS[period] = (Spread[period]-min) / ((max-min)/100) ;

end

