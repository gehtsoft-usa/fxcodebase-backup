-- Id: 668
--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

-- The indicator corresponds to the Stochastic indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 6 "Momentum and Oscillators" (page 135-137)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Stochastic on averaged data");
    indicator:description("Shows the location of the current close relative to the high/low range over a set number of periods.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("K", "Number of periods for %K", "", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "", 3, 2, 1000);
    indicator.parameters:addInteger("D", "The number of periods for %D.", "", 3, 2, 1000);

    indicator.parameters:addString("MVAT_K", "The type of smoothing algorithm for %K.", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K", "MT4", "", "MT");

    indicator.parameters:addString("MVAT_D", "The type of smoothing algorithm for %D.", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "EMA", "", "EMA");

    indicator.parameters:addString("MVAT_P", "The type of smoothing algorithm for source prices", "The methods marked by the star (*) requires to have approriate indicators installed", "MVA");
    indicator.parameters:addStringAlternative("MVAT_P", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_P", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MVAT_P", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MVAT_P", "TMA", "", "TMA");
    indicator.parameters:addStringAlternative("MVAT_P", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MVAT_P", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MVAT_P", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MVAT_P", "Wilders*", "", "WMA");

    indicator.parameters:addInteger("N_P", "Periods for smoothing the source prices", "", 7, 1, 1000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrFirst", "%K line color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrSecond", "%D line color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local k;
local d;
local sd;
local averageTypeK = nil;
local averageTypeD = nil;

local source = nil;
local mins = nil;
local maxes = nil;
local mva = nil;
local FastK = nil;
local fastkFirst = nil;
local kFirst = nil;
local dFirst = nil;
local isMT = nil;
local MC, MH, ML;
local C, H, L;

-- Streams block
local K = nil;
local D = nil;

-- Routine
function Prepare(nameOnly)
    k = instance.parameters.K;
    d = instance.parameters.D;
    sd = instance.parameters.SD;
    MVAT_P = instance.parameters.MVAT_P;
    N_P = instance.parameters.N_P;

    source = instance.source;

    MC = core.indicators:create(MVAT_P, source.close, N_P);
    MH = core.indicators:create(MVAT_P, source.high, N_P);
    ML = core.indicators:create(MVAT_P, source.low, N_P);

    C = MC.DATA;
    H = MH.DATA;
    L = ML.DATA;

    mins = instance:addInternalStream(C:first() + k, 0);
    maxes = instance:addInternalStream(C:first() + k, 0);
    FastK = instance:addInternalStream(mins:first(), 0);

    fastkFirst = FastK:first();

    averageTypeK = instance.parameters.MVAT_K;
    averageTypeD = instance.parameters.MVAT_D;

    local name = profile:id() .. "(" .. MVAT_P .. "(" .. source:name() .. "," .. N_P .. ")" .. ", " .. k .. ", " .. d .. ", " .. sd .. ", " .. averageTypeK .. ", " .. averageTypeD .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

	
    if averageTypeK ~= "MT" then
        mva = core.indicators:create(averageTypeK, FastK, sd);
        K = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.clrFirst, mva.DATA:first());
        isMT = false;
    else
        K = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.clrFirst, FastK:first() + sd);
        isMT = true;
    end
	
	 K:setWidth(instance.parameters.width1);
     K:setStyle(instance.parameters.style1);

    kFirst = K:first();

    signalLine = core.indicators:create(averageTypeD, K, d);
    D = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.clrSecond, signalLine.DATA:first());
	D:setWidth(instance.parameters.width2);
    D:setStyle(instance.parameters.style2);
    dFirst = D:first();
	
	
	K:setPrecision(math.max(2, instance.source:getPrecision())); 
	D:setPrecision(math.max(2, instance.source:getPrecision())); 

    D:addLevel(20);
    D:addLevel(80);

end

-- Indicator calculation routine
function Update(period, mode)
    MC:update(mode);
    MH:update(mode);
    ML:update(mode);

    if period >= fastkFirst then
      --  local kRange = core.rangeTo(period, k);
      --  local minLow = core.min(L, kRange);
	  local minLow = mathex.min(L, period-k+1, period);
      --  local maxHigh = core.max(H, kRange);
	   local maxHigh = mathex.max(H, period-k+1, period);
        mins[period] = C[period] - minLow;
        maxes[period] = maxHigh - minLow;
        if maxes[period] > 0 then
            FastK[period] = mins[period] / maxes[period] * 100;
        else
            FastK[period] = 50;
        end
    end
    if isMT == false then
        mva:update(mode);
        if period >= kFirst then
            K[period] = mva.DATA[period];
        end
    else
        if period >= kFirst then
           -- local dRange = core.rangeTo(period, sd);
            --local sumMax = core.sum(maxes, dRange);
			 local sumMax = mathex.sum(maxes, period-sd+1, period);
            if sumMax == 0 then
                K[period] = 50;
            else
               -- local sumMin = core.sum(mins, dRange);
			   local sumMin = mathex.sum(mins, period-sd+1, period);
                K[period] = sumMin / sumMax * 100;
            end
        end
    end
    signalLine:update(mode);
    if period >= dFirst then
        D[period] = signalLine.DATA[period];
    end
end

