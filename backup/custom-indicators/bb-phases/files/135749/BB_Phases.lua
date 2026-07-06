-- More information about this indicator can be found at:
-- http://fxcodebase.com/ 

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
    indicator:name("BB Phases indicator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Number of periods", "", 20);
    indicator.parameters:addDouble("Deviation", "Number of standard deviations", "", 2);
    indicator.parameters:addInteger("NLimit", "Narrow limit in pips", "", 20);
    indicator.parameters:addInteger("ELimit", "Expansion limit in pips", "", 40);
    indicator.parameters:addInteger("AnPeriod", "Analizing period", "", 10);
    indicator.parameters:addInteger("GLimit", "Limit for growth in %", "", 70);
    indicator.parameters:addInteger("FLimit", "Limit for fall in %", "", 30);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Bclr", "Band lines color", "Band lines color", core.rgb(219, 64, 0));
    indicator.parameters:addInteger("Bwidth", "Band lines width", "Band lines width", 1, 1, 5);
    indicator.parameters:addInteger("Bstyle", "Band lines style", "Band lines style", core.LINE_SOLID);
    indicator.parameters:setFlag("Bstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addBoolean("ADisable", "Hide average line", "", false);
    indicator.parameters:addColor("Aclr", "Average line color", "Average line color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Awidth", "Average line width", "Average line width", 1, 1, 5);
    indicator.parameters:addInteger("Astyle", "Average line style", "Average line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Astyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clr1", "Break preparation phase color", "Break preparation phase color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr2", "Breakout phase color", "Breakout phase color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("clr3", "Break normalization phase color", "Break normalization phase color", core.rgb(255, 255, 0));
    indicator.parameters:addColor("clr4", "Closing breakout phase color", "Closing breakout phase color", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("Transparency", "Transparency", "", 80,0,100);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local  first;
local source = null;
local Period;
local Deviation;
local NLimit;
local ELimit;
local AnPeriod;
local GLimit;
local FLimit;
local BB;
local TL=null;
local BL=null;
local AL=null;
local TL2=null;
local BL2=null;
local pipSize;
-- Routine
 function Prepare(nameOnly)   
 
 
    source = instance.source;
    Period=instance.parameters.Period;
    Deviation=instance.parameters.Deviation;
    NLimit=instance.parameters.NLimit;
    ELimit=instance.parameters.ELimit;
    AnPeriod=instance.parameters.AnPeriod;
    GLimit=instance.parameters.GLimit;
    FLimit=instance.parameters.FLimit;
    first = source:first()+2;
    TL2 = instance:addInternalStream(first, 0);
    BL2 = instance:addInternalStream(first, 0);
    BB = core.indicators:create("BB", source, Period, Deviation);
    local  name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Deviation .. ", " .. instance.parameters.NLimit .. ", " .. instance.parameters.ELimit .. ", " .. instance.parameters.AnPeriod ..", " .. instance.parameters.GLimit .. ", " .. instance.parameters.FLimit .. ")";
 
	
    instance:name(name); 


    if   (nameOnly) then
        return;
    end 
	
	
    TL = instance:addStream("TL", core.Line, name .. ".TL", "TL", instance.parameters.Bclr, first);
    TL:setWidth(instance.parameters.Bwidth);
    TL:setStyle(instance.parameters.Bstyle);
    BL = instance:addStream("BL", core.Line, name .. ".BL", "BL", instance.parameters.Bclr, first);
    BL:setWidth(instance.parameters.Bwidth);
    BL:setStyle(instance.parameters.Bstyle);
    AL = instance:addStream("AL", core.Line, name .. ".AL", "AL", instance.parameters.Aclr, first);
    AL:setWidth(instance.parameters.Awidth);
    AL:setStyle(instance.parameters.Astyle);
    if (instance.parameters.ADisable) then    
     AL:setVisible(false);
    end
    instance:createChannelGroup("BB_Phases", "BB_Phases", TL2, BL2, instance.parameters.clr1, 100-instance.parameters.Transparency);
    pipSize=source:pipSize();

	
	
end

-- Indicator calculation routine
function Update(period, mode)

   if (period<first+AnPeriod) then
   return;
   end
   
   
    BB:update(mode);
    TL[period]=BB.TL[period];
    BL[period]=BB.BL[period];
    AL[period]=BB.AL[period];
    
    local  Range=(TL[period]-BL[period])/pipSize;
    if (Range<=NLimit) then
   
     TL2[period]=TL[period];
     BL2[period]=BL[period];
     TL2:setColor(period, instance.parameters.clr1);
    

    elseif (Range>=ELimit) then
    
						 local Up = 0;
						 local Dn=0;
						 local i;
						 for  i=0,  AnPeriod-1, 1 do
								 
								  if (TL[period-i]-BL[period-i]>TL[period-i-1]-BL[period-i-1]) then
								  
								   Up=Up+1;
								  
								  elseif (TL[period-i]-BL[period-i]<TL[period-i-1]-BL[period-i-1]) then
							  
								   Dn=Dn+1;
								  
								 end
						 end
						 
						 if (Up+Dn>0) then
						
								  local UpPC=100*Up/(Up+Dn);
								  if (UpPC>=GLimit) then
								 
								   TL2[period]=TL[period];
								   BL2[period]=BL[period];
								   TL2:setColor(period, instance.parameters.clr2);
								
								  elseif (UpPC<=FLimit) then
								 
								  
								   TL2[period]=TL[period];
								   BL2[period]=BL[period];
								   TL2:setColor(period, instance.parameters.clr4);
								   
								  else
							 
								   TL2[period]=TL[period];
								   BL2[period]=BL[period];
								   TL2:setColor(period, instance.parameters.clr3);
								   end
						 end
    
    else
    
     TL2[period]=null;
     BL2[period]=null; 
    end
  

 
 
end


 
