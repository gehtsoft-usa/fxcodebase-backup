-- Id: 411
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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Moving Average Envelope (New Version)");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods for Moving Average", "", 14);
    indicator.parameters:addString("MET", "Moving Average Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "MVA");
    indicator.parameters:addStringAlternative("MET", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MET", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MET", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MET", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MET", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MET", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MET", "Wilders*", "", "WMA");

    indicator.parameters:addDouble("B", "Band Width", "", 25);
    indicator.parameters:addString("BWU", "Band Width Units", "", "%%");
    indicator.parameters:addStringAlternative("BWU", "In 1/100 of percent", "", "%%");
    indicator.parameters:addStringAlternative("BWU", "In pips", "", "pip(s)");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addBoolean("SM", "Show MA line", "", true);
    indicator.parameters:addColor("MVA_color", "Color of MA line", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("B_color", "Color of Band", "", core.rgb(0, 0, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local N;
local B;
local BWU;
local MET;
local SM;

local first;
local source = nil;
local IND;

-- Streams block
local MVA = nil;
local UB = nil;
local LB = nil;

-- Routine
 function Prepare(nameOnly) 
    N = instance.parameters.N;
    B = instance.parameters.B;
    BWU = instance.parameters.BWU;
    MET = instance.parameters.MET;
    SM = instance.parameters.SM;
    source = instance.source;
    assert(core.indicators:findIndicator(MET) ~= nil, MET .. " indicator must be installed");
    IND = core.indicators:create(MET, source, N);
    first = IND.DATA:first();

    local name = profile:id() .. "(" .. source:name() .. "," .. MET .. "(" .. N .. ")," .. B .. BWU .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    if BWU == "%%" then
        BWU = 1;
    else
        BWU = 2;
        B = B * source:pipSize();
    end

    if SM then
        MVA = instance:addStream("MVA", core.Line, name .. ".MVA", "MVA", instance.parameters.MVA_color, first);
    end
    UB = instance:addStream("UB", core.Line, name .. ".UB", "UB", instance.parameters.B_color, first);
    LB = instance:addStream("LB", core.Line, name .. ".LB", "LB", instance.parameters.B_color, first);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period >= first then
        IND:update(mode);

        local d = IND.DATA[period];
        local s;

        if BWU == 1 then
            s = d * B / 10000;
        else
            s = B;
        end

        if SM then
            MVA[period] = d;
        end
        UB[period] = d + s;
        LB[period] = d - s;
    end
end

