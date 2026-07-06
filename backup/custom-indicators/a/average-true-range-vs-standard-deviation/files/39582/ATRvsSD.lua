-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22965
-- Id: 7266

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
    indicator:name("Average True Range vs Standard Deviation");
    indicator:description("Average True Range vs Standard Deviation");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("AP", "ATR Period", "ATR Period", 14);
    indicator.parameters:addInteger("SP", "SD Period", "SP Period", 14);
	
	indicator.parameters:addString("Price" , "SD Data Source", "", "close");
    indicator.parameters:addStringAlternative("Price" , "Open", "", "open");
    indicator.parameters:addStringAlternative("Price", "High", "", "high");
    indicator.parameters:addStringAlternative("Price" , "Low", "", "low");
	indicator.parameters:addStringAlternative("Price" , "Close", "", "close");
	indicator.parameters:addStringAlternative("Price", "Median", "", "median");
    indicator.parameters:addStringAlternative("Price" , "Typical", "", "typical");
	indicator.parameters:addStringAlternative("Price" , "Weighted ", "", "weighted");	
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("ATR_color", "Color of ATR", "Color of ATR", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Awidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Astyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Astyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("SD_color", "Color of SD", "Color of SD", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Swidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Sstyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Sstyle", core.FLAG_LINE_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local AP;
local SP;
local Price;
local first;
local source = nil;

-- Streams block
local ATR = nil;
local SD = nil;
local A;
-- Routine
function Prepare(nameOnly)
    AP = instance.parameters.AP;
    SP = instance.parameters.SP;
    source = instance.source;
    Price = instance.parameters.Price;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(AP) .. ", " .. tostring(SP) .. ")";
    instance:name(name);
	
    if (not (nameOnly)) then
        A= core.indicators:create("ATR", source, AP);
        
         first = math.max(A.DATA:first(), SP);
    
        ATR = instance:addStream("ATR", core.Line, name .. ".ATR", "ATR", instance.parameters.ATR_color, first);
		ATR:setWidth(instance.parameters.Awidth);
        ATR:setStyle(instance.parameters.Astyle);
        SD = instance:addStream("SD", core.Line, name .. ".SD", "SD", instance.parameters.SD_color, first);
		SD:setWidth(instance.parameters.Swidth);
         SD:setStyle(instance.parameters.Sstyle);
		 
		ATR:setPrecision(math.max(2, instance.source:getPrecision()));
		SD:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period >= first and source:hasData(period) then
	
	   A:update(mode); 
	   ATR[period] = A.DATA[period];
        SD[period] = mathex.stdev(source[Price], period - SP + 1, period);
    end
end

