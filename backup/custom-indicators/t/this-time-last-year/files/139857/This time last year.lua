-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=70759

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("This  time last year");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  

  
    indicator.parameters:addColor("color", "Line Color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local Flag;
local first;
local source = nil;
local High={};
local Low={};
local Change={};
local Range={};
local Count={};
local PeriodSize;
local Price;
--local NumberOfElements;
-- Routine
function Prepare(nameOnly)
    AdjustedColor = instance.parameters.AdjustedColor;
	 SeasonallyAdjustedColor = instance.parameters. SeasonallyAdjustedColor;
    source = instance.source;
    first = source:first()+1;
	
	local  s1, e1 = core.getcandle(source:barSize(), 0, 0, 0);	
	PeriodSize=e1-s1;
	
	
    NumberOfElements=1/PeriodSize;
	
	local  s2, e2 = core.getcandle("D1", 0, 0, 0);	
	MinPeriodSize=e2-s2;
	
	assert(MinPeriodSize <= PeriodSize , "Please select D1 Time frame or higher");

    local name = profile:id() .. "(" .. source:name()   .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
 
 
   Flag=true;
   
   Close = instance:addStream("Close", core.Line,   "Close"  , "Close", instance.parameters.color, first,365*2);
   Close:setPrecision(math.max(2, instance.source:getPrecision()));
   Close:setWidth(instance.parameters.width);
   Close:setStyle(instance.parameters.style);
   
   Price= instance:addInternalStream(0, 365*2);
end


function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

   
    Price[period]=source.close[period];

    period=period-1;
	
    if period <=first then
	 Flag=true; 
	 High={};
	 Low={};
	 Change={};
	 Range={};
	 Count={}; 
	return;
	end
	
	
	
	
	Calculate(period); 
	
	

	
	if period  < source:size()-2 then
	return; 
	end
	 
	if Flag then
		for i= first, source:size()-1, 1 do
		ReCalculate(i); 
		end
		
		Flag=false;
	end
	


   
end



function ReCalculate(period) 


     local Date= core.dateToTable(source:date(period)); 
  
 

 
	local StartDate=  core.datetime (Date.year , 1, 1, 1, 1, 1);  
    local StartPeriod= core.findDate (source, StartDate, false);
	
    local Index= period- StartPeriod+1;	
	
	 if Low[Index] ==nil then  
	 return;
	 end

    Close[period]= (source.close[period]-Low[Index])/((High[Index]-Low[Index])/100);
 
	

end
	
function Calculate(period) 

	if period == source:size()-2 then
	return;
	end
 
 
 local Date= core.dateToTable(source:date(period)); 
 
 
 
	local StartDate=  core.datetime (Date.year , 1, 1, 1, 1, 1);  
    local StartPeriod= core.findDate (source, StartDate, false);
   
    local Index= period- StartPeriod+1;	 

  
		  if Low[Index] ==nil then  
		  Low[Index] = source.low[period]; 			  
		  elseif  Low[Index] > source.low[period]   then
		   Low[Index] = source.low[period]
		  end
		  
		   if  High[Index] == nil    then
			High[Index] = source.high[period] 
		  elseif  High[Index] < source.high[period]   then
		   High[Index] = source.high[period] 
		  end
  
  
          if Change[Index] == nil then   
          Change[Index]= (source.close[period] -	 source.open[period])/ source:pipSize();	  
          Count[Index]=1;	 		  
		  
		  else
		   Change[Index]=  Change[Index]+   ( source.close[period] -	 source.open[period]) / source:pipSize();	
		  Count[Index]= Count[Index]+1;			   
		  end
  
             if Range[Index] == nil then   
          Range[Index]= (source.high[period] -	 source.low[period]) / source:pipSize();	
		  else
		   Range[Index]= Range[Index] +((source.high[period] -	 source.low[period]) / source:pipSize());		  
 		  
		  end

 end 
  