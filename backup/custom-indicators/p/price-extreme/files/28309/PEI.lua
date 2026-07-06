-- Id: 6096
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=14942

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
    indicator:name("Price Extreme");
    indicator:description("Price Extreme");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 2, 1, 100);
    indicator.parameters:addInteger("Shift", "Shift", "Shift", 0, 0 , 100);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Color of Top", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("DOWN", "Color of Bottom", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Font Size", "", 10, 1 , 100);	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Shift;

local first;
local source = nil;
local Size;
-- Streams block
local Top = nil;
local up,down;
-- Routine
function Prepare(nameOnly)
    Period = (instance.parameters.Period-1);
	Size = instance.parameters.Size;
    Shift = instance.parameters.Shift;
    source = instance.source;
    first = source:first()+ Shift  +Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Shift) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.UP, 0);
		down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.DOWN, 0);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not source:hasData(period) then
	return;
	end	
	
	local UP = true;
	local DOWN = true;

	period = period-Shift;

	local i;
	
	for i = 0, Period , 1 do
	
			if source.close[period-i] < source.high[period-i-1] then
			UP = false;
			end
			
			if source.close[period-i] > source.low[period-i-1] then
			DOWN = false;
			end
	
	end
	
	
	
	if UP then
	   up:set(period , source.high[period], "\108");
    else 
	   up:setNoData (period);
    end

    if DOWN then	
	 down:set(period, source.low[period], "\108");
	else
	  down:setNoData (period);
     end	
	 
	
       -- Top[period] = nil;
    
end

