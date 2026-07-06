--
-- 3 down days indicator for stock indicies
-- Inspired by Ivan Scherman
-- https://www.businessinsider.com/stock-trading-strategy-quant-fund-manager-competition-champion-sp500-return-2024-9
--
-- Additional features have been added to try and improve results:
-- Looking at quality of last down day candle prior to a trade
-- -> has it got a wick? and is the body not thin indecision? implying possible upwards momentum has started...
-- Configurable number of down days
--
-- Ocillator histogram output:
-- Up = potential long Trade
-- Down = exit trade

-- Intended usage:
-- Stock Indices
-- Daily timeframe
-- Long only
-- Apply optional trend filter based on long simple moving average 
-- Apply a short moving average exit filter - this is also used as a Limit target for a strategy 
-- Wait for 3 successive daily closes each lower than the previous
-- Define a quality of last closing candle - it must have a lower wick and a body above certain sizes
-- Default parameters partly optimised for SPX500 for recent data, but similar values will work with other indices and history give or take
-- The indicator provides fairly infrequent daily signals (circa 10-15 per year)

-- original code by: SM Webb December 2024 aka Steve_W per fxcodebase


-- code version, revision and author
local version = 1;
local revision = 0;
local rev_author = "Steve_W";


-- Parameters
function Init()
    indicator:name("3 Down");
    indicator:description("3 down days, go long");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("down_days", "Down Days", "Required number of down days to trigger signal", 3, 1, 10);
	indicator.parameters:addBoolean("use_trend_filter", "Use Trend Filter", "Trade if upwards filter slope", false);
	indicator.parameters:addInteger("trend_filter_length", "Trend Filter Length", "", 200, 2, 300);
	indicator.parameters:addInteger("exit_filter_length", "Exit Filter Length", "Trade to close at or above exit filter", 4, 2, 20);
	indicator.parameters:addInteger("percent_wick", "Wick Percentage", "Low wick as a percentage of High-Low", 10, 1, 200);
	indicator.parameters:addInteger("percent_body", "Body Percentage", "Body as a percentage of High-Low", 20, 1, 200);
 
	indicator.parameters:addGroup("Line Style");	  
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 255));
	
	indicator.parameters:addGroup("About");
	indicator.parameters:addInteger("version", "Version", "", version, version, version);
	indicator.parameters:addInteger("revision", "Revision", "", revision, revision, revision);
	indicator.parameters:addString("rev_author", "Revision Author", "for this code revision", rev_author);
end


-- Indicator instance initialization	
local first;
local source = nil; 
local trend_filter = {};
local exit_filter = {};
function Prepare(nameOnly)   
 
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," .. "down=" .. instance.parameters.down_days .. "days" .. ")";
    instance:name(name); 

    if nameOnly then return end
	

	exit_filter = core.indicators:create("MVA", source, instance.parameters.exit_filter_length);
	trend_filter = core.indicators:create("MVA", source, instance.parameters.trend_filter_length);
	first = trend_filter.DATA:first();  
	  
	
    signal = instance:addStream("signal", core.Bar, name, "signal", instance.parameters.color, first );
    signal:setPrecision(math.max(2, instance.source:getPrecision())); 
    signal:addLevel(0);	
end


-- Compute indicator
local trade = false;
function Update(period, mode)
	exit_filter:update(mode);
	trend_filter:update(mode);
 
	if period <= first or not source:hasData(period) then return end
	
	signal[period] = 0;
	if trend_filter.DATA[period] > trend_filter.DATA[period - 1] or			-- upwards trend?
		instance.parameters.use_trend_filter == false						-- or no trend filter?
	then	
		if 	trade == false and												-- no trade open has been previously signalled
			Down_days(period, instance.parameters.down_days) == true and	-- required number of down days?
			source.close[period] < exit_filter.DATA[period]	and				-- below exit filter?
			((source.close[period] - source.low[period]) / (source.high[period] - source.low[period])) > (instance.parameters.percent_wick / 100) and	-- lower wick larger enough?
			((source.open[period] - source.close[period]) / (source.high[period] - source.low[period])) > (instance.parameters.percent_body / 100)		-- body larger enough?
		then
			signal[period] = 1;												-- signal to open trade on next bar
			trade = true;
		end
		if 	source.close[period] > exit_filter.DATA[period] and				-- time to close trade?
			trade == true													-- there was a trade to close?
		then
			signal[period] = -1;											-- signal to close trade
			trade = false;
		end
	end
 end				 
 
 
 -- Check there have been n down days at current p
 function Down_days(p, n)
	local i;
	local down_n = true;
	
	for i = 1, n, 1 do
		if source.close[p - i + 1] > source.close[p - i] then down_n = false end
	end
	
	return down_n;
 end
 