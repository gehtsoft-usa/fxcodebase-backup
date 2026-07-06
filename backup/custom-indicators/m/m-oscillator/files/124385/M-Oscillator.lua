-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67438

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

function Init()
    indicator:name("M-Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 14, 1, 2000);
	indicator.parameters:addInteger("Period1", "1. EMA Period", "", 5, 1, 2000);
	indicator.parameters:addInteger("Period2", "2. EMA Period", "", 3, 1, 2000);
	indicator.parameters:addInteger("Period3", "3. EMA Period", "", 2, 1, 2000);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Histogram Color", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addColor("color2", "Oscillator Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addColor("color3", "Signal Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 10);
    indicator.parameters:addDouble("oversold","Oversold Level","", -10);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period1,Period2, Period3, Period;

local first;
local source = nil;
local EMA1, EMA2, EMA3;
local Data;

local Oscillator;  
local Histogram;  
local Signal;   

-- Routine
 function Prepare(nameOnly)    
 
    Period= instance.parameters.Period;
	Period1= instance.parameters.Period1;
	Period2= instance.parameters.Period2;
	Period3= instance.parameters.Period3;
	
	
	local Parameters= Period;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
  
  
    Data = instance:addInternalStream(0, 0);
    
			
    source = instance.source;
    first=source:first()+Period;
  
    EMA1 = core.indicators:create("EMA", Data, Period1);
    EMA2 = core.indicators:create("EMA",  EMA1.DATA, Period1);
    EMA3 = core.indicators:create("EMA",  EMA2.DATA, Period2);
    
	
	 
   
 
	Histogram = instance:addStream("Histogram" , core.Bar, " Histogram"," Histogram",instance.parameters.color1, first+Period1+ Period2+Period3 );
	Histogram:setPrecision(math.max(2, source:getPrecision()));
	
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color2, first+Period1+ Period2+Period3 );
	Oscillator:setWidth(instance.parameters.width2);
    Oscillator:setStyle(instance.parameters.style2);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
	Signal = instance:addStream("Signal" , core.Line, " Signal"," Signal",instance.parameters.color3, first+Period1+ Period2+Period3 );
	Signal:setWidth(instance.parameters.width3);
    Signal:setStyle(instance.parameters.style3);
    Signal:setPrecision(math.max(2, source:getPrecision()));
	
	
	Histogram:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Histogram:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 

	
	
    if period < first then
	return;
	end
	
	local S=0;
	
	
	for i= 1, Period,1 do
	
		if source[period]> source[period-i] then
		S=S+1;
		elseif source[period]< source[period-i] then
		S=S-1;
		end
	
	end
	
	
	Data[period]=S;
	
	
	EMA1:update(mode);
	EMA2:update(mode);
	EMA3:update(mode);
		
	if period < first+Period1+ Period2+Period3 then
	return;
	end
	

    
		
    Histogram[period]=EMA1.DATA[period];
	Oscillator[period]=EMA2.DATA[period];
	Signal[period]=EMA3.DATA[period];
				  
end


 