-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69360

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
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
    indicator:name("TREND BANDS");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "1. Period", "", 5, 1, 2000);
    indicator.parameters:addInteger("Period2", "2. Period", "", 10, 1, 2000);
	
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "1. Top Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color3", "1. Bottom Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_DASH);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5);
	
	indicator.parameters:addColor("color2", "2. Top Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color4", "2. Bottom Line Color", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period1,Period2 ; 
local first;
local source = nil;
 
local Top1, Top2;  
local Bottom1, Bottom2;   
 
-- Routine
 function Prepare(nameOnly)   
 
 
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
 
	
	
	local Parameters= Period1..", "..Period2;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+math.max(Period1,Period2);
 
   
 
    Top1 = instance:addStream("Top1" , core.Line, " Top1"," Top1",instance.parameters.color1, first);
	Top2 = instance:addStream("Top2" , core.Line, " Top2"," Top2",instance.parameters.color2, first);
	Bottom1 = instance:addStream("Bottom1" , core.Line, " Bottom1"," Bottom1",instance.parameters.color3, first);
	Bottom2 = instance:addStream("Bottom2" , core.Line, " Bottom2"," Bottom2",instance.parameters.color4, first);
 
	
	
	Top1:setWidth(instance.parameters.width1);
    Top1:setStyle(instance.parameters.style1);
    Top1:setPrecision(math.max(2, source:getPrecision()));
	
	Top2:setWidth(instance.parameters.width2);
    Top2:setStyle(instance.parameters.style2);
    Top2:setPrecision(math.max(2, source:getPrecision()));
	
	
	Bottom1:setWidth(instance.parameters.width1);
    Bottom1:setStyle(instance.parameters.style1);
    Bottom1:setPrecision(math.max(2, source:getPrecision()));
	
	
	Bottom2:setWidth(instance.parameters.width2);
    Bottom2:setStyle(instance.parameters.style2);
    Bottom2:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < first
	then
	return;
	end
	
	local min1, max1 = mathex.minmax(source, period-Period1+1, period);
    local min2, max2 = mathex.minmax(source, period-Period2+1, period);
	
	
	Top1[period]=max1;
	Bottom1[period]=min1;
	
	
	Top2[period]=max2;
	Bottom2[period]=min2;
 
end


 