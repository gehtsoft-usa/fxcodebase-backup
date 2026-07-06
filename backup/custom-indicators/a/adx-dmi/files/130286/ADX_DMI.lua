
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69238

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
    indicator:name("ADX DMI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addInteger("Period", "ADX Period", "Period", 14);
    indicator.parameters:addInteger("DMI", "DMI Period", "DMI Period", 14, 1, 1000);

    indicator.parameters:addColor("adx_color", "ADX Color", "ADX Color", core.colors().Red);
    indicator.parameters:addInteger("adx_width", "ADX Width", "ADX Width", 1, 1, 5);
    indicator.parameters:addInteger("adx_style", "ADX Style", "ADX Style", core.LINE_SOLID);
    indicator.parameters:setFlag("adx_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("dmip_color", "DMI+ Color", "DMI+ Color", core.colors().Blue);
    indicator.parameters:addInteger("dmip_width", "DMI+ Width", "DMI+ Width", 1, 1, 5);
    indicator.parameters:addInteger("dmip_style", "DMI+ Style", "DMI+ Style", core.LINE_SOLID);
    indicator.parameters:setFlag("dmip_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("dmim_color", "DMI- Color", "DMI- Color", core.colors().Green);
    indicator.parameters:addInteger("dmim_width", "DMI- Width", "DMI- Width", 1, 1, 5);
    indicator.parameters:addInteger("dmim_style", "DMI- Style", "DMI- Style", core.LINE_SOLID);
    indicator.parameters:setFlag("dmim_style", core.FLAG_LINE_STYLE);
end

local source, adx, out, adx_indi, dmi, dmip, dmim;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end

    adx_indi = core.indicators:create("ADX", source, instance.parameters.Period);
    dmi = core.indicators:create("DMI", source, instance.parameters.DMI);
    adx = instance:addStream("ADX", core.Line, "ADX", "ADX", instance.parameters.adx_color, 0, 0);
    adx:setWidth(instance.parameters.adx_width);
    adx:setStyle(instance.parameters.adx_style);

    dmip = instance:addStream("DMI+", core.Line, "DMI+", "DMI+", instance.parameters.dmip_color, 0, 0);
    dmip:setWidth(instance.parameters.dmip_width);
    dmip:setStyle(instance.parameters.dmip_style);

    dmim = instance:addStream("DMI-", core.Line, "DMI-", "DMI-", instance.parameters.dmim_color, 0, 0);
    dmim:setWidth(instance.parameters.dmim_width);
    dmim:setStyle(instance.parameters.dmim_style);
end

function Update(period, mode)
    adx_indi:update(mode);
    dmi:update(mode);
    adx[period] = adx_indi.DATA[period];
    dmip[period] = dmi.DIP[period];
    dmim[period] = dmi.DIM[period];
end