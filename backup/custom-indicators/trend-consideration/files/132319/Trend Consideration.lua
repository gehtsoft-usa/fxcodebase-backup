-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69585

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("Trend Consideration");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addInteger("Period", "Period", "", 5);
 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "1. Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", "2. Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("color3", "3. Color", "", core.rgb(0, 0, 288));
	indicator.parameters:addColor("color4", "4. Color", "", core.rgb(128, 128, 128));
 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period; 
 

local first;
local source = nil;
 
local Delta,RawData ;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
    
	 source = instance.source; 
    first=source:first();
	
	local Parameters= Period ;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    assert (source:barSize()=="m15", "The chosen m15 time frame!");
			
   
	
	RawData = instance:addInternalStream(0, 0); 
 
	Delta = instance:addStream("Delta" , core.Bar, " Delta"," Delta",instance.parameters.color1, first ); 
    Delta:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	
	if period < source:first()  
	then
	return;
	end 
 
	RawData[period]=(source[period]- source[period-1])/source:pipSize(); 
 
 
    local date; 
	local Count=0;
	local Sum=0; 
	local ItIs;
	
	    date = core.dateToTable(source:date(period));
	
	    if date.min >= 0 and date.min < 15    then
		ItIs=1;
		Delta:setColor(period, instance.parameters.color1 );
		elseif date.min >= 15 and date.min < 30    then 
		ItIs=2; 
		Delta:setColor(period, instance.parameters.color2 );
		elseif date.min >= 30 and date.min < 45    then  
		ItIs=3; 
		Delta:setColor(period, instance.parameters.color3 );
		elseif date.min >= 45 and date.min < 60    then   
		ItIs=4; 
		Delta:setColor(period, instance.parameters.color4 );
		end		
		
		
    for i= period, source:first(), -1 do
 
		date = core.dateToTable(source:date(period));
		if date.min >= 0 and date.min < 15   and Count<= Period and ItIs ==1 then
		 Count= Count+1; 
		 Sum=Sum+RawData[period];
		elseif date.min >= 15 and date.min < 30  and Count<= Period and ItIs ==2  then 
		  Count= Count+1; 
		 Sum=Sum+RawData[period];
		elseif date.min >= 30 and date.min < 45   and Count<= Period and ItIs ==3 then  
		  Count= Count+1; 
		 Sum=Sum+RawData[period];
		elseif date.min >= 45 and date.min < 60  and Count<= Period and ItIs ==4 then   
		  Count= Count+1; 
		 Sum=Sum+RawData[period];
		end		
		
		
		if Count==Period then
		break;
		end
	
    end
	
	
	  
	if Count~=0 then
	Delta[period]=Sum/Count;
    end	
end

 
