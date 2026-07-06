-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64558

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+
 

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
	indicator:name("Stochastic Min Max Oscillator")
	indicator:description("Shows the location of the  high/low price achieved between two Stochastic crosses")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("K", "Number of periods for %K", "", 25, 2, 1000)
	indicator.parameters:addInteger("SD", "%D slowing periods", "", 25, 2, 1000)
	indicator.parameters:addInteger("D", "The number of periods for %D.", "", 25, 2, 1000)

	indicator.parameters:addString("KS", "Smoothing type for %K", "", "MVA")
	indicator.parameters:addStringAlternative("KS", "MVA", "", "MVA")
	indicator.parameters:addStringAlternative("KS", "EMA", "", "EMA")
	indicator.parameters:addStringAlternative("KS", "FS", "", "FS")

	indicator.parameters:addString("DS", "Smoothing type for %D", "", "MVA")
	indicator.parameters:addStringAlternative("DS", "MVA", "", "MVA")
	indicator.parameters:addStringAlternative("DS", "EMA", "", "EMA")

	indicator.parameters:addBoolean("TrendFilter", "Use Trend Filter", "", true)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Bottom", "Period Max Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Top", "Period Min Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first
local source = nil
local Up, Down
local DS, KS
local K, SD, D
local Size
local Stochastic = nil
local font
local Trend
local TrendFilter
local up,down;
local Top, Bottom;
function Prepare(nameOnly)
	TrendFilter = instance.parameters.TrendFilter
	DS = instance.parameters.DS
	KS = instance.parameters.KS
	K = instance.parameters.K
	SD = instance.parameters.SD
	D = instance.parameters.D
	Size = instance.parameters.Size
	Up = instance.parameters.Up
	Down = instance.parameters.Down

	source = instance.source

	local name =
		profile:id() ..
		"(" ..
			source:name() .. ", " .. source:barSize() .. ", " .. K .. ", " .. SD .. ", " .. D .. ", " .. KS .. ", " .. DS .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	Stochastic = core.indicators:create("STOCHASTIC", source, K, SD, D, KS, DS)
	first = Stochastic.D:first()
	Trend = instance:addInternalStream(first, 0)

	Top = instance:addStream("Top" , core.Line, " Top"," Top",instance.parameters.Top, first);
	Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
    Top:setPrecision(math.max(2, source:getPrecision())); 
	
	Bottom = instance:addStream("Bottom" , core.Line, " Bottom"," Bottom",instance.parameters.Bottom, first);
	Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
    Bottom:setPrecision(math.max(2, source:getPrecision())); 
end

-- Indicator calculation routine
function Update(period, mode)
	period = period - 1
	Stochastic:update(mode)

	if Stochastic.K[period] > Stochastic.D[period] and Stochastic.K[period - 1] <= Stochastic.D[period - 1] then
		Trend[period] = 1
	end

	if Stochastic.K[period] < Stochastic.D[period] and Stochastic.K[period - 1] >= Stochastic.D[period - 1] then
		Trend[period] = -1
	end
	
	
	local Last=FindLast(period);
	
	if Last==0 
	then
	return;
	end
	
	local min, max, minpos, maxpos = mathex.minmax(source, Last, period - 1)
	
    Top[period]=max;
	Bottom[period]=min;
	
end


function FindLast(period)

    local from=0;

    for i= period-1, first, -1 do
	
	        if Trend[i] == 1 or Trend[i] == -1 then
			from = i;
			break
		end
	end
	
   return from;
end

 