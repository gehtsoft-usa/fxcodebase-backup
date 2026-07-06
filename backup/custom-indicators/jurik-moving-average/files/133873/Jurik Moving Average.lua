-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69854

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
    indicator:name("Jurik Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Length", "Length", "", 7, 1, 2000);
    indicator.parameters:addInteger("Phase", "Phase", "", 50 );	
    indicator.parameters:addInteger("Power", "Power", "", 2, 1, 2000);
	
	

 
   
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Length,Phase, Power; 
local first;
local source = nil;
local phaseRatio, beta,alpha; 
local e0, e1, e2;
local JMA;
-- Routine
 function Prepare(nameOnly)   
 
 
    Length= instance.parameters.Length;
    Phase= instance.parameters.Phase;
	Power= instance.parameters.Power;
	
	
	local Parameters= Length..", "..Phase..", "..Power;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 
	
	
 
	if Phase < -100 then
	phaseRatio= 0.5;
    elseif Phase > 100 then
	phaseRatio= 2.5; 
	else
	phaseRatio= Phase/100+1.5; 
	end
	

	beta = 0.45 * (Length - 1) / (0.45 * (Length - 1) + 2)
	alpha = math.pow(beta, Power)


    if   (nameOnly) then
        return;
    end

    e0= instance:addInternalStream(0, 0);
	e1= instance:addInternalStream(0, 0);
	e2= instance:addInternalStream(0, 0);
			
    source = instance.source; 
    first=source:first();
	
 
   
 
	JMA = instance:addStream("JMA" , core.Line, " JMA"," JMA",instance.parameters.Up, first );
	JMA:setWidth(instance.parameters.width);
    JMA:setStyle(instance.parameters.style);
    JMA:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < source:first() 
	then
	return;
	end
	
	
	JMA[period] = 0.0;

	e0[period] = 0.0
	e0[period]= (1 - alpha) * source[period] + alpha *  e0[period-1] 

	e1[period] = 0.0
	e1[period]= (source[period] - e0[period]) * (1 - beta) + beta *  e1[period-1] 

	e2[period] = 0.0
	e2[period]= (e0[period] + phaseRatio * e1[period] - JMA[period-1]) * math.pow(1 - alpha, 2) +  math.pow(alpha, 2) *  e2[period-1] 

	JMA[period]= e2[period] +  JMA[period-1];


    
	
	if JMA[period]> JMA[period-1] then
	JMA:setColor(period, instance.parameters.Up);
	else
	JMA:setColor(period, instance.parameters.Down);
	end
 
				  
end


 