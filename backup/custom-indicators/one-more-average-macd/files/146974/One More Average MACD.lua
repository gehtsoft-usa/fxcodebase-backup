-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72586

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
    indicator:name("One More Average MACD");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addDouble("Sensibility", "Sensibility", "", 5, -1.5, 2000);
	indicator.parameters:addBoolean("Adaptive", "Adaptive", "", true);
	
 
    indicator.parameters:addInteger("FLength", "Fast Period", "", 24, 1, 2000);
    indicator.parameters:addInteger("SLength", "Slow Period", "", 52, 1, 2000);
    indicator.parameters:addInteger("SigLength", "Signal Period", "", 9, 1, 2000);	
    indicator.parameters:addInteger("Sigma", "Sigma", "", 4, 1, 2000);
    indicator.parameters:addDouble("Offset", "Offset", "", 0.85, 0, 2000);	
    indicator.parameters:addInteger("Period", "Color Range Period", "", 200, 1, 2000);	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 0, 255));  
end 
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
 
	
-- Routine
 function Prepare(nameOnly)   
 
	
	Sensibility=instance.parameters.Sensibility;
	Adaptive=instance.parameters.Adaptive;
	FLength=instance.parameters.FLength;
	SLength=instance.parameters.SLength;
	SigLength=instance.parameters.SigLength;
	Sigma=instance.parameters.Sigma;
	Offset=instance.parameters.Offset; 
	Period=instance.parameters.Period;
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name()   .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=source:first() +math.max(FLength,SLength,SigLength ); 
	
	
	Stream = instance:addInternalStream(0, 0);
 
	e1 = instance:addInternalStream(0, 0);
	e2 = instance:addInternalStream(0, 0);
	v1 = instance:addInternalStream(0, 0);
	e3 = instance:addInternalStream(0, 0);
	e4 = instance:addInternalStream(0, 0);
	v2 = instance:addInternalStream(0, 0);
	e5  = instance:addInternalStream(0, 0);
	e6  = instance:addInternalStream(0, 0);
	
	
	E1 = instance:addInternalStream(0, 0);
	E2 = instance:addInternalStream(0, 0);
	V1 = instance:addInternalStream(0, 0);
	E3 = instance:addInternalStream(0, 0);
	E4 = instance:addInternalStream(0, 0);
	V2 = instance:addInternalStream(0, 0);
	E5  = instance:addInternalStream(0, 0);
	E6  = instance:addInternalStream(0, 0);
	

 
    Line1 = instance:addStream("Line1", core.Bar, name, "1. Line", core.COLOR_LABEL , first );
    Line1:setPrecision(math.max(2, instance.source:getPrecision())); 
    Line1:addLevel(0);	
	
    Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color1, first );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:addLevel(0);		
  
end


function Update(period, mode)

	--  Indicator:update(mode); 

	 if period <= first then
	 return;
	 end
	 
    local averagePeriod = FLength
	
	if Adaptive  and averagePeriod > 1 then
	 minPeriod = averagePeriod/2.0
	 maxPeriod = minPeriod*5.0
	 endPeriod = math.floor(maxPeriod)
	 signal    = math.abs((source[period]-source[period-endPeriod ]))
	 noise     = 0.00000000001
	 
	 for k=1,endPeriod , 1  do
	  noise=noise+math.abs(source[period]-source[period-k])
	  averagePeriod = math.floor(((signal/noise)*(maxPeriod-minPeriod))+minPeriod)
	 end
	 
	end 
		
    alpha = (2.0+Sensibility)/(1.0+Sensibility+averagePeriod)

	e1[period] = e1[period-1] + alpha*(source[period]-e1[period-1])
	e2[period] = e2[period-1] + alpha*(e1[period]-e2[period-1])
	v1[period] = 1.5 * e1[period] - 0.5 * e2[period]
	e3[period] = e3[period-1] + alpha*(v1[period]   -e3[period-1])
	e4[period] = e4[period-1] + alpha*(e3[period]-e4[period-1])
	v2[period] = 1.5 * e3[period] - 0.5 * e4[period]
	e5[period] = e5[period-1] + alpha*(v2[period]   -e5[period-1])
	e6[period] = e6[period-1] + alpha*(e5[period]-e6[period-1])
	Fast = 1.5 * e5[period] - 0.5 * e6[period]
 
 
    averagePeriod = SLength
	if Adaptive  and averagePeriod > 1 then
	 minPeriod = averagePeriod/2.0
	 maxPeriod = minPeriod*5.0
	 endPeriod =  math.floor(maxPeriod)
	 signal    = math.abs((source[period]-source[period-endPeriod]))
	 noise     = 0.00000000001
	 
	 for k=1, endPeriod,1  do
	  noise=noise+math.abs(source[period]-source[period-k])
	  averagePeriod = math.floor(((signal/noise)*(maxPeriod-minPeriod))+minPeriod)
	 end
	 
	end 
 
    alpha = (2.0+Sensibility)/(1.0+Sensibility+averagePeriod)
 
	E1[period] = E1[period-1] + alpha*(source[period]-E1[period-1])
	E2[period] = E2[period-1] + alpha*(E1[period]-E2[period-1])
	V1[period] = 1.5 * E1[period] - 0.5 * E2[period]
	E3[period] = E3[period-1] + alpha*(V1[period]   -E3[period-1])
	E4[period] = E4[period-1] + alpha*(E3[period]-E4[period-1])
	V2[period] = 1.5 * E3[period] - 0.5 * E4[period]
	E5[period] = E5[period-1] + alpha*(V2[period]   -E5[period-1])
	E6[period] = E6[period-1] + alpha*(E5[period]-E6[period-1])
	Slow = 1.5 * E5[period] - 0.5 * E6[period]
	
	Line1[period]=  Fast-Slow;


	n = (Offset * (SigLength - 1))
	t = SigLength/Sigma
	
	
	SWtdSum = 0
	SCumWt  = 0
	for k =   SigLength , 0 , -1  do
	 SWtd = math.exp(-((k-n)*(k-n))/(2*t*t))
	 SWtdSum = SWtdSum + SWtd * Line1[period- k]
	 SCumWt = SCumWt + SWtd
	end
	Line2[period] =  SWtdSum / SCumWt
	
	
	if period <= first + Period then
	return;
	end
	
	local min, max = mathex.minmax(Line1, period-Period+1, period)
    local absmaxvalue = math.abs(max)
	local absminvalue = math.abs(min)
	local absmidvalue =0;
	
	maxr = 153 
	maxg = 255 
	maxb = 153 
	minr = 255 
	ming = 204 
	minb = 204 
	
	if Line1[period]>absmidvalue then
	 r = maxr/(absmaxvalue-absmidvalue)*Line1[period]
	 g = maxg/(absmaxvalue-absmidvalue)*Line1[period]
	 b = maxb/(absmaxvalue-absmidvalue)*Line1[period]
	else
	 r = math.abs(minr/math.abs(absminvalue-absmidvalue)*Line1[period])
	 g = math.abs(ming/math.abs(absminvalue-absmidvalue)*Line1[period])
	 b = math.abs(minb/math.abs(absminvalue-absmidvalue)*Line1[period])
	end 	


 
     Line1:setColor(period,  core.rgb(r, g, b));	

end

--[[
//--parameters
//>OMA parameters
Sensibility = 1
Adaptive = 1
//>MACD periods
FLength = 24
SLength = 52
//>signal line
SigLength = 9
Sigma = 4
Offset = 0.85
//--------
 
Speed = Sensibility
Speed  = Max(Speed,-1.5)
price = average[1](customclose)
tconst=Speed
 
//--Fast moving average
FLength = Max(FLength,1)
//adaptive period
averagePeriod = FLength
if adaptive=1 and averagePeriod > 1 then
 minPeriod = averagePeriod/2.0
 maxPeriod = minPeriod*5.0
 endPeriod = round(maxPeriod)
 signal    = Abs((price-stored[endPeriod]))
 noise     = 0.00000000001
 
 for k=1 to endPeriod do
  noise=noise+Abs(price-stored[k])
  averagePeriod = round(((signal/noise)*(maxPeriod-minPeriod))+minPeriod)
 next
 
endif
 
alpha = (2.0+tconst)/(1.0+tconst+averagePeriod)
 
e1 = e1 + alpha*(price-e1)
e2 = e2 + alpha*(e1-e2)
v1 = 1.5 * e1 - 0.5 * e2
e3 = e3 + alpha*(v1   -e3)
e4 = e4 + alpha*(e3-e4)
v2 = 1.5 * e3 - 0.5 * e4
e5 = e5 + alpha*(v2   -e5)
e6 = e6 + alpha*(e5-e6)
Fast = 1.5 * e5 - 0.5 * e6
//------------------------------------
 
//--Slow moving average
SLength = Max(SLength,1)
//adaptive period
averagePeriod = SLength
if adaptive=1 and averagePeriod > 1 then
 minPeriod = averagePeriod/2.0
 maxPeriod = minPeriod*5.0
 endPeriod = round(maxPeriod)
 signal    = Abs((price-stored[endPeriod]))
 noise     = 0.00000000001
 
 for k=1 to endPeriod do
  noise=noise+Abs(price-stored[k])
  averagePeriod = round(((signal/noise)*(maxPeriod-minPeriod))+minPeriod)
 next
 
endif
 
alpha = (2.0+tconst)/(1.0+tconst+averagePeriod)
 
e1 = e1 + alpha*(price-e1)
e2 = e2 + alpha*(e1-e2)
v1 = 1.5 * e1 - 0.5 * e2
e3 = e3 + alpha*(v1   -e3)
e4 = e4 + alpha*(e3-e4)
v2 = 1.5 * e3 - 0.5 * e4
e5 = e5 + alpha*(v2   -e5)
e6 = e6 + alpha*(e5-e6)
Slow = 1.5 * e5 - 0.5 * e6
//------------------------------------
 
 
//--Signal moving average
OMAMACD = Slow-Fast
SigLength = Max(SigLength,1)
//---Signal MA
n = (Offset * (SigLength - 1))
t = SigLength/Sigma
SWtdSum = 0
SCumWt  = 0
for k = 0 to SigLength - 1 do
 SWtd = Exp(-((k-n)*(k-n))/(2*t*t))
 SWtdSum = SWtdSum + SWtd * OMAMACD[SigLength - 1 - k]
 SCumWt = SCumWt + SWtd
next
SIGMACD = SWtdSum / SCumWt
//------------------------------------
 
stored=price
 
// --- ProRealcode RGB color matrix for PRT v10.3
valueentry = OMAMACD //data entry for automatic color scaling
maxr = 153 //R of RGB value for "bullish" sentiment/zone
maxg = 255 //G of RGB value for "bullish" sentiment/zone
maxb = 153 //B of RGB value for "bullish" sentiment/zone
minr = 255 //R of RGB value for "bearish" sentiment/zone
ming = 204 //G of RGB value for "bearish" sentiment/zone
minb = 204 //B of RGB value for "bearish" sentiment/zone
maxvalue = highest[200](valueentry) //could be modified by the maximum value in a bounded oscillator
middlevalue = 0 //middle value of the indicator
minvalue = lowest[200](valueentry) //could be modified by the minimum value in a bounded oscillator
absmaxvalue = abs(maxvalue)
absminvalue = abs(minvalue)
absmidvalue = abs(middlevalue)
if valueentry>absmidvalue then
 r = maxr/(absmaxvalue-absmidvalue)*valueentry
 g = maxg/(absmaxvalue-absmidvalue)*valueentry
 b = maxb/(absmaxvalue-absmidvalue)*valueentry
else
 r = abs(minr/abs(absminvalue-absmidvalue)*valueentry)
 g = abs(ming/abs(absminvalue-absmidvalue)*valueentry)
 b = abs(minb/abs(absminvalue-absmidvalue)*valueentry)
endif
 
RETURN OMAMACD coloured(r,g,b), SIGMACD as "Signal"
]]
 
 