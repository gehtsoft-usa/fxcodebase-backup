-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72516

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

function Init()
    indicator:name("Adaptive ATR-ADX Trend");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	 
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addString("Price", "Price", "", "median");
	indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");
	

	
   indicator.parameters:addBoolean("useHeiken", "Use Heiken", "", true);	
   indicator.parameters:addBoolean("aboveThresh", "ADX Above Threshold uses ATR Falling Multiplier Even if Rising?", "", true);
   
    indicator.parameters:addInteger("atrLen", "ATR Period", "", 21, 1, 2000);	   
    indicator.parameters:addInteger("adxLen", "ADX Period", "", 14, 1, 2000);	


    indicator.parameters:addDouble("m1", "ATR Multiplier - ADX Rising", "", 3.5, 1, 2000);	   
    indicator.parameters:addDouble("m2", "ATR Multiplier - ADX Falling", "", 1.75, 1, 2000);	

    indicator.parameters:addDouble("adxThresh", "ADX Threshold", "", 30, 0, 2000);	

	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color2", "Down Line Color", "", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 local first;
local source = nil;
 
local HA, Line

-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    Price= instance.parameters.Price;
    useHeiken= instance.parameters.useHeiken;
    aboveThresh = instance.parameters.aboveThresh;
	
	atrLen= instance.parameters.atrLen;
    adxLen= instance.parameters.adxLen;
    m1 = instance.parameters.m1;
    m2 = instance.parameters.m2;	
	adxThresh = instance.parameters.adxThresh;
	
	local Parameters= Price ..  ", " .. atrLen ..  ", " .. adxLen..  ", " ..m1 ..  ", " .. m2 ..  ", " .. adxThresh;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
	
	sTR = instance:addInternalStream(0, 0); 
	sDMPos = instance:addInternalStream(0, 0); 
	sDMNeg = instance:addInternalStream(0, 0); 
	DX = instance:addInternalStream(0, 0); 
	aadx= instance:addInternalStream(0, 0);
	xHigh= instance:addInternalStream(0, 0);
	xLow= instance:addInternalStream(0, 0);	
 	xOpen= instance:addInternalStream(0, 0);
	xClose= instance:addInternalStream(0, 0);	
    trueRange = instance:addInternalStream(0, 0);	
    m= instance:addInternalStream(0, 0);	
	TUp= instance:addInternalStream(0, 0);	
	TDown= instance:addInternalStream(0, 0);	
    src= instance:addInternalStream(0, 0);	
    c= instance:addInternalStream(0, 0);
    trend= instance:addInternalStream(0, 0);	
  
    HA = core.indicators:create("HA", source  ); 
    TR = core.indicators:create("ATR", source, 1  );
    ATR = core.indicators:create("ATR", source, atrLen  );  
    WilderAverage = core.indicators:create("WMA", trueRange, atrLen  );  	
    first=math.max(HA.DATA:first())+1;
	
  
 
	Line = instance:addStream("Line" , core.Line, " Line"," Line",instance.parameters.color1, first+adxLen);
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    HA:update(mode);
    TR:update(mode);	
    ATR:update(mode);	
	
    if period <= first then
	return;
	end
	 
	local HR = source.high[period]-source.high[period-1]
	local LR = -(source.low[period]-source.low[period-1])
	 
	if HR>LR then
	dmPos=math.max(HR,0)
	else
	dmPos=0
	end
	if LR>HR then
	dmNeg=math.max(LR,0)
	else
	dmNeg=0
	end
	


   sTR[period] = (sTR[period-1] - sTR[period-1]) / adxLen + TR.DATA[period];
   
   
    sDMPos[period]   = (sDMPos[period-1] - sDMPos[period-1]) / adxLen + dmPos
    sDMNeg[period] = (sDMNeg[period-1] - sDMNeg[period-1]) / adxLen + dmNeg

	local DIP = sDMPos[period] / sTR[period] * 100
	local DIN = sDMNeg[period] / sTR[period] * 100
	DX[period] = math.abs(DIP - DIN) / (DIP + DIN) * 100
	
	if period > first+adxLen then
 	aadx[period] = mathex.avg(DX, period-adxLen+1, period);	
	end
	

	
	
	if period<2 then
	xClose[period] = source.close[period]
	xOpen[period] = source.open[period]
	else 
	xClose[period] = (source.open[period]+source.high[period]+source.low[period]+source.close[period])/4;
	xOpen[period] = (xOpen[period-1] + source.close[period-1]) / 2
	end 
	xHigh[period] = math.max(source.high[period], math.max(xOpen[period], xClose[period]))
	xLow[period] = math.min(source.low[period], math.min(xOpen[period], xClose[period]))
 
 
 
 
	local v1 = math.abs(xHigh[period] - xClose[period-1])
	local v2 = math.abs(xLow[period] - xClose[period-1])
	local v3 = xHigh[period] - xLow[period]
	 
	trueRange[period] = math.max(v1, math.max(v2, v3))
	WilderAverage:update(mode);
	
	if period < WilderAverage.DATA:first() then
	return;
	end
	
	local atr;
	
	if useHeiken then
	atr = WilderAverage.DATA[period];
	else
	atr = ATR.DATA[period];
	end 
	
	if aadx[period]>aadx[period-1] and (aadx[period] < adxThresh or not aboveThresh) then
	m[period]=m1
	elseif aadx[period]<aadx[period-1] or (aadx[period] > adxThresh and aboveThresh) then
	m[period]=m2
	else
	m[period] = m[period-1]
	end 
	
	if DIP >= DIN then
	mUp=m[period]
	else
	mUp=m2
	end 
	if DIN >= DIP then
	mDn=m[period]
	else
	mDn=m2
	end 

	if useHeiken then
	src[period]=xClose[period]
	c[period]=xClose[period]
	t=(xHigh[period]+xLow[period])/2
	else
	src[period]=source[Price][period]
	c[period]=source.close[period]
	t=source.median[period]
	end 
	
	local up = t - mUp * atr
    local dn = t + mDn * atr
	
	
	if math.max(src[period-1], c[period-1]) > TUp[period-1] then
	TUp[period] = math.max(up,TUp[period-1])
	else
	TUp[period] = up
	end 
 
 
 
	
	 if math.min(src[period-1], c[period-1]) < TDown[period-1] then
	TDown[period] = math.min(dn, TDown[period-1])
	else
	TDown[period] = dn
	end 
	
	
	if math.min(src[period],math.min(c[period],source.close[period]))>TDown[period-1] then
	trend[period]=1
	elseif math.max(src[period],math.max(c[period],source.close[period]))<TUp[period-1] then
	trend[period]=-1
	else
	trend[period]=trend[period-1]
	end 
	
	
	
	if trend[period]==1 then
	Line[period]=TUp[period] 
	Line:setColor(period,  instance.parameters.color1);
	else
	Line[period]=TDown[period] 
	Line:setColor(period,  instance.parameters.color2);	
	end 
 	  
end

 