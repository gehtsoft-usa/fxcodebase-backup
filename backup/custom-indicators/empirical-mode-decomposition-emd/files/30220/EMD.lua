-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=16189
-- Id: 6368

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("EMPIRICAL MODE DECOMPOSITION");
    indicator:description("EMPIRICAL MODE DECOMPOSITION");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	 indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "BandPass Flter Period", "", 20);
	 indicator.parameters:addInteger("P2", "Threshold Period", "", 20);
	indicator.parameters:addDouble("Delta", "Delta", "", 0.5);
	indicator.parameters:addDouble("Fraction", "Fraction", "", 0.1);

	 indicator.parameters:addGroup("Band Pass Filter Style Options");
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("BPwidth", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("BPstyle", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("BPstyle", core.FLAG_LINE_STYLE);
	
	   indicator.parameters:addGroup("Peak Line Style Options");
	 indicator.parameters:addColor("Peak", "Peak Line Color", "", core.rgb(0, 255, 0));
	 indicator.parameters:addInteger("Peakwidth", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("Peakstyle", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Peakstyle", core.FLAG_LINE_STYLE);
	 
	 indicator.parameters:addGroup("Valley Line Style Options");
	  indicator.parameters:addColor("Valley", "Valley Line Color", "", core.rgb(255, 0, 0));
	  indicator.parameters:addInteger("Valleywidth", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("Valleystyle", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Valleystyle", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Delta, Beta, Gamma,Alpha;

local Period;
local first;
local source = nil;

-- Streams block
local BP = nil;
local AVG;
local Valley, Peak; 
local AVGValley, AVGPeak; 
local Fraction;
local P2;
-- Routine
function Prepare(nameOnly)
    P2 = instance.parameters.P2;
    Fraction = instance.parameters.Fraction;
    Delta = instance.parameters.Delta;
	Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+1;
	
	Beta = math.cos(math.rad(360 / Period));
    Gamma = 1 / math.cos(math.rad(720*Delta / Period));
    Alpha = Gamma - math.sqrt(Gamma*Gamma - 1);
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Delta) .. ", " .. tostring(Fraction)  .. ", " .. tostring(P2).. ")";
    instance:name(name);

    if (not (nameOnly)) then
        BP= instance:addInternalStream(first, 0);
        Peak= instance:addInternalStream(first, 0);
        Valley= instance:addInternalStream(first, 0);
        AVG = instance:addStream("BPF", core.Line, name, "BPF", instance.parameters.color, first+ Period*2);
    AVG:setPrecision(math.max(2, instance.source:getPrecision()));
		 AVG:setWidth(instance.parameters.BPwidth);
         AVG:setStyle(instance.parameters.BPstyle);
		AVGValley= instance:addStream("VALLEY", core.Line, name, "Valley", instance.parameters.Valley, first+ Period*2);
    AVGValley:setPrecision(math.max(2, instance.source:getPrecision()));
		AVGValley:setWidth(instance.parameters.Valleywidth);
         AVGValley:setStyle(instance.parameters.Valleystyle);
     	AVGPeak= instance:addStream("PEAk", core.Line, name, "Peak", instance.parameters.Peak, first+ Period*2);
    AVGPeak:setPrecision(math.max(2, instance.source:getPrecision()));
		AVGPeak:setWidth(instance.parameters.Peakwidth);
         AVGPeak:setStyle(instance.parameters.Peakstyle);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not  source:hasData(period) then
	return;
	end
        BP[period] =  0.5*(1 - Alpha)*(source.median[period] - source.median[period-2]) + Beta*(1 + Alpha)*BP[period-1]- Alpha* BP[period-2];
		
	if period < first + 2* Period then
    return;
    end	
		AVG[period]= mathex.avg(BP, period - 2*Period + 1, period);
		
		
	if period < first + 2* Period + P2 then
    return;
    end		
	
	Peak[period] = Peak[period-1];
    Valley[period] = Valley[period-1];	
	
	
	if BP[period-1] > BP[period] and BP[period-1] > BP[period-2] then 
	Peak[period] = BP[period-1];
	end
    if BP[period-1] < BP[period] and BP[period-1] < BP[period-2] then
	Valley[period] = BP[period-1];
	end
	
	
	AVGPeak[period]= mathex.avg(Peak, period - P2  + 1, period) * Fraction;
	AVGValley[period]= mathex.avg(Valley, period - P2  + 1, period) *Fraction;	
		
	
    
end

