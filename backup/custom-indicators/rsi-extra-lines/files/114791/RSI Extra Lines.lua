-- Id: 19017

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65072

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
    indicator:name("RSI Extra Lines");
    indicator:description("RSI Extra Lines");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	 
    indicator.parameters:addInteger("Period", "Period", "Period", 14);

	
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("color", "Color of RSI", "Color of RSI", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	
	
	indicator.parameters:addGroup("Levels");	
	indicator.parameters:addDouble("Level1","Oversold Level","", 80);
	indicator.parameters:addColor("level_overboughtsold_color1", "Line Color","", core.rgb(33, 167, 238));
    indicator.parameters:addInteger("level_overboughtsold_width1","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style1", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style1", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addDouble("Level2","Oversold Level","", 20);
	indicator.parameters:addColor("level_overboughtsold_color2", "Line Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("level_overboughtsold_width2","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style2", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style2", core.FLAG_LEVEL_STYLE);
	
	
	indicator.parameters:addDouble("Level3","Oversold Level","", 40);
	indicator.parameters:addColor("level_overboughtsold_color3", "Line Color","",core.rgb(33, 167, 238));
    indicator.parameters:addInteger("level_overboughtsold_width3","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style3", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style3", core.FLAG_LEVEL_STYLE);
	
	
	indicator.parameters:addDouble("Level4","Oversold Level","", 60);
	indicator.parameters:addColor("level_overboughtsold_color4", "Line Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("level_overboughtsold_width4","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style4", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style4", core.FLAG_LEVEL_STYLE);
	
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
local RSI = nil;
local rsi;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period; 	
   
    source = instance.source;
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
	rsi = core.indicators:create("RSI", source, Period);
    first = rsi.DATA:first();
	
	
        RSI = instance:addStream("RSI", core.Line, name, "RSI", instance.parameters.color, first);
 
	
        RSI:setWidth(instance.parameters.width);
        RSI:setStyle(instance.parameters.style);
		
		RSI:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style1, instance.parameters.level_overboughtsold_width1, instance.parameters.level_overboughtsold_color1);
		RSI:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style2, instance.parameters.level_overboughtsold_width2, instance.parameters.level_overboughtsold_color2);
		RSI:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style3, instance.parameters.level_overboughtsold_width3, instance.parameters.level_overboughtsold_color3);
		RSI:addLevel(instance.parameters.Level4, instance.parameters.level_overboughtsold_style4, instance.parameters.level_overboughtsold_width4, instance.parameters.level_overboughtsold_color4);
		
		RSI:setPrecision(math.max(2, instance.source:getPrecision()));
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    rsi:update(mode);
	 

    if period < first or not  source:hasData(period) then
	return;
	end
	
        RSI[period] =  rsi.DATA[period]  ;
      
	 
	
end

