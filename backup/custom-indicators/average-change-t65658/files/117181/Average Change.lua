-- Id: 20409
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65658

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
    indicator:name("Average Change");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addString("Mode", "Method", "Method" , "Open/Close");
    indicator.parameters:addStringAlternative("Mode", "High/Low", "High/Low" , "High/Low");
    indicator.parameters:addStringAlternative("Mode", "Open/Close", "Open/Close" , "Open/Close");
	
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Period", "Period", "Period" , 14);

    indicator.parameters:addColor("Up", "Up  Color","Up Color", core.COLOR_UPCANDLE);
	indicator.parameters:addColor("Down", "Down Color","Down Color", core.COLOR_DOWNCANDLE);
	indicator.parameters:addColor("color", "Color of Signal", "Color of Signal", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Method;
local Mode;
-- Streams block
local Range = nil;
local Period;
local Signal;
local MA;
local Up,Down;
--local N;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	Method=instance.parameters.Method;
	Mode=instance.parameters.Mode;
	Period=instance.parameters.Period;
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;

    local name = profile:id() .. "(" .. source:name() .. "," .. Mode.. ", " .. Method.. ", " .. Period.. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Range = instance:addStream("Range", core.Bar, name, "Range",Up, first);
		MA = core.indicators:create(Method, Range, Period);
		Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.color, MA.DATA:first());
		Signal:setWidth(instance.parameters.width);
        Signal:setStyle(instance.parameters.style);
		
		Range:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    if period < first 
	or not source:hasData(period) then
	return;
	end
	

	    

       local Min,Max=source.low[period], source.high[period];

	    if Mode == "High/Low" then
        Range[period] =( Max-Min)/source:pipSize();
		else
		Range[period] =math.abs( source.open[period]-source.close[period])/source:pipSize();
		end
		
		
	if source.close[period]> source.open[period] then
	Range:setColor(period, Up);
	else
	Range:setColor(period,  Down);
	end
		
	
	MA:update(mode);
	
	if period< 	MA.DATA:first() then
	return;
	end
    Signal[period]= MA.DATA[period];
end

