-- Id: 7553
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=24002

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Market Mode");
    indicator:description("Market Mode");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("Period", "Period", "Period", 20);
    indicator.parameters:addDouble("Delta", "Delta", "Delta", 0.1);
    indicator.parameters:addDouble("Fract", "Fract", "Fract", 0.25);
    indicator.parameters:addColor("Mode_color", "Color of Mode", "Color of Mode", core.rgb(0, 0, 255));
    indicator.parameters:addColor("Peak_color", "Color of Peak", "Color of Peak", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Valley_color", "Color of Valley", "Color of Valley", core.rgb(0,255, 0));
    --indicator.parameters:addColor("Ratio_color", "Color of Ratio", "Color of Ratio", core.rgb(0, 0, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Delta;
local Fract;

local first;
local source = nil;

-- Streams block
local Mode = nil;
local Peak = nil;
local Valley = nil;
local Ratio = nil;
local fMean;
local BP;
local fPeak,fValley;

local fAvgPeak;
local fAvgValley;

--local fOutVal;

    local fBeta;
    local fGamma;
    local fAlpha;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    Delta = instance.parameters.Delta;
    Fract = instance.parameters.Fract;
    source = instance.source;
    first = source:first();
	
	fBeta = math.cos(6.28 / Period);
    fGamma = 1 / math.cos(2*6.28*Delta / Period);
    fAlpha = fGamma-math.sqrt(fGamma*fGamma - 1);

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Delta) .. ", " .. tostring(Fract) .. ")";
    instance:name(name);
		
	BP=  instance:addInternalStream(first+2, 0);		
	fMean=core.indicators:create("MVA",BP , first+5+ 2*Period);
	
	fPeak=  instance:addInternalStream(first+2, 0);
	fValley=  instance:addInternalStream(first+2, 0);
	
	 if   (nameOnly) then
        return;
    end
	
	
	fAvgPeak=core.indicators:create("MVA",fPeak , 50);
    fAvgValley=core.indicators:create("MVA",fValley , 50);
	

    
        Mode = instance:addStream("Mode", core.Line, name .. ".Mode", "Mode", instance.parameters.Mode_color, first+ Period*2+50);
    Mode:setPrecision(math.max(2, instance.source:getPrecision()));
        Peak = instance:addStream("Peak", core.Line, name .. ".Peak", "Peak", instance.parameters.Peak_color, first+Period*2+50);
    Peak:setPrecision(math.max(2, instance.source:getPrecision()));
        Valley = instance:addStream("Valley", core.Line, name .. ".Valley", "Valley", instance.parameters.Valley_color, first+50);
    Valley:setPrecision(math.max(2, instance.source:getPrecision()));
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

   if period < first+2 then
   return;
   end

    BP[period] = 0.5*(1-fAlpha)*(source.median[period]-source.median[period-2])+fBeta*(1+fAlpha)*BP[period-1]-fAlpha*BP[period-2]

	

	
	if BP[period-1] > BP[period] and BP[period-1] > BP[period-2] then
	fPeak[period] = BP[period-1] 
	else
	fPeak[period] = fPeak[period-1]
	end
	
    if BP[period-1] < BP[period] and BP[period-1] < BP[period-2] then
	fValley[period] = BP[period-1]
	else
	fValley[period] = fValley[period-1]
	end
		
	if period < fAvgPeak.DATA:first() then
   return;
   end
		
	
	fAvgPeak:update(mode);	
	fAvgValley:update(mode);
	
	if period < first+5+ 2*Period then
   return;
   end
	
	
	fMean:update(mode);		

  
	
--[[	
	if fMean.DATA[period] > 0 and fAvgPeak.DATA[period] > 0  then
	fOutVal[period] = fMean.DATA[period]/(fAvgPeak.DATA[period]*Fract)
	elseif fMean.DATA[period] < 0 and fAvgValley.DATA[period] < 0  then
	fOutVal[period] = -fMean.DATA[period]/(fAvgValley.DATA[period]*Fract)
    else
	fOutVal[period] = 0
    end
	]]
	
	
		
	
        Mode[period] = fMean.DATA[period];
        Peak[period] = Fract*fAvgPeak.DATA[period];
        Valley[period] = Fract*fAvgValley.DATA[period];
       --  Ratio[period]= fOutVal[period];
	   --Ratio[period]=0;
    
end

