-- Id: 22489
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66844

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
    indicator:name("CM-RSI");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("WilderAverage Calculation"); 
    indicator.parameters:addInteger("Period1", "Period", "", 2, 1, 2000);
 
    indicator.parameters:addInteger("Period2", "Period", "", 5, 1, 2000); 
	indicator.parameters:addInteger("Period3", "Period", "", 200, 1, 2000); 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(128, 128, 128));
	 indicator.parameters:addColor("OB_color", "OB Line Color", "", core.rgb(0, 255, 0));
	  indicator.parameters:addColor("OS_color", "OS Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("OB", "Overbought Level","", 90);
    indicator.parameters:addDouble("OS","Oversold Level","", 10);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period1;
local Period2; 
local Period3; 
local first;
local source = nil;
 
local Oscillator;  
local WilderUp, WilderDown;
local Up, Down;
local MA1, MA2;
local OB, OS;
-- Routine
 function Prepare(nameOnly)    
 
    Period1= instance.parameters.Period1; 
	Period2= instance.parameters.Period2; 
	Period3= instance.parameters.Period3;
	OB= instance.parameters.OB;
	OS= instance.parameters.OS;
	
	
	local Parameters= Period1  ..  ", " ..Period2..  ", " ..Period3 ;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    Up = instance:addInternalStream(0, 0);
    Down = instance:addInternalStream(0, 0);   
			
    source = instance.source;
    
  
    WilderUp = core.indicators:create("WMA", Up, Period1);
    WilderDown = core.indicators:create("WMA", Down, Period1);
	
	MA2 = core.indicators:create("MVA", source, Period3);
    MA1 = core.indicators:create("MVA", source, Period2);
    
    first=math.max(WilderUp.DATA:first(),MA2.DATA:first(), MA1.DATA:first());
	
	 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    
	Oscillator:addLevel(OB, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Oscillator:addLevel(OS, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	
	Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
	
end

-- Indicator calculation routine
function Update(period, mode)

 
   
   
    Up[period]= math.max(source[period]-source[period-1],0);
	Down[period]= -math.min(source[period]-source[period-1],0);
	
    WilderUp:update(mode);
	WilderDown:update(mode);
	MA1:update(mode);
	MA2:update(mode);
		
    if period < first then
	return;
	end
	
	
	Oscillator[period] =  100 - (100 / (1 + WilderUp.DATA[period] / WilderDown.DATA[period]));
	
	
	
	if source[period]> MA2.DATA[period] and source[period]< MA1.DATA[period] and Oscillator[period] < OS then
	Oscillator:setColor(period, instance.parameters.OB_color);
	elseif source[period]< MA2.DATA[period] and source[period]> MA1.DATA[period] and Oscillator[period] > OB then
	Oscillator:setColor(period, instance.parameters.OS_color);
	else
	Oscillator:setColor(period, instance.parameters.color);
	end
	
		
   
				  
end 