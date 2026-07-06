-- Id: 14383

-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=62380

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
    indicator:name("Stack");
    indicator:description("Stack");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("slow", "Slow Stochastic Period", "Period", 34);
	indicator.parameters:addInteger("mid", "Mid Stochastic Period", "Period", 16);
	indicator.parameters:addInteger("fast", "Fast Stochastic Period", "Period", 8);
	indicator.parameters:addInteger("period", "Larry Williams' Percent Range Period", "Period", 6);
 
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Color of Slow", "Color of Slow Stochastic", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("color2", "Color of Mid", "Color of Mid Stochastic", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	  indicator.parameters:addColor("color3", "Color of Fast", "Color of Fast Stochastic", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	  indicator.parameters:addColor("color4", "Color of  Larry Williams' Percent Range", "Color of  Larry Williams' Percent Range", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 80);
    indicator.parameters:addDouble("oversold","Oversold Level","", 20);
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
 

local first;
local source = nil;
local Slow, Mid, Fast,Wpr;
local slow, mid, fast,wpr;
  
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    
 
    source = instance.source;
    first = source:first();
	
	

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
	
	slow = core.indicators:create("STOCHASTIC", source, instance.parameters.slow, 3,3,"MVA", "MVA");
	mid = core.indicators:create("STOCHASTIC", source, instance.parameters.mid, 3,3,"MVA", "MVA");
	fast = core.indicators:create("STOCHASTIC", source, instance.parameters.fast, 3,3,"MVA", "MVA");
	wpr = core.indicators:create("RLW", source, instance.parameters.period);
	
	
        Slow = instance:addStream("Slow", core.Line, name .. ".Slow", "Slow", instance.parameters.color1, slow.DATA:first());
		Slow:setWidth(instance.parameters.width1);
        Slow:setStyle(instance.parameters.style1);
		Slow:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		Slow:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
		
        Mid = instance:addStream("Mid", core.Line, name .. ".Mid", "Mid", instance.parameters.color2, mid.DATA:first());
		Mid:setWidth(instance.parameters.width2);
        Mid:setStyle(instance.parameters.style2);
 
		Fast= instance:addStream("Fast", core.Line, name .. ".Fast", "Fast", instance.parameters.color3, fast.DATA:first());
		Fast:setWidth(instance.parameters.width3);
        Fast:setStyle(instance.parameters.style3);
		
		Wpr= instance:addStream("WPR", core.Line, name .. ".WPR", "WPR", instance.parameters.color4, wpr.DATA:first());
		Wpr:setWidth(instance.parameters.width4);
        Wpr:setStyle(instance.parameters.style4);
		
		
		Slow:setPrecision(math.max(2, instance.source:getPrecision()));
		Mid:setPrecision(math.max(2, instance.source:getPrecision()));
		Fast:setPrecision(math.max(2, instance.source:getPrecision()));
		Wpr:setPrecision(math.max(2, instance.source:getPrecision()));
     
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
 
	
	 
		fast:update(mode);
		slow:update(mode);
		mid:update(mode);
		wpr:update(mode);
		
		if period >  fast.DATA:first() then
		Fast[period] = fast.DATA[period]; 
		end
		
		if period >  slow.DATA:first() then
		Slow[period] = slow.DATA[period];  
		end
		
		if period >  mid.DATA:first() then
		Mid[period] = mid.DATA[period]; 
		end
		
		if period >  wpr.DATA:first() then
		Wpr[period] = wpr.DATA[period]+100;  
		end
		
        
    
end

