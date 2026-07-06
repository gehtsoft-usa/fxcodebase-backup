-- Id: 18673

-- Available @  http://fxcodebase.com/code/viewtopic.php?f=17&t=64558
--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
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
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
	indicator:name("Stochastic Min Max Signal Oscillator")
	indicator:description("Shows the location of the  high/low price achieved between two Stochastic crosses")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("iK", "Number of periods for %K", "", 25, 2, 1000)
	indicator.parameters:addInteger("iSD", "%D slowing periods", "", 25, 2, 1000)
	indicator.parameters:addInteger("iD", "The number of periods for %D.", "", 25, 2, 1000)

	indicator.parameters:addString("KS", "Smoothing type for %K", "", "MVA")
	indicator.parameters:addStringAlternative("KS", "MVA", "", "MVA")
	indicator.parameters:addStringAlternative("KS", "EMA", "", "EMA")
	indicator.parameters:addStringAlternative("KS", "FS", "", "FS")

	indicator.parameters:addString("DS", "Smoothing type for %D", "", "MVA")
	indicator.parameters:addStringAlternative("DS", "MVA", "", "MVA")
	indicator.parameters:addStringAlternative("DS", "EMA", "", "EMA") 

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("UpColor", "Cross Up Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("DownColor", "Cross Down Color", "", core.rgb(255, 0, 0)) 
	indicator.parameters:addColor("NeutralColor", "Min Max Color", "", core.rgb(0, 0, 255)) 
 
end

 
 
local first
local source = nil
local UpColor, DownColor
local DS, KS
local iK, iSD, iD 
local Stochastic = nil 
local Trend 
function Prepare(nameOnly)
	  
	DS = instance.parameters.DS
	KS = instance.parameters.KS
	iK = instance.parameters.iK
	iSD = instance.parameters.iSD
	iD = instance.parameters.iD 
	UpColor = instance.parameters.UpColor
	DownColor = instance.parameters.DownColor

	source = instance.source

	local name =
		profile:id() ..
		"(" ..
			source:name() ..
				", " .. source:barSize() .. ", " .. iK .. ", " .. iSD .. ", " .. iD .. ", " .. KS .. ", " .. DS .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	Stochastic = core.indicators:create("STOCHASTIC", source, iK, iSD, iD, KS, DS)
	first = Stochastic.D:first() 

	
	Min = instance:addStream("Min", core.Bar, name, "Min", instance.parameters.UpColor, first );
    Min:setPrecision(math.max(2, instance.source:getPrecision())); 

	Max = instance:addStream("Max", core.Bar, name, "Max", instance.parameters.DownColor, first );
    Max:setPrecision(math.max(2, instance.source:getPrecision())); 
	
	Cross = instance:addStream("Cross", core.Bar, name, "Cross", instance.parameters.UpColor, first );
    Cross:setPrecision(math.max(2, instance.source:getPrecision())); 	
end

 

-- Indicator calculation routine
function Update(period, mode)
    
	Stochastic:update(mode)
    if period <=first then
	return;
	end
	
	

		
	if Stochastic.K[period] > Stochastic.D[period] and Stochastic.K[period - 1] <= Stochastic.D[period - 1] then
		Cross[period] = 1
		 Cross:setColor(period, instance.parameters.UpColor);	
	elseif Stochastic.K[period] < Stochastic.D[period] and Stochastic.K[period - 1] >= Stochastic.D[period - 1] then
		Cross[period] = -1
		 Cross:setColor(period, instance.parameters.DownColor);			
	else	
	     Cross[period] = 0 
		 Cross:setColor(period, instance.parameters.NeutralColor);			
	end
	
	
	if Cross[period] == 1 or Cross[period] == -1 then
		local from = Find(period)
			if from~=-1 then
			local min, max, minpos, maxpos = mathex.minmax(source, from, period)
			Min[minpos]=-2;
			Max[maxpos]=2	 
        end		
	end	
		
 
end

function Find(Start)
	local from=-1

	for period = Start - 1, first, -1 do
	
		
		if Cross[period] == 1 or Cross[period] == -1 then
			from = period
			break
		else
           Cross[period]=0;		
           Min[period]=0;			
           Max[period]=0;		   
		end
		
	end

	return from
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