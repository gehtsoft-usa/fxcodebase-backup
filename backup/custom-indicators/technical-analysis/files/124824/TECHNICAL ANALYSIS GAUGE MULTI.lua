-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65703

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
    indicator:name("Technical Analysis");
    indicator:description("Technical Analysis");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addString("currency", "Currency", "", "EUR");
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

    indicator.parameters:addString("DisplayMethod", "Display Method", "",  "Analog");
    indicator.parameters:addStringAlternative("DisplayMethod", "Table", "", "Table");
    indicator.parameters:addStringAlternative("DisplayMethod", "Analog", "", "Analog");
    
    indicator.parameters:addGroup("Table display parameters");
    indicator.parameters:addInteger("font_size", "Font Size", "", 10);
    indicator.parameters:addColor("font_color", "Font Color", "", core.rgb(128, 128, 128));
    indicator.parameters:addColor("font_color_buy", "Buy Font Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("font_color_sell", "Sell Font Color", "", core.rgb(255, 0, 0));
          
    indicator.parameters:addGroup("Analog display parameters");
    indicator.parameters:addInteger("analog_font_size", "Font Size", "", 7);
    indicator.parameters:addInteger("analog_clock_gap", "Clock Gap", "", 30);
    indicator.parameters:addInteger("analog_clock_size", "Clock Size", "", 150);
    indicator.parameters:addColor("analog_clock_shape" ,  "Clock Shape Color", "", core.rgb(0, 0, 0));
    indicator.parameters:addColor("analog_clock_hands" ,  "Clock Hands Color", "", core.rgb(0, 0, 0));
    
    indicator.parameters:addColor("analog_font_color", "Font Color", "", core.rgb(0, 0, 0));
    indicator.parameters:addColor("analog_color_buy", "Buy Color", "", core.rgb(189, 236, 182));
    indicator.parameters:addColor("analog_color_sell", "Sell Color", "", core.rgb(255,133,151));    
    indicator.parameters:addColor("analog_color_neutral", "Neutral Color", "", core.rgb(128, 128, 128));   
    indicator.parameters:addColor("analog_force_color_buy", "Force Buy Color", "", core.rgb(31,117,21));
    indicator.parameters:addColor("analog_force_color_sell", "Force Sell Color", "", core.rgb(143,36,71));    
end

local source;
local font_size = 10;
local font_color;
local indicators = {};
local oscillators = {};
local sources = {};
local sides = {};
local displayMethod;

local analog_font_size = 10;
local analog_font_color;
local analog_color_buy;
local analog_color_sell;
local analog_color_neutral;
local analog_force_color_buy;
local analog_force_color_sell;
local analog_clock_gap;
local analog_clock_size;
local analog_clock_shape;
local analog_clock_hands;
    
function Prepare(onlyName)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end
    font_size = instance.parameters.font_size;
    font_color = instance.parameters.font_color;
    displayMethod = instance.parameters.DisplayMethod;

    analog_font_size =  instance.parameters.analog_font_size;
    analog_font_color = instance.parameters.analog_font_color;
    
    analog_color_buy = instance.parameters.analog_color_buy;
    analog_color_sell = instance.parameters.analog_color_sell;
    analog_color_neutral = instance.parameters.analog_color_neutral;
    analog_force_color_buy = instance.parameters.analog_force_color_buy;
    analog_force_color_sell = instance.parameters.analog_force_color_sell;    
    analog_clock_gap = instance.parameters.analog_clock_gap;
    analog_clock_size = instance.parameters.analog_clock_size;
    analog_clock_shape = instance.parameters.analog_clock_shape;
    analog_clock_hands = instance.parameters.analog_clock_hands;
    
    local enum = core.host:findTable("offers"):enumerator();
    local row = enum:next();
    local lastId = 1;
    while (row ~= nil) do
        local pos = string.find(row.Instrument, instance.parameters.currency);
        if pos ~= nil then
            local data = {};
            data.LoadingId = lastId;
            data.LoadedId = lastId + 1;
            lastId = lastId + 2;
            sides[row.Instrument] = pos > 1 and -1 or 1;
            data.Source = core.host:execute("getSyncHistory", row.Instrument, source:barSize(), 
                source:isBid(), 300, data.LoadedId, data.LoadingId);
            sources[#sources + 1] = data;
        end
        row = enum:next();
    end

    oscillators[#oscillators + 1] =
    {
        Name = "RSI";
        Index = 0;
        Indi = {};
        GetAction = function(self)
            local total = 0;
            for _, data in ipairs(self.Indi) do
                if data.DATA:size() == 0 then
                    return nil;
                end
                if data.DATA[NOW] > instance.parameters.rsi_ob then
                    total = total - 1 * sides[data.DATA:instrument()];
                elseif data.DATA[NOW] < instance.parameters.rsi_os then
                    total = total + 1 * sides[data.DATA:instrument()];
                end
            end
            return total;
        end
    };
    for _, data in ipairs(sources) do
        oscillators[#oscillators].Indi[#oscillators[#oscillators].Indi + 1] = 
            core.indicators:create("RSI", data.Source, instance.parameters.rsi_period);
    end
    oscillators[#oscillators + 1] =
    {
        Name = "Stochastic";
        Index = 0;
        Indi = {};
        GetAction = function(self)
            local total = 0;
            for _, data in ipairs(self.Indi) do
                if data.DATA:size() == 0 then
                    return nil;
                end
                if data.DATA[NOW] > instance.parameters.stoch_ob then
                    total = total - 1 * sides[data.DATA:instrument()];
                elseif data.DATA[NOW] < instance.parameters.stoch_os then
                    total = total + 1 * sides[data.DATA:instrument()];
                end
            end
            return total;
        end
    };
    for _, data in ipairs(sources) do
        oscillators[#oscillators].Indi[#oscillators[#oscillators].Indi + 1] = 
            core.indicators:create("STOCHASTIC", data.Source, instance.parameters.stoch_K, instance.parameters.stoch_SD, 
                instance.parameters.stoch_D, instance.parameters.stoch_MVAT_K, instance.parameters.stoch_MVAT_D);
    end
    oscillators[#oscillators + 1] =
    {
        Name = "CCI";
        Index = 0;
        Indi = {};
        GetAction = function(self)
            local total = 0;
            for _, data in ipairs(self.Indi) do
                if data.DATA:size() == 0 then
                    return nil;
                end
                if data.DATA[NOW] > instance.parameters.cci_ob then
                    total = total - 1 * sides[data.DATA:instrument()];
                elseif data.DATA[NOW] < instance.parameters.cci_os then
                    total = total + 1 * sides[data.DATA:instrument()];
                end
            end
            return total;
        end
    };
    for _, data in ipairs(sources) do
        oscillators[#oscillators].Indi[#oscillators[#oscillators].Indi + 1] = 
            core.indicators:create("CCI", data.Source, instance.parameters.cci_period)
    end
    oscillators[#oscillators + 1] =
    {
        Name = "AO";
        Index = 0;
        Indi = {};
        GetAction = function(self)
            local total = 0;
            for _, data in ipairs(self.Indi) do
                if data.DATA:size() == 0 then
                    return nil;
                end
                if data.DATA[NOW] > 0 then
                    total = total - 1 * sides[data.DATA:instrument()];
                elseif data.DATA[NOW] < 0 then
                    total = total + 1 * sides[data.DATA:instrument()];
                end
            end
            return total;
        end
    };
    for _, data in ipairs(sources) do
        oscillators[#oscillators].Indi[#oscillators[#oscillators].Indi + 1] = 
            core.indicators:create("AO", data.Source, instance.parameters.ao_fast_period, instance.parameters.ao_slow_period)
    end
    oscillators[#oscillators + 1] =
    {
        Name = "MACD";
        Index = 0;
        Indi = {};
        GetAction = function(self)
            local total = 0;
            for _, data in ipairs(self.Indi) do
                if data.DATA:size() == 0 then
                    return nil;
                end
                if data:getStream(2):tick(NOW) > 0 then
                    total = total - 1 * sides[data.DATA:instrument()];
                elseif data:getStream(2):tick(NOW) < 0 then
                    total = total + 1 * sides[data.DATA:instrument()];
                end
            end
            return total;
        end
    };
    for _, data in ipairs(sources) do
        oscillators[#oscillators].Indi[#oscillators[#oscillators].Indi + 1] = 
            core.indicators:create("MACD", data.Source, instance.parameters.macd_SN, instance.parameters.macd_LN, 
                instance.parameters.macd_IN)
    end

    for i = 1, 6 do
        indicators[#indicators + 1] =
        {
            Name = "EMA " .. instance.parameters:getInteger("mva_" .. i);
            Index = 0;
            Indi = {};
            GetAction = function(self)
                local total = 0;
                for _, data in ipairs(self.Indi) do
                    if data.DATA:size() == 0 then
                        return nil;
                    end
                    if data.DATA[NOW] < data.DATA[NOW - 1] then
                        total = total - 1 * sides[data.DATA:instrument()];
                    elseif data.DATA[NOW] > data.DATA[NOW - 1] then
                        total = total + 1 * sides[data.DATA:instrument()];
                    end
                end
                return total;
            end
        };
        for _, data in ipairs(sources) do
            indicators[#indicators].Indi[#indicators[#indicators].Indi + 1] = 
                core.indicators:create("EMA", data.Source, instance.parameters:getInteger("ema_" .. i))
        end
        indicators[#indicators + 1] =
        {
            Name = "MVA " .. instance.parameters:getInteger("mva_" .. i);
            Index = 0;
            Indi = {};
            GetAction = function(self)
                local total = 0;
                for _, data in ipairs(self.Indi) do
                    if data.DATA:size() == 0 then
                        return nil;
                    end
                    if data.DATA[NOW] < data.DATA[NOW - 1] then
                        total = total - 1 * sides[data.DATA:instrument()];
                    elseif data.DATA[NOW] > data.DATA[NOW - 1] then
                        total = total + 1 * sides[data.DATA:instrument()];
                    end
                end
                return total;
            end
        };
        for _, data in ipairs(sources) do
            indicators[#indicators].Indi[#indicators[#indicators].Indi + 1] = 
                core.indicators:create("MVA", data.Source, instance.parameters:getInteger("mva_" .. i))
        end
    end
    indicators[#indicators + 1] =
    {
        Name = "WMA";
        Index = 0;
        Indi = {};
        GetAction = function(self)
            local total = 0;
            for _, data in ipairs(self.Indi) do
                if data.DATA:size() == 0 then
                    return nil;
                end
                if data.DATA[NOW] < data.DATA[NOW - 1] then
                    total = total - 1 * sides[data.DATA:instrument()];
                elseif data.DATA[NOW] > data.DATA[NOW - 1] then
                    total = total + 1 * sides[data.DATA:instrument()];
                end
            end
            return total;
        end
    };
    for _, data in ipairs(sources) do
        indicators[#indicators].Indi[#indicators[#indicators].Indi + 1] = 
            core.indicators:create("WMA", data.Source, instance.parameters.wma_period)
    end

    instance:ownerDrawn(true);
end

function Update(period, mode)
    for i, indi in ipairs(oscillators) do
        for _, data in ipairs(indi.Indi) do
            data:update(mode);
        end
    end
    for i, indi in ipairs(indicators) do
        for _, data in ipairs(indi.Indi) do
            data:update(mode);
        end
    end
end

local init = false;
local FONT_ID = 1;
local ANALOG_FONT_ID = 10;
local ANALOG_BRUSH_BUY = 11;
local ANALOG_BRUSH_SELL = 12;
local ANALOG_BRUSH_FORCE_BUY = 13;
local ANALOG_BRUSH_FORCE_SELL = 14;
local ANALOG_BRUSH_NEUTRAL = 15;
    
local captionNeutral = "NEUTRAL";
local captionBUY = "BUY";
local captionSELL = "SELL";
local captionFORCEBUY = "FORCE BUY";
local captionFORCESELL = "FORCE SELL";

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
        col_1:DrawText(context, indi.Name);
    end

    local col_3 = createColumn(col_1.x + col_1.max_width + 10, y + height * 1.5);
    col_3:DrawText(context, "Action");
    for i, indi in ipairs(oscillators) do
        local action = indi:GetAction(indi.Indi);
        if action == nil then
            col_3:DrawText(context, "-", instance.parameters.font_color_sell);
        elseif action >= 1 then
            col_3:DrawText(context, "Buy", instance.parameters.font_color_buy);
        elseif action == 0 then
            col_3:DrawText(context, "Neutral");
        elseif action <= -1 then
            col_3:DrawText(context, "Sell", instance.parameters.font_color_sell);
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
        col_1:DrawText(context, indi.Name);
    end
    
    local col_3 = createColumn(col_1.x + col_1.max_width + 10, y + height * 1.5);
    col_3:DrawText(context, "Action");
    for i, indi in ipairs(indicators) do
        local action = indi:GetAction(indi.Indi);
        if action == nil then
            col_3:DrawText(context, "-", instance.parameters.font_color_sell);
        elseif action >= 1 then
            col_3:DrawText(context, "Buy", instance.parameters.font_color_buy);
        elseif action == 0 then
            col_3:DrawText(context, "Neutral");
        elseif action <= -1 then
            col_3:DrawText(context, "Sell", instance.parameters.font_color_sell);
        end
    end
    return col_3.x + col_3.max_width, col_3.y;
end

function DrawAnalog(context, _x, _y, array, caption)
    local fontHeight = context:pointsToPixels(analog_font_size);
    local counter = {}
    counter["Buy"] = 0;
    counter["Neutral"] = 0;
    counter["Sell"] = 0;
    counter["-"] = 0;
     
    for i, indi in ipairs(array) do
        local action = indi:GetAction(indi.Indi);
        if action == nil then
            counter["-"] = counter["-"] + 1;
        elseif action >= 1 then
            counter["Buy"] = counter["Buy"] + action;
        elseif action == 0 then
            counter["Neutral"] = counter["Neutral"] + 1;
        elseif action <= -1 then
            counter["Sell"] = counter["Sell"] + math.abs(action);
        end
    end
       
    counter["ALL"] = counter["Buy"] + counter["Neutral"] + counter["Sell"];
    
    local direction = 0;
    local count = 0;
    local brush = ANALOG_BRUSH_NEUTRAL;
    local captionResult = captionNeutral;
    local captionResultColor = analog_color_neutral;
       
    if counter["Buy"] ~=  counter["Sell"] then         
        if counter["Buy"] >  counter["Sell"] then
            direction = -1 ;
            count = counter["Buy"];   
            if count >= counter["ALL"]/2 then
                brush = ANALOG_BRUSH_FORCE_BUY;
                captionResult = captionFORCEBUY;
                captionResultColor = analog_force_color_buy;
            else
                brush = ANALOG_BRUSH_BUY;
                captionResult = captionBUY;
                captionResultColor = analog_color_buy
            end
        else
            direction = 1;
            count = counter["Sell"];   
            if count >= counter["ALL"]/2 then
                brush = ANALOG_BRUSH_FORCE_SELL;
                captionResult = captionFORCESELL;
                captionResultColor = analog_force_color_sell;
            else
                brush = ANALOG_BRUSH_SELL;
                captionResult = captionSELL;
                captionResultColor = analog_color_sell;
            end     
        end
    end
      
    local xCell, yCell, xWidth;
    local x1, y1, x2, y2, x, y;
    local clockGap = analog_clock_gap;
    local clockSize = analog_clock_size;
    local xWidth = clockGap * 2 + clockSize;

    xCell = _x + clockGap;
    yCell = _y + clockGap;

    -- draw clocks
    x1 = xCell + clockGap;
    x2 = x1 + clockSize;
    y1 = yCell + fontHeight;
    y2 = y1 + clockSize;
    x = (x1 + x2) / 2;
    y = (y1 + y2) / 2;

    context:drawArc(4, brush, x1, y1, x2, y2, x, y, x1, y);
    context:drawEllipse(3, 6, x - clockSize/100, y -clockSize/100, x + clockSize/100, y +clockSize/100);
                      
    local r = clockSize / 2;

    local hx, hy, mx, my;
    for i = 1, 24, 2 do
        if i <= 6 or i >= 18 then          
            hx, hy = math2d.polarToCartesian(r, toAngle(i, 24));
            mx, my = math2d.polarToCartesian(r * 0.85, toAngle(i, 24));
            hx = hx + x;
            hy = hy + y;
            mx = mx + x;
            my = my + y;
            context:drawLine(2, mx, my, hx, hy);
        end
    end
        
    mx, my = math2d.polarToCartesian(r * 3 / 4, toAngle(count * direction , count ~= counter["ALL"] and (counter["ALL"])  * 4 or (counter["ALL"] + 1)  * 4));--indisize *4
    mx = mx + x;
    my = my + y;
    context:drawLine(3, x, y, mx, my);
              
    context:drawText(FONT_ID, caption, font_color, -1, xCell, _y, xCell + xWidth, _y + context:pointsToPixels(font_size), context.CENTER);
    context:drawText(ANALOG_FONT_ID, captionNeutral, analog_color_neutral, -1, xCell, yCell - clockSize/20, xCell + xWidth, yCell + fontHeight, context.CENTER);
    local capX = x - clockSize/4 - string.len(captionBUY) * fontHeight;
    context:drawText(ANALOG_FONT_ID, captionBUY, analog_color_buy, -1, capX, yCell + clockSize/15, capX + string.len(captionBUY) * fontHeight, yCell + clockSize/15 + fontHeight, context.LEFT);
    
    capX = x + clockSize/4;
    context:drawText(ANALOG_FONT_ID, captionSELL, analog_color_sell, -1, capX, yCell + clockSize/15, capX + string.len(captionBUY) * fontHeight, yCell + clockSize/15 + fontHeight, context.RIGHT);
                     
    capX = x - clockSize/3 - string.len(captionFORCEBUY) * fontHeight;
    context:drawText(ANALOG_FONT_ID, captionFORCEBUY, analog_force_color_buy, -1, capX, yCell + clockSize/3, capX + string.len(captionFORCEBUY) * fontHeight, yCell + clockSize/3 + fontHeight, context.LEFT);

    capX = x + clockSize/3
    context:drawText(ANALOG_FONT_ID, captionFORCESELL, analog_force_color_sell, -1, capX, yCell + clockSize/3, capX + string.len(captionFORCESELL) * fontHeight, yCell + clockSize/3 + fontHeight, context.RIGHT);

    context:drawText(FONT_ID, captionResult, captionResultColor, -1, xCell, yCell + 2*clockSize/3, xCell + xWidth, yCell + 2*clockSize/3 + context:pointsToPixels(font_size), context.CENTER);
    
    context:drawText(ANALOG_FONT_ID, counter["Buy"], analog_color_buy, -1, x - clockSize/2, yCell + 4*clockSize/5, x - clockSize/2 + clockSize, yCell + 4*clockSize/5 + fontHeight, context.LEFT);
    context:drawText(ANALOG_FONT_ID, counter["Neutral"], analog_color_neutral, -1, x - clockSize/2, yCell + 4*clockSize/5, x - clockSize/2 + clockSize, yCell + 4*clockSize/5 + fontHeight, context.CENTER);
    context:drawText(ANALOG_FONT_ID, counter["Sell"], analog_color_sell, -1,  x - clockSize/2, yCell + 4*clockSize/5, x - clockSize/2 + clockSize, yCell + 4*clockSize/5 + fontHeight, context.RIGHT);              

    context:drawText(ANALOG_FONT_ID, captionBUY:lower(), analog_color_buy, -1, x - clockSize/2, yCell + 9*clockSize/10, x - clockSize/2 + clockSize, yCell + 9*clockSize/10 + fontHeight, context.LEFT);
    context:drawText(ANALOG_FONT_ID, captionNeutral:lower(), analog_color_neutral, -1, x - clockSize/2, yCell + 9*clockSize/10, x - clockSize/2 + clockSize, yCell + 9*clockSize/10 + fontHeight, context.CENTER);
    context:drawText(ANALOG_FONT_ID, captionSELL:lower(), analog_color_sell, -1,  x - clockSize/2, yCell + 9*clockSize/10, x - clockSize/2 + clockSize, yCell + 9*clockSize/10 + fontHeight, context.RIGHT);              
                  
    return  x + clockSize/2 + string.len(captionFORCESELL) * fontHeight , y;
end

function toAngle(value, totalValues)
    return value / totalValues * 2 * math.pi - math.pi / 2;
end

function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        context:createFont(FONT_ID, "Arial", 0, context:pointsToPixels(font_size), 0);
        context:createFont(ANALOG_FONT_ID, "Arial", 0, context:pointsToPixels(analog_font_size), 0);
        context:createSolidBrush(ANALOG_BRUSH_BUY, analog_color_buy);
        context:createSolidBrush(ANALOG_BRUSH_SELL, analog_color_sell);
        context:createSolidBrush(ANALOG_BRUSH_FORCE_BUY, analog_force_color_buy);
        context:createSolidBrush(ANALOG_BRUSH_FORCE_SELL, analog_force_color_sell);
        context:createSolidBrush(ANALOG_BRUSH_NEUTRAL, analog_color_neutral);        

        context:createPen(3, context.SOLID, 3, core.rgb(0, 0, 0));
        context:createSolidBrush(6, core.rgb(0, 0, 0));
    
        init = true;
    end

    local x1, y1, x2, y2;
    if displayMethod == "Table" then
        x1, y1 = DrawOsicllators(context, 0, 20);
        x2, y2 = DrawIndicators(context, x1 + 20, 20);    
    elseif displayMethod == "Analog" then
        x1, y1 = DrawAnalog(context, 0, 20, oscillators, "Osicllators");
        x2, y2 = DrawAnalog(context, x1, 20, indicators, "Indicators");     
    end
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    local allLoaded = true;
    for _, data in ipairs(sources) do
        if data.LoadedId == cookie then
            data.Loading = false;
        elseif data.LoadingId == cookie then
            data.Loading = true;
        end
        if data.Loading then
            allLoaded = false;
        end
    end
    if allLoaded then
        instance:updateFrom(0);
    end
end