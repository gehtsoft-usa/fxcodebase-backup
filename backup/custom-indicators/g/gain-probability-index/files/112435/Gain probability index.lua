-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64656
-- Id: 18137

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Gain probability index");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 50, 1 , 2000);
	
 
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Line Color","", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("style","Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
	
	 indicator.parameters:addGroup("OB/OS Levels");	 
	indicator.parameters:addDouble("overbought1", "OB Level","", 70);
    indicator.parameters:addDouble("oversold1","OS Level","", 30);
  
	
	indicator.parameters:addColor("level_overboughtsold_color1", "Line Color","", core.rgb(255, 0, 0)); 
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	


end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Signal;
local Period;
local first;
local source = nil;
local GPI; 

-- Routine
function Prepare(nameOnly)
    
    Period = instance.parameters.Period;
	source = instance.source;
    first = source:first()+Period;
	
    local name = profile:id() .. "(" .. source:name()   .. ")";
    instance:name(name);
	if nameOnly then 
        return;
    end
	
    GPI = instance:addStream("GPI", core.Line, name .. ".GPI", "GPI", instance.parameters.color,source:first()+Period)
    GPI:setPrecision(math.max(2, instance.source:getPrecision()));
    GPI:setWidth(instance.parameters.width);
    GPI:setStyle(instance.parameters.style); 
    GPI:addLevel(instance.parameters.oversold1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color1);
	GPI:addLevel(instance.parameters.overbought1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color1);    	 
 

	
end

 



function Update(period)
   
   if period < first then
   return;
   end
   
   local Up=0;
   local Down=0;
   
   
   for i= 0,Period, 1 do
   if source[period-i]>source[period-i-1] then
    Up=Up+1;
	 
	end
	if source[period-i]<source[period-i-1] then
    Down=Down+ 1;	 
	end
	end
	
	 
	
    GPI[period]=100*( (Up) /(Up+Down));	
		
end 