-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67149

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("RSI of RSI");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period1", "Short EMA", "", 14, 1, 1000);
    indicator.parameters:addInteger("Period2", "Signal Line", "", 5, 1, 1000);
	
	 
	
	indicator.parameters:addGroup("Selector");
    indicator.parameters:addBoolean("Show1", "Show First", "", true);
    indicator.parameters:addBoolean("Show2", "Show Second", "", true);
 
	
	indicator.parameters:addGroup("1. Line Style");
	indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
 
	indicator.parameters:addGroup("2. Line Style");
	indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
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

 

local Show1,Show2;
local Period1, Period2;
local One, Two, Three;
local RSI1,RSI2,rsi1,rsi2;

 function Prepare(nameOnly)   
 
 
    Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " ..  Period1 .. ", " ..  Period2 .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    Show1 = instance.parameters.Show1;
	Show2 = instance.parameters.Show2;
	
  

	source = instance.source;
	
	
	
	rsi1=core.indicators:create("RSI",  source  ,  Period1);
	rsi2=core.indicators:create("RSI",  rsi1.DATA,  Period2);
 
	
	first= rsi2.DATA:first();

    if Show1 then	
	RSI1 = instance:addStream("RSI1", core.Line, "1. RSI", "1. RSI", instance.parameters.color1, first);
	RSI1:setWidth(instance.parameters.width1);
    RSI1:setStyle(instance.parameters.style1);
	else
	RSI1 = instance:addInternalStream(0, 0);
	end
	
	if Show2 then
    RSI2 = instance:addStream("RSI2", core.Line, "2. RSI", "2. RSI", instance.parameters.color2, first);
	RSI2:setWidth(instance.parameters.width2);
    RSI2:setStyle(instance.parameters.style2);
	else
	RSI2 = instance:addInternalStream(0, 0);
	end
	
	
	RSI1:setPrecision(math.max(2, source:getPrecision()));
	RSI2:setPrecision(math.max(2, source:getPrecision()));
	
	RSI1:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	RSI1:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	
	
	RSI2:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	RSI2:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		
end

-- Indicator calculation routine
function Update(period, mode)
	
    
			if period < first then 
			return;
			end
	

    
			   rsi1:update(mode);
			   rsi2:update(mode); 
	 
		
	RSI1[period]=rsi1.DATA[period];			
    RSI2[period]=rsi2.DATA[period];		
		
 end


