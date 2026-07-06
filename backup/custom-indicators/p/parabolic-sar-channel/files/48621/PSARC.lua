-- Id: 8128
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27761

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


-- The indicator corresponds to the Parabolic indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 5 "Trend Systems" (page 98-99)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Parabolic SAR Channel");
    indicator:description("Helps to define the direction of the prevailing trend and the moment to close positions opened during the reversal.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("Step", "Step", "", 0.02, 0.001, 1);
    indicator.parameters:addDouble("Max", "Max", "", 0.2, 0.001, 10);
	indicator.parameters:addBoolean("OVERLAY", "Show PSAR", "", false);
	indicator.parameters:addBoolean("Channel", "Show Channel", "", true);
	indicator.parameters:addGroup("PSAR Style");
    indicator.parameters:addColor("clrUp", "Up SAR Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("clrDown", "Down SAR Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	
	indicator.parameters:addGroup("Channel Up Style");
	indicator.parameters:addColor("ChannelUp", "Up  Channel Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	indicator.parameters:addGroup("Channel Down Style");	
    indicator.parameters:addColor("ChannelDown", "Down Channel Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
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
local Channel;
-- Streams block
local SAR = nil;
local OUT = nil;
local OVERLAY;
local Top, Bottom;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first() + 1;
    OVERLAY = instance.parameters.OVERLAY;
	Channel = instance.parameters.Channel;
    Step = instance.parameters.Step;
    Max = instance.parameters.Max;

    local name = profile:id() .. "(" .. source:name() .. "," .. Step .. "," .. Max .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end


    tradeHigh = instance:addInternalStream(0, 0);
    tradeLow = instance:addInternalStream(0, 0);
    parOp = instance:addInternalStream(0, 0);
    position = instance:addInternalStream(0, 0);
    af = instance:addInternalStream(0, 0);
    SAR = instance:addInternalStream(first, 0);
	
	if Channel then
	Top = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.ChannelDown, first)
	Top:setWidth(instance.parameters.width1);
    Top:setStyle(instance.parameters.style1);
	Bottom= instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.ChannelUp, first)
	Bottom:setWidth(instance.parameters.width2);
    Bottom:setStyle(instance.parameters.style2);
	else
	Top = instance:addInternalStream(first, 0);	
	Bottom = instance:addInternalStream(first, 0);	
	end
	
	if OVERLAY then
    OUT = instance:addStream("SAR", core.Dot, name .. ".SAR", "SAR", instance.parameters.clrUp, first)
	OUT:setWidth(instance.parameters.width);	
	else
	OUT = instance:addInternalStream(first, 0);	
	end
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
		
		
		
		
		Top[period] = Top[period-1];
		Bottom[period] = Bottom[period-1];
		
		  OUT[period] = SAR[period];
		  
		  if position[period] == 1 and  position[period-1] == -1 then
		 Top[period] = OUT[period];
		 elseif position[period] == -1 and  position[period-1] == 1 then
		 Bottom[period] = OUT[period];
		 end 
		  
		  
            if OVERLAY then  
				if position[period] == 1 then
				OUT:setColor(period,instance.parameters.clrDown);
				else
				 OUT:setColor(period,instance.parameters.clrUp);   
				end
			end
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