-- Id: 23046
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67039

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("RSI Channel");
    indicator:description("");
    indicator:setTag("Version", "1");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("RSIPeriod", "RSI Period", "", 14);
    indicator.parameters:addInteger("HighLowPeriod", "High/Low Period", "", 30);
    indicator.parameters:addInteger("T3Period", "T3 Period", "", 8);
    indicator.parameters:addDouble("T3Hot", "T3 Hot", "", 0.7);
    indicator.parameters:addBoolean("T3Original", "T3 Original", "", false);
    
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("rsi_color", "Color of RSI", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("rsi_width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("rsi_style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("rsi_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addBoolean("ShowChannel", "Show Channel", "", true);
    indicator.parameters:addColor("low_color", "Color of Channel Low", "", core.rgb(255, 128, 0));
    indicator.parameters:addInteger("low_width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("low_style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("low_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("high_color", "Color of Channel High", "", core.rgb(255, 128, 0));
    indicator.parameters:addInteger("high_width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("high_style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("high_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addBoolean("ShowZigZag", "Show ZigZag", "", true);
    indicator.parameters:addColor("ZigZag_color", "Color of ZigZag", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("ZigZag_width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("ZigZag_style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("ZigZag_style", core.FLAG_LINE_STYLE);
	
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);


end

local source;
local T3RSIBuffer;
local HighBuffer;
local LowBuffer;
local ZigZagBuffer;

local emas = {};
local alpha;
local c1;
local c2;
local c3;
local c4;
local ShowZigZag;
local HighLowPeriod;
local rsi;

function Prepare(nameOnly) 
    source = instance.source;
    ShowZigZag = instance.parameters.ShowZigZag;
    HighLowPeriod = instance.parameters.HighLowPeriod;
    
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    
    if (nameOnly) then
        return;
    end

    local a = instance.parameters.T3Hot;
    c1 = -a * a * a;
    c2 = 3 * (a * a + a * a * a);
    c3 = -3 * (2 * a * a + a + a * a * a);
    c4 = 1 + 3 * a + a * a * a + 3 * a * a;
    if (instance.parameters.T3Original) then
        alpha = 2.0 / (1.0 + instance.parameters.T3Period);
    else
        alpha = 2.0 / (2.0 + (instance.parameters.T3Period - 1.0) / 2.0);
    end

    T3RSIBuffer = instance:addStream("RSI", core.Line, name, "RSI", instance.parameters.rsi_color, 0);
    T3RSIBuffer:setPrecision(math.max(2, instance.source:getPrecision()));
    T3RSIBuffer:setWidth(instance.parameters.rsi_width);
    T3RSIBuffer:setStyle(instance.parameters.rsi_style);
    rsi = core.indicators:create("RSI", source, instance.parameters.RSIPeriod);
    if instance.parameters.ShowChannel then
        LowBuffer = instance:addStream("Low", core.Line, name, "Low", instance.parameters.low_color, 0);
    LowBuffer:setPrecision(math.max(2, instance.source:getPrecision()));
        LowBuffer:setWidth(instance.parameters.low_width);
        LowBuffer:setStyle(instance.parameters.low_style);
        HighBuffer = instance:addStream("High", core.Line, name, "High", instance.parameters.high_color, 0);
    HighBuffer:setPrecision(math.max(2, instance.source:getPrecision()));
        HighBuffer:setWidth(instance.parameters.high_width);
        HighBuffer:setStyle(instance.parameters.high_style);
    else
        LowBuffer = instance:addInternalStream(0, 0);
        HighBuffer = instance:addInternalStream(0, 0);
    end
    if ShowZigZag then
        ZigZagBuffer = instance:addStream("ZigZag", core.Line, name, "ZigZag", instance.parameters.ZigZag_color, 0);
    ZigZagBuffer:setPrecision(math.max(2, instance.source:getPrecision()));
        ZigZagBuffer:setWidth(instance.parameters.ZigZag_width);
        ZigZagBuffer:setStyle(instance.parameters.ZigZag_style);
    else
        ZigZagBuffer = instance:addInternalStream(0, 0);
    end
    for i = 0, 5 do
        emas[i] = instance:addInternalStream(0, 0);
    end
	
	
	T3RSIBuffer:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	T3RSIBuffer:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  

   T3RSIBuffer:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	T3RSIBuffer:addLevel(100, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 	
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
end

function Update(period, mode)
    rsi:update(core.UpdateLast);
    T3RSIBuffer[period] = iT3(rsi.DATA[period], period);
    if period < HighLowPeriod then
        return;
    end
    LowBuffer[period] = mathex.min(T3RSIBuffer, period - HighLowPeriod, period);
    HighBuffer[period] = mathex.max(T3RSIBuffer, period - HighLowPeriod, period);
    if not ShowZigZag then
        return;
    end

    if (LowBuffer[period] < LowBuffer[period - 1]) then
        local lastZag = ZigZagBuffer:getBookmark(2);
        if lastZag ~= -1 then
            core.drawLine(ZigZagBuffer, core.range(lastZag, period), ZigZagBuffer[lastZag], lastZag, LowBuffer[period], period);
        else
            ZigZagBuffer[period] = LowBuffer[period];
        end
        ZigZagBuffer:setBookmark(1, period);
        return;
    end
    if (HighBuffer[period] > HighBuffer[period - 1]) then
        local lastZag = ZigZagBuffer:getBookmark(1);
        if lastZag ~= -1 then
            core.drawLine(ZigZagBuffer, core.range(lastZag, period), ZigZagBuffer[lastZag], lastZag, HighBuffer[period], period);
        else
            ZigZagBuffer[period] = HighBuffer[period];
        end
        ZigZagBuffer:setBookmark(2, period);
    end
end

function iT3(price, period)
   if (period == 0) then
      emas[0][period] = price;
      emas[1][period] = price;
      emas[2][period] = price;
      emas[3][period] = price;
      emas[4][period] = price;
      emas[5][period] = price;
   else
      emas[0][period] = emas[0][period - 1]+alpha*(price -emas[0][period - 1]);
      emas[1][period] = emas[1][period - 1]+alpha*(emas[0][period]-emas[1][period - 1]);
      emas[2][period] = emas[2][period - 1]+alpha*(emas[1][period]-emas[2][period - 1]);
      emas[3][period] = emas[3][period - 1]+alpha*(emas[2][period]-emas[3][period - 1]);
      emas[4][period] = emas[4][period - 1]+alpha*(emas[3][period]-emas[4][period - 1]);
      emas[5][period] = emas[5][period - 1]+alpha*(emas[4][period]-emas[5][period - 1]);
   end
   return(c1*emas[5][period] + c2*emas[4][period] + c3*emas[3][period] + c4*emas[2][period]);
end