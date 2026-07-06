-- Id: 15502
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63153

--+------------------------------------------------------------------+
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("ATR Stop Dots");
    indicator:description("ATR Stop Dots");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("Percentage", "Risk Percentage", "", 1.0);
    indicator.parameters:addDouble("Multiplier", "ATR Multiplier", "", 1.5);
    indicator.parameters:addDouble("pMultiplier", "Profit Multiplier", "", 2.0);
    indicator.parameters:addInteger("Period", "ATR Period", "", 14);
    indicator.parameters:addInteger("NumDots", "Num Dots", "", 5);
    indicator.parameters:addBoolean("LAST_CANDLE", "Put on the current candle", "", false);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("DOTclr", "Stop Dot colour", "Stop Dot colour", core.rgb(255, 0, 0));
    indicator.parameters:addColor("pDOTclr", "Profit Dot colour", "Profit Dot colour", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 2, 1, 5);
    indicator.parameters:addInteger("FontSize", "Font Size", "", 8, 4, 12);
    indicator.parameters:addColor("LblColour", "Colour for pattern labels", "", core.COLOR_LABEL);
end

local UP;
local DN;
local first;
local source = nil;
local Percentage;
local Multiplier;
local pMultiplier;
local PipPct;
local ATR;
local DOTh=nil;
local DOTl=nil;
local DOThp=nil;
local DOTlp=nil;
local NumDots=2;

function Prepare(nameOnly)
    source = instance.source;
    Percentage=instance.parameters.Percentage;
    Multiplier=instance.parameters.Multiplier;
    pMultiplier=instance.parameters.pMultiplier;
    NumDots=instance.parameters.NumDots;

    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Percentage .. "," .. instance.parameters.Multiplier .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    if nameOnly then
        return;
    end
    ATR = core.indicators:create("ATR", source, Period);

    local Balance;
    local accounts = core.host:findTable("accounts");
    local enum = accounts:enumerator();
    local row = enum:next();
    if row ~= nil then
        Balance= row.Balance;
    end

    local PipCost   = core.host:findTable("offers"):find("Instrument", source:instrument()).PipCost;
    local BalPct = (Balance * Percentage) / 100.0;
    PipPct = BalPct / PipCost;
    
    DOTh = instance:addStream("DOTh", core.Dot, name .. ".DOTh", "DOTh", instance.parameters.DOTclr, first);
    DOTh:setWidth(instance.parameters.DotSize);
    DOTl = instance:addStream("DOTl", core.Dot, name .. ".DOTl", "DOTl", instance.parameters.DOTclr, first);
    DOTl:setWidth(instance.parameters.DotSize);
    DOThp = instance:addStream("DOThp", core.Dot, name .. ".DOThp", "DOThp", instance.parameters.pDOTclr, first);
    DOThp:setWidth(instance.parameters.DotSize);
    DOTlp = instance:addStream("DOTlp", core.Dot, name .. ".DOTlp", "DOTlp", instance.parameters.pDOTclr, first);
    DOTlp:setWidth(instance.parameters.DotSize);

    UP = instance:createTextOutput("L", "L", "Arial", instance.parameters.FontSize, core.H_Center, core.V_Top, instance.parameters.LblColour, 0);
    DN = instance:createTextOutput("L", "L", "Arial", instance.parameters.FontSize, core.H_Center, core.V_Bottom, instance.parameters.LblColour, 0);
end

function Update(period, mode)
    local last_candle = instance.parameters:getBoolean("LAST_CANDLE");
    if (period>source:size()-NumDots-2) and ((period<source:size()-1) or (last_candle == true)) then
        ATR:update(mode);

        local atr_value = (ATR.DATA[period]*Multiplier);
        local base_value = PipPct*source:pipSize();
        if (atr_value < base_value) then
            base_value = atr_value;
        end

        DOTh[period]=source.close[period]+base_value;
        DOTl[period]=source.close[period]-base_value;
        DOThp[period]=source.close[period]+(base_value*pMultiplier);
        DOTlp[period]=source.close[period]-(base_value*pMultiplier);

        local display_value = math.floor(base_value/source:pipSize());
        local lotsize = math.floor(PipPct/display_value);
        UP:set(period, source.high[period]+base_value+(source:pipSize()*10), "Lot: " .. lotsize .. "K", "Lot: " .. lotsize .. "K");
        DN:set(period, source.low[period]-base_value-(source:pipSize()*10), display_value, display_value);
    end
end

