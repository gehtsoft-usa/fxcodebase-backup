-- Id: 19622
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=65320

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


function Init()
    indicator:name("StatArb");
    indicator:description("Pair Trading. Grey area chart is normalized spread between two pairs");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addString("tf_short", "Timeframe", "", "m15");
    indicator.parameters:setFlag("tf_short", core.FLAG_PERIODS);

    indicator.parameters:addDouble("stoploss", "StopLoss %", "", 10);
    indicator.parameters:addDouble("takeprofit", "takeProfit %", "", 30);
    indicator.parameters:addInteger("avgLookback", "Smoothing Lookback period in bars - short", "", 10);
    indicator.parameters:addInteger("avgLookback_long", "Smoothing Lookback period in bars - long", "", 100);
    indicator.parameters:addInteger("stdDevMultiplier", "Standard deviation multiplier", "", 4);
    indicator.parameters:addString("sym1_short", "Symbol1", "", "AUD/USD");
    indicator.parameters:addString("sym2_short", "Symbol2", "", "XAU/USD");
	
	
	 indicator.parameters:addColor("C7","Spread Line Color","", core.rgb(128, 128, 128));
	 indicator.parameters:addColor("C1","Stop Short Color","", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("C2","Limit Short Color", "",core.rgb(255, 0, 0));
	 indicator.parameters:addColor("C3","Short Color", "",core.rgb(255, 0, 0));
	 indicator.parameters:addColor("C4","Long Color", "",core.rgb(0, 255, 0));
	 indicator.parameters:addColor("C5","Stop Long Color","", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("C6","Limit Long Color","", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 5, 1, 5);
end

local tf_short;
local stoploss;
local takeprofit;
local avgLookback;
local avgLookback_long;
local stdDevMultiplier;
local sym1_short;
local sym2_short;
local sym_price1;
local sym_price2;
local cum_changePcnt1_short;
local cum_changePcnt2_short;
local spread_norm;
local spread_short;
local spread_long;
local stoploss_level_short;
local takeprofit_level_short;
local stoploss_level_long;
local takeprofit_level_long;
local upper_band_exit;
local lower_band_exit;
local entry_Short;
local entry_Long;
local first;
local sym_price1_loaded = false;
local sym_price2_loaded = false;
local lower_band_entry;
local C1, C2, C3,C4,C5,C6,C7;

-- Routine
function Prepare(nameOnly)
    tf_short = instance.parameters.tf_short;
    stoploss = instance.parameters.stoploss;
    takeprofit = instance.parameters.takeprofit;
    avgLookback = instance.parameters.avgLookback;
    avgLookback_long = instance.parameters.avgLookback_long;
    stdDevMultiplier = instance.parameters.stdDevMultiplier;
    sym1_short = instance.parameters.sym1_short;
    sym2_short = instance.parameters.sym2_short;
	
	C1 = instance.parameters.C1;
	C2 = instance.parameters.C2;
	C3 = instance.parameters.C3;
	C4 = instance.parameters.C4;
	C5 = instance.parameters.C5;
	C6 = instance.parameters.C6;
	C7 = instance.parameters.C7;

    local name = string.format("%s (%s, %s, %s)", profile:id(), tf_short, sym1_short, sym2_short);
    instance:name(name);
	
    if nameOnly then
        return ;
    end
	
	sym_price1_loaded = false;
    sym_price2_loaded = false;

    sym_price1 = core.host:execute("getSyncHistory", sym1_short, tf_short, instance.source:isBid(), 300, 100, 101);
    sym_price2 = core.host:execute("getSyncHistory", sym2_short, tf_short, instance.source:isBid(), 300, 200, 201);

    cum_changePcnt1_short = instance:addInternalStream(0, 0);
    cum_changePcnt2_short = instance:addInternalStream(0, 0);
    upper_band_exit = instance:addInternalStream(0, 0);
    lower_band_exit = instance:addInternalStream(0, 0);
    lower_band_entry = instance:addInternalStream(0, 0);
    upper_band_entry = instance:addInternalStream(0, 0);
    spread_norm = instance:addStream("Spread", core.Line, name .. ".Spread", "Spread", C7, 0);
    spread_norm:setPrecision(math.max(2, instance.source:getPrecision()));

    spread_short = core.indicators:create("EMA", spread_norm, avgLookback);
    spread_long = core.indicators:create("EMA", spread_norm, avgLookback_long);
    first = math.max(spread_short.DATA:first(), spread_long.DATA:first()) + avgLookback;

    stoploss_level_short = instance:addStream("StopShort", core.Dot, name .. ".StopShort", "StopShort", C1, first);
    stoploss_level_short:setPrecision(math.max(2, instance.source:getPrecision()));
	stoploss_level_short:setWidth(instance.parameters.width);
    takeprofit_level_short = instance:addStream("LimitShort", core.Dot, name .. ".LimitShort", "LimitShort", C2, first);
    takeprofit_level_short:setPrecision(math.max(2, instance.source:getPrecision()));
	takeprofit_level_short:setWidth(instance.parameters.width);
    entry_Short = instance:addStream("Short", core.Dot, name .. ".Short", "Short", C3, first);
    entry_Short:setPrecision(math.max(2, instance.source:getPrecision()));
	entry_Short:setWidth(instance.parameters.width);
    entry_Long = instance:addStream("Long", core.Dot, name .. ".Long", "Long", C4, first);
    entry_Long:setPrecision(math.max(2, instance.source:getPrecision()));
	entry_Long:setWidth(instance.parameters.width);
    stoploss_level_long = instance:addStream("StopLong", core.Dot, name .. ".StopLong", "StopLong", C5, first);
    stoploss_level_long:setPrecision(math.max(2, instance.source:getPrecision()));
	stoploss_level_long:setWidth(instance.parameters.width);
    takeprofit_level_long = instance:addStream("LimitLong", core.Dot, name .. ".LimitLong", "LimitLong", C6, first);
    takeprofit_level_long:setPrecision(math.max(2, instance.source:getPrecision()));
	takeprofit_level_long:setWidth(instance.parameters.width);
end

function Initialization(period, src)
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
    local Candle = core.getcandle(instance.source:barSize(), instance.source:date(period), dayoffset, weekoffset);
    local p = core.findDate(src, Candle, false);
    -- candle is not found
    if p < 0 then
        return nil;
    else
        return p;	
    end
end	

function Update(period, mode) 
    if period <= first or  not sym_price1_loaded or  not sym_price2_loaded then
        return;
    end
    local period1 = Initialization(period, sym_price1);
    local period2 = Initialization(period, sym_price2);
	
	
    if period1 == nil or period2 == nil
	or not sym_price1.close:hasData(period1)
	or not sym_price1.close:hasData(period1-1)
	or not sym_price2.close:hasData(period2) 
	or  not sym_price2.close:hasData(period2-1)
	then
        return;
    end
	
	

    cum_changePcnt1_short[period] = ((sym_price1.close[period1] - sym_price1.close[period1 - 1]) / sym_price1.close[period1]) + (period1 <= 1 and 0 or cum_changePcnt1_short[period - 1]);
    cum_changePcnt2_short[period] = ((sym_price2.close[period2] - sym_price2.close[period2 - 1]) / sym_price2.close[period2]) + (period2 <= 1 and 0 or cum_changePcnt2_short[period - 1]);
    local sym_priceNorm_1 = (sym_price1.close[period1]) * (1 + cum_changePcnt1_short[period]);
    local sym_priceNorm_2 = (sym_price1.close[period1]) * (1 + cum_changePcnt2_short[period]);
    spread_norm[period] = sym_priceNorm_1 - sym_priceNorm_2;
    spread_short:update(mode);
    spread_long:update(mode);
    local spread_stdev_short = mathex.stdev(spread_long.DATA, core.rangeTo(period, avgLookback));
    lower_band_entry[period] = spread_long.DATA[period] - spread_stdev_short * stdDevMultiplier;
    upper_band_entry[period] = spread_long.DATA[period] + spread_stdev_short * stdDevMultiplier;
    lower_band_exit[period] = spread_long.DATA[period] - spread_stdev_short * stdDevMultiplier * 4;
    upper_band_exit[period] = spread_long.DATA[period] + spread_stdev_short * stdDevMultiplier * 4;

    if (spread_short.DATA[period] - lower_band_entry[period]) > 0 
        and (spread_short.DATA[period - 1] - lower_band_entry[period - 1]) < 0 then
        entry_Short[period] = spread_norm[period];
        stoploss_level_short[period] = entry_Short[period] + math.abs(entry_Short[period] * (stoploss / 100));
        takeprofit_level_short[period] = entry_Short[period] - math.abs(entry_Short[period] * (takeprofit / 100));
    end
    if (spread_short.DATA[period] - upper_band_entry[period]) < 0 
        and (spread_short.DATA[period - 1] - upper_band_entry[period - 1]) > 0 then
        entry_Long[period] = spread_norm[period];
        stoploss_level_long[period] = entry_Long[period] - math.abs(entry_Long[period] * (stoploss / 100));
        takeprofit_level_long[period] = entry_Long[period] + math.abs(entry_Long[period] * (takeprofit / 100));
    end
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 100 then
        sym_price1_loaded = true;
  
    elseif coookie == 101 then
        sym_price1_loaded = false;
    elseif cookie == 200 then
        sym_price2_loaded = true;
        
    elseif coookie == 201 then
        sym_price2_loaded = false;
    end
	
	if  sym_price2_loaded and   sym_price1_loaded
	then
	instance:updateFrom(0);
	end
	
end
