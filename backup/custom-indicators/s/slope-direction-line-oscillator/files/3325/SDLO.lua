-- Id: 2281
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1670

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
    indicator:name("Slope direction line oscillator");
    indicator:description("Slope direction line oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addInteger("Frame1", "Short Period", " Short Period", 40);
		
	indicator.parameters:addString("Method1", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "", "TMA"); 
    indicator.parameters:addString("Price1", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price1", "open", "", "open");
    indicator.parameters:addStringAlternative("Price1", "close", "", "close");
    indicator.parameters:addStringAlternative("Price1", "high", "", "high");
    indicator.parameters:addStringAlternative("Price1", "low", "", "low");
	indicator.parameters:addStringAlternative("Price1", "median", "", "median");
    indicator.parameters:addStringAlternative("Price1", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "weighted", "", "weighted");
	
	indicator.parameters:addInteger("Frame2", "Long Period", " Long Period", 80);
	
	indicator.parameters:addString("Method2", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "", "TMA"); 
        indicator.parameters:addString("Price2", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price2", "open", "", "open");
    indicator.parameters:addStringAlternative("Price2", "close", "", "close");
    indicator.parameters:addStringAlternative("Price2", "high", "", "high");
    indicator.parameters:addStringAlternative("Price2", "low", "", "low");
	indicator.parameters:addStringAlternative("Price2", "median", "", "median");
    indicator.parameters:addStringAlternative("Price2", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "weighted", "", "weighted");
	
    indicator.parameters:addColor("UP_color", "Color of  UP", "Color of UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DOWN_color", "Color of DOWN", "Color of DOWN", core.rgb(255, 0, 0));
    indicator.parameters:addColor("NEUTRAL_color", "Color of NEUTRAL", "Color of NEUTRAL", core.rgb(255, 128, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Price1, Price2,Method1, Method2, Frame1, Frame2 ;

local first;
local source = nil;

-- Streams block
local UP = nil;
local DOWN = nil;
local NEUTRAL = nil;

local SHORT=nil;
local LONG = nil;
local SDLInput2, SDLInput1;
-- Routine
function Prepare(nameOnly)
     
	Price1=instance.parameters.Price1; 
	Price2=instance.parameters.Price2; 
	Method1=instance.parameters.Method1;
	Method2=instance.parameters.Method2; 
	Frame1=instance.parameters.Frame1;
	Frame2=instance.parameters.Frame2; 
    source = instance.source;
   
    
	assert(core.indicators:findIndicator("SLOPE_DIRECTION_LINE") ~= nil, "Please, download and install SLOPE_DIRECTION_LINE.LUA indicator");    
    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame1 .."," .. Price1 .. ", "..Method1 .. ", ".. Frame2 .."," .. Price2.. ", ".. Method2  .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end	
	LONG= core.indicators:create("SLOPE_DIRECTION_LINE", source[Price1], Frame1 , Method1 , true);
	SHORT= core.indicators:create("SLOPE_DIRECTION_LINE", source[Price2], Frame2 , Method2 , true);
	 first = math.max(LONG.DATA:first(),SHORT.DATA:first()); 

    UP = instance:addStream("UP", core.Bar, name .. ".UP", "UP", instance.parameters.UP_color, first);
    UP:setPrecision(math.max(2, instance.source:getPrecision()));
    DOWN = instance:addStream("DOWN", core.Bar, name .. ".DOWN", "DOWN", instance.parameters.DOWN_color, first);
    DOWN:setPrecision(math.max(2, instance.source:getPrecision()));
    NEUTRAL = instance:addStream("NEUTRAL", core.Bar, name .. ".NEUTRAL", "NEUTRAL", instance.parameters.NEUTRAL_color, first);
    NEUTRAL:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    
	
	LONG:update(mode);
	SHORT:update(mode);
	
	 UP[period] = nil;
     DOWN[period] = nil;
     NEUTRAL[period] = nil;	 
	 
	 if period < first then
	 return;
	 end
	 
	
				if LONG.DATA[period-1] < LONG.DATA[period] and SHORT.DATA[period-1] < SHORT.DATA[period]   then 
				UP[period] = 1;
				elseif LONG.DATA[period-1] > LONG.DATA[period] and SHORT.DATA[period-1] > SHORT.DATA[period]   then 
			    DOWN[period] = 1;
				else
				NEUTRAL[period] = 1;
				end
 
end

