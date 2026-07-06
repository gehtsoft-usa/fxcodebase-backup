-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2637
-- Id: 2256

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
    indicator:name("JP Oscillator");
    indicator:description("JP Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
   
    indicator.parameters:addInteger("Frame", "MA Period", "", 5,2,2000);
	indicator.parameters:addBoolean("USE", "Use MA", "", true);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("JP_UP", "Color of JP UP", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("JP_DN", "Color of JP DN", "", core.rgb(255, 0, 0));
  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block


local first;
local source = nil;

-- Streams block
local JP=nil;
local JPUP = nil;
local JPDN = nil;
local MA=nil;
local USE;
-- Routine
function Prepare(nameOnly)
    USE=instance.parameters.USE;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() ..  ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	JP=instance:addInternalStream (first, 0);
	MA = core.indicators:create("MVA", JP, instance.parameters.Frame);
    JPUP = instance:addStream("JPUP", core.Bar, name .. ".UP", "UP", instance.parameters.JP_UP, first+4);
    JPUP:setPrecision(math.max(2, instance.source:getPrecision()));
    JPDN = instance:addStream("JPDN", core.Bar, name .. ".DN", "DN", instance.parameters.JP_DN, first+4);
    JPDN:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)      
    if period >= first+4 and source:hasData(period) then
        JP[period] = (source[period] -  (source[period-1]/2 + source[period-2]/2)) - ( 0 - (source[period] - source[period-4]));
		
		if USE then
			 MA:update(mode);  
			 if MA.DATA:hasData(period) and MA.DATA:hasData(period-1) then
					 if MA.DATA[period] > MA.DATA[period-1] then 
					JPUP[period]=MA.DATA[period];
					JPDN[period]=nil;
					else
					JPDN[period]=MA.DATA[period];
					JPUP[period]=nil;
					end
			 end
		else 
		             if JP[period] > JP[period-1] then 
					JPUP[period]=JP[period];
					JPDN[period]=nil;
					else
					JPDN[period]=JP[period];
					JPUP[period]=nil;
					end
		     
        end  		
    end
end

