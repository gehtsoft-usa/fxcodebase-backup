-- Id: 14008
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60133

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
    indicator:name("HA Difference");
    indicator:description("HA Difference");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period", "Period" , 3);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("open_color", "Color of Difference", "Color of Difference", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("close_color", "Color of Signal", "Color of Signal", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Method, Period;
local first;
local source = nil;
local open, close;
-- Streams block
local Difference = nil;
local Signal = nil;
local MA;
-- Routine
function Prepare(nameOnly)
    source = instance.source; 
	Method =instance.parameters.Method;
	Period = instance.parameters.Period;
    first = source:first();
	
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. Period.. ", " .. Method.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	open = instance:addInternalStream(0, 0);
	close = instance:addInternalStream(0, 0);

 
        Difference = instance:addStream("Difference", core.Line, name .. ".Difference", "Difference", instance.parameters.open_color, first);
    Difference:setPrecision(math.max(2, instance.source:getPrecision()));
		Difference:setWidth(instance.parameters.width1);
        Difference:setStyle(instance.parameters.style1);
		
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
		MA = core.indicators:create(Method, Difference, Period);
        Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.close_color, MA.DATA:first());
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setWidth(instance.parameters.width2);
        Signal:setStyle(instance.parameters.style2);
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period , mode)

     
    if period < first  then
	return;
	end
     if period == first then
        open[period] = ( source.open[period-1] + source.close[period-1] ) / 2;
     else
        open[period] = ( open[period-1] + close[period-1] ) / 2;
     end
     close[period] =  ( source.open[period] + source.high[period] + source.low[period] + source.close[period] ) / 4 ;
	   
	     Difference[period]=close[period]-open[period];
	   
	  MA:update(mode);  
	  
	if period < MA.DATA:first()  then
	return;
	end 
	 
	  Signal[period]= MA.DATA[period]; 
     
end

 