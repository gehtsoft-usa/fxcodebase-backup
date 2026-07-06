-- Id: 17079
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64126

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

function Init()
    indicator:name("BB ATR Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("ATR Calculation"); 
    indicator.parameters:addInteger("ATR_Period", "Period", "", 14);
    indicator.parameters:addDouble("ATR_Multiplier", "Multiplier", "", 2);
 
	
	indicator.parameters:addGroup("BB Calculation"); 
    indicator.parameters:addInteger("BB_Period", "Period", "", 20);
    indicator.parameters:addDouble("BB_Deviation", "Period", "", 2);
  
  
  
   indicator.parameters:addGroup("OB/OS Levels");	
   indicator.parameters:addDouble("Line1", "Top Line", "", 0);
   indicator.parameters:addDouble("Line2", "Bottom Line", "", 0);
   
   	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Neutral", "Neutral Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local first;
local source = nil;
local Line1, Line2;
local ATR_Period, ATR_Multiplier, BB_Period, BB_Deviation;
local ATR, BB;
-- Routine
function Prepare(nameOnly)
    ATR_Period= instance.parameters.ATR_Period;
	ATR_Multiplier= instance.parameters.ATR_Multiplier;
	BB_Period= instance.parameters.BB_Period;
	BB_Deviation= instance.parameters.BB_Deviation; 
	Line1= instance.parameters.Line1;
	Line2= instance.parameters.Line2;
			
    source = instance.source;
    
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
  
    ATR = core.indicators:create("ATR", source, ATR_Period);
    BB = core.indicators:create("BB", source.close,  BB_Period, BB_Deviation);
    
    first=math.max(ATR.DATA:first(), BB.DATA:first());
	
	
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.Neutral, first);
    Oscillator:addLevel(Line1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Oscillator:addLevel(Line2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
    Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);	
	
	Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
		
end

-- Indicator calculation routine
function Update(period, mode) 
 
    ATR:update(mode);
    BB:update(mode);	
	
    if period < first then
	return;
	end

		
     Oscillator[period]= (BB.TL[period]-BB.BL[period]) -(ATR.DATA[period]*ATR_Multiplier);
	 
	 if Oscillator[period] > Line1 then
	 Oscillator:setColor(period, instance.parameters.Up);
	 elseif Oscillator[period] < Line2 then
	 Oscillator:setColor(period, instance.parameters.Down);
	 else
	 Oscillator:setColor(period, nstance.parameters.Neutral	);
	 end

end

