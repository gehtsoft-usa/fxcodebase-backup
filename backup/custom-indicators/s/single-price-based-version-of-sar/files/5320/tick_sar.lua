
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2450

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
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

 

-- The indicator corresponds to the Parabolic indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 5 "Trend Systems" (page 98-99)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Parabolic Time/Price System (Tick version)");
    indicator:description("Helps to define the direction of the prevailing trend and the moment to close positions opened during the reversal.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("Step", "Step", "The sensitivity of SAR.", 0.02, 0.001, 1);
    indicator.parameters:addDouble("Max", "Max", "The maximum value of Step.", 0.2, 0.001, 10);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUp", "Up dots color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrDown", "Down dots color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width", "Dots size", "", 3, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local first;
local source = nil;
local tradeHigh = nil;
local tradeLow = nil;
local parOp = nil;
local position = nil;
local af = nil;
local Step;
local Max;

-- Streams block
local SAR = nil;
local UP = nil;
local DOWN = nil;

-- Routine
function Prepare(nameOnly) 
    source = instance.source;
    first = source:first() + 1;

    Step = instance.parameters.Step;
    Max = instance.parameters.Max;

    local name = profile:id() .. "(" .. source:name() .. "," .. Step .. "," .. Max .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end


    tradeHigh = instance:addInternalStream(0, 0);
    tradeLow = instance:addInternalStream(0, 0);
    parOp = instance:addInternalStream(0, 0);
    position = instance:addInternalStream(0, 0);
    af = instance:addInternalStream(0, 0);
    SAR = instance:addInternalStream(first, 0);
    UP = instance:addStream("UP", core.Dot, name .. ".Up", "UP", instance.parameters.clrUp, first)
    UP:setWidth(instance.parameters.width);
    DOWN = instance:addStream("DN", core.Dot, name .. ".Dn", "DN", instance.parameters.clrDown, first)
    DOWN:setWidth(instance.parameters.width);
end

-- Indicator calculation routine
function Update(period)
    local init = Step;
    local quant = Step;
    local maxVal = Max;
    local lastHighest = 0;
    local lastLowest = 0;
    local high = 0;
    local low = 0;
    local prevHigh = 0;
    local prevLow = 0;
    if period >= first then
        high = source[period];
        low = source[period];
        prevHigh = source[period - 1];
        prevLow = source[period - 1];
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
            DOWN[period] = SAR[period];
            UP[period] = nil;
        else
            UP[period] = SAR[period];
            DOWN[period] = nil;
        end
    end
end



