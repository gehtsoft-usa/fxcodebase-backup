-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67251

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("GT Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("tsi_period_1", "TSI Smooth 1 Period", "", 7);
    indicator.parameters:addInteger("tsi_period_2", "TSI Smooth 2 Period", "", 14);
    indicator.parameters:addInteger("lookback", "Lookback Bars", "", 5);
    indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("Size1", "Arrow Size","", 15);
    indicator.parameters:addColor("clrUP", "Up Color","", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN", "Down Color","", core.COLOR_DOWNCANDLE);
end

local source;
local up, down;
local Size1;
local lookback;
local tsi;

function Prepare(nameOnly) 
    source = instance.source;
    Size1 = instance.parameters.Size1;
    lookback = instance.parameters.lookback;
	
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	if (nameOnly) then
        return;
    end
    up = instance:createTextOutput("Up", "Up", "Wingdings", Size1, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
    down = instance:createTextOutput("Dn", "Dn", "Wingdings", Size1, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);
    tsi = core.indicators:create("TSI", source, instance.parameters.tsi_period_1, instance.parameters.tsi_period_2);
end

function IsUp(period)
    if not core.crossesOver(tsi.DATA, 0, period) then
        return false;
    end
    for i = 1, lookback do
        if period - i - 1 < 0 or not tsi.DATA:hasData(period - i - 1) then
            return false;
        end
        if tsi.DATA[period - i] < 0 and tsi.DATA[period - i - 1] < 0
            and source.close[period - i] > source.close[period - i - 1]
            and (source.close[period - i] >= source.open[period - i]) ~= (source.close[period - i - 1] >= source.open[period - i - 1])
        then
            return true;
        end
    end
    return false;
end

function IsDown(period)
    if not core.crossesUnder(tsi.DATA, 0, period) then
        return false;
    end
    for i = 1, lookback do
        if period - i - 1 < 0 or not tsi.DATA:hasData(period - i - 1) then
            return false;
        end
        if tsi.DATA[period - i] > 0 and tsi.DATA[period - i - 1] > 0
            and source.close[period - i] < source.close[period - i - 1]
            and (source.close[period - i] <= source.open[period - i]) ~= (source.close[period - i - 1] <= source.open[period - i - 1])
        then
            return true;
        end
    end
    return false;
end

function Update(period, mode)
    tsi:update(mode);
    if IsUp(period) then
        up:set(period, source.high[period], "\217", source.high[period]);
    end
    if IsDown(period) then
        down:set(period, source.low[period], "\218", source.low[period]);
    end
end
