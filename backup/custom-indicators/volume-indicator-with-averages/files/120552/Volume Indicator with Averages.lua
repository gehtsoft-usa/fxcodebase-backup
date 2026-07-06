-- Id: 21970

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66501

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
    indicator:name("Volume Indicator with Averages");
    indicator:description("Volume Indicator with Averages");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Calculaton");
	indicator.parameters:addInteger("Period", "MA Period", "Period" , 14);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");

	
	indicator.parameters:addGroup("Volume Style");
	
	indicator.parameters:addBoolean("Color", "Color Mode", "", false);
    indicator.parameters:addColor("Up", "Color of Up", "Color of Volume", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down", "Color of Volume", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Volume", core.rgb(128, 128, 128));
	
	indicator.parameters:addGroup("MA Line Style");
	 indicator.parameters:addColor("color", "Line Color", "Line Color", core.rgb(0, 0, 255));
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

-- Streams block
local Volume = nil;
 
local Up,Down,Neutral,Color;
local Period, Method;
local MA,ma;
-- Routine
function Prepare(nameOnly)
     
	Up = instance.parameters.Up;
	Down = instance.parameters.Down; 
	Neutral = instance.parameters.Neutral;
	Color = instance.parameters.Color;
	Period = instance.parameters.Period;
	Method = instance.parameters.Method;
    source = instance.source;
	 
    first = source.close:first();
	
 

    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
	
	 if   (nameOnly) then
        return;
    end 
	
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	ma = core.indicators:create(Method, source.volume, Period);
	

   
     Volume = instance:addStream("Volume", core.Bar, name, "Volume", Up, first); 
    Volume:setPrecision(math.max(2, instance.source:getPrecision()));
	 MA = instance:addStream("MA", core.Line, name, "Volume", instance.parameters.color, first+Period); 
	 MA:setWidth(instance.parameters.width);
     MA:setStyle(instance.parameters.style);
	 MA:setPrecision(math.max(2, instance.source:getPrecision()));
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

     
	
	if period < first or not  source:hasData(period) then
	return;
	end
	
 
        Volume[period] = source.volume[period];
		
	
		
		if  Color  then
		
			if Volume[period]>  Volume[period-1] then
				
				Volume:setColor(period, Up);
				
			elseif Volume[period]<  Volume[period-1] then
			   
				Volume:setColor(period, Down);
			else
				Volume:setColor(period, Neutral);
			end
		
		end 
		
		ma:update(mode);
			
			if period < first +Period then
			return;
			end
			MA[period]=ma.DATA[period];
    
end

