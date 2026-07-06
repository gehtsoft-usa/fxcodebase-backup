-- Id: 7558
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=24005

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
    indicator:name("REX Indicator");
    indicator:description("REX Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SP", "Smoothing Period", "Smoothing Period", 14);
    indicator.parameters:addInteger("SS", "Signal Period", "Signal Period", 14);
	
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("REX_color", "Color of REX", "Color of REX", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("SIGNAL_color", "Color of SIGNAL", "Color of SIGNAL", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Swidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Sstyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Sstyle", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local SP;
local SS;

local first;
local source = nil;

-- Streams block
local REX = nil;
local SIGNAL = nil;
local TVB;
-- Routine
function Prepare(nameOnly)
    SP = instance.parameters.SP;
    SS = instance.parameters.SS;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(SP) .. ", " .. tostring(SS) .. ")";
    instance:name(name);
    if (not (nameOnly)) then
        TVB=instance:addInternalStream(first, 0);	
        
        MA1= core.indicators:create("MVA",TVB , SP);
        MA2= core.indicators:create("MVA",MA1.DATA , SS);
        REX = instance:addStream("REX", core.Line, name .. ".REX", "REX", instance.parameters.REX_color, MA1.DATA:first());
		REX:setWidth(instance.parameters.width);
        REX:setStyle(instance.parameters.style);
		
        SIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color, MA2.DATA:first());
		SIGNAL:setWidth(instance.parameters.Swidth);
        SIGNAL:setStyle(instance.parameters.Sstyle);
		
		REX:setPrecision(math.max(2, instance.source:getPrecision()));
	    SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first then
	return;
	end
	
	
	    TVB[period]= 3 * source.close[period]-(source.low[period]+source.open[period]+source.high[period]);
		
		MA1:update(mode);
        MA2:update(mode);
		
		
		if period < MA1.DATA:first() then
		return;
		end		
		
        REX[period] = MA1.DATA[period];	       
		
		if period < MA2.DATA:first() then
		return;
		end
		
		 SIGNAL[period] =MA2.DATA[period];
 
end

