-- Id: 4879
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7662

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
    indicator:name("Closing Price Position Oscillator");
    indicator:description("Closing Price Position Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
       indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("High", "High(%)", "", 75);
    indicator.parameters:addDouble("Low", "Low(%)", "", 25);
	
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Color of Top Range Candle", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN", "Color of Bottom Range Candle", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("NE", "Color of Mid Range Candle", "", core.rgb(0, 0, 255));
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local High;
local Low;
local UP, DN, NE;

local first;
local source = nil;

-- Streams block
local open = nil;
local close = nil;
local high = nil;
local low = nil;

-- Routine
function Prepare(nameOnly)
    UP = instance.parameters.UP;
	DN = instance.parameters.DN;
	NE = instance.parameters.NE;
	
    High = instance.parameters.High;
    Low = instance.parameters.Low;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. High .. ", " .. Low .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    open = instance:addStream("open", core.Bar, name .. ".open", "open",  core.rgb(0, 0, 0), first);
    open:setPrecision(math.max(2, instance.source:getPrecision()));
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first and not source:hasData(period) then
	return;
	end

	
	
		local One=  (source.high[period] -source.low[period]) /100;
           open[period]  =   (source.close[period]-source.low[period])/ One;	
		
			if  open[period] > High  then 
			open:setColor(period, UP);	
			elseif  open[period] < Low then 
			open:setColor(period, DN);	
			else
            open:setColor(period, NE);				
			end	
    
end

