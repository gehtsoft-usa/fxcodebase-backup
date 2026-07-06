-- Id: 6180
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15310

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
    indicator:name("KMAMA");
    indicator:description("KMAMA");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("Short", "Short Period", "Short Period", 25);
	indicator.parameters:addInteger("Long", "Long Period", "Long Period", 50);
    indicator.parameters:addColor("Up", "Color of Up", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Short, SHORT;
local Long, LONG;

local first;
local source = nil;

-- Streams block
local KMAMA = nil;
local HZU, HZL;
-- Routine
function Prepare(nameOnly)
    Short = instance.parameters.Short;
	Long = instance.parameters.Long;
    source = instance.source;   

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Short).. ", " .. tostring(Long) .. ")";
    instance:name(name);
	

    if (not (nameOnly)) then
		SHORT = core.indicators:create("MVA", source.close, Short);
		LONG = core.indicators:create("MVA", source.close, Long);
		
		 first = math.max(SHORT.DATA:first(), LONG.DATA:first());
	    KMAMA =instance:addInternalStream(0, 0);
		
		HZU = instance:addStream("HZU", core.Bar, name .. "HZU", "", core.rgb(0, 0, 0), first);
    HZU:setPrecision(math.max(2, instance.source:getPrecision()));
		HZL = instance:addStream("HZL", core.Bar, name .. "HZL", "", core.rgb(0, 0, 0), first);	
    HZL:setPrecision(math.max(2, instance.source:getPrecision()));
		instance:createFromToBarGroup("KMAMA", "", HZU, HZL, core.rgb(0, 0, 0));
	
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period <  first and  not source:hasData(period) then
	return;
	end
	
	SHORT:update(mode);
	LONG:update(mode);
	
        KMAMA[period] = 100* (SHORT.DATA[period]/LONG.DATA[period]);
		

		
    	if KMAMA[period] > KMAMA[period-1] then
		-- KMAMA:setColor(period,instance.parameters.Up);
		HZU:setColor(period,instance.parameters.Up);
         HZU[period]=	KMAMA[period];	
		 HZL[period]=	100;
		else
		-- KMAMA:setColor(period,instance.parameters.Down);
		HZU:setColor(period,instance.parameters.Down);
	  	 HZL[period]=	KMAMA[period];	
		 HZU[period]=	100;
		 end
		
end

