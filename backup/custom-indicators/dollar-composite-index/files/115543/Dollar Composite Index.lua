-- Id: 19348
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65196

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
    indicator:name("Dollar Composite Index");
    indicator:description("Dollar Composite Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addBoolean("invert", "Invert", "", false);
end

local O;
local H;
local L;
local C;
local instruments = {};

function Subscribe(instrument, id1, id2, multiplier)
    local val = {};
    val.source = core.host:execute("getSyncHistory", instrument, instance.source:barSize(), instance.source:isBid(), 0, id1, id2);
    val.open = instance:addInternalStream(1, 0);
    val.high = instance:addInternalStream(1, 0);
    val.low = instance:addInternalStream(1, 0);
    val.close = instance:addInternalStream(1, 0);
    val.loading_id = id2;
    val.loaded_id = id1;
    val.loading = true;
    val.multiplier = multiplier;
    return val;
end

function Prepare(only_name)
    local name = profile:id();
    instance:name(name);
    if only_name then
        return ;
    end

    instruments[#instruments + 1] = Subscribe("EUR/USD", 2000 + #instruments, 1000 + #instruments, -1);
    instruments[#instruments + 1] = Subscribe("GBP/USD", 2000 + #instruments, 1000 + #instruments, -1);
    instruments[#instruments + 1] = Subscribe("AUD/USD", 2000 + #instruments, 1000 + #instruments, -1);
    instruments[#instruments + 1] = Subscribe("USD/JPY", 2000 + #instruments, 1000 + #instruments, 1);
    instruments[#instruments + 1] = Subscribe("USD/CAD", 2000 + #instruments, 1000 + #instruments, 1);
    instruments[#instruments + 1] = Subscribe("USD/CHF", 2000 + #instruments, 1000 + #instruments, 1);
    instruments.loading = true;

    O = instance:addStream("O", core.Line, name .. ".O", "O", core.rgb(255, 0, 0), 0);
    O:setPrecision(math.max(2, instance.source:getPrecision()));
    H = instance:addStream("H", core.Line, name .. ".H", "H", core.rgb(255, 0, 0), 0);
    H:setPrecision(math.max(2, instance.source:getPrecision()));
    L = instance:addStream("L", core.Line, name .. ".L", "L", core.rgb(255, 0, 0), 0);
    L:setPrecision(math.max(2, instance.source:getPrecision()));
    C = instance:addStream("C", core.Line, name .. ".C", "C", core.rgb(255, 0, 0), 0);
    C:setPrecision(math.max(2, instance.source:getPrecision()));
    instance:createCandleGroup("DCI", "DCI", O, H, L, C);
end

function GetPeriod(source_period, source, target)
    if source_period < 0 then
        return nil;
    end
    local source_date = source:date(source_period);
    local index = core.findDate(target, source_date, false);
    if index == -1 then
        return nil;
    end
    return index;
end

function CalculateValue(source, period)
    if instance.parameters.invert then
        return source[period] / source[period - 1];
    else
        return (source[period] - source[period - 1]) / source[period];
    end
end

function CalculateInternalStreams(instrument, period)
    local source_period = GetPeriod(period, instance.source, instrument.source);
    if source_period == nil or source_period == 0 then
        return;
    end
    local prev_high = period == 1 and 0 or instrument.high[period - 1];
    local prev_low = period == 1 and 0 or instrument.low[period - 1];
    local prev_close = period == 1 and 0 or instrument.close[period - 1];
    instrument.high[period] = CalculateValue(instrument.source.high, source_period) + prev_high;
    instrument.low[period] = CalculateValue(instrument.source.low, source_period) + prev_low;
    instrument.close[period] = CalculateValue(instrument.source.close, source_period) + prev_close;
    instrument.open[period] = period > 1 and instrument.close[period - 1] or instrument.close[period];
end

function Calculate(period)
    local open = 0;
    local close = 0;
    local high = 0;
    local low = 0;
    for i, instr in ipairs(instruments) do
        open = open + (instr.open[period] or 0) * instr.multiplier;
        high = high + (instr.high[period] or 0) * instr.multiplier;
        low = low + (instr.low[period] or 0) * instr.multiplier;
        close = close + (instr.close[period] or 0) * instr.multiplier;
    end
    return open / #instruments, high / #instruments, low / #instruments, close / #instruments;
end

function Update(period)
    if (period == 0 or instruments.loading) then
        return;
    end
    for i, instr in ipairs(instruments) do
        CalculateInternalStreams(instr, period);
    end

    local open, high, low, close = Calculate(period);
    if instance.parameters.invert then
        O[period] = -open;
        H[period] = -high;
        L[period] = -low;
        C[period] = -close;
    else
        O[period] = open;
        H[period] = high;
        L[period] = low;
        C[period] = close;
    end
end

function AsyncOperationFinished(cookie)
    local loading_count = 0;
    for i, instr in ipairs(instruments) do
        if instr.loading_id == cookie then
            instr.loading = true;
        elseif instr.loaded_id == cookie then
            instr.loading = false;
        end
        if instr.loading then
            loading_count = loading_count + 1;
        end
    end
    instruments.loading = loading_count > 0;

    if instruments.loading then
        core.host:execute("setStatus", "Loading " .. (#instruments - loading_count) .. " / " .. #instruments);
    else
        core.host:execute("setStatus", "Loaded");
        instance:updateFrom(0);
    end

    return core.ASYNC_REDRAW;
end