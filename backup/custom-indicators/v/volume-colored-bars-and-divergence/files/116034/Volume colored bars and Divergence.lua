-- Id: 19735
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=65363

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
    indicator:name("Volume colored bars and Divergence");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));
	
	indicator.parameters:addGroup("Calculation");
	
	
	indicator.parameters:addInteger("Period", "MA Period", "Period" , 20);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addGroup("MA Line Style");
	indicator.parameters:addColor("color", " color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up,Down, Neutral;
local first;
local source = nil;


local  Volume=nil;
local MA,ma;


function Prepare(nameOnly)

    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
 
	source = instance.source;
	
	
	 
    local name = profile:id() .. "(" .. source:name() .. ", " .. source:barSize() 
	..  ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	
	first= source:first();

    	
	Volume = instance:addStream("Volume", core.Bar, "Volume", "Volume", Neutral, first);
    Volume:setPrecision(math.max(2, instance.source:getPrecision()));
     
    assert(core.indicators:findIndicator(instance.parameters.Method) ~= nil, instance.parameters.Method .. " indicator must be installed");
	MA = core.indicators:create(instance.parameters.Method, Volume, instance.parameters.Period);	
	
	ma = instance:addStream("Average", core.Line, "Average", "Average", instance.parameters.color, MA.DATA:first());
    ma:setPrecision(math.max(2, instance.source:getPrecision()));
	ma:setWidth(instance.parameters.width);
    ma:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
function Update(period,mode )
	
    Volume[period] = source.volume[period];
	
			if period < first then
			open:setColor(period, Neutral);	
			return;
			end
	
 
		 
		 
if(source.high[period]>source.high[period-1] and source.low[period]>=source.low[period-1]) then 
Volume:setColor(period, Up);	
elseif(source.high[period]>source.high[period-1] and source.low[period]<source.low[period-1]) then  
Volume:setColor(period, Neutral);	
elseif(source.high[period]<=source.high[period-1] and source.low[period]<source.low[period-1]) then  
Volume:setColor(period, Down);
elseif(source.high[period]<=source.high[period-1] and source.low[period]>=source.low[period-1]) then 
Volume:setColor(period, Neutral);
end 


MA:update(mode);

if period < MA.DATA:first() then
return;
end


ma[period]= MA.DATA[period];
				

		
 end


