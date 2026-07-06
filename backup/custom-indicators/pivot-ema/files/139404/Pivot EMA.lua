-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70701

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+



-- Indicator profile initialization routine

function Init()
    indicator:name("Pivot & EMA");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
	 indicator.parameters:addInteger("Period", "Trigger Line", "", 8, 1, 2000);
    indicator.parameters:addInteger("Period1", "Short EMA", "", 13, 1, 2000);
    indicator.parameters:addInteger("Period2", "Medium EMA", "", 34, 1, 2000);	
    indicator.parameters:addInteger("Period3", "Long EMA", "", 55, 1, 2000);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addColor("color3", "3. Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addColor("color4", "4. Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style4", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width4", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period1,Period2,Period3,Period; 
local first;
local source = nil;
 
local L1, L2,  L3, L4;  
local EMA1, EMA2, EMA3,EMA4,EMA5,Pivot;
-- Routine
 function Prepare(nameOnly)   
   
   
    source = instance.source; 
 
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
	Period3= instance.parameters.Period3;
	Period= instance.parameters.Period;
	
	
	local Parameters= Period ..", ".. Period1..", "..Period2..", "..Period3;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
    Pivot= instance:addInternalStream(0, 0); 
	EMA1 = core.indicators:create("EMA", source.close, Period); 
	EMA2 = core.indicators:create("EMA", Pivot, Period1); 
	EMA3 = core.indicators:create("EMA", Pivot, Period2); 
	EMA4 = core.indicators:create("EMA", Pivot, Period3);
	
	first=math.max(EMA1.DATA:first(), EMA2.DATA:first(), EMA3.DATA:first(), EMA4.DATA:first());
	
    L1 = instance:addStream("Line1" , core.Line, "1. Line","1. Line",instance.parameters.color1, first );
	L1:setWidth(instance.parameters.width1);
    L1:setStyle(instance.parameters.style1);
    L1:setPrecision(math.max(2, source:getPrecision()));
	
	L2 = instance:addStream("Line2" , core.Line, "2. Line","2. Line",instance.parameters.color2, first );
	L2:setWidth(instance.parameters.width2);
    L2:setStyle(instance.parameters.style2);
    L2:setPrecision(math.max(2, source:getPrecision()));
	
	
	
	L3= instance:addStream("Line3" , core.Line, "3. Line","3. Line",instance.parameters.color3, first );
	L3:setWidth(instance.parameters.width3);
    L3:setStyle(instance.parameters.style3);
    L3:setPrecision(math.max(2, source:getPrecision()));
	
	
	
	L4 = instance:addStream("Line4" , core.Line, "4. Line","4. Line",instance.parameters.color4, first );
	L4:setWidth(instance.parameters.width4);
    L4:setStyle(instance.parameters.style4);
    L4:setPrecision(math.max(2, source:getPrecision()));
	
	
	
end

-- Indicator calculation routine
function Update(period, mode)

Pivot[period]=  (source.high[period] + source.low[period] + source.close[period])/3;
EMA1:update(mode);
EMA2:update(mode);
EMA3:update(mode);
EMA4:update(mode);

 
	if period < first
	then
	return;
	end
 
		
     L1[period]= EMA1.DATA[period];
	 L2[period]= EMA2.DATA[period];
	 L3[period]= EMA3.DATA[period];
	 L4[period]= EMA4.DATA[period];
end

 