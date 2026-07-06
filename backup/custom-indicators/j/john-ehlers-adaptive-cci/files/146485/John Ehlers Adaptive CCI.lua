-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72418

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("John Ehlers Adaptive CCI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addDouble("CycPart", "Cycle Part", "", 1, 0.1, 2000);
    indicator.parameters:addInteger("min", "Minimum", "", 6, 1, 2000);	
    indicator.parameters:addInteger("max", "Maximum", "", 50, 3, 2000);		
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local CycPart; 
local max, min;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	CycPart=instance.parameters.CycPart;
	min=instance.parameters.min;
	max=instance.parameters.max;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  CycPart  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	first= source:first() +3  ; 
	
	Period = instance:addInternalStream(0, 0);
	
	Smooth = instance:addInternalStream(0, 0);
 	Detrender = instance:addInternalStream(0, 0);

	Q1 = instance:addInternalStream(0, 0);
 	I1 = instance:addInternalStream(0, 0);	
	
	Q2 = instance:addInternalStream(0, 0);
 	I2 = instance:addInternalStream(0, 0);	

	Re = instance:addInternalStream(0, 0);
 	Im = instance:addInternalStream(0, 0);

    SmoothPeriod= instance:addInternalStream(0, 0);	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)

	--  Indicator:update(mode); 

	 if period <= first then
	 return;
	 end 
	
	Smooth[period] = (4*source.median[period] + 3*source.median[period-1] + 2*source.median[period-2] + source.median[period-3]) / 10; 
	
	if period <= first+6 then
	return;
	end 
	 
	Detrender[period] = (0.0962*Smooth[period] + 0.5769*Smooth[period-2] - 0.5769*Smooth[period-4] - 0.0962*Smooth[period-6])*(0.075*Period[period-1] + 0.54)



	if period <= first+12 then
	return;
	end 
	
    Q1[period] = (0.0962*Detrender[period] + 0.5769*Detrender[period-2] - 0.5769*Detrender[period-4] - 0.0962*Detrender[period- 6])*(0.075*Period[period-1] + 0.54) 
	I1[period] = Detrender[period-3];
	
	
	if period <= first+21 then
	return;
	end 
	
	
	
	local j1 = (0.0962*I1[period] + 0.5769*I1[period-2] - 0.5769*I1[period-4] - 0.0962*I1[period-6])*(0.075*Period[period-1] + 0.54)
	local jQ = (0.0962*Q1[period] + 0.5769*Q1[period-2] - 0.5769*Q1[period-4] - 0.0962*Q1[period-6])*(0.075*Period[period-1] + 0.54)
 
 
	I2[period] = I1[period] - jQ
	Q2[period] = Q1[period] + j1


	if period <= first+22 then
	return;
	end 
	
	I2[period] = 0.2*I2[period] + 0.8*I2[period-1]
	Q2[period] = 0.2*Q2[period] + 0.8*Q2[period-1]	
	
	
	Re[period] = I2[period]*I2[period-1] + Q2[period]*Q2[period-1]
	Im[period] = I2[period]*Q2[period-1] - Q2[period]*I2[period-1]
	
	if period <= first+23 then
	return;
	end 
	
	Re[period] = 0.2*Re[period] + 0.8*Re[period-1]
	Im[period] = 0.2*Im[period] + 0.8*Im[period-1]
	
	
	if Im[period]~= 0 and Re[period] ~= 0 then
		Period[period] = 360/math.atan(Im[period]/Re[period])
	end
	
	
	if period <= first+24 then
	return;
	end 
	
	if Period[period] > 1.5*Period[period-1] then
		Period[period] = 1.5*Period[period-1]
	end
	if Period[period] < 0.67*Period[period-1] then
		Period[period] = 0.67*Period[period-1]
	end
	if Period[period] < min then
		Period[period] = min
	end
	if Period[period] > max then
		Period[period] = max
	end
	
		if period <= first+24 then
	return;
	end 
		
	Period[period] = 0.2*Period[period] + 0.8*Period[period-1]
	SmoothPeriod[period] = 0.33*Period[period] + 0.67*SmoothPeriod[period-1]
	
	
	
	local Length = math.floor(CycPart*Period[period])
	
	if period <= Length  or  Length <= 1	then
    return;
    end

	
    local Avg=mathex.avg(source.typical , period-Length+1, period);
 
    
	
	local MD = 0
	for count = 0 , Length - 1, 1  do
		MD = MD + math.abs(source.typical [period-count] - Avg)
	end
	
	MD = MD / Length
	
	
	if MD ~= 0 then
		Line[period] = (source.typical[period]  - Avg) / (0.015*MD)
	end
	
	
end

 