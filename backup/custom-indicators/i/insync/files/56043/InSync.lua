-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32957
-- Id: 8710

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

function Init()
	indicator:name("InSync")
	indicator:description("InSync")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)

	indicator.parameters:addGroup("Bollinger Calculation")
	indicator.parameters:addInteger("B1", "Period", "", 20)
	indicator.parameters:addInteger("B2", "Multiplicator", "", 2)

	indicator.parameters:addGroup("MFI Calculation")
	indicator.parameters:addInteger("MFI1", "Period", "", 20)

	indicator.parameters:addGroup("CCI Calculation")
	indicator.parameters:addInteger("C1", "Period", "", 14)

	indicator.parameters:addGroup("RSI Calculation")
	indicator.parameters:addInteger("R1", "Period", "", 14)

	indicator.parameters:addGroup("Stochastic Calculation")
	indicator.parameters:addInteger("S1", "K Period", "", 14)
	indicator.parameters:addInteger("S2", "D Period", "", 3)
	indicator.parameters:addInteger("S3", "Smoothing Period", "", 2)

	indicator.parameters:addGroup("Ease of Movement Calculation")
	indicator.parameters:addInteger("E1", "Period", "", 10)

	indicator.parameters:addGroup("MACD Calculation")
	indicator.parameters:addInteger("M1", "Short Period", "", 12)
	indicator.parameters:addInteger("M2", "Long Period", "", 26)
	indicator.parameters:addInteger("M3", "Signal Period", "", 9)
	indicator.parameters:addInteger("M4", "Smoothing Period", "", 10)

	indicator.parameters:addGroup("ROC Calculation")
	indicator.parameters:addInteger("ROC1", "Period", "", 10)
	indicator.parameters:addInteger("ROC2", "Smoothing Period", "", 10)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("InSync_color", "Color of InSync", "Color of InSync", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries

local C1, R1, S1, S2, S3, E1, M1, M2, M3, M4, ROC1, ROC2, MFI1, B1, B2
local first
local source = nil

-- Streams block
local InSync = nil
local CCI, RSI, STO, EMV, MA, MACD, SS, ROC, RS, MFI, POS, NEG, DPO
-- Routine
function Prepare(nameOnly)
	S1 = instance.parameters.S1
	S2 = instance.parameters.S2
	S3 = instance.parameters.S3
	C1 = instance.parameters.C1
	R1 = instance.parameters.R1
	E1 = instance.parameters.E1
	M1 = instance.parameters.M1
	M2 = instance.parameters.M2
	M3 = instance.parameters.M3
	M4 = instance.parameters.M4
	MFI1 = instance.parameters.MFI1
	B1 = instance.parameters.B1
	B2 = instance.parameters.B2
	ROC1 = instance.parameters.ROC1
	ROC2 = instance.parameters.ROC2
	source = instance.source
	first = source:first()

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)

	if (not (nameOnly)) then
		CCI = core.indicators:create("CCI", source, C1)
		first = math.max(first, CCI.DATA:first())
	
		RSI = core.indicators:create("RSI", source.close, R1)
		first = math.max(first, RSI.DATA:first())
	
		STO = core.indicators:create("STOCHASTIC", source, S1, S2, S3)
		first = math.max(first, STO.D:first())
	
		EMV = instance:addInternalStream(0, 0)
		MA = core.indicators:create("MVA", EMV, E1)
		first = math.max(first, MA.DATA:first())
	
		MACD = core.indicators:create("MACD", source.close, M1, M2, M3)
		SS = core.indicators:create("MVA", MACD.DATA, M4)
		first = math.max(first, SS.DATA:first())
	
		ROC = core.indicators:create("ROC", source.close, ROC1)
		RS = core.indicators:create("MVA", ROC.DATA, ROC2)
		first = math.max(first, RS.DATA:first())
	
		POS = instance:addInternalStream(0, 0)
		NEG = instance:addInternalStream(0, 0)
		MFI = instance:addInternalStream(0, 0)
	
		DPO = instance:addInternalStream(0, 0)
		InSync = instance:addStream("InSync", core.Line, name, "InSync", instance.parameters.InSync_color, first)
        InSync:setPrecision(math.max(2, instance.source:getPrecision()));
		InSync:setWidth(instance.parameters.width)
		InSync:setStyle(instance.parameters.style)
	end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
	if period < B1 then
		return
	end

	local Avg = mathex.avg(source.close, period - B1 + 1, period)
	local StDev = mathex.stdev(source.close, period - B1 + 1, period)

	local BOLInSLB = Avg - B2 * StDev
	local BOLInSUB = Avg + B2 * StDev
	local BOLInS2 = (source.close[period] - BOLInSLB) / (BOLInSUB - BOLInSLB)
	local BOLInSLL

	if BOLInS2 < 0.05 then
		BOLInSLL = -5
	elseif BOLInS2 > 0.95 then
		BOLInSLL = -5
	else
		BOLInSLL = 0
	end

	CCI:update(mode)

	if period < CCI.DATA:first() then
		return
	end

	local CCIInS
	if CCI.DATA[period] > 100 then
		CCIInS = 5
	elseif CCI.DATA[period] < -100 then
		CCIInS = -5
	else
		CCIInS = 0
	end

	RSI:update(mode)

	if period < RSI.DATA:first() then
		return
	end

	local RSIInS
	if RSI.DATA[period] > 70 then
		RSIInS = 5
	elseif RSI.DATA[period] < 30 then
		RSIInS = -5
	else
		RSIInS = 0
	end

	STO:update(mode)

	if period < STO.D:first() then
		return
	end

	local STOdInS
	if STO.K[period] > 80 then
		STOdInS = 5
	elseif STO.K[period] < 20 then
		STOdInS = -5
	else
		STOdInS = 0
	end

	local STOkInS
	if STO.K[period] > 80 then
		STOkInS = 5
	elseif STO.K[period] < 20 then
		STOkInS = -5
	else
		STOkInS = 0
	end

	EMVCalculation(period)
	MA:update(mode)

	if period < MA.DATA:first() then
		return
	end

	local EMVInSB = 0
	local EMVInSS = 0
	local EMVInS2 = EMV[period] - MA.DATA[period]

	if EMVInS2 > 0 then
		if MA.DATA[period] < 0 then
			EMVInSB = -5
		else
			EMVInSB = 0
		end
	else
		if MA.DATA[period] > 0 then
			EMVInSS = 5
		else
			EMVInSS = 0
		end
	end

	MACD:update(mode)
	SS:update(mode)

	if period < SS.DATA:first() then
		return
	end

	local MACDInS2
	MACDInS2 = MACD.DATA[period] - SS.DATA[period]

	local MACDinSB = 0
	local MACDInSS = 0

	if MACDInS2 > 0 then
		if SS.DATA[period] < 0 then
			MACDinSB = -5
		else
			MACDinSB = 0
		end
	else
		if SS.DATA[period] > 0 then
			MACDInSS = 5
		else
			MACDInSS = 0
		end
	end

	ROC:update(mode)
	RS:update(mode)

	if period < RS.DATA:first() then
		return
	end

	local ROCInS2
	ROCInS2 = ROC.DATA[period] - RS.DATA[period]

	local ROCInSB = 0
	local ROCInSS = 0

	if ROCInS2 > 0 then
		if RS.DATA[period] < 0 then
			ROCInSB = -5
		else
			ROCInSB = 0
		end
	else
		if RS.DATA[period] > 0 then
			ROCInSS = 5
		else
			ROCInSS = 0
		end
	end

	if period < MFI1 then
		return
	end

	MFICalculation(mode)

	local MFIInS = 0

	if MFI[period] > 80 then
		MFIInS = 5
	elseif MFI[period] < 20 then
		MFIInS = -5
	end

	--  ( 20 ) ,> ,80 ,5 , If( MFI( 20 ) ,< ,20 ,-5 ,0 ) )

	--[[
PDOInS2
DPO( 18 ) - Mov( DPO( 18 ) ,10 ,S )

PDOInSB
If( Fml( "PDOInS2" ) ,< ,0 ,If( Mov( DPO( 18 ) ,10 , S) ,< ,0 ,-5 ,0 ) ,0 )

PDOInSS
If( Fml( "PDOInS2" ) ,> ,0 ,If( Mov( DPO ( 18 ) ,10 ,S) ,> ,0 ,5 ,0 ) ,0 )
 ]]
	--  + Ref (Fml( "PDOInSS" ) ,-10 ) + Ref (Fml( "PDOInSB" ) ,-10 )

	InSync[period] =
		50 + BOLInSLL + CCIInS + RSIInS + STOdInS + STOkInS + EMVInSB + EMVInSS + MACDinSB + MACDInSS + ROCInSS + ROCInSB +
		MFIInS
end

function EMVCalculation(period)
	local highCurr = source.high[period]
	local lowCurr = source.low[period]
	local highP = source.high[period - 1]
	local lowP = source.low[period - 1]

	EMV[period] = (((highCurr + lowCurr) / 2) - ((highP + lowP) / 2)) / ((source.volume[period]) / (highCurr - lowCurr))
end

--function DPOCalculation(period)
--end

function MFICalculation(period)
	if source.typical[period] > source.typical[period - 1] then
		POS[period] = source.typical[period] * source.volume[period]
	elseif source.typical[period] < source.typical[period - 1] then
		NEG[period] = source.typical[period] * source.volume[period]
	end

	if period >= 20 then
		local a, b, r

		a = mathex.sum(POS, period - MFI1 + 1, period)
		b = mathex.sum(NEG, period - MFI1 + 1, period)

		if b ~= 0 then
			MFI[period] = 100 - (100 / (1 + a / b))
		else
			MFI[period] = 100
		end
	end
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