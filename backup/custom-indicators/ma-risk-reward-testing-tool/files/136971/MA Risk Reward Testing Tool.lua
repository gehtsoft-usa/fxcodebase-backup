-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70315

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
    indicator:name("MA Risk Reward Testing Tool");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
	
	indicator.parameters:addInteger("Short", "Short Period", "Period" , 50);
	indicator.parameters:addInteger("Long", "Long Period", "Period" , 200);
	
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
    indicator.parameters:addInteger("Risk", "Risk", "", 1, 1, 2000);
    indicator.parameters:addInteger("Reward", "Reward", "", 1, 1, 2000);
    indicator.parameters:addInteger("Targer", "Targer", "", 100 , 1, 100000);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Risk,Reward,Targer; 
local first;
local source = nil;
 
local Oscillator;  
local Indicator={};
local Method,Short, Long;
-- Routine
 function Prepare(nameOnly)   
 
 
    Risk= instance.parameters.Risk;
    Reward= instance.parameters.Reward;
	Targer= instance.parameters.Targer;
	Method= instance.parameters.Method;
	Short= instance.parameters.Short;
	Long= instance.parameters.Long;
	
	local Parameters= Risk..", "..Reward;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	short = core.indicators:create(Method, source, Short);
	long = core.indicators:create(Method, source, Long);
	
    first=math.max(short.DATA:first(), long.DATA:first()) ;
	
	One= instance:addInternalStream(0, 0);
    Two= instance:addInternalStream(0, 0);

	
	
end

-- Indicator calculation routine
function Update(period, mode)


    short:update(mode);
	long:update(mode);

 
	if period < first
	then
	return;
	end
	
	One[period]=short.DATA[period];
    Two[period]=long.DATA[period];
	
	local Up, Down=0,0; 
	local Signal;
	if period < source:size()-1 then
	return;
	end 
	
	
	for period= source:first(), source:size()-1, 1 do
	   
	   
	     Signal=0;
		 
		 if One[period]> Two[period]  and One[period-1]<= Two[period-1] then
		 Signal= Test (period, 1)
		 elseif One[period]< Two[period]  and One[period-1]>= Two[period-1] then
		 Signal= Test (period, -1)
		 end
	   
	     if Signal> 0 then
	     Up=Up+Signal;
		 else
		 Down=Down+Signal;
		 end
	      
	end
	
 
	core.host:execute ("drawLabel", 1, source:date(source:size()-1), source[period], Up.."/"..Down);			  
end


function Test (period, Side)

 local Return =0;
 
      for i= period+1	  , source:size()-1 , 1  do
	  
	       
	  
	       if Side== 1 then
	  
				   if source[i]>(source[period]+source:pipSize()*Targer*Reward) then
				   Return=Targer*Reward; 
					elseif source[i]<(source[period]-source:pipSize()*Targer*Risk) then
				   Return=-Targer*Risk;				    
				   end				   
				   
				   if Return~=0 then
				   break;
				   end
				   
				   
		   elseif Side== -1 then
		           if source[i]<(source[period]+source:pipSize()*Targer*Reward) then
				   Return=Targer*Reward; 
					elseif source[i]>(source[period]-source:pipSize()*Targer*Risk) then
				   Return=-Targer*Risk; 
				   end  
				   
				   if Return~=0 then
				   break;
				   end
		   
		   end
	  
	  
	  end
	  
	  
	 return Return;
end


 
