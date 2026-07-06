-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68173

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
    indicator:name("ADX Weighted RSI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "ADX Period", "", 14, 1, 2000);
    indicator.parameters:addInteger("Period2", "RSI Period", "", 14, 1, 2000);
	indicator.parameters:addDouble("weightingPC", "Weighting", "% percentage of RSI being affected", 80);
	indicator.parameters:addDouble("ADX_Min", "ADX Min", "", 23);
	indicator.parameters:addDouble("ADX_Max", "ADX Max", "", 70);
	
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
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
-- Parameters block

local Period1;
local Period2; 
local weightingPC;
local ADX_Min, ADX_Max;

local first;
local source = nil;
 
local Oscillator;  


local ADX, RSI;

local adxRange, weighting;
-- Routine
 function Prepare(nameOnly)    
 
    Period1= instance.parameters.Period1;
	Period2= instance.parameters.Period2;
	weightingPC= instance.parameters.weightingPC;
	ADX_Min= instance.parameters.ADX_Min;
	ADX_Max= instance.parameters.ADX_Max;
	
	
	local Parameters= Period1 ..  ", " ..Period2 ..  ", " .. weightingPC;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    
  
    ADX = core.indicators:create("ADX", source , Period1);
    RSI = core.indicators:create("RSI", source.close, Period2);
    
    first=math.max(ADX.DATA:first(), RSI.DATA:first());
	
	 
    adxRange = (ADX_Max-ADX_Min);
    weighting = weightingPC / 100;
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
	Oscillator:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Oscillator:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
	
	
end

-- Indicator calculation routine
function Update(period, mode)
 
    ADX:update(mode);  
	RSI:update(mode);
	
    if period < first then
	return;
	end
	
	local ADXR = (ADX.DATA[period] + ADX.DATA[period-Period1+1]) / 2
	
	
	if ADX.DATA[period]< ADXR then
     Oscillator[period]=RSI.DATA[period]
	else
	
		local rZero = RSI.DATA[period]-50;                                            
		local a = math.min(ADX_Max, math.max(ADX_Min, ADX.DATA[period]));                       
		local aNorm = 1- ( (((a-ADX_Min)/adxRange) / 1.5  ) * weighting );  
		Oscillator[period] = (rZero * aNorm) + 50              
	end
	
				  
end

 
 