-- Id: 2647
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2961

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("KAMA Oscillator");
    indicator:description("KAMA Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("SF", "Short Period", "", 20,2, 2000);
    indicator.parameters:addInteger("LP", "Long Period", "", 100, 2, 2000);
    indicator.parameters:addColor("KO_Up", "Color of KO Up", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("KO_Down", "Color of KO Down", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local SF;
local LP;

local Short, Long;

local first;
local source = nil;

-- Streams block
local UP = nil;
local DOWN = nil;

-- Routine
function Prepare(nameOnly)
    SF = instance.parameters.SF;
    LP = instance.parameters.LP;
    source = instance.source;
     
    local name = profile:id() .. "(" .. source:name() .. ", " .. SF .. ", " .. LP .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	Short = core.indicators:create("KAMA", source, SF);
	Long = core.indicators:create("KAMA", source, LP);  
	first = math.max(Short.DATA:first(),Long.DATA:first());
	
    UP = instance:addStream("Up", core.Bar, name, "Up", instance.parameters.KO_Up, first);
	DOWN = instance:addStream("Down", core.Bar, name, "Down", instance.parameters.KO_Down, first);
	 
	 
	UP:setPrecision(math.max(2, instance.source:getPrecision()));
	DOWN:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)    
    if period >= first and source:hasData(period) then
	
	  Short:update(mode);
	  Long:update(mode);  
	  
 
	   
	    local F =  Long.DATA[period] -Short.DATA[period];
		local L =  Long.DATA[period-1] -Short.DATA[period-1];
	   
	    if  F > L then
        UP[period] = F;
		DOWN[period] = nil;
		else
		DOWN[period] = F;
		UP[period] = nil;
		end
    end
end

