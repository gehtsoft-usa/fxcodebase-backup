-- Id: 10751
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60149

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
    indicator:name("Custom CCI");
    indicator:description("Custom CCI");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
     indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "CCI period", "CCI Period", 14);
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Color", "Line Color","", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought1", "Overbought Level","", 100);
    indicator.parameters:addDouble("oversold1","Oversold Level","", -100);
	indicator.parameters:addDouble("overbought2", "Overbought Level","", 250);
    indicator.parameters:addDouble("oversold2","Oversold Level","", -250);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;

-- Streams block
local Open = nil;
local Close = nil;
local High = nil;
local Low = nil;

local CCIOpen = nil;
local CCIClose = nil;
local CCIHigh = nil;
local CCILow = nil;
  
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	CCIClose = core.indicators:create("CCI", source, Period);	
	first = CCIClose.DATA:first() ;
	
    Close = instance:addStream("CCI", core.Line, name .. "CCI", "CCI", instance.parameters.Color, first);
	Close:setWidth(instance.parameters.width);
    Close:setStyle(instance.parameters.style);
        
    Close:addLevel(instance.parameters.oversold1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    Close:addLevel(instance.parameters.overbought1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
    Close:addLevel(instance.parameters.oversold2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    Close:addLevel(instance.parameters.overbought2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
    Close:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
				
	Close:setPrecision(math.max(2, instance.source:getPrecision()));  
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period < first   then
	return;
	end	
 
	CCIClose:update(mode);
        
        Close[period] = CCIClose.DATA[period];
        
   
end

