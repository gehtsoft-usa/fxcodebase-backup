-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71250

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
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

-- http://vtsystems.com/resources/helps/0000/HTML_VTtrader_Help_Manual/index.html?ti_donchianchannel.html
--

-- initializes the indicator
function Init()
	-- indicator:fail()
	indicator:name("Donchian Channel Continuation")
	indicator:description(
		"The simple trend-following indicator. Shows highest high and lowest low for the specified number of periods."
	)
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("N", "Number of periods", "", 20, 2, 10000)
	indicator.parameters:addString("AC", "Analyze the current period", "", "yes")
	indicator.parameters:addStringAlternative("AC", "no", "", "no")
	indicator.parameters:addStringAlternative("AC", "yes", "", "yes")

 

 

	indicator.parameters:addGroup("Line Style")
	indicator.parameters:addColor("Up", "Color of the Up bar", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Down", "Color of the Down bar", "", core.rgb(255, 0, 0))
    indicator.parameters:addColor("Neutral", "Color of the Neutral bar", "", core.rgb(0, 0, 255)) 
end

local first = 0
local n = 0
local ac = true
local source = nil
local dn = nil
local du = nil
local UpTrend,DownTrend;

-- initializes the instance of the indicator
function Prepare(nameOnly)
	source = instance.source
	n = instance.parameters.N

	local name = profile:id() .. "(" .. source:name() .. "," .. n .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	ac = (instance.parameters.AC == "yes")
 

	Show = instance.parameters.Show
	ShowLabel = instance.parameters.ShowLabel

	first = n + source:first() - 1
	if (not ac) then
		first = first + 1
	end

	du = instance:addInternalStream(0, 0);
 
	dn = instance:addInternalStream(0, 0);
	
	UpTrend=instance:addStream("UpTrend", core.Bar, name .. ".UpTrend", "UpTrend", instance.parameters.Neutral, first)
	DownTrend=instance:addStream("DownTrend", core.Bar, name .. ".DownTrend", "DownTrend", instance.parameters.Neutral, first) 
 
end
 
-- calculate the value
function Update(period)
	if (period < first) then
		return
	end

		if (ac) then
			dn[period], du[period] = mathex.minmax(source, period - n + 1, period)
		else
			dn[period], du[period] = mathex.minmax(source, period - n + 1 - 1, period - 1)
		end
		


		
		if du[period] > du[period-1] then 
		UpTrend[period]=1;	
        elseif du[period] < du[period-1] then 		
		UpTrend[period]=0;	
		else
		UpTrend[period]=UpTrend[period-1];
		end
		
		if dn[period] < dn[period-1] then 
		DownTrend[period]=-1;
		elseif dn[period] > dn[period-1] then 
		DownTrend[period]=0;	
		else
		DownTrend[period]=DownTrend[period-1];
		end
		
		
		
		if UpTrend[period]== 1 then
		UpTrend:setColor(period,instance.parameters.Up);
		else 
		UpTrend:setColor(period,instance.parameters.Neutral);
		end
		
		
		if DownTrend[period]== -1 then
		DownTrend:setColor(period,instance.parameters.Down);				
		else
		DownTrend:setColor(period,instance.parameters.Neutral);		
		end
end
