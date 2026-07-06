-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68435

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
    indicator:name("Davits Pivot");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addDate("startDate", "Start", "", -100);
    indicator.parameters:addDate("endDate", "End", "", 0);

    indicator.parameters:addString("pivot_meth", "Pivot Method", "", "HLC")
    indicator.parameters:addStringAlternative("pivot_meth", "Avg of High, Low, Close", "", "HLC");
    indicator.parameters:addStringAlternative("pivot_meth", "Avg of High, Low, Close, Close", "", "HLCC");
    indicator.parameters:addStringAlternative("pivot_meth", "Avg of High, Low, Open, Close", "", "HLOC");
    indicator.parameters:addStringAlternative("pivot_meth", "Avg of High, Low, Open, Open", "", "HLOO");
    indicator.parameters:addStringAlternative("pivot_meth", "Avg of High, Low, Open", "", "HLO");
    indicator.parameters:addBoolean("pivot_fib", "Choose Fib(true) or Standard(false)", "", true)

    indicator.parameters:addInteger("LineStyle", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("LineStyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("LineStylePP", "Line Style PP", "", core.LINE_SOLID);
    indicator.parameters:setFlag("LineStylePP", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("ColorP", "Color P", "", core.colors().Yellow);
    indicator.parameters:addColor("ColorR38", "Color R38", "", core.colors().Magenta);
    indicator.parameters:addColor("ColorS38", "Color S38", "", core.colors().Magenta);
    indicator.parameters:addColor("ColorR61", "Color R61", "", core.colors().LimeGreen);
    indicator.parameters:addColor("ColorS61", "Color S61", "", core.colors().LimeGreen);
    indicator.parameters:addColor("ColorR78", "Color R78", "", core.colors().Red);
    indicator.parameters:addColor("ColorS78", "Color S78", "", core.colors().Red);
    indicator.parameters:addColor("ColorR100", "Color R100", "", core.colors().Aqua);
    indicator.parameters:addColor("ColorS100", "Color S100", "", core.colors().Aqua);
    indicator.parameters:addColor("ColorR138", "Color R138", "", core.colors().Orange);
    indicator.parameters:addColor("ColorS138", "Color S138", "", core.colors().Orange);
    indicator.parameters:addColor("ColorR161", "Color R161", "", core.colors().Black);
    indicator.parameters:addColor("ColorS161", "Color S161", "", core.colors().Black);
    indicator.parameters:addColor("ColorR200", "Color R200", "", core.colors().Brown);
    indicator.parameters:addColor("ColorS200", "Color S200", "", core.colors().Brown);
end

local Res100, R61, R38, Pivot, S38, Supp61, Supp100, Res78, Supp78, Res138, Supp138, Res161, Supp161, Res200, Supp200;
local source, tf_source;
local LOADING_STARTED_ID = 1;
local LOADING_FINISHED_ID = 2;
local startDate, endDate, pivot_meth, pivot_fib;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    pivot_meth = instance.parameters.pivot_meth;
    startDate = instance.parameters.startDate;
    endDate = instance.parameters.endDate;
    pivot_fib = instance.parameters.pivot_fib;

    tf_source = core.host:execute("getSyncHistory", source:instrument(), "H1", source:isBid(), 0, LOADING_FINISHED_ID, LOADING_STARTED_ID);

    Pivot = instance:addStream("Pivot", core.Line, "Pivot", "Pivot", instance.parameters.ColorP, 0, 0);
    Pivot:setStyle(instance.parameters.LineStylePP);
    R38 = instance:addStream("R38", core.Line, "R38", "R38", instance.parameters.ColorR38, 0, 0);
    R38:setStyle(instance.parameters.LineStyle);
    R61 = instance:addStream("R61", core.Line, "R61", "R61", instance.parameters.ColorR61, 0, 0);
    R61:setStyle(instance.parameters.LineStyle);
    R78 = instance:addStream("Res78", core.Line, "Res78", "Res78", instance.parameters.ColorR78, 0, 0);
    R78:setStyle(instance.parameters.LineStyle);
    R100 = instance:addStream("Res100", core.Line, "Res100", "Res100", instance.parameters.ColorR100, 0, 0);
    R100:setStyle(instance.parameters.LineStyle);
    R138 = instance:addStream("Res138", core.Line, "Res138", "Res138", instance.parameters.ColorR138, 0, 0);
    R138:setStyle(instance.parameters.LineStyle);
    R161 = instance:addStream("Res161", core.Line, "Res161", "Res161", instance.parameters.ColorR161, 0, 0);
    R161:setStyle(instance.parameters.LineStyle);
    R200 = instance:addStream("Res200", core.Line, "Res200", "Res200", instance.parameters.ColorR200, 0, 0);
    R200:setStyle(instance.parameters.LineStyle);
    S38 = instance:addStream("S38", core.Line, "S38", "S38", instance.parameters.ColorS38, 0, 0);
    S38:setStyle(instance.parameters.LineStyle);
    S61 = instance:addStream("Supp61", core.Line, "Supp61", "Supp61", instance.parameters.ColorS61, 0, 0);
    S61:setStyle(instance.parameters.LineStyle);
    S78 = instance:addStream("Supp78", core.Line, "Supp78", "Supp78", instance.parameters.ColorS78, 0, 0);
    S78:setStyle(instance.parameters.LineStyle);
    S100 = instance:addStream("Supp100", core.Line, "Supp100", "Supp100", instance.parameters.ColorS100, 0, 0);
    S100:setStyle(instance.parameters.LineStyle);
    S138 = instance:addStream("Supp138", core.Line, "Supp138", "Supp138", instance.parameters.ColorS138, 0, 0);
    S138:setStyle(instance.parameters.LineStyle);
    S161 = instance:addStream("Supp161", core.Line, "Supp161", "Supp161", instance.parameters.ColorS161, 0, 0);
    S161:setStyle(instance.parameters.LineStyle);
    S200 = instance:addStream("Supp200", core.Line, "Supp200", "Supp200", instance.parameters.ColorS200, 0, 0);
    S200:setStyle(instance.parameters.LineStyle);
end

function Update(period, mode)
    local endPeriod = core.findDate(tf_source, endDate, false); 
    if endPeriod < 0 then
        return;
    end
    local startPeriod = core.findDate(tf_source, startDate, false); 
    if startPeriod < 0 then
        startPeriod = 0;
    end
    wopen = tf_source.open[startPeriod];
    wclose = tf_source.close[endPeriod];
    whigh, wlow = mathex.minmax(tf_source, core.range(startPeriod, endPeriod));

    local calPivot;
    if pivot_meth == "HLC" then
        calPivot = (whigh + wlow + wclose) / 3;
    elseif pivot_meth == "HLCC" then
        calPivot = (whigh + wlow + wclose + wclose) / 4;
    elseif pivot_meth == "HLOC" then
        calPivot = (whigh + wlow + wclose + wopen) / 4;
    elseif pivot_meth == "HLOO" then
        calPivot = (whigh + wlow + wopen + wopen) / 4;
    elseif pivot_meth == "HLO" then
        calPivot = (whigh + wlow + wopen) / 3;
    end
    local calRange = (whigh - wlow);
    if pivot_fib then
        R38[period]  = calRange*0.382+calPivot;
        R61[period]  = calRange*0.618+calPivot;
        R78[period]  = calRange*0.786+calPivot;
        R100[period] = calRange*1.00+calPivot;
        R138[period] = calRange*1.382+calPivot;
        R161[period] = calRange*1.618+calPivot;
        R200[period] = calRange*2.00+calPivot;

        S38[period]  = calPivot-calRange*0.382;
        S61[period]  = calPivot-calRange*0.618;
        S78[period]  = calPivot-calRange*0.786;
        S100[period] = calPivot-calRange*1.00;
        S138[period] = calPivot-calRange*1.382;
        S161[period] = calPivot-calRange*1.618;
        S200[period] = calPivot-calRange*2.00;
    else
        R38[period]=2*calPivot-wlow;
        R61[period]=calPivot+calRange;
        R100[period]=R61[period]+calRange;
        S38[period]=2*calPivot-whigh;
        S61[period]=calPivot-calRange;
        S100[period]=S61[period]-calRange;
    end
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == LOADING_FINISHED_ID then
        instance:updateFrom(0);
    end
end
