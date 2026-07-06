-- Id: 975
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1394

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

function Init()
    indicator:name("Vertical Horizontal Filter");
    indicator:description("Determines whether price in a trending phase or a congestion phase  ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("TF", "Period", "Period", 28, 12, 2000);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("VHF_color", "Color of VHF", "Color of VHF", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Signal", "Color of VHF", "Color of Signal", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame;

local first;
local source = nil;

local HCP,LCP;
local Numerator,Denominator, RawDenominator ;
local Line=nil;
local TMP;

local i;

-- Streams block
local VHF = nil;

-- Routine
function Prepare(nameOnly)
    Frame = instance.parameters.TF;
    source = instance.source;
    first = source:first();
	
	if Frame >= 12 and Frame< 25 then 
	TMP= 0.45;
	elseif Frame >= 25 and Frame < 50 then 
	TMP= 0.37;
	elseif Frame >= 50 and Frame < 100 then
    TMP= 0.26;
    elseif Frame >= 100 then 
	TMP= 0.17;
	end

    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
   
	RawDenominator=instance:addInternalStream(0,0)

    VHF = instance:addStream("VHF", core.Line, name, "VHF", instance.parameters.VHF_color, first+Frame);
    VHF:setPrecision(math.max(2, instance.source:getPrecision()));
	VHF:setWidth(instance.parameters.width1);
    VHF:setStyle(instance.parameters.style1);
    Line = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.Signal, first);
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
	Line:setWidth(instance.parameters.width2);
    Line:setStyle(instance.parameters.style2);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
	 
	Line[period]=TMP;

    
    if period > 1 then    
	RawDenominator[period]= math.abs(source.close[period]-source.close[period-1]);
    end	
    
    if period < first+Frame or not  source:hasData(period) then
	return;
	end

	LCP, HCP= mathex.minmax(source.close, period-Frame+1, period);
	
	Numerator= math.abs(HCP-LCP);
	Denominator= mathex.sum(RawDenominator, period-Frame+1, period);
	
   VHF[period] = Numerator/Denominator;
    
end

