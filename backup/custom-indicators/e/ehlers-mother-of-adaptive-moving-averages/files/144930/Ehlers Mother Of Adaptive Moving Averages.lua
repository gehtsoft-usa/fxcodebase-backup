-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71851

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
    indicator:name("Ehlers Mother Of Adaptive Moving Averages");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addDouble("FastLimit", "FastLimit", "", 0.5, 0.01, 2000);
    indicator.parameters:addDouble("SlowLimit", "SlowLimit", "", 0.05, 0.01, 2000);	
	
	indicator.parameters:addGroup("MAMA Line Style");	
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Up", "Up Trend Line Color", "", core.rgb(0, 255, 0));  
	indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0)); 

	indicator.parameters:addGroup("FAMA Line Style");	
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "Line Color", "", core.rgb(0, 0, 255)); 	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local FastLimit,SlowLimit; 

local MAMA, FAMA; 
local pi;
-- Routine
 function Prepare(nameOnly)   
 
    
	FastLimit=instance.parameters.FastLimit;
	SlowLimit=instance.parameters.SlowLimit;
	source = instance.source
	
	pi = 2 * math.asin(1);
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  FastLimit .. "," ..  SlowLimit .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	smooth = instance:addInternalStream(0, 0);
	detrender = instance:addInternalStream(0, 0);	
	Period = instance:addInternalStream(0, 0);	
	q1 = instance:addInternalStream(0, 0);	
	i1 = instance:addInternalStream(0, 0);	
	i2 = instance:addInternalStream(0, 0);	
	q2 = instance:addInternalStream(0, 0);	
	im = instance:addInternalStream(0, 0);	
	re = instance:addInternalStream(0, 0);	
	phase = instance:addInternalStream(0, 0);	
	smoothPeriod = instance:addInternalStream(0, 0);
	
	first=source:first()+3; 
	
 
	
	
    MAMA = instance:addStream("MAMA", core.Line, name, "MAMA", instance.parameters.Up, first );
    MAMA:setPrecision(math.max(2, instance.source:getPrecision()));
    MAMA:setWidth(instance.parameters.width1);
    MAMA:setStyle(instance.parameters.style1);
    MAMA:addLevel(0);	
	
    FAMA = instance:addStream("FAMA", core.Line, name, "FAMA", instance.parameters.color2, first );
    FAMA:setPrecision(math.max(2, instance.source:getPrecision()));
    FAMA:setWidth(instance.parameters.width2);
    FAMA:setStyle(instance.parameters.style2);
    FAMA:addLevel(0);		
 
end


function Update(period, mode)

 

	 if period < first then
	 return;
	 end
	 
    smooth[period] = ((4 * source[period]) + (3 * source[period-1]) + (2 * source[period-2]) + source[period-3]) / 10
    detrender[period] = ((0.0962 * smooth[period]) + (0.5769 *smooth[period-2]) - (0.5769 *smooth[period-4]) - (0.0962 * smooth[period-6])) * ((0.075 * Period[period-1]) + 0.54)

	
	q1[period] = ((0.0962 * detrender[period]) + (0.5769 * detrender[period-2] ) - (0.5769 * detrender[period-4]) - (0.0962 * detrender[period-6])) * ((0.075 * Period[period-1]) + 0.54)
    i1[period] =  detrender[period-3] 
	
	local jI = ((0.0962 * i1[period]) + (0.5769 * i1[period-2]) - (0.5769 * i1[period-4]) - (0.0962 * i1[period-6])) * ((0.075 * Period[period-1]) + 0.54)
    local jQ = ((0.0962 * q1[period]) + (0.5769 * q1[period-2]) - (0.5769 * q1[period-4]) - (0.0962 * q1[period-6])) * ((0.075 * Period[period-1]) + 0.54)
	
	
	i2[period] = i1[period] - jQ
    i2[period]= (0.2 * i2[period]) + (0.8 * i2[period-1])
    q2[period] = q1[period] + jI
    q2[period]= (0.2 * q2[period]) + (0.8 * q2[period-1])
	
	re[period] = (i2[period] * i2[period-1]) + (q2[period] *  q2[period-1])
	re[period]= (0.2 * re[period]) + (0.8 * re[period-1])
	im[period] = (i2[period] *q2[period-1]) - (q2[period] * i2[period-1])
	im[period]= (0.2 * im[period]) + (0.8 * im[period-1] )
	
	

	if im[period] ~= 0 and re[period] ~= 0 then
	Period[period]= 2 * pi / math.atan(im[period] / re[period]	)
	else
	Period[period]= 0
	end
	
	Period[period]= math.min(math.max(Period[period], 0.67 * Period[period-1]), 1.5 * Period[period-1])
	Period[period]= math.min(math.max(Period[period], 6), 50)
	Period[period]= (0.2 * Period[period]) + (0.8 *Period[period-1])

	
	smoothPeriod[period]= (0.33 * Period[period]) + (0.67 * smoothPeriod[period-1])
 
	if i1 ~= 0  then
	phase[period]=math.atan(q1[period] / i1[period]) * 180 / pi 
	else
	phase[period]=0
	end
	local deltaPhase = phase[period-1] - phase[period]
	
 
	if deltaPhase < 1 then
	deltaPhase=1;
	end

    local alpha = FastLimit / deltaPhase
    if alpha < SlowLimit  then
	alpha=SlowLimit
	end
	

    MAMA[period]= (alpha * source[period]) + ((1 - alpha) * MAMA[period-1])
    FAMA[period]=(0.5 * alpha * MAMA[period]) + ((1 - (0.5 * alpha)) *FAMA[period-1])
 
		if MAMA[period]> FAMA[period] then	
		MAMA:setColor(period,instance.parameters.Up);
		elseif MAMA[period]< FAMA[period] then	
		MAMA:setColor(period, instance.parameters.Down);
		end
	

 
end
 