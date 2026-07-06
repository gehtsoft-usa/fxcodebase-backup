-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70463

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
    indicator:name("QQE of CCI");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "CCI Period", "", 50, 1, 2000);
	indicator.parameters:addInteger("Smoothing", "Smoothing ", "", 5);
    indicator.parameters:addDouble("Fast", "Fast Smoothing ", "", 2.618);
	indicator.parameters:addDouble("Slow", "Slow Smoothing", "",4.236);
	
	

 

	indicator.parameters:addGroup("Style"); 	
	 indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	
    indicator.parameters:addColor("color1", "Cental Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	 indicator.parameters:addColor("color2", "Fast Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	 indicator.parameters:addColor("color3", "Slow Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
 local Smoothing, Fast, Slow, Period;
local first;
local source = nil;
 
local Central;
local fast_line, slow_line;
local Average,Stdev;
local ema1, ema2, ema3;
local Data1, Data2;
local fast, slow;
-- Routine
 function Prepare(nameOnly)   
   
   Smoothing= instance.parameters.Smoothing;
   Fast= instance.parameters.Fast;
   Slow= instance.parameters.Slow;
   Period= instance.parameters.Period;
 
 
	
	
	local Parameters= Period..", "..Smoothing..", "..Fast..", "..Slow;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    Up= instance.parameters.Up;
	Down= instance.parameters.Down;
			
    source = instance.source; 
    first=source:first()+Period;
	
	 Average= instance:addInternalStream(0, 0); 
	 Stdev= instance:addInternalStream(0, 0); 
	 Data1= instance:addInternalStream(0, 0); 
	  Data2= instance:addInternalStream(0, 0); 
	 ema1= core.indicators:create("EMA", Data1, Smoothing);
	 ema2= core.indicators:create("EMA", Data2, Period);
	 ema3= core.indicators:create("EMA", ema2.DATA, Period);
   
    fast= instance:addInternalStream(0, 0);
	slow= instance:addInternalStream(0, 0);
	fast_line = instance:addInternalStream(0, 0);
	slow_line= instance:addInternalStream(0, 0);
	Color= instance:addInternalStream(0, 0);
	
	Central = instance:addStream("Central" , core.Line, " Central"," Central",instance.parameters.color1, first);
	Central:setWidth(instance.parameters.width1);
    Central:setStyle(instance.parameters.style1);
    Central:setPrecision(math.max(2, source:getPrecision()));
	
	fast = instance:addStream("fast" , core.Line, " fast"," fast",instance.parameters.color2, first);
	fast:setWidth(instance.parameters.width2);
    fast:setStyle(instance.parameters.style2);
    fast:setPrecision(math.max(2, source:getPrecision()));
	
	
	slow = instance:addStream("slow" , core.Line, " slow"," slow",instance.parameters.color3, first);
	slow:setWidth(instance.parameters.width3);
    slow:setStyle(instance.parameters.style3);
    slow:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < first
	then
	return;
	end
 

   Average[period]= mathex.avg(source, period -Period+1, period);
   
   local Sum=0;
   

   for i= period-Period+1, period, 1 do
   Sum=Sum+ math.abs(source[i] -Average[period]);   
   end
   
   Stdev[period]= Sum/Period;
   
    Data1[period]=  (source[period]-Average[period])/(0.015*Stdev[period]);
	 
   ema1:update(mode);
   
   Central[period]= ema1.DATA[period];
   
   
   Data2[period]=  math.abs(ema1.DATA[period-1]-ema1.DATA[period]);
   ema2:update(mode);
   ema3:update(mode);
   
   


   fast_line[period]=ema3.DATA[period]*Fast;
   slow_line [period]= ema3.DATA[period]*Slow;
   
        
		
		Value=slow[period-1];
 
         if(ema1.DATA[period] <slow[period] ) then
		  Value = ema1.DATA[period] + slow_line [period]; 
				  if ema1.DATA[period-1] < slow[period-1]  and  ema1.DATA[period-1] > slow[period-1] then
				  Value=slow[period-1];
				  end
		 end
		 
		 
		  
		  if(ema1.DATA[period] >slow[period] ) then
        Value= ema1.DATA[period] - slow_line [period]; 
           
		   
			   if ema1.DATA[period-1] >slow[period-1]  and  ema1.DATA[period-1] < slow[period-1] then
			  Value=slow[period-1];
			  end
		  
		  
         end
		 
		slow[period]=Value;
		 
		Value=fast[period-1];
		 
		  if(ema1.DATA[period] <fast[period] ) then
        Value =ema1.DATA[period] + fast_line[period]; 
			  if ema1.DATA[period-1] < fast[period-1]  and  ema1.DATA[period-1] > fast[period-1] then
			  Value=fast[period-1];
			  end
		end
		 if(ema1.DATA[period] >fast[period] ) then
        Value= ema1.DATA[period] - fast_line[period];
			  if ema1.DATA[period-1] >fast[period-1]  and  ema1.DATA[period-1] < fast[period-1] then
			  Value=fast[period-1];
			  end
        end
	  
	     
		  fast[period]=Value;
      
 
     
	   if ema1.DATA[period] >fast[period] and ema1.DATA[period] >slow[period] then
	   Color[period]=1;
	   elseif ema1.DATA[period] <fast[period] and ema1.DATA[period] <slow[period] then
	    Color[period]=-1;
	   else
	    Color[period]=Color[period-1];
	   end
	   
	   if Color[period]== 1 then
	   Central:setColor(period,Up);
	   elseif Color[period]== -1 then
	   Central:setColor(period,Down);
	   end

				  
end

 
