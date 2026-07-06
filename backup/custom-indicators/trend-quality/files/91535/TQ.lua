-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60117
-- Id: 10700

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

function Init()
    indicator:name("TrendQuality");
    indicator:description("TrendQuality");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FastAvgLen", "Fast Period EMA", "Fast Period EMA", 7);
    indicator.parameters:addInteger("SlowAvgLen", "Slow Period EMA", "Slow Period EMA", 14);
    indicator.parameters:addInteger("M", "Scalar Trend Period ", "Scalar Trend Period ", 5);
    indicator.parameters:addInteger("N", "Scalar Nise Period", "Scalar Noise Period", 250);
    indicator.parameters:addInteger("Correction", "Scalar Correction Factor", "Scalar Correction Factor", 2);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("TQ_Up", "Color of Up TQ", "Color of TQ", core.rgb(0, 255, 0));
    indicator.parameters:addColor("TQ_Down", "Color of Dwon TQ", "Color of TQ", core.rgb(255, 0, 0));
	indicator.parameters:addColor("TrendColor", "Color of Dwon Trend", "Color of Trend", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local FastAvgLen;
local SlowAvgLen;
local M;
local N;
local Correction;

local first;
local source = nil;
local LPF1, LPF2;
local CPC,Trend,DT,Average;

-- Streams block
local TQ = nil;
local Reversals,DC;
local T;
-- Routine
function Prepare(nameOnly)
    FastAvgLen = instance.parameters.FastAvgLen;
    SlowAvgLen = instance.parameters.SlowAvgLen;
    M = instance.parameters.M;
    N = instance.parameters.N;
    Correction = instance.parameters.Correction;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(FastAvgLen) .. ", " .. tostring(SlowAvgLen) .. ", " .. tostring(M) .. ", " .. tostring(N) .. ", " .. tostring(Correction) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		LPF1 = core.indicators:create("EMA", source, FastAvgLen);
		LPF2 = core.indicators:create("EMA", source, SlowAvgLen);
		
		Reversals= instance:addInternalStream(0, 0);
		DC= instance:addInternalStream(0, 0);
		CPC= instance:addInternalStream(0, 0);
		Trend= instance:addInternalStream(0, 0);
		DT= instance:addInternalStream(0, 0);
		Average = core.indicators:create("MVA", DT, N);
		
		first = math.max(LPF1.DATA:first(),LPF2.DATA:first());
        TQ = instance:addStream("TQ", core.Bar, name, "TQ", instance.parameters.TQ_Up, Average.DATA:first());
    TQ:setPrecision(math.max(2, instance.source:getPrecision()));
		T = instance:addStream("T", core.Line, name, "Trend", instance.parameters.TrendColor, Average.DATA:first());
    T:setPrecision(math.max(2, instance.source:getPrecision()));
		T:setWidth(instance.parameters.width);
        T:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    LPF1:update(mode);
	LPF2:update(mode);
	
    if period < first   then
	return;
	end
	
	Reversals[period]= LPF1.DATA[period] - LPF2.DATA[period];
	DC[period] = source[period] - source[period-1] ;
	
	if  core.crosses (Reversals, 0, period) then
	CPC[period]=0;
	Trend[period]=0;
	else
	CPC[period] = CPC[period-1] + DC[period]  ;
	Trend[period] = CPC[period] * 1 / M + Trend[period-1] * ( 1 - ( 1 / M ) ) ;
	end
	
	DT[period]= CPC[period] - Trend[period] ;
	DT[period]=DT[period]*DT[period];

	--Average( DT * DT, N )
	Average:update(mode);
	if period < Average.DATA:first()   then
	return;
	end
	local Noise = math.sqrt (Average.DATA[period]  ) ;
	
	
	 TQ[period]= Correction *( Trend[period] / Noise);
	
	 
	 
	 if LPF1.DATA[period]>LPF2.DATA[period] then
	 T[period]=1;
	 else
	 T[period]=-1;
	 end
	
	if TQ[period]> TQ[period-1] then
	TQ:setColor(period, instance.parameters.TQ_Up);
	else
    TQ:setColor(period, instance.parameters.TQ_Down);
    end
end
