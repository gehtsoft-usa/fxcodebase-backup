-- Id: 2216
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2615&sid=e771a98f6d78bea9bee97875e3ca9bbb

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
    indicator:name("Wilders moving average Oscilator");
    indicator:description("Wilders moving average Oscilator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("ShortFrame", "Short WMA Period", "No description", 5);
    indicator.parameters:addInteger("LongFrame", "Long WMA Period", "No description", 20);	
    
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("WMAODown_color", "Color of WMAODown", "Color of WMAODown", core.rgb(255, 0, 0));		
	indicator.parameters:addColor("WMAOUp_color", "Color of WMAOUp", "Color of WMAOUp", core.rgb(0, 255, 0));
	indicator.parameters:addBoolean("ONE", "One Color Line Mode", "", false);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local ShortFrame;
local LongFrame;
local One;

local first;
local source = nil;

-- Streams block
local WMAO = nil;
local WMAODown = nil;
local WMAOUp = nil;

local Short;
local Long;

-- Routine
function Prepare(nameOnly)
    
	 assert(core.indicators:findIndicator("WMA") ~= nil, "Please download and install WMA Indicator");
    ShortFrame = instance.parameters.ShortFrame;
    LongFrame = instance.parameters.LongFrame;
	One = instance.parameters.ONE;
	
	assert(not ( ShortFrame > LongFrame)  , "Short WMA Must have a shorter period from the Long WMA.");
	
    source = instance.source;
    first = source:first();
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. ShortFrame .. ", " .. LongFrame .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	Short =core.indicators:create("WMA", source, ShortFrame);
	Long =core.indicators:create("WMA", source, LongFrame);
	if One then
    WMAO = instance:addStream("WMAO", core.Bar, name .. ".WMAO", "WMAO", instance.parameters.WMAODown_color, first);
    WMAO:setPrecision(math.max(2, instance.source:getPrecision()));
	else
	WMAO = instance:addInternalStream (first,0);   
    WMAOUp = instance:addStream("WMAOUp", core.Bar, name .. ".WMAOUp", "WMAOUp", instance.parameters.WMAOUp_color, first);
    WMAOUp:setPrecision(math.max(2, instance.source:getPrecision()));
	WMAODown = instance:addStream("WMAODown", core.Bar, name .. ".WMAODown", "WMAODown", instance.parameters.WMAODown_color, first);
    WMAODown:setPrecision(math.max(2, instance.source:getPrecision()));
	end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period >= first and source:hasData(period) then
	
	
	Short:update(mode);
	Long:update(mode);
	
	if not Long.DATA:hasData(period) or not Long.DATA:hasData(period-1)  then 
	return;
	end
	
        WMAO[period] = Short.DATA[period] - Long.DATA[period];
		
		if not  One  then
				if  WMAO[period] > WMAO[period-1] then 	
				WMAOUp[period] = WMAO[period];
				WMAODown[period] = nil;
				else		  
				WMAODown[period] = WMAO[period];
				WMAOUp[period] = nil;
				end
		end
    end
end

