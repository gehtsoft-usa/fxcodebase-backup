-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67280

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
    indicator:name("SVE Stochastic RSI");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	

	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("RSILength", "RSI Length", "", 13, 1, 2000);
    indicator.parameters:addInteger("StochLength", "Stoch Length", "", 5, 1, 2000);
	indicator.parameters:addInteger("StochAvgLength", "Stoch Avg Lengt", "", 8, 1, 2000);
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 80);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local RSILength, StochLength, StochAvgLength ; 
local first;
local source = nil;
 
local Oscillator;  
local RSI;

local RSILow, HiLow;
-- Routine
 function Prepare(nameOnly)   
 
 
 
    RSILength= instance.parameters.RSILength;
	StochLength= instance.parameters.StochLength;
	StochAvgLength= instance.parameters.StochAvgLength;
 
	
	local Parameters= RSILength ..  ", " .. StochLength ..  ", " .. StochAvgLength;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    RSILow= instance:addInternalStream(0, 0);
	HiLow= instance:addInternalStream(0, 0);
			
    source = instance.source;
    
  
    RSI = core.indicators:create("RSI", source, RSILength);
    
    first=RSI.DATA:first()+StochLength ;
	
	 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first +StochAvgLength );
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	Oscillator:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Oscillator:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Oscillator:addLevel(50, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    RSI:update(mode);
     
	
	
    if period < first then
	return;
	end
	
    
  local min,max =mathex.minmax(RSI.DATA, period-StochLength+1,period)
 
   
  
   RSILow[period] = RSI.DATA[period] - min ;
   HiLow[period] = max -min ;
 
   if period < first +StochAvgLength then
	return;
	end
 
    AvgRSILow = mathex.avg( RSILow, period-StochAvgLength+1,period ) ;
    AvgHiLow = mathex.avg( HiLow, period-StochAvgLength+1,period ) ;
 
 
    
 
     Oscillator[period]=AvgRSILow / ( 0.1 + AvgHiLow ) * 100;
				  
end

 
 