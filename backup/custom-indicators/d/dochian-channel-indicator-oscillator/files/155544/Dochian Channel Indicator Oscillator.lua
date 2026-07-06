-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74924

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                               https://appliedmachinelearning.systems/contact/  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+

-- http://vtsystems.com/resources/helps/0000/HTML_VTtrader_Help_Manual/index.html?ti_donchianchannel.html
--

-- initializes the indicator
function Init()
	-- indicator:fail()
	indicator:name("Dochian Channel Indicator Oscillator")
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
	
	indicator.parameters:addString("Method", "Signal Method", "", "TopBottom")
	indicator.parameters:addStringAlternative("Method", "Central Line", "", "Central")
	indicator.parameters:addStringAlternative("Method", "Top Bottom Line", "", "TopBottom")	
	
	indicator.parameters:addBoolean("Continue", "Continue the Trend", "", false);	
 

	indicator.parameters:addGroup("Line Style")
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128))

 
end

local first = 0
local n = 0
local ac = true 
local source = nil
local dn = nil
local du = nil
local dm = nil 
local min = {}
local max = {}
local Size
local ShowLabel
-- initializes the instance of the indicator
function Prepare(nameOnly)
	source = instance.source
	n = instance.parameters.N
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Neutral = instance.parameters.Neutral;
	Method = instance.parameters.Method;
	Continue = instance.parameters.Continue;

	local name = profile:id() .. "(" .. source:name() .. "," .. n .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	ac = (instance.parameters.AC == "yes") 
	local min = {}
	local max = {}

 
	ShowLabel = instance.parameters.ShowLabel

	first = n + source:first() - 1
	if (not ac) then
		first = first + 1
	end
	
	
    du = instance:addInternalStream(0, 0);	
    dn = instance:addInternalStream(0, 0);	
    dm = instance:addInternalStream(0, 0);	
	
	
	Signal = instance:addStream("Signal", core.Bar, name .. ".Signal", "Signal", Neutral, first) 

 

 
end

           
 
-- calculate the value
function Update(period)
	if (period < first) then
		return
	end

	if period == source:size() - 1 then
		for Shift = 1, n, 1 do
			if (ac) then
				min[Shift], max[Shift] = mathex.minmax(source, period - Shift + 1, period)
			else
				min[Shift], max[Shift] = mathex.minmax(source, period - Shift + 1 - 1, period - 1)
			end
		end

		dn[period] = min[n]
		du[period] = max[n]
	else
		if (ac) then
			dn[period], du[period] = mathex.minmax(source, period - n + 1, period)
		else
			dn[period], du[period] = mathex.minmax(source, period - n + 1 - 1, period - 1)
		end
	end

 
		dm[period] = (du[period] + dn[period]) / 2
		
	if Method== "Central" then
	
		if source.close[period]> dm[period-1] then
		Signal[period]=1;		
		elseif source.close[period]< dm[period-1] then	
		Signal[period]=-1;			
		else
			if Continue then 
			Signal[period]=Signal[period-1]; 
			else
			Signal[period]=0;
			end	
		end	

    else				
		if source.close[period]> du[period-1] then
		Signal[period]=1;	
		elseif source.close[period]< dn[period-1] then	
		Signal[period]=-1;				
		else
			if Continue then 
			Signal[period]=Signal[period-1]; 
			else
			Signal[period]=0;
			end		
		end
	end
	
	if Signal[period]== 1 then
	Signal:setColor(period, Up);
	elseif Signal[period]== -1 then
    Signal:setColor(period, Down);
	else
    Signal:setColor(period, Neutral)	
    end	
 
end


--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+