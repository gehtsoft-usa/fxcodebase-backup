-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69054

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
    indicator:name("Financial Freedom with Forex");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addInteger("RiskModel", "Risk Model", "", 1);

    indicator.parameters:addColor("ExtMapBuffer1_color", "Line 1 Color", "Color", core.colors().Magenta);
    indicator.parameters:addInteger("ExtMapBuffer1_width", "Line 1 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("ExtMapBuffer1_style", "Line 1 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("ExtMapBuffer1_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("ExtMapBuffer2_color", "Line 2 Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("ExtMapBuffer2_width", "Line 2 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("ExtMapBuffer2_style", "Line 2 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("ExtMapBuffer2_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("ExtMapBuffer3_color", "Line 3 Color", "Color", core.colors().Silver);
    indicator.parameters:addInteger("ExtMapBuffer3_width", "Line 3 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("ExtMapBuffer3_style", "Line 3 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("ExtMapBuffer3_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("ExtMapBuffer4_color", "Line 4 Color", "Color", core.colors().Silver);
    indicator.parameters:addInteger("ExtMapBuffer4_width", "Line 4 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("ExtMapBuffer4_style", "Line 4 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("ExtMapBuffer4_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("ExtMapBuffer5_color", "Line 5 Color", "Color", core.colors().Silver);
    indicator.parameters:addInteger("ExtMapBuffer5_width", "Line 5 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("ExtMapBuffer5_style", "Line 5 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("ExtMapBuffer5_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("ExtMapBuffer6_color", "Line 6 Color", "Color", core.colors().Silver);
    indicator.parameters:addInteger("ExtMapBuffer6_width", "Line 6 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("ExtMapBuffer6_style", "Line 6 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("ExtMapBuffer6_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("ExtMapBuffer7_color", "Line 7 Color", "Color", core.colors().Blue);
    indicator.parameters:addInteger("ExtMapBuffer7_width", "Line 7 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("ExtMapBuffer7_style", "Line 7 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("ExtMapBuffer7_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("ExtMapBuffer8_color", "Line 8 Color", "Color", core.colors().Silver);
    indicator.parameters:addInteger("ExtMapBuffer8_width", "Line 8 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("ExtMapBuffer8_style", "Line 8 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("ExtMapBuffer8_style", core.FLAG_LINE_STYLE);
end

local source;
local ExtMapBuffer1, ExtMapBuffer2, ExtMapBuffer3, ExtMapBuffer4, ExtMapBuffer5, ExtMapBuffer6, ExtMapBuffer7, ExtMapBuffer8;
local ma1, ma2;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    ExtMapBuffer1 = instance:addStream("ExtMapBuffer1", core.Line, "55 SMA Median", "55 SMA Median", instance.parameters.ExtMapBuffer1_color, 0, 0);
    ExtMapBuffer1:setWidth(instance.parameters.ExtMapBuffer1_width);
    ExtMapBuffer1:setStyle(instance.parameters.ExtMapBuffer1_style);

    ExtMapBuffer2 = instance:addStream("ExtMapBuffer2", core.Line, "8 SMA Close", "8 SMA Close", instance.parameters.ExtMapBuffer2_color, 0, 0);
    ExtMapBuffer2:setWidth(instance.parameters.ExtMapBuffer2_width);
    ExtMapBuffer2:setStyle(instance.parameters.ExtMapBuffer2_style);

    ExtMapBuffer3 = instance:addStream("ExtMapBuffer3", core.Line, "1st FibLine up", "1st FibLine up", instance.parameters.ExtMapBuffer3_color, 0, 0);
    ExtMapBuffer3:setWidth(instance.parameters.ExtMapBuffer3_width);
    ExtMapBuffer3:setStyle(instance.parameters.ExtMapBuffer3_style);

    ExtMapBuffer4 = instance:addStream("ExtMapBuffer4", core.Line, "2nd FibLine up", "2nd FibLine up", instance.parameters.ExtMapBuffer4_color, 0, 0);
    ExtMapBuffer4:setWidth(instance.parameters.ExtMapBuffer4_width);
    ExtMapBuffer4:setStyle(instance.parameters.ExtMapBuffer4_style);

    ExtMapBuffer5 = instance:addStream("ExtMapBuffer5", core.Line, "1st FibLine down", "1st FibLine down", instance.parameters.ExtMapBuffer5_color, 0, 0);
    ExtMapBuffer5:setWidth(instance.parameters.ExtMapBuffer5_width);
    ExtMapBuffer5:setStyle(instance.parameters.ExtMapBuffer5_style);

    ExtMapBuffer6 = instance:addStream("ExtMapBuffer6", core.Line, "2nd FibLine down", "2nd FibLine down", instance.parameters.ExtMapBuffer6_color, 0, 0);
    ExtMapBuffer6:setWidth(instance.parameters.ExtMapBuffer6_width);
    ExtMapBuffer6:setStyle(instance.parameters.ExtMapBuffer6_style);

    ExtMapBuffer7 = instance:addStream("ExtMapBuffer7", core.Line, "Slope Change", "Slope Change", instance.parameters.ExtMapBuffer7_color, 0, 0);
    ExtMapBuffer7:setWidth(instance.parameters.ExtMapBuffer7_width);
    ExtMapBuffer7:setStyle(instance.parameters.ExtMapBuffer7_style);

    ExtMapBuffer8 = instance:addStream("ExtMapBuffer8", core.Line, "", "", instance.parameters.ExtMapBuffer8_color, 0, 0);
    ExtMapBuffer8:setWidth(instance.parameters.ExtMapBuffer8_width);
    ExtMapBuffer8:setStyle(instance.parameters.ExtMapBuffer8_style);
    ma1 = core.indicators:create("MVA", source.median, 55);
    ma2 = core.indicators:create("MVA", source.close, 8);
end
function Update(period, mode)
    ma1:update(mode);
    ma2:update(mode);

    ExtMapBuffer1[period] = ma1.DATA[period]
    ExtMapBuffer2[period] = ma2.DATA[period];
    if (period < 8 ) then
        return;
    end
    ExtMapBuffer7[period] = source.close[period - 8];
    if (RiskModel == 1) then
        ExtMapBuffer3[period] = ExtMapBuffer1[period] + 89 * source:pipSize();  
        ExtMapBuffer4[period] = ExtMapBuffer1[period] + 144 * source:pipSize();

        ExtMapBuffer5[period] = ExtMapBuffer1[period] - 89 * source:pipSize();
        ExtMapBuffer6[period] = ExtMapBuffer1[period] - 144 * source:pipSize();
    elseif (RiskModel == 2) then
        ExtMapBuffer3[period] = ExtMapBuffer1[period] + 144 * source:pipSize();
        ExtMapBuffer4[period] = ExtMapBuffer1[period] + 233 * source:pipSize();

        ExtMapBuffer5[period] = ExtMapBuffer1[period] - 144 * source:pipSize();
        ExtMapBuffer6[period] = ExtMapBuffer1[period] - 233 * source:pipSize();
    elseif (RiskModel == 3) then
        ExtMapBuffer3[period] = ExtMapBuffer1[period] + 233 * source:pipSize();
        ExtMapBuffer4[period] = ExtMapBuffer1[period] + 377 * source:pipSize();

        ExtMapBuffer5[period] = ExtMapBuffer1[period] - 233 * source:pipSize();
        ExtMapBuffer6[period] = ExtMapBuffer1[period] - 377 * source:pipSize();
    end
end