-- Id: 422
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=671

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
function Init()
    indicator:name("Aroon Oscillator");
    indicator:description("Aroon Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Trend");

    indicator.parameters:addGroup("Calculation");	 
    indicator.parameters:addInteger("N", "Period", "Period", 25, 3, 1000);
    indicator.parameters:addGroup("Style");
	
	indicator.parameters:addGroup("Style");	 
    indicator.parameters:addColor("Color", "Aroon Oscillator", "Aroon Oscillator ", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
   
   
    indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 50);
    indicator.parameters:addDouble("oversold","Oversold Level","", -50);
    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;

local firstPeriod;
local source = nil;

-- Streams block
local UP = {};
local DOWN = {};
local Aroon=nil;


-- Routine
function Prepare(nameOnly) 
    N = instance.parameters.N;
    source = instance.source;
    firstPeriod = source:first() + N - 1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
    
	UP = instance:addInternalStream(0, 0);
	DOWN = instance:addInternalStream(0, 0);
	
	
    Aroon = instance:addStream("Aroon", core.Line, name .. " Oscillator", "Aroon", instance.parameters.Color, firstPeriod)
    Aroon:setPrecision(math.max(2, instance.source:getPrecision()));
	Aroon:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Aroon:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
    Aroon:setWidth(instance.parameters.width);
    Aroon:setStyle(instance.parameters.style);	
end

-- Indicator calculation routine
function Update(period)
    local v, i;
    if period >= firstPeriod then
        v, i = core.max(source.high, core.rangeTo(period, N));
        UP[period] = (N - (period - i)) / N * 100;
		
        v, i = core.min(source.low, core.rangeTo(period, N));
        DOWN[period] = (N - (period - i)) / N * 100;
				
		Aroon[period]= UP[period]-DOWN[period];
				
    end
	
end
