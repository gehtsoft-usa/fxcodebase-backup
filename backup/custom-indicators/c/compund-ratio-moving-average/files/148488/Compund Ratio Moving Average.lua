-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72984

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Compund Ratio Moving Average");
    indicator:description("Compund Ratio Moving Average"); 
    indicator:requiredSource(core.Bar);
 
    indicator:type(core.Indicator);
 

    indicator.parameters:addGroup("Calculation");

    indicator.parameters:addInteger("length", "Length", "Length", 10, 1, 100000);
    indicator.parameters:addInteger("smooth", "Smoothing", "Smoothing", 3, 1, 100000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end


 

-- Routine
function Prepare() 
	smooth= instance.parameters.smooth;
	length= instance.parameters.length;	 
    source = instance.source;
 

    local name = profile:id() .. "(" .. source:name() .. ", " .. length .. ", " .. smooth..")"
    instance:name(name);
	
    raw= instance:addInternalStream(0,0)
   
	WMA= core.indicators:create("WMA", raw, smooth);
	first=WMA.DATA:first() ; 	 
	
 
    Line= instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first)
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
	


end

-- Indicator calculation routine
function Update(period)

   if period <=source:first() + length then
   return;
   end
   
   
    numerator   = 0.0
	denom = 0.0
    c_weight    = 0.0
	r_multi = 2.0
    Start_Wt    = 0.01     
    End_Wt      = length    
    
    r = math.pow(End_Wt / Start_Wt, 1 / (length - 1)) - 1
    base = 1 + r * r_multi

    for i = 0 ,  length - 1 ,  1 do
        c_weight     = Start_Wt * math.pow(base, length - i)
        numerator    = numerator+  source[period-i] * c_weight
        denom       = denom+ c_weight
    end  

    raw[period]    = numerator / denom 


    WMA:update(mode);

   if period < first then
   return;
   end

 
   Line[period]= WMA.DATA[period];
 
   
   
end 

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

