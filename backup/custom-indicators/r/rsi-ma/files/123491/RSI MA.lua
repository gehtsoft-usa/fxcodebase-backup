-- Id: 23725
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67292

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("RSI + MA");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period", "", 14, 1, 1000);
 
 
 
 
	indicator.parameters:addGroup("Line Style");
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
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

 


local Period;

local RSI,MA;
local rsi, ma;

 function Prepare(nameOnly)   
 
 
    Period = instance.parameters.Period;

 
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " ..  Period .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

  

	source = instance.source;
	
	
	
	rsi=core.indicators:create("RSI",  source  ,  Period);
	ma=core.indicators:create("MVA",  source,  Period);
 
	
	first= rsi.DATA:first();

    
	RSI = instance:addStream("RSI", core.Line, "RSI", "RSI", instance.parameters.color, first);
	RSI:setWidth(instance.parameters.width);
    RSI:setStyle(instance.parameters.style);


    MA= instance:addStream("MA", core.Line, "MA", "MA", instance.parameters.color, first);
    MA:setPrecision(math.max(2, instance.source:getPrecision()));
	MA:setWidth(instance.parameters.width);
    MA:setStyle(instance.parameters.style);
 
	
	core.host:execute ("attachOuputToChart", "MA")
	
	
	RSI:setPrecision(math.max(2, source:getPrecision()));
	RSI:setPrecision(math.max(2, source:getPrecision()));
	
	RSI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	RSI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	
	
 
		
end

-- Indicator calculation routine
function Update(period, mode)
	
    
			if period < first then 
			return;
			end
	

    
			   rsi:update(mode);
			   ma:update(mode); 
	 
		
	MA[period]=ma.DATA[period];			
    RSI[period]=rsi.DATA[period];		
		
 end


