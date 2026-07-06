-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74115

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Three bar engulfing pattern");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");	 
    indicator.parameters:addBoolean("Signal", "Signal Mode", "", false);   	
	indicator.parameters:addGroup("Line Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
   indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);	
	indicator.parameters:addColor("color", "Bar Color", "", core.rgb(0, 0, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local Signal;	
local first;
local source = nil; 
local Bar;	
local up, down;
-- Routine
 function Prepare(nameOnly)   
  
	source = instance.source
	
	Signal=instance.parameters.Signal;  
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	first=source:first()+2;  
	
	High=source.high;
	Low=source.low;
	Close=source.close;
	
	
	if Signal then
    Bar = instance:addStream("Bar", core.Bar, name, "Bar", instance.parameters.color, first );
    Bar:setPrecision(math.max(2, instance.source:getPrecision())); 
    Bar:addLevel(0);	
	else
    Bar = instance:addInternalStream(0, 0);	
	end
	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top , instance.parameters.clrDN, 0);
 
end


function Update(period, mode)

    up:setNoData(period);
    down:setNoData(period);
	
 
	
	if period <= first
	or not  source:hasData(period)
	then
	return;
	end
	
 
	  
    if source.close[period] < source.open[period]
	and source.close[period] <= math.min(source.close[period-1],source.open[period-1])
	and source.close[period] <= math.min(source.close[period-2],source.open[period-2])
	and source.open[period] >= math.max(source.close[period-1],source.open[period-1])
	and source.open[period] >= math.max(source.close[period-2],source.open[period-2]) 
	then
	BearCondition = true;
	else
	BearCondition = false;
    end	
 
            
    if source.close[period] > source.open[period]
	and source.close[period] >= math.max(source.close[period-1],source.open[period-1])
	and source.close[period] >= math.max(source.close[period-2],source.open[period-2])
	and source.open[period] <= math.min(source.close[period-1],source.open[period-1])
	and source.open[period] <= math.min(source.close[period-2],source.open[period-2])	 
	then	  
	BullCondition = true;
	else
	BullCondition = false;
    end	
	
	
	if BullCondition
	then
	Bar[period]= 1;
    up:set(period, source.low[period] , "\217");	
	elseif BearCondition
    then	
    down:set(period, source.high[period] , "\218");	
	Bar[period]= -1;
    else
	Bar[period]= 0;	
	end
	
	
	
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   | 
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |   
--|USDT addres  ERC-20 (Ethereum) address)            0x258C74Caac21c9535A0969F169FE0271d3cE56A0   | 
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+