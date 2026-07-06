-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1989

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--|                         https://AppliedMachineLearning.systems   |
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

function Init()
    indicator:name("Conqueror indicator");
    indicator:description("Conqueror indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("Frame", "MVA Period", "MVA Period", 10);
	indicator.parameters:addInteger("RANGE", "Range Period", "Range Period", 40);

	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP_color", "Color of UP", "Color of UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DOWN_color", "Color of DOWN", "Color of DOWN", core.rgb(255, 0, 0));
	indicator.parameters:addColor("NEUTRAL_color", "Color of NEUTRAL", "Color of NEUTRAL", core.rgb(0, 0, 255));
	
	indicator.parameters:addBoolean("show_arrows", "Show arrows", "", true);
	indicator.parameters:addBoolean("strategy_mode", "Strategy mode", "", false);
end

local Frame;
local Range;
local source = nil;
local first=nil;

-- Streams block
local UP = nil;
local DOWN = nil;
local NEUTRAL = nil;

local MVA=nil;
local ONE=nil;
local TWO=nil;
local THREE=nil;
local U=nil;
local D=nil;
local N1=nil;
local N2=nil;
local FLAG="";

-- Routine
function Prepare(nameOnly)
	Frame = instance.parameters.Frame;
	source = instance.source;
	Range=instance.parameters.RANGE;

	first = source:first()+math.max(Frame, Range);

	local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	MVA = core.indicators:create("MVA", source.close, Frame);

	UP = instance:addStream("UP", core.Bar, name .. ".UP", "UP", instance.parameters.UP_color, first);
	DOWN = instance:addStream("DOWN", core.Bar, name .. ".DOWN", "DOWN", instance.parameters.DOWN_color,first );
	NEUTRAL = instance:addStream("NEUTRAL", core.Bar, name .. ".NEUTRAL", "NEUTRAL", instance.parameters.NEUTRAL_color, first);
	
	UP:setPrecision(math.max(2, instance.source:getPrecision()));
	DOWN:setPrecision(math.max(2, instance.source:getPrecision()));
	NEUTRAL:setPrecision(math.max(2, instance.source:getPrecision()));
 
	UP:addLevel(0);
	UP:addLevel(1);
	if instance.parameters.show_arrows then
		U = instance:createTextOutput ("LONG", "LONG", "Wingdings", 15, core.H_Center, core.V_Top, instance.parameters.UP_color, first);
		D = instance:createTextOutput ("SHORT", "SHORT", "Wingdings", 15, core.H_Center, core.V_Bottom, instance.parameters.DOWN_color, first);
		if not instance.parameters.strategy_mode then
			core.host:execute ("attachTextToChart", "LONG");
			core.host:execute ("attachTextToChart", "SHORT");
		end
	end
	N1 = instance:createTextOutput ("NEUTRAL", "NEUTRAL1", "Tahoma", 8, core.H_Center, core.V_Top, instance.parameters.NEUTRAL_color, first);
	N2 = instance:createTextOutput ("NEUTRAL", "NEUTRAL2", "Tahoma", 8, core.H_Center, core.V_Bottom, instance.parameters.NEUTRAL_color, first)
	if not instance.parameters.strategy_mode then
		core.host:execute ("attachTextToChart", "NEUTRAL1");
		core.host:execute ("attachTextToChart", "NEUTRAL2");
	end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
	if period >= first and source:hasData(period) then
		MVA:update(mode);
		--1. Last Close>10 day moving average of close (10DMAc)
		if source.close[period]> MVA.DATA[period]then
			ONE=true;
		end
		 --2. Today's 10DMAc >10DMAc of 10 days ago
		if MVA.DATA[period] > MVA.DATA[period-10]then
			TWO=true;
		end
		 --3. Last Close > Close 40 days ago
		if source.close[period]> source.close[period-Range]then
			THREE=true
		end

		--4. Last Close<10 day moving average of close (10DMAc)
		if source.close[period]< MVA.DATA[period]then
			ONE=false;
		end
		 --5. Today's 10DMAc <10DMAc of 10 days ago
		if MVA.DATA[period] < MVA.DATA[period-10]then
			TWO=false;
		end
		 --6. Last Close < Close 40 days ago
		if source.close[period]< source.close[period-Range]then
			THREE=false
		end

		if ONE and TWO and THREE then -- All positive, buy
			UP[period] = 1;
			if FLAG ~= "buy" then
				if U ~= nil then
					U:set(period, source.high[period], "\225");
					D:set(period, source.low[period], "");
				end
				N1:set(period, source.high[period], "");
				N2:set(period, source.low[period], "");
			end
			FLAG="buy";
		elseif not ONE and not TWO and not THREE then -- All negative, sell
			DOWN[period] = 1;
			if FLAG ~= "sell" then
				if U ~= nil then
					U:set(period, source.high[period], "");
					D:set(period, source.low[period], "\226");
				end
				N1:set(period, source.high[period], "");
				N2:set(period, source.low[period], "");
			end
			FLAG="sell";
		else -- Mixed signals
			NEUTRAL[period] = 1;
			if FLAG == "buy" or FLAG == "buy_mixed" then
				local negatives = 0;
				if not ONE then
					negatives = negatives + 1;
				end
				if not TWO then
					negatives = negatives + 1;
				end
				if not THREE then
					negatives = negatives + 1;
				end

				FLAG = "buy_mixed";
				if U ~= nil then
					U:set(period, source.high[period], "");
					D:set(period, source.low[period], "");
				end
				N1:set(period, source.high[period], "");
				N2:set(period, source.low[period], "" .. negatives);
			elseif FLAG == "sell" or FLAG == "sell_mixed" then
				local positives = 0;
				if ONE then
					positives = positives + 1;
				end
				if TWO then
					positives = positives + 1;
				end
				if THREE then
					positives = positives + 1;
				end

				FLAG = "sell_mixed";
				if U ~= nil then
					U:set(period, source.high[period], "");
					D:set(period, source.low[period], "");
				end
				N1:set(period, source.high[period], "" .. positives);
				N2:set(period, source.low[period], "");
			end
		end
	end
end
