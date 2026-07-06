-- More information about this indicator can be found at:
--https://fxcodebase.com/code/viewtopic.php?f=17&t=71346

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

function Init()
    indicator:name("VWAP");
    indicator:description("VWAP");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addString("src", "Source", "", "typical");
    indicator.parameters:addStringAlternative("src", "Open", "", "open");
    indicator.parameters:addStringAlternative("src", "High", "", "high");
    indicator.parameters:addStringAlternative("src", "Low", "", "low");
    indicator.parameters:addStringAlternative("src", "Close", "", "close");
    indicator.parameters:addStringAlternative("src", "Median", "", "median");
    indicator.parameters:addStringAlternative("src", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("src", "Weighted", "", "weighted");
    indicator.parameters:addInteger("offset", "Offset", "", 0);
    indicator.parameters:addBoolean("showBands", "Calculate Bands", "", true);
    indicator.parameters:addDouble("stDevMultiplier", "Bands Multiplier", "", 1);
    indicator.parameters:addString("anchor", "Anchor", "", "Session");
    indicator.parameters:addStringAlternative("anchor", "Session", "", "Session");
    indicator.parameters:addStringAlternative("anchor", "Week", "", "Week");
    indicator.parameters:addStringAlternative("anchor", "Month", "", "Month");
    indicator.parameters:addStringAlternative("anchor", "Quarter", "", "Quarter");
    indicator.parameters:addStringAlternative("anchor", "Year", "", "Year");
	
	indicator.parameters:addColor("color", "Band Color","", core.colors().Green);
	indicator.parameters:addColor("line_color", "Line Color","", core.colors().Blue);	
	indicator.parameters:addInteger("transparency", "Transparency","", 95);
end

local source;
local params = {};
local plot1, upperBand, lowerBand, tradingDayOffset, tradingWeekOffset;
local sumSrcVol, sumVol, sumSrcSrcVol, anchor;
local vars = {};
function Prepare(nameOnly)
    tradingWeekOffset = core.host:execute("getTradingWeekOffset");
    tradingDayOffset = core.host:execute("getTradingDayOffset");
    anchor = instance.parameters.anchor;
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    params["src"] = instance.parameters.src;
    params["offset"] = instance.parameters.offset;
    params["showBands"] = instance.parameters.showBands;
    params["stDevMultiplier"] = instance.parameters.stDevMultiplier;
    plot1 = instance:addStream("plot1", core.Line, "VWAP", "VWAP",  instance.parameters.line_color, 0, 0);
    plot1:setWidth(1);
    plot1:setStyle(core.LINE_SOLID);
    sumSrcVol = instance:addInternalStream(0, 0);
    sumVol = instance:addInternalStream(0, 0);
    sumSrcSrcVol = instance:addInternalStream(0, 0);
    if params["showBands"] then
        upperBand = instance:addStream("upperBand", core.Line, "Upper Band", "Upper Band", core.colors().Green, 0, 0);
        upperBand:setWidth(1);
        upperBand:setStyle(core.LINE_SOLID);
        lowerBand = instance:addStream("lowerBand", core.Line, "Lower Band", "Lower Band", core.colors().Green, 0, 0);
        lowerBand:setWidth(1);
        lowerBand:setStyle(core.LINE_SOLID);
        instance:createChannelGroup("fill", "fill", upperBand, lowerBand, instance.parameters.color, instance.parameters.transparency);
    end
end

function GetPrice(period)
    return source[params["src"]][period];
end

function IsNewPeriod(period)
    if (period == 0) then
        return true;
    end
    if (anchor == "Session") then
        local s, e = core.getcandle("D1", source:date(period), tradingDayOffset, tradingWeekOffset);
        return source:date(period) >= s and source:date(period - 1) < s;
    end
    if (anchor == "Week") then
        local s, e = core.getcandle("W1", source:date(period), tradingDayOffset, tradingWeekOffset);
        return source:date(period) >= s and source:date(period - 1) < s;
    end
    if (anchor == "Month") then
        local s, e = core.getcandle("M1", source:date(period), tradingDayOffset, tradingWeekOffset);
        return source:date(period) >= s and source:date(period - 1) < s;
    end
    if (anchor == "Year") then
        local s, e = core.getcandle("Y1", source:date(period), tradingDayOffset, tradingWeekOffset);
        return source:date(period) >= s and source:date(period - 1) < s;
    end
    if (anchor == "Quarter") then
        local s, e = core.getcandle("M1", source:date(period), tradingDayOffset, tradingWeekOffset);
        local date = core.dateToTable(s);
        return source:date(period) >= s and source:date(period - 1) < s and date.month % 3 == 0;
    end
end

function Update(period, mode)


    if period <= source:first() then
	return;
	end
	
	
    isNewPeriod = false;
    if IsNewPeriod(period) then
        isNewPeriod = true;
    end
    local src = GetPrice(period);
    local volume = source.volume[period];
    sumSrcVol[period] = (isNewPeriod and src * volume or src * volume + sumSrcVol[period - 1]);
    sumVol[period] = (isNewPeriod and volume or volume + sumVol[period - 1]);
    sumSrcSrcVol[period] = (isNewPeriod and volume * math.pow(src, 2) or volume * math.pow(src, 2) + sumSrcSrcVol[period - 1]);
    vwapValue = sumSrcVol[period] / sumVol[period];
    variance = sumSrcSrcVol[period] / sumVol[period] - math.pow(vwapValue, 2);
    variance = ((variance < 0) and 0 or variance);
    stDev = math.sqrt(variance);
    plot1[period] = vwapValue;
    if showBands then
        upperBand[period] = (vwapValue + stDev * stDevMultiplier or nil);
        lowerBand[period] = (vwapValue - stDev * stDevMultiplier or nil);
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