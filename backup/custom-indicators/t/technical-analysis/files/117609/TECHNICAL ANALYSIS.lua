
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=65703

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


function Init()
    indicator:name("Technical Analysis");
    indicator:description("Technical Analysis");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("rsi_period", "RSI Period", "", 14);
    indicator.parameters:addInteger("rsi_ob", "RSI Overbought", "", 70);
    indicator.parameters:addInteger("rsi_os", "RSI Oversold", "", 30);
    indicator.parameters:addInteger("stoch_K", "Stochastic %K Period", "", 5, 2, 1000);
    indicator.parameters:addInteger("stoch_SD", "Stochastic slow %D Period", "", 3, 2, 1000);
    indicator.parameters:addInteger("stoch_D", "Stochastic %D Period", "", 3, 2, 1000);
    indicator.parameters:addString("stoch_MVAT_K", "Stochastic Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("stoch_MVAT_K", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("stoch_MVAT_K", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("stoch_MVAT_K", "Fast Smoothed", "", "FS");
    indicator.parameters:addString("stoch_MVAT_D", "Stochastic Smoothing type for %D", "", "MVA");
    indicator.parameters:addStringAlternative("stoch_MVAT_D", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("stoch_MVAT_D", "EMA", "", "EMA");
    indicator.parameters:addInteger("stoch_ob", "Stochastic Overbought", "", 80);
    indicator.parameters:addInteger("stoch_os", "Stochastic Oversold", "", 20);
    indicator.parameters:addInteger("cci_period", "CCI Period", "", 20);
    indicator.parameters:addInteger("cci_ob", "CCI Overbought", "", 100);
    indicator.parameters:addInteger("cci_os", "CCI Oversold", "", -100);
    indicator.parameters:addInteger("adx_period", "ADX Period", "", 14);
    indicator.parameters:addInteger("ao_fast_period", "AO Fast MA periods", "", 5);
    indicator.parameters:addInteger("ao_slow_period", "AO Slow MA periods", "", 35);
    indicator.parameters:addInteger("macd_SN", "MACD Fast MA periods", "", 12, 2, 1000);
    indicator.parameters:addInteger("macd_LN", "MACD Slow MA periods", "", 26, 2, 1000);
    indicator.parameters:addInteger("macd_IN", "MACD Signal line", "", 9, 2, 1000);

    indicator.parameters:addInteger("ema_1", "EMA 1 Period", "", 10, 2, 1000);
    indicator.parameters:addInteger("mva_1", "MVA 1 Period", "", 10, 2, 1000);
    indicator.parameters:addInteger("ema_2", "EMA 2 Period", "", 20, 2, 1000);
    indicator.parameters:addInteger("mva_2", "MVA 2 Period", "", 20, 2, 1000);
    indicator.parameters:addInteger("ema_3", "EMA 3 Period", "", 30, 2, 1000);
    indicator.parameters:addInteger("mva_3", "MVA 3 Period", "", 30, 2, 1000);
    indicator.parameters:addInteger("ema_4", "EMA 4 Period", "", 50, 2, 1000);
    indicator.parameters:addInteger("mva_4", "MVA 4 Period", "", 50, 2, 1000);
    indicator.parameters:addInteger("ema_5", "EMA 5 Period", "", 100, 2, 1000);
    indicator.parameters:addInteger("mva_5", "MVA 5 Period", "", 100, 2, 1000);
    indicator.parameters:addInteger("ema_6", "EMA 6 Period", "", 200, 2, 1000);
    indicator.parameters:addInteger("mva_6", "MVA 6 Period", "", 200, 2, 1000);
    indicator.parameters:addInteger("ich_X", "ICH Tenkan-sen period", "", 9, 1, 10000);
    indicator.parameters:addInteger("ich_Y", "ICH Kijun-sen period", "", 26, 1, 10000);
    indicator.parameters:addInteger("ich_Z", "ICH Senkou Span B period", "", 52, 1, 10000);
    indicator.parameters:addInteger("wma_period", "WMA Period", "", 20);

    indicator.parameters:addInteger("font_size", "Font Size", "", 10);
    indicator.parameters:addColor("font_color", "Font Color", "", core.rgb(128, 128, 128));
    indicator.parameters:addColor("font_color_buy", "Buy Font Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("font_color_sell", "Sell Font Color", "", core.rgb(255, 0, 0));
end

local source;
local font_size = 10;
local font_color;
local indicators = {};
local oscillators = {};
local pivots = {};
function Prepare(onlyName)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end
    font_size = instance.parameters.font_size;
    font_color = instance.parameters.font_color;

    oscillators[#oscillators + 1] =
    {
        Index = 0;
        Indi = core.indicators:create("RSI", source, instance.parameters.rsi_period);
        GetAction = function(self)
            if self.Indi.DATA[NOW] > instance.parameters.rsi_ob then
                return -1;
            elseif self.Indi.DATA[NOW] < instance.parameters.rsi_os then
                return 1;
            end
            return 0;
        end
    };
    oscillators[#oscillators + 1] =
    {
        Index = 0;
        Indi = core.indicators:create("STOCHASTIC", source, instance.parameters.stoch_K, instance.parameters.stoch_SD, 
            instance.parameters.stoch_D, instance.parameters.stoch_MVAT_K, instance.parameters.stoch_MVAT_D);
        GetAction = function(self)
            if self.Indi.DATA[NOW] > instance.parameters.stoch_ob then
                return -1;
            elseif self.Indi.DATA[NOW] < instance.parameters.stoch_os then
                return 1;
            end
            return 0;
        end
    };
    oscillators[#oscillators + 1] =
    {
        Index = 0;
        Indi = core.indicators:create("CCI", source, instance.parameters.cci_period);
        GetAction = function(self)
            if self.Indi.DATA[NOW] > instance.parameters.cci_ob then
                return -1;
            elseif self.Indi.DATA[NOW] < instance.parameters.cci_os then
                return 1;
            end
            return 0;
        end
    };
    oscillators[#oscillators + 1] =
    {
        Index = 0;
        Indi = core.indicators:create("ADX", source, instance.parameters.adx_period);
        GetAction = function(self)
            return nil;
        end
    };
    oscillators[#oscillators + 1] =
    {
        Index = 0;
        Indi = core.indicators:create("AO", source, instance.parameters.ao_fast_period, instance.parameters.ao_slow_period);
        GetAction = function(self)
            if self.Indi.DATA[NOW] > 0 then
                return -1;
            elseif self.Indi.DATA[NOW] < 0 then
                return 1;
            end
            return 0;
        end
    };
    oscillators[#oscillators + 1] =
    {
        Index = 0;
        Indi = core.indicators:create("MACD", source, instance.parameters.macd_SN, instance.parameters.macd_LN, instance.parameters.macd_IN);
        GetAction = function(self)
            if self.Indi:getStream(2):tick(NOW) > 0 then
                return 1;
            elseif self.Indi:getStream(2):tick(NOW) < 0 then
                return -1;
            end
            return 0;
        end
    };

    for i = 1, 6 do
        indicators[#indicators + 1] =
        {
            Index = 0;
            Indi = core.indicators:create("EMA", source, instance.parameters:getInteger("ema_" .. i));
            GetAction = function(self)
                if self.Indi.DATA[NOW] < self.Indi.DATA[NOW - 1] then
                    return -1;
                elseif self.Indi.DATA[NOW] > self.Indi.DATA[NOW - 1] then
                    return 1;
                end
                return 0;
            end
        };
        indicators[#indicators + 1] =
        {
            Index = 0;
            Indi = core.indicators:create("MVA", source, instance.parameters:getInteger("mva_" .. i));
            GetAction = function(self)
                if self.Indi.DATA[NOW] < self.Indi.DATA[NOW - 1] then
                    return -1;
                elseif self.Indi.DATA[NOW] > self.Indi.DATA[NOW - 1] then
                    return 1;
                end
                return 0;
            end
        };
    end
    indicators[#indicators + 1] =
    {
        Index = 0;
        Indi = core.indicators:create("ICH", source, instance.parameters.ich_X, instance.parameters.ich_Y, instance.parameters.ich_Z);
        GetAction = function(self)
            return nil;
        end
    };
    indicators[#indicators + 1] =
    {
        Index = 0;
        Indi = core.indicators:create("WMA", source, instance.parameters.wma_period);
        GetAction = function(self)
            if self.Indi.DATA[NOW] < self.Indi.DATA[NOW - 1] then
                return -1;
            elseif self.Indi.DATA[NOW] > self.Indi.DATA[NOW - 1] then
                return 1;
            end
            return 0;
        end
    };

    pivots[#pivots + 1] =
    {
        Indi = core.indicators:create("PIVOT", source, "D1", "Pivot", "HIST");
    };
    pivots[#pivots + 1] =
    {
        Indi = core.indicators:create("PIVOT", source, "D1", "Camarilla", "HIST");
    };
    pivots[#pivots + 1] =
    {
        Indi = core.indicators:create("PIVOT", source, "D1", "Woodie", "HIST");
    };
    pivots[#pivots + 1] =
    {
        Indi = core.indicators:create("PIVOT", source, "D1", "Fibonacci", "HIST");
    };
    pivots[#pivots + 1] =
    {
        Indi = core.indicators:create("PIVOT", source, "D1", "Floor", "HIST");
    };
    pivots[#pivots + 1] =
    {
        Indi = core.indicators:create("PIVOT", source, "D1", "FibonacciR", "HIST");
    };

    instance:ownerDrawn(true);
end

function Update(period, mode)
    for i, indi in ipairs(oscillators) do
        indi.Indi:update(mode);
    end
    for i, indi in ipairs(indicators) do
        indi.Indi:update(mode);
    end
    for i, indi in ipairs(pivots) do
        indi.Indi:update(mode);
    end
end

local init = false;
local FONT_ID = 1;

function createColumn(x, y)
    local col_1 = {};
    col_1.x = x;
    col_1.y = y;
    col_1.max_width = 0;
    function col_1:DrawText(context, text, color)
        local width, height = context:measureText(FONT_ID, text, 0);
        context:drawText(FONT_ID, text, color or font_color, -1, self.x, self.y, self.x + width, self.y + height, 0);
        self.y = self.y + height * 1.5;
        self.max_width = math.max(self.max_width, width);
    end
    return col_1;
end

function round(num, idp)
    if idp and idp>0 then
        local mult = 10^idp
        return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end

function DrawOsicllators(context, x, y)
    local width, height = context:measureText(FONT_ID, "Oscillators", 0);
    context:drawText(FONT_ID, "Oscillators", font_color, -1, x, y, x + width, y + height, 0);
    local col_1 = createColumn(x, y + height * 1.5);
    col_1:DrawText(context, "Name");
    for i, indi in ipairs(oscillators) do
        col_1:DrawText(context, indi.Indi:name());
    end

    local col_2 = createColumn(col_1.x + col_1.max_width + 10, y + height * 1.5);
    col_2:DrawText(context, "Value");
    for i, indi in ipairs(oscillators) do
        local stream = indi.Indi:getStream(indi.Index);
        local val = round(stream:tick(NOW), stream:getPrecision());
        col_2:DrawText(context, tostring(val));
    end

    local col_3 = createColumn(col_2.x + col_2.max_width + 10, y + height * 1.5);
    col_3:DrawText(context, "Action");
    for i, indi in ipairs(oscillators) do
        local action = indi:GetAction(indi.Indi);
        if action == 1 then
            col_3:DrawText(context, "Buy", instance.parameters.font_color_buy);
        elseif action == 0 then
            col_3:DrawText(context, "Neutral");
        elseif action == -1 then
            col_3:DrawText(context, "Sell", instance.parameters.font_color_sell);
        elseif action == nil then
            col_3:DrawText(context, "-", instance.parameters.font_color_sell);
        end
    end
    return col_3.x + col_3.max_width, col_3.y;
end

function DrawIndicators(context, x, y)
    local width, height = context:measureText(FONT_ID, "Indicators", 0);
    context:drawText(FONT_ID, "Indicators", font_color, -1, x, y, x + width, y + height, 0);

    local col_1 = createColumn(x, y + height * 1.5);
    col_1:DrawText(context, "Name");
    for i, indi in ipairs(indicators) do
        col_1:DrawText(context, indi.Indi:name());
    end

    local col_2 = createColumn(col_1.x + col_1.max_width + 10, y + height * 1.5);
    col_2:DrawText(context, "Value");
    for i, indi in ipairs(indicators) do
        local stream = indi.Indi:getStream(indi.Index);
        local val = round(stream:tick(NOW), stream:getPrecision());
        col_2:DrawText(context, tostring(val));
    end
    
    local col_3 = createColumn(col_2.x + col_2.max_width + 10, y + height * 1.5);
    col_3:DrawText(context, "Action");
    for i, indi in ipairs(indicators) do
        local stream = indi.Indi:getStream(indi.Index);
        local action = indi:GetAction(indi.Indi);
        if action == 1 then
            col_3:DrawText(context, "Buy", instance.parameters.font_color_buy);
        elseif action == 0 then
            col_3:DrawText(context, "Neutral");
        elseif action == -1 then
            col_3:DrawText(context, "Sell", instance.parameters.font_color_sell);
        elseif action == nil then
            col_3:DrawText(context, "-", instance.parameters.font_color_sell);
        end
    end
    return col_3.x + col_3.max_width, col_3.y;
end

function DrawPivot(context, x, y)
    local width, height = context:measureText(FONT_ID, "Pivots", 0);
    context:drawText(FONT_ID, "Pivots", font_color, -1, x, y, x + width, y + height, 0);

    local col_1 = createColumn(x, y + height * 1.5);
    col_1:DrawText(context, "Name");
    for i, indi in ipairs(pivots) do
        col_1:DrawText(context, indi.Indi:name());
    end

    local col_2 = createColumn(col_1.x + col_1.max_width + 10, y + height * 1.5);
    col_2:DrawText(context, "S3");
    for i, indi in ipairs(pivots) do
        local stream = indi.Indi.S3;
        local val = round(stream:tick(NOW), stream:getPrecision());
        col_2:DrawText(context, tostring(val));
    end

    local col_3 = createColumn(col_2.x + col_2.max_width + 10, y + height * 1.5);
    col_3:DrawText(context, "S2");
    for i, indi in ipairs(pivots) do
        local stream = indi.Indi.S2;
        local val = round(stream:tick(NOW), stream:getPrecision());
        col_3:DrawText(context, tostring(val));
    end

    local col_4 = createColumn(col_3.x + col_3.max_width + 10, y + height * 1.5);
    col_4:DrawText(context, "S1");
    for i, indi in ipairs(pivots) do
        local stream = indi.Indi.S1;
        local val = round(stream:tick(NOW), stream:getPrecision());
        col_4:DrawText(context, tostring(val));
    end

    local col_5 = createColumn(col_4.x + col_4.max_width + 10, y + height * 1.5);
    col_5:DrawText(context, "P");
    for i, indi in ipairs(pivots) do
        local stream = indi.Indi.P;
        local val = round(stream:tick(NOW), stream:getPrecision());
        col_5:DrawText(context, tostring(val));
    end

    local col_6 = createColumn(col_5.x + col_5.max_width + 10, y + height * 1.5);
    col_6:DrawText(context, "R1");
    for i, indi in ipairs(pivots) do
        local stream = indi.Indi.R1;
        local val = round(stream:tick(NOW), stream:getPrecision());
        col_6:DrawText(context, tostring(val));
    end

    local col_7 = createColumn(col_6.x + col_6.max_width + 10, y + height * 1.5);
    col_7:DrawText(context, "R2");
    for i, indi in ipairs(pivots) do
        local stream = indi.Indi.R2;
        local val = round(stream:tick(NOW), stream:getPrecision());
        col_7:DrawText(context, tostring(val));
    end

    local col_8 = createColumn(col_7.x + col_7.max_width + 10, y + height * 1.5);
    col_8:DrawText(context, "R3");
    for i, indi in ipairs(pivots) do
        local stream = indi.Indi.R3;
        local val = round(stream:tick(NOW), stream:getPrecision());
        col_8:DrawText(context, tostring(val));
    end
end

function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        context:createFont(FONT_ID, "Arial", 0, context:pointsToPixels(font_size), 0);
        init = true;
    end
    local x1, y1 = DrawOsicllators(context, 0, 20);
    local x2, y2 = DrawIndicators(context, x1 + 20, 20);
    DrawPivot(context, x2 + 20, 20);
end
