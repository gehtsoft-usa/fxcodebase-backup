-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66652

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
    indicator:name("Regularized Momentum");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator); 
	
	indicator.parameters:addGroup("Calculation"); 
     
    indicator.parameters:addInteger("Length", "Length", "", 14);
    indicator.parameters:addDouble("Lambda", "Lambda", "", 7);
	indicator.parameters:addInteger("MinMaxPeriod", "MinMaxPeriod", "", 15);
    indicator.parameters:addDouble("LevelUp", "Period", "", 90);
    indicator.parameters:addDouble("LevelDown", "Period", "", 10);
    indicator.parameters:addInteger("Multiplier", "Multiplier", "", 1); 
	
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	
	
	indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 255));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5);
	
	
	indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 255));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5);
	
	
	indicator.parameters:addColor("color3", "Central Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 1, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local LevelUp, LevelDown, Lambda, MinMaxPeriod, Length; 
local first;
local source = nil;
local alpha,regf1, regf2; 
local Oscillator, Data;  
local Top, Bottom, Central; 
local Multiplier;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	LevelUp= instance.parameters.LevelUp;
	LevelDown= instance.parameters.LevelDown;
	Lambda= instance.parameters.Lambda;
	MinMaxPeriod= instance.parameters.MinMaxPeriod;
	Length= instance.parameters.Length;
	Multiplier= instance.parameters.Multiplier;
	
	
	alpha  = 2.0/(1.0+Length);
    regf1  = (1.0+Lambda*2.0);
    regf2  = (1.0+Lambda);

    
	Data= instance:addInternalStream(0, 0);
			
    source = instance.source; 
    first=source:first();
	
	 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.Up, first+1);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
	
	
	Top = instance:addStream("Top" , core.Line, " Top"," Top",instance.parameters.color1, first+1+MinMaxPeriod);
	Top:setWidth(instance.parameters.width1);
    Top:setStyle(instance.parameters.style1);
	
	Bottom = instance:addStream("Bottom" , core.Line, " Bottom"," Bottom",instance.parameters.color2, first+1+MinMaxPeriod);
	Bottom:setWidth(instance.parameters.width2);
    Bottom:setStyle(instance.parameters.style2);
	
	Central = instance:addStream("Central" , core.Line, " Central"," Central",instance.parameters.color3, first+1+MinMaxPeriod);
	Central:setWidth(instance.parameters.width3);
    Central:setStyle(instance.parameters.style3);
	
	
	Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
	Top:setPrecision(math.max(2, instance.source:getPrecision()));
	Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
	Central:setPrecision(math.max(2, instance.source:getPrecision()));
	
end

-- Indicator calculation routine
function Update(period, mode)

 
   	
    if period < first then
	return;
	end
	
	if period == first then
	Data[period]= source.median[period];
	return;
	end 
	
	if period < first+1 then
	return;
	end
 
  Data[period] = (regf1*Data[period-1]+alpha*(source.median[period]-Data[period-1])-Lambda*Data[period-2])/regf2;
  Oscillator[period] = ((Data[period]-Data[period-1])/Data[period])*Multiplier;
 
 
    if Oscillator[period]> Oscillator[period-1] then
	Oscillator:setColor(period, instance.parameters.Up);
    else
	Oscillator:setColor(period, instance.parameters.Down);
	end
	
	
 
    if period < first+1+MinMaxPeriod then
	return;
	end

  local min,max=mathex.minmax(Oscillator, period-MinMaxPeriod+1, period);
  
  
  local range = max-min;
  
  Top[period] = min+LevelUp*range/100.0
  Bottom[period] = min+LevelDown*range/100.0
  Central[period] = min+0.5*range
  
end 