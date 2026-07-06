-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=70967

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--+------------------------------------------------------------------+


function Init()
    indicator:name("Manual Levels Plotter");
    indicator:description("Manual Levels Plotter");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addDouble("a1", "Horizontal Line 1", "", 0);
    indicator.parameters:addBoolean("b1", "Highlight Line 1?", "", false);
    indicator.parameters:addDouble("a2", "Horizontal Line 2", "", 0);
    indicator.parameters:addBoolean("b2", "Highlight Line 2?", "", false);
    indicator.parameters:addDouble("a3", "Horizontal Line 3", "", 0);
    indicator.parameters:addBoolean("b3", "Highlight Line 3?", "", false);
    indicator.parameters:addDouble("a4", "Horizontal Line 4", "", 0);
    indicator.parameters:addBoolean("b4", "Highlight Line 4?", "", false);
    indicator.parameters:addDouble("a5", "Horizontal Line 5", "", 0);
    indicator.parameters:addBoolean("b5", "Highlight Line 5?", "", false);
    indicator.parameters:addDouble("a6", "Horizontal Line 6", "", 0);
    indicator.parameters:addBoolean("b6", "Highlight Line 6?", "", false);
    indicator.parameters:addDouble("a7", "Horizontal Line 7", "", 0);
    indicator.parameters:addBoolean("b7", "Highlight Line 7?", "", false);
    indicator.parameters:addDouble("a8", "Horizontal Line 8", "", 0);
    indicator.parameters:addBoolean("b8", "Highlight Line 8?", "", false);
    indicator.parameters:addDouble("a9", "Horizontal Line 9", "", 0);
    indicator.parameters:addBoolean("b9", "Highlight Line 9?", "", false);
    indicator.parameters:addDouble("a10", "Horizontal Line 10", "", 0);
    indicator.parameters:addBoolean("b10", "Highlight Line 10?", "", false);
    indicator.parameters:addDouble("a11", "Horizontal Line 11", "", 0);
    indicator.parameters:addBoolean("b11", "Highlight Line 11?", "", false);
    indicator.parameters:addDouble("a12", "Horizontal Line 12", "", 0);
    indicator.parameters:addBoolean("b12", "Highlight Line 12?", "", false);
    indicator.parameters:addDouble("a13", "Horizontal Line 13", "", 0);
    indicator.parameters:addBoolean("b13", "Highlight Line 13?", "", false);
    indicator.parameters:addDouble("a14", "Horizontal Line 14", "", 0);
    indicator.parameters:addBoolean("b14", "Highlight Line 14?", "", false);
    indicator.parameters:addDouble("a15", "Horizontal Line 15", "", 0);
    indicator.parameters:addBoolean("b15", "Highlight Line 15?", "", false);
    indicator.parameters:addDouble("a16", "Horizontal Line 16", "", 0);
    indicator.parameters:addBoolean("b16", "Highlight Line 16?", "", false);
    indicator.parameters:addDouble("a17", "Horizontal Line 17", "", 0);
    indicator.parameters:addBoolean("b17", "Highlight Line 17?", "", false);
    indicator.parameters:addDouble("a18", "Horizontal Line 18", "", 0);
    indicator.parameters:addBoolean("b18", "Highlight Line 18?", "", false);
    indicator.parameters:addDouble("a19", "Horizontal Line 19", "", 0);
    indicator.parameters:addBoolean("b19", "Highlight Line 19?", "", false);
    indicator.parameters:addDouble("a20", "Horizontal Line 20", "", 0);
    indicator.parameters:addBoolean("b20", "Highlight Line 20?", "", false);
    indicator.parameters:addDouble("a21", "Horizontal Line 21", "", 0);
    indicator.parameters:addBoolean("b21", "Highlight Line 21?", "", false);
    indicator.parameters:addDouble("a22", "Horizontal Line 22", "", 0);
    indicator.parameters:addBoolean("b22", "Highlight Line 22?", "", false);
    indicator.parameters:addDouble("a23", "Horizontal Line 23", "", 0);
    indicator.parameters:addBoolean("b23", "Highlight Line 23?", "", false);
    indicator.parameters:addDouble("a24", "Horizontal Line 24", "", 0);
    indicator.parameters:addBoolean("b24", "Highlight Line 24?", "", false);
    indicator.parameters:addDouble("a25", "Horizontal Line 25", "", 0);
    indicator.parameters:addBoolean("b25", "Highlight Line 25?", "", false);
    indicator.parameters:addDouble("a26", "Horizontal Line 26", "", 0);
    indicator.parameters:addBoolean("b26", "Highlight Line 26?", "", false);
    indicator.parameters:addDouble("a27", "Horizontal Line 27", "", 0);
    indicator.parameters:addBoolean("b27", "Highlight Line 27?", "", false);
    indicator.parameters:addDouble("a28", "Horizontal Line 28", "", 0);
    indicator.parameters:addBoolean("b28", "Highlight Line 28?", "", false);
    indicator.parameters:addDouble("a29", "Horizontal Line 29", "", 0);
    indicator.parameters:addBoolean("b29", "Highlight Line 29?", "", false);
    indicator.parameters:addDouble("a30", "Horizontal Line 30", "", 0);
    indicator.parameters:addBoolean("b30", "Highlight Line 30?", "", false);
end

local source;
local params = {};
local out;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    params["a1"] = instance.parameters.a1;
    params["b1"] = instance.parameters.b1;
    params["a2"] = instance.parameters.a2;
    params["b2"] = instance.parameters.b2;
    params["a3"] = instance.parameters.a3;
    params["b3"] = instance.parameters.b3;
    params["a4"] = instance.parameters.a4;
    params["b4"] = instance.parameters.b4;
    params["a5"] = instance.parameters.a5;
    params["b5"] = instance.parameters.b5;
    params["a6"] = instance.parameters.a6;
    params["b6"] = instance.parameters.b6;
    params["a7"] = instance.parameters.a7;
    params["b7"] = instance.parameters.b7;
    params["a8"] = instance.parameters.a8;
    params["b8"] = instance.parameters.b8;
    params["a9"] = instance.parameters.a9;
    params["b9"] = instance.parameters.b9;
    params["a10"] = instance.parameters.a10;
    params["b10"] = instance.parameters.b10;
    params["a11"] = instance.parameters.a11;
    params["b11"] = instance.parameters.b11;
    params["a12"] = instance.parameters.a12;
    params["b12"] = instance.parameters.b12;
    params["a13"] = instance.parameters.a13;
    params["b13"] = instance.parameters.b13;
    params["a14"] = instance.parameters.a14;
    params["b14"] = instance.parameters.b14;
    params["a15"] = instance.parameters.a15;
    params["b15"] = instance.parameters.b15;
    params["a16"] = instance.parameters.a16;
    params["b16"] = instance.parameters.b16;
    params["a17"] = instance.parameters.a17;
    params["b17"] = instance.parameters.b17;
    params["a18"] = instance.parameters.a18;
    params["b18"] = instance.parameters.b18;
    params["a19"] = instance.parameters.a19;
    params["b19"] = instance.parameters.b19;
    params["a20"] = instance.parameters.a20;
    params["b20"] = instance.parameters.b20;
    params["a21"] = instance.parameters.a21;
    params["b21"] = instance.parameters.b21;
    params["a22"] = instance.parameters.a22;
    params["b22"] = instance.parameters.b22;
    params["a23"] = instance.parameters.a23;
    params["b23"] = instance.parameters.b23;
    params["a24"] = instance.parameters.a24;
    params["b24"] = instance.parameters.b24;
    params["a25"] = instance.parameters.a25;
    params["b25"] = instance.parameters.b25;
    params["a26"] = instance.parameters.a26;
    params["b26"] = instance.parameters.b26;
    params["a27"] = instance.parameters.a27;
    params["b27"] = instance.parameters.b27;
    params["a28"] = instance.parameters.a28;
    params["b28"] = instance.parameters.b28;
    params["a29"] = instance.parameters.a29;
    params["b29"] = instance.parameters.b29;
    params["a30"] = instance.parameters.a30;
    params["b30"] = instance.parameters.b30;
    out = instance:addStream("out", core.Line, "Out", "Out", core.colors().Black, 0, 0);
    out:addLevel(params["a1"], core.LINE_SOLID, 2, params["b1"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a2"], core.LINE_SOLID, 2, params["b2"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a3"], core.LINE_SOLID, 2, params["b3"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a4"], core.LINE_SOLID, 2, params["b4"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a5"], core.LINE_SOLID, 2, params["b5"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a6"], core.LINE_SOLID, 2, params["b6"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a7"], core.LINE_SOLID, 2, params["b7"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a8"], core.LINE_SOLID, 2, params["b8"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a9"], core.LINE_SOLID, 2, params["b9"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a10"], core.LINE_SOLID, 2, params["b10"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a11"], core.LINE_SOLID, 2, params["b11"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a12"], core.LINE_SOLID, 2, params["b12"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a13"], core.LINE_SOLID, 2, params["b13"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a14"], core.LINE_SOLID, 2, params["b14"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a15"], core.LINE_SOLID, 2, params["b15"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a16"], core.LINE_SOLID, 2, params["b16"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a17"], core.LINE_SOLID, 2, params["b17"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a18"], core.LINE_SOLID, 2, params["b18"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a19"], core.LINE_SOLID, 2, params["b19"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a20"], core.LINE_SOLID, 2, params["b20"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a21"], core.LINE_SOLID, 2, params["b21"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a22"], core.LINE_SOLID, 2, params["b22"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a23"], core.LINE_SOLID, 2, params["b23"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a24"], core.LINE_SOLID, 2, params["b24"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a25"], core.LINE_SOLID, 2, params["b25"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a26"], core.LINE_SOLID, 2, params["b26"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a27"], core.LINE_SOLID, 2, params["b27"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a28"], core.LINE_SOLID, 2, params["b28"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a29"], core.LINE_SOLID, 2, params["b29"] and core.colors().Red or core.colors().Yellow)
    out:addLevel(params["a30"], core.LINE_SOLID, 2, params["b30"] and core.colors().Red or core.colors().Yellow)
end

function Update(period, mode)
end
