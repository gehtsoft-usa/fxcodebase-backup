-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70511

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
    indicator:name("Tick Neio-SweetSpot");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
	
	 indicator.parameters:addInteger("Period", "Period", "", 3 , 1, 2000);
	
    indicator.parameters:addDouble("pip1", "1. Pip", "", 10 , 1, 2000);
    indicator.parameters:addDouble("pip2", "2. Pip", "", 3 , 1, 2000);
	
    indicator.parameters:addDouble("pip3", "3. Pip", "", 7, 1, 2000);
 
	
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Central Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addColor("color2", "1. Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addColor("color3", "2. Line Color", "", core.rgb(255, 128, 0));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addColor("color4", "3. Line Color", "", core.rgb(255, 255, 0));
	indicator.parameters:addInteger("style4", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width4", "Line Width", "", 3, 1, 5);
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local pip1,pip2, pip3; 
local Pip1,Pip2, Pip3; 
local first;
local source = nil;
 
local Central; 
local Top={};
local Bottom={}; 
local Period;

 
   
-- Routine
 function Prepare(nameOnly)   
 
    Period= instance.parameters.Period;
    pip1= instance.parameters.pip1;
    pip2= instance.parameters.pip2;
	pip3= instance.parameters.pip3;
	
	
	local Parameters= Period ..", ".. pip1..", "..pip2..", "..pip3;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first();
	
	
	Pip1=pip1*source:pipSize();
	Pip2=pip2*source:pipSize();
	Pip3=pip3*source:pipSize();
	
	 Average= instance:addInternalStream(0, 0);
   
 
	Central = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color1,source:first());
	Central:setWidth(instance.parameters.width1);
    Central:setStyle(instance.parameters.style1);
    Central:setPrecision(math.max(2, source:getPrecision()));
	
	
	for i= 1, 3 ,1 do
	
	
	Top[i] = instance:addStream("Top"..i , core.Line, " Top"..i," Top"..i,instance.parameters:getColor("color" .. i+1),source:first());
	Top[i]:setWidth(instance.parameters:getInteger("width" .. i+1));
    Top[i]:setStyle(instance.parameters:getInteger("style" .. i+1));
    Top[i]:setPrecision(math.max(2, source:getPrecision()));
	
	
	Bottom[i] = instance:addStream("Bottom"..i , core.Line, " Bottom"..i," Bottom"..i,instance.parameters:getColor("color" .. i+1),source:first());
	Bottom[i]:setWidth(instance.parameters:getInteger("width" .. i+1));
    Bottom[i]:setStyle(instance.parameters:getInteger("style" .. i+1));
    Bottom[i]:setPrecision(math.max(2, source:getPrecision()));
	
	end
	
	
	
end

-- Indicator calculation routine
function Update(period, mode)


 
   
   if period < source:first()+Period then
   return;
   end
   
   
   local Low, High= mathex.minmax(source, period-Period+1, period);
   
         if (period== source:first()+Period) then
          
			 Top[3][period]=High ;
			 Bottom[3][period]=Top[3][period]-Pip1;
       
         else
       
		 
		   if (High-Bottom[3][period-1])>=Pip1   then            
            Top[3][period]=High ;
            Bottom[3][period]= Top[3][period]-Pip1;
           end
		   
		   
		     if (Top[3][period-1]-Low>Pip1)  then
            
           
            Bottom[3][period]=Low;
			 Top[3][period]=Bottom[3][period] +Pip1;
            end
		   
		    if ((High-Bottom[3][period-1]<=Pip1) and  (Top[3][period-1]-Low<=Pip1)) then
            
            Bottom[3][period]=Bottom[3][period-1];
            Top[3][period]= Top[3][period-1];
            end
         
 
		   
		 Central[period]=( Top[3][period]+Bottom[3] [period])/2;
		 
          
		 Top[2][period]=Central[period]+Pip2;
		 Top[1][period]=Central[period]+Pip1;
		 Bottom[2][period]=Central[period]-Pip2;
		 Bottom[1][period]=Central[period]-Pip1;
		 
		end
  
end
 
 
