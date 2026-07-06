-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71673

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--+------------------------------------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("Ehlers Hilbert Transformation");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period3", "1. Period", "", 14, 2, 2000);
    indicator.parameters:addInteger("Period1", "2. Period", "", 14, 2, 2000);
	
    indicator.parameters:addInteger("Period2", "3. Period", "", 1, 1, 2000);
 
	
	indicator.parameters:addGroup("1. Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	indicator.parameters:addGroup("2. Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local first;
local source = nil;
 
local Oscillator;  
local pi;
local smooth,detrender; 
-- Routine
 function Prepare(nameOnly)   
 
 
    pi = 2 * math.asin(1);
	
	
	local Parameters= "";
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first() +3;
	
	Period= instance:addInternalStream(0, 0);
	smooth= instance:addInternalStream(0, 0);
	detrender= instance:addInternalStream(0, 0);
	i1= instance:addInternalStream(0, 0);
	i2= instance:addInternalStream(0, 0);
	re= instance:addInternalStream(0, 0);	
    im= instance:addInternalStream(0, 0);	
	q1= instance:addInternalStream(0, 0);
	q2= instance:addInternalStream(0, 0);
	q3= instance:addInternalStream(0, 0);	
	smoothPeriod= instance:addInternalStream(0, 0);
   

	Line1 = instance:addStream("Line1" , core.Line, " Line1"," Line1",instance.parameters.color1, first+6+9+6+2);
	Line1:setWidth(instance.parameters.width1);
    Line1:setStyle(instance.parameters.style1);
    Line1:setPrecision(math.max(2, source:getPrecision()));
	
	Line2 = instance:addStream("Line2" , core.Line, " Line2"," Line2",instance.parameters.color2, first+6+9+6+2);
	Line2:setWidth(instance.parameters.width2);
    Line2:setStyle(instance.parameters.style2);
    Line2:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < first
	then
	return;
	end
 
	Period[period] = 0.0
	smooth[period] = ((4 * source[period]) + (3 * source[period-1]) + (2 * source[period-2]) + source[period-3]) / 10
	
	if period < first+6
	then
	return;
	end
	
	detrender[period] = ((0.0962 * smooth[period]) + (0.5769 * smooth[period-2] ) - (0.5769 *  smooth[period-4])  - (0.0962 *  smooth[period-6] )) * (0.075 *  Period[period-1] + 0.54)

	q1[period] =  ((0.0962 * detrender[period]) + (0.5769 *  detrender[period-2] )  - (0.5769 *  detrender[period-4] ) - (0.0962 *  detrender[period-6] )) * (0.075 *  Period[period-1] + 0.54)
	i1[period] = detrender[period-3]; 


   	if period < first+6+9
	then
	return;
	end
	
	local jI = ((0.0962 * i1[period]) + (0.5769 * i1[period-2] ) - (0.5769 *  i1[period-4]) - (0.0962 *i1[period-6])) * ((0.075 * Period[period-1]) + 0.54)
	local jQ = ((0.0962 * q1[period]) + (0.5769 *  q1[period-2] ) - (0.5769 * q1[period-4]) - (0.0962 * q1[period-6])) * ((0.075 * Period[period-1]) + 0.54)
	
	
	if period < first+6+9+6
	then
	return;
	end
	

	i2[period] = i1[period] - jQ
	i2[period]= (0.2 * i2[period]) + (0.8 *  i2[period-1])
	q2[period] = q1[period] + jI
	q2[period]= (0.2 * q2[period]) + (0.8 * q2[period-1])

	re[period] = (i2[period] * i2[period-1] ) + (q2[period] *  q2[period-1] )
	re[period]= (0.2 * re[period]) + (0.8 *  re[period-1])
	im[period] = (i2[period] * q2[period-1]) - (q2[period] *  i2[period-1])
	im[period]= (0.2 * im[period]) + (0.8 * im[period-1])
	
	if period < first+6+9+6+2
	then
	return;
	end
	

    if im[period]~=0 and re[period]~=0 then
	Period[period]=2 * pi / math.atan(im[period] / re[period]);
	else
	Period[period]=0;
	end

	Period[period]= math.min(math.max(Period[period], 0.67 *  Period[period-1]), 1.5 * Period[period-1])
	Period[period]= math.min(math.max(Period[period], 6), 50)
	Period[period]= (0.2 * Period[period]) + (0.8 * Period[period-1]);

	smoothPeriod[period] = 0.0
	smoothPeriod[period] = (0.33 * Period[period]) + (0.67 *  smoothPeriod[period-1]);

	q3[period] = 0.5 * (smooth[period] -  smooth[period-2]) * ((0.1759 * smoothPeriod[period]) + 0.4607)

	Line1[period] = 0.0
	sp2 = math.ceil(smoothPeriod[period] / 2)
	for i = 0 , sp2 - 1, 1 do
		Line1[period] = Line1[period] +  q3[period-i];
	end
	Line1[period] = (1.57 * Line1[period]) / sp2;


	Line2[period] = 0.0;
	local sp4 = math.ceil(smoothPeriod[period] / 4);
	for i = 0, sp4 - 1, 1 do
		Line2[period]  = Line2[period] +  q3[period-i];
	end
	Line2[period]= (1.25 * Line2[period]) / sp4;
		
 
				  
end

 
