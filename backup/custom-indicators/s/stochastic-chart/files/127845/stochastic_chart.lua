-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68775

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

function AddAverages(id, name, default)
    indicator.parameters:addString(id, name, "", default);
    indicator.parameters:addStringAlternative(id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative(id, "EMA", "", "EMA");
    indicator.parameters:addStringAlternative(id, "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative(id, "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative(id, "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative(id, "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative(id, "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative(id, "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative(id, "HMA", "", "HMA");
    indicator.parameters:addStringAlternative(id, "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative(id, "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative(id, "T3", "", "T3");
    indicator.parameters:addStringAlternative(id, "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative(id, "Median", "", "Median");
    indicator.parameters:addStringAlternative(id, "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative(id, "REMA", "", "REMA");
    indicator.parameters:addStringAlternative(id, "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative(id, "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative(id, "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative(id, "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative(id, "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative(id, "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative(id, "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative(id, "HPF", "", "HPF");
    indicator.parameters:addStringAlternative(id, "VAMA", "", "VAMA");
end

function CreateAverages(method, source, period)
    if method == "MVA" or method == "EMA" or method == "ARSI" 
        or method == "KAMA" or method == "LWMA" or method == "SMMA"
        or method == "VIDYA"
    then
        --assert(core.indicators:findIndicator(method) ~= nil, method .. " indicator must be installed");
        return core.indicators:create(method, source, period);
    end
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES indicator");
    return core.indicators:create("AVERAGES", source, method, period);
end

function Init()
    indicator:name("Stochastic Chart");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addInteger("ssd_K", "Number of periods for %K", "The number of periods for %K.", 10, 2, 1000);
    indicator.parameters:addInteger("ssd_SD", "%D slowing periods", "The number of periods for slow %D.", 5, 2, 1000);
    indicator.parameters:addInteger("ssd_D", "Number of periods for %D", "The number of periods for %D.", 5, 2, 1000);
    indicator.parameters:addInteger("Level_Stochastic_UP", "Level Stochastic UP", "", 70);
    indicator.parameters:addInteger("Level_Stochastic_DN", "Level Stochastic DN", "", 30);
    indicator.parameters:addDouble("Dev", "Dev", "", 10);

    AddAverages("method", "MA method", "SMMA");
    indicator.parameters:addInteger("XLength", "X Length", "", 12);

    indicator.parameters:addGroup("K Line Style");
    indicator.parameters:addColor("K_color", "Color of K", "Color of K", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("K_width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("K_style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("K_style", core.FLAG_LINE_STYLE);
	indicator.parameters:addGroup("D Line Style");
    indicator.parameters:addColor("D_color", "Color of D", "Color of D", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("D_width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("D_style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("D_style", core.FLAG_LINE_STYLE);
    
	indicator.parameters:addGroup("Avg Line Style");
    indicator.parameters:addColor("Avg_color", "Color of Avg", "Color of Avg", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Avg_width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("Avg_style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("Avg_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("cloud_color", "Cloud Color", "", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("transparency", "Transparency", "", 50, 0, 100);
end

local ssd_K, ssd_SD, ssd_D;
local indi, SK, SD, Level_Stochastic_UP, Level_Stochastic_DN, Dev, xavg, Avg;
local up, dn;

function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    
    Level_Stochastic_UP = instance.parameters.Level_Stochastic_UP;
    Level_Stochastic_DN = instance.parameters.Level_Stochastic_DN;
    Dev = instance.parameters.Dev;

    xavg = CreateAverages(instance.parameters.method, source, instance.parameters.XLength);
    indi = core.indicators:create("SSD", source, instance.parameters.ssd_K, instance.parameters.ssd_SD, instance.parameters.ssd_D);

    SK = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.K_color, 0);
	SK:setWidth(instance.parameters.K_width);
    SK:setStyle(instance.parameters.K_style);
    SD = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.D_color, 0);
	SD:setWidth(instance.parameters.D_width);
    SD:setStyle(instance.parameters.D_style);

    Avg = instance:addStream("Avg", core.Line, name .. ".Avg", "Avg", instance.parameters.Avg_color, 0);
	Avg:setWidth(instance.parameters.Avg_width);
    Avg:setStyle(instance.parameters.Avg_style);

    up = instance:addInternalStream(0, 0);
    dn = instance:addInternalStream(0, 0);
    instance:createChannelGroup("channel", "channel", up, dn, instance.parameters.cloud_color, instance.parameters.transparency);
end

function Update(period, mode)
    indi:update(mode);
    xavg:update(mode);

    Avg[period] = xavg.DATA[period];
    SK[period] = xavg.DATA[period] + Dev * (indi.K[period] - 50) * source:pipSize();
    SD[period] = xavg.DATA[period] + Dev * (indi.D[period] - 50) * source:pipSize();
    up[period] = xavg.DATA[period] + (Level_Stochastic_UP - 50) * source:pipSize() * Dev;
    dn[period] = xavg.DATA[period] + (Level_Stochastic_DN - 50) * source:pipSize() * Dev;
end