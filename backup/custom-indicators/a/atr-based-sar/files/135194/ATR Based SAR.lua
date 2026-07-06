
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70058

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+


-- The indicator corresponds to the Parabolic indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 5 "Trend Systems" (page 98-99)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("ATR Based SAR");
    indicator:description("Helps to define the direction of the prevailing trend and the moment to close positions opened during the reversal.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("ATR Calculation");	
	
	indicator.parameters:addInteger("Period", "Period", "", 14 );
	indicator.parameters:addDouble("Multiplier", "Step Multiplier", "", 20 );
    indicator.parameters:addDouble("Max", "Max Multiplier", "", 40 );
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUp", "Up Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrDown", "Down Line Color", "", core.rgb(0, 255, 0));
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Multiplier, Period, ATR;
local first;
local source = nil;
local tradeHigh = nil;
local tradeLow = nil;
local parOp = nil;
local position = nil;
local af = nil;
 
local Max;

-- Streams block
local SAR = nil;
local UP = nil;
local DOWN = nil;

-- Routine
function Prepare(nameOnly)  
    source = instance.source;
   

    
    Max = instance.parameters.Max;
	
	Multiplier= instance.parameters.Multiplier;
	Period= instance.parameters.Period;

    local name = profile:id() .. "(" .. source:name() .. "," .. Period .. "," .. Multiplier .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	ATR = core.indicators:create("ATR", source, Period);
    first=ATR.DATA:first()+1;
	

    tradeHigh = instance:addInternalStream(0, 0);
    tradeLow = instance:addInternalStream(0, 0);
    parOp = instance:addInternalStream(0, 0);
    position = instance:addInternalStream(0, 0);
    af = instance:addInternalStream(0, 0);
    SAR =   instance:addStream("SAR", core.Dot, name .. ".SAR", "SAR", instance.parameters.clrUp, first);
    SAR:setWidth(instance.parameters.width);
    
end

-- Indicator calculation routine
function Update(period)



    ATR:update(mode);
    if period < first then
	return;
	end
	
 	
    local init = ATR.DATA[period]*Multiplier;
    local quant = ATR.DATA[period]*Multiplier;
    local maxVal =  ATR.DATA[period]*Max;
    local lastHighest = 0;
    local lastLowest = 0;
    local high = 0;
    local low = 0;
    local prevHigh = 0;
    local prevLow = 0;
    if period >= first then
        high = source.high[period];
        low = source.low[period];
        prevHigh = source.high[period - 1];
        prevLow = source.low[period - 1];
        if (period == first) then
            tradeHigh[period] = prevHigh;
            tradeLow[period] = prevLow;
            position[period] = -1;
            parOp[period] = prevHigh;
            af[period] = 0;
        else
            parOp[period] = parOp[period - 1];
            position[period] = position[period - 1];
            tradeHigh[period] = tradeHigh[period - 1];
            tradeLow[period] = tradeLow[period - 1];
            af[period] = af[period - 1];
        end
        lastHighest = tradeHigh[period];
        lastLowest = tradeLow[period];
        if high > lastHighest then
            tradeHigh[period] = high;
        end

        if low < lastLowest then
            tradeLow[period] = low;
        end

        if position[period] == 1 then
            if (low < parOp[period]) then
                position[period] = -1;
                SAR[period] = lastHighest;
                tradeHigh[period] = high;
                tradeLow[period] = low;
                af[period] = init;
                parOp[period] = SAR[period] + af[period] * (tradeLow[period] - SAR[period]);
                if (parOp[period] < high) then
                    parOp[period] = high;
                end
                if (parOp[period] < prevHigh) then
                    parOp[period] = prevHigh;
                end
            else
                SAR[period] = parOp[period];
                if (tradeHigh[period] > tradeHigh[period - 1] and af[period] < maxVal) then
                    af[period] = af[period] + quant;
                    if af[period] > maxVal then
                        af[period] = maxVal;
                    end
                end

                parOp[period] = SAR[period] + af[period] * (tradeHigh[period] - SAR[period]);
                if (parOp[period] > low) then
                    parOp[period] = low;
                end
                if (parOp[period] > prevLow) then
                    parOp[period] = prevLow;
                end
            end
        else
            if (high > parOp[period]) then
                position[period] = 1;
                SAR[period] = lastLowest;
                tradeHigh[period] = high;
                tradeLow[period] = low;
                af[period] = init;
                parOp[period] = SAR[period] + af[period] * (tradeHigh[period] - SAR[period]);
                if (parOp[period] > low) then
                    parOp[period] = low;
                end
                if (parOp[period] > prevLow) then
                    parOp[period] = prevLow;
                end
            else
                SAR[period] = parOp[period];
                if (tradeLow[period] < tradeLow[period - 1] and af[period] < maxVal) then
                    af[period] = af[period] + quant;
                    if af[period] > maxVal then
                        af[period] = maxVal;
                    end
                end

                parOp[period] = SAR[period] + af[period] * (tradeLow[period] - SAR[period]);
                if (parOp[period] < high) then
                    parOp[period] = high;
                end
                if (parOp[period] < prevHigh) then
                    parOp[period] = prevHigh;
                end
            end
        end

        if position[period] == 1 then
            SAR:setColor(period, instance.parameters.clrDown);
        else
            SAR:setColor(period,instance.parameters.clrUp);
        end
    end
end



