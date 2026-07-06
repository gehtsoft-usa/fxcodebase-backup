-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74322

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+
 


function Init()
    indicator:name("MTF TDI Histogram");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addInteger("RSI_N", "RSI Periods", "Recommended values are in 8-25 range", 13, 2, 1000);
    indicator.parameters:addInteger("VB_N", "Volatility Band", "Number of periods to find volatility band. Recommended value is 20-40", 34, 2, 1000);
    indicator.parameters:addDouble("VB_W", "Volatility Band Width", "", 1.6185, 0, 100);

    indicator.parameters:addInteger("RSI_P_N", "RSI Price Line Periods", "", 2, 1, 1000);
    indicator.parameters:addString("RSI_P_M", "RSI Price Line Smoothing Method", "", "MVA");
    indicator.parameters:addStringAlternative("RSI_P_M", "MVA(SMA)", "", "MVA");
    indicator.parameters:addStringAlternative("RSI_P_M", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "LSMA(Regression)", "", "REGRESSION");
    indicator.parameters:addStringAlternative("RSI_P_M", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "WMA(Wilders)", "", "WMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "KAMA(Kaufman)", "", "KAMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "VIDYA", "VIDYA" , "VIDYA");

    indicator.parameters:addInteger("TS_N", "Trade Signal Line Periods", "", 7, 1, 1000);
    indicator.parameters:addString("TS_M", "Trade Signal Line Smoothing Method", "", "MVA");
    indicator.parameters:addStringAlternative("TS_M", "MVA(SMA)", "", "MVA");
    indicator.parameters:addStringAlternative("TS_M", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("TS_M", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("TS_M", "LSMA(Regression)", "", "REGRESSION");
    indicator.parameters:addStringAlternative("TS_M", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("TS_M", "WMA(Wilders)", "", "WMA");
    indicator.parameters:addStringAlternative("TS_M", "KAMA(Kaufman)", "", "KAMA");
    indicator.parameters:addStringAlternative("TS_M", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("TS_M", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addString("tf1", "Timeframe 1", "", "H1");
    indicator.parameters:setFlag("tf1", core.FLAG_PERIODS);
    indicator.parameters:addString("tf2", "Timeframe 2", "", "H4");
    indicator.parameters:setFlag("tf2", core.FLAG_PERIODS);
    indicator.parameters:addString("tf3", "Timeframe 3", "", "H8");
    indicator.parameters:setFlag("tf3", core.FLAG_PERIODS);
    indicator.parameters:addString("tf4", "Timeframe 4", "", "D1");
    indicator.parameters:setFlag("tf4", core.FLAG_PERIODS);

    indicator.parameters:addInteger("buy_level", "Buy level", "", 50);
    indicator.parameters:addInteger("buy_exit", "Buy exit", "", 80);
    indicator.parameters:addInteger("sell_level", "Sell level", "", 50);
    indicator.parameters:addInteger("sell_exit", "Sell exit", "", 20);

    indicator.parameters:addColor("color", "Histogram color", "", core.colors().Blue)
end

-- Sources v1.3
local sources = {}
sources.last_id = 1
sources.ids = {}
sources.items = {}
function sources:Request(id, source, tf, isBid, instrument)
	local ids = {}
	ids.loading_id = self.last_id
	ids.loaded_id = self.last_id + 1
	ids.loaded = false
	self.last_id = self.last_id + 2
	self.ids[id] = ids

    if tf == nil then
        tf = source:barSize()
    end
	if isBid == nil then
		isBid = source:isBid()
    end
    if instrument == nil then
        instrument = source:instrument();
    end

	self.items[id] = core.host:execute("getSyncHistory", instrument, tf, isBid, 100, ids.loaded_id, ids.loading_id)
	return self.items[id];
end
function sources:AsyncOperationFinished(cookie, successful, message, message1, message2)
	for index, ids in pairs(self.ids) do
		if ids.loaded_id == cookie then
			ids.loaded = true
			self.allLoaded = nil
			return true
		elseif ids.loading_id == cookie then
			ids.loaded = false
			self.allLoaded = false
			return false
		end
	end
	return false
end
function sources:IsAllLoaded()
	if self.allLoaded == nil then
		for index, ids in pairs(self.ids) do
			if not ids.loaded then
				self.allLoaded = false
				return false
			end
		end
		self.allLoaded = true
	end
	return self.allLoaded
end

function CreateIndi(src, profile)
    local indicatorParams = profile:parameters();
    indicatorParams:setInteger("RSI_N", instance.parameters.RSI_N);
    indicatorParams:setInteger("VB_N", instance.parameters.VB_N);
    indicatorParams:setInteger("RSI_P_N", instance.parameters.RSI_P_N);
    indicatorParams:setInteger("TS_N", instance.parameters.TS_N);
    indicatorParams:setString("RSI_P_M", instance.parameters.RSI_P_M);
    indicatorParams:setString("TS_M", instance.parameters.TS_M);
    indicatorParams:setDouble("VB_W", instance.parameters.VB_W);
    return core.indicators:create("TRADERSDYNAMICINDEX", src, indicatorParams);
end

local source;
local indi1;
local indi2;
local indi3;
local indi4;
local buy_level, buy_exit, sell_level, sell_exit;
local HIST;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    buy_level = instance.parameters.buy_level;
    buy_exit = instance.parameters.buy_exit;
    sell_level = instance.parameters.sell_level;
    sell_exit = instance.parameters.sell_exit;
    local profile = core.indicators:findIndicator("TRADERSDYNAMICINDEX");
    assert(profile ~= nil, "Please, download and install " .. "TRADERSDYNAMICINDEX" .. ".LUA indicator");
    indi1 = CreateIndi(sources:Request(1, source, instance.parameters.tf1), profile);
    indi2 = CreateIndi(sources:Request(2, source, instance.parameters.tf2), profile);
    indi3 = CreateIndi(sources:Request(3, source, instance.parameters.tf3), profile);
    indi4 = CreateIndi(sources:Request(4, source, instance.parameters.tf4), profile);
    HIST = instance:addStream("HIST", core.Bar, "Histogram", "Histogram", instance.parameters.color, 0, 0);
end

function GetRate(indi, period)
    local index = core.findDate(indi.DATA, source:date(period), false);
    if index == -1 then
        return 0;
    end
    if indi.RSI_P[index] > indi.TS[index] 
        and indi.TS[index] > indi.MB[index] 
        and indi.RSI_P[index] > buy_level
        and indi.RSI_P[index] < buy_exit 
    then
        return 1;
    end
    if indi.RSI_P[index] < indi.TS[index] 
        and indi.TS[index] < indi.MB[index] 
        and indi.RSI_P[index] < sell_level
        and indi.RSI_P[index] > sell_exit 
    then
        return -1;
    end
    return 0;
end

function Update(period, mode)
    if not sources:IsAllLoaded() then
        return;
    end
    indi1:update(mode);
    indi2:update(mode);
    indi3:update(mode);
    indi4:update(mode);
    HIST[period] = GetRate(indi1, period) + GetRate(indi2, period) + GetRate(indi3, period) + GetRate(indi4, period)
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    if sources:AsyncOperationFinished(cookie, successful, message, message1, message2) then
        instance:updateFrom(0);
    end
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
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