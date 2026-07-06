-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=71208
-- More information about this indicator can be found at:
--https://fxcodebase.com/code/viewtopic.php?f=17&t=71208

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+


function Init()
    indicator:name("Pivot Pscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addString("TF","Time Frame", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_BARPERIODS);

    indicator.parameters:addString("CalcMode", "Calculation Mode", "", "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", "Pivot", "", "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", "Camarilla", "", "Camarilla");
    indicator.parameters:addStringAlternative("CalcMode", "Woodie", "", "Woodie");
    indicator.parameters:addStringAlternative("CalcMode", "Fibonacci", "", "Fibonacci");
    indicator.parameters:addStringAlternative("CalcMode", "Floor", "", "Floor");
    indicator.parameters:addStringAlternative("CalcMode", "FibonacciR", "", "FibonacciR")

    indicator.parameters:addColor("p_color", "P Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("p_width", "P Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("p_style", "P Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("p_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("r1_color", "R1 Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("r1_width", "R1 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("r1_style", "R1 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("r1_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("r2_color", "R2 Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("r2_width", "R2 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("r2_style", "R2 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("r2_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("r3_color", "R3 Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("r3_width", "R3 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("r3_style", "R3 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("r3_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("s1_color", "S1 Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("s1_width", "S1 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("s1_style", "S1 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("s1_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("s2_color", "S2 Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("s2_width", "S2 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("s2_style", "S2 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("s2_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("s3_color", "S3 Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("s3_width", "S3 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("s3_style", "S3 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("s3_style", core.FLAG_LINE_STYLE);
end

local tradingWeekOffset, tradingDayOffset
local source, pivot;
local p, r1, r2, r3, s1, s2, s3;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end

    pivot = core.indicators:create("PIVOT", source, instance.parameters.TF, instance.parameters.CalcMode, "HIST");

    p = instance:addStream("p", core.Line, "Pivot Wave", "Pivot Wave", instance.parameters.p_color, 0, 0);
    p:setWidth(instance.parameters.p_width);
    p:setStyle(instance.parameters.p_style);

    r1 = instance:addStream("r1", core.Line, "R1 Wave", "R1 Wave", instance.parameters.r1_color, 0, 0);
    r1:setWidth(instance.parameters.r1_width);
    r1:setStyle(instance.parameters.r1_style);
    
    r2 = instance:addStream("r2", core.Line, "R2 Wave", "R2 Wave", instance.parameters.r2_color, 0, 0);
    r2:setWidth(instance.parameters.r2_width);
    r2:setStyle(instance.parameters.r2_style);

    r3 = instance:addStream("r3", core.Line, "R3 Wave", "R3 Wave", instance.parameters.r3_color, 0, 0);
    r3:setWidth(instance.parameters.r3_width);
    r3:setStyle(instance.parameters.r3_style);

    s1 = instance:addStream("s1", core.Line, "S1 Wave", "S1 Wave", instance.parameters.s1_color, 0, 0);
    s1:setWidth(instance.parameters.s1_width);
    s1:setStyle(instance.parameters.s1_style);

    s2 = instance:addStream("s2", core.Line, "S2 Wave", "S2 Wave", instance.parameters.s2_color, 0, 0);
    s2:setWidth(instance.parameters.s2_width);
    s2:setStyle(instance.parameters.s2_style);

    s3 = instance:addStream("s3", core.Line, "S3 Wave", "S3 Wave", instance.parameters.s3_color, 0, 0);
    s3:setWidth(instance.parameters.s3_width);
    s3:setStyle(instance.parameters.s3_style);
	
    core.host:execute ("setTimer", 1, 5);
    tradingWeekOffset = core.host:execute("getTradingWeekOffset");
    tradingDayOffset = core.host:execute("getTradingDayOffset");
end

local recalcNeeded = false;
local current_day;
function Update(period, mode)
    pivot:update(mode);
 
    local date = core.getcandle("D1", source:date(period), tradingDayOffset, tradingWeekOffset);
    if date ~= current_day then
        return;
    end    
    p[period] = source.close[period] - pivot.P[period];
    s1[period] = source.close[period] - pivot.S1[period];
    s2[period] = source.close[period] - pivot.S2[period];
    s3[period] = source.close[period] - pivot.S3[period];
    r1[period] = source.close[period] - pivot.R1[period];
    r2[period] = source.close[period] - pivot.R2[period];
    r3[period] = source.close[period] - pivot.R3[period];
end

function AsyncOperationFinished(cookie)
    if cookie == 1 then
        if source:size() > 0 then
            current_day = core.getcandle("D1", source:date(NOW), tradingDayOffset, tradingWeekOffset)
        end
        instance:updateFrom(0);
    end
end