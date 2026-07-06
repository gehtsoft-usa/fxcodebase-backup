-- Id: 1400
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1975

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Gator Oscillator");
    indicator:description("Gator Oscillator is based on the Alligator and shows the degree of convergence/divergence of the Balance Lines")
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Bill Williams");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("JawN", "Number of periods for smoothing the alligator jaw", "", 13, 1, 300);
    indicator.parameters:addInteger("JawS", "Number of periods for shifting the alligator jaw", "", 8, 0, 300);

    indicator.parameters:addInteger("TeethN", "Number of periods for smoothing the alligator teeth", "", 8, 1, 300);
    indicator.parameters:addInteger("TeethS", "Number of periods for shifting the alligator teeth", "", 5, 0, 300);

    indicator.parameters:addInteger("LipsN", "Number of periods for smoothing the alligator lips", "", 5, 1, 300);
    indicator.parameters:addInteger("LipsS", "Number of periods for shifting the alligator lips", "", 3, 0, 300);

    indicator.parameters:addString("MTH", "Smoothing method", "The methods marked with (*) must be downloaded and installed", "SMMA");
    indicator.parameters:addStringAlternative("MTH", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MTH", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MTH", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MTH", "SMMA(*)", "", "SMMA");
    indicator.parameters:addStringAlternative("MTH", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MTH", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MTH", "Wilders*", "", "WMA");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addString("Display", "Display Mode", "", "H");
    indicator.parameters:addStringAlternative("Display", "Line", "", "L");
    indicator.parameters:addStringAlternative("Display", "Histogram", "", "H");
    indicator.parameters:addColor("GrowColor", "Color of the growing bar or up line", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("FallColor", "Color of the falling bar or down line", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);

end

local source;
local first;
local alligator;
local jaws, teeth, lips;
local UP, DOWN;
local HUG, HUF, HDG, HDF;
local DU, DD;
local line;
local Ufirst, Uextent;
local Dfirst, Dextent;
local DZ;
local Zone;
local ZoneLabel;
local Zfirst;
local Zextent;
local Z_NONE = 0;
local Z_SLEEP = 1;
local Z_AWAKE = 2;
local Z_EAT = 3;
local Z_FILLSOUT = 4;

function Prepare(nameOnly)
    assert(core.indicators:findIndicator(instance.parameters.MTH) ~= nil, "Please download and install " .. instance.parameters.MTH .. ".lua indicator");
    assert(core.indicators:findIndicator("ALLIGATOR2") ~= nil, "Please download and install ALLIGATOR2.lua indicator");
    line = (instance.parameters.Display ~= "H");
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.JawN .. "(" .. instance.parameters.JawS .. ")," .. instance.parameters.TeethN .. "(" .. instance.parameters.TeethS .. ")," .. instance.parameters.LipsN .. "(" .. instance.parameters.LipsS .. ")," .. instance.parameters.MTH .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    local aprof, aparams;
    aprof = core.indicators:findIndicator("ALLIGATOR2");
    aparams = aprof:parameters();

    aparams:setInteger("JawN", instance.parameters.JawN);
    aparams:setInteger("JawS", instance.parameters.JawS);
    aparams:setInteger("TeethN", instance.parameters.TeethN);
    aparams:setInteger("TeethS", instance.parameters.TeethS);
    aparams:setInteger("LipsN", instance.parameters.LipsN);
    aparams:setInteger("LipsS", instance.parameters.LipsS);
    aparams:setString("MTH", instance.parameters.MTH);
    alligator = aprof:createInstance(source, aparams);
    jaws = alligator:getStream(0);
    teeth = alligator:getStream(1);
    lips = alligator:getStream(2);

    Uextent = math.min(instance.parameters.JawS, instance.parameters.TeethS);
    Ufirst = math.max(jaws:first(), teeth:first());
    Dextent = math.min(instance.parameters.TeethS, instance.parameters.LipsS);
    Dfirst = math.max(lips:first(), teeth:first());

    if line then
        UP = instance:addStream("UP", core.Line, name .. ".UP", "UP", instance.parameters.GrowColor, Ufirst, Uextent);
    UP:setPrecision(math.max(2, instance.source:getPrecision()));
        DOWN = instance:addStream("DOWN", core.Line, name .. ".DN", "DN", instance.parameters.FallColor, Dfirst, Dextent);
    DOWN:setPrecision(math.max(2, instance.source:getPrecision()));
		UP:setWidth(instance.parameters.width1);
		UP:setStyle(instance.parameters.style1);
		DOWN:setWidth(instance.parameters.width1);
		DOWN:setStyle(instance.parameters.style1);
    else
        UP = instance:addInternalStream(Ufirst, Uextent);
        DOWN = instance:addInternalStream(Dfirst, Dextent);

        HUG = instance:addStream("UPG", core.Bar, name .. ".UP^", "UP^", instance.parameters.GrowColor, Ufirst, Uextent);
    HUG:setPrecision(math.max(2, instance.source:getPrecision()));
        HUF = instance:addStream("UPF", core.Bar, name .. ".UPv", "UPv", instance.parameters.FallColor, Ufirst, Uextent);
    HUF:setPrecision(math.max(2, instance.source:getPrecision()));
        HDG = instance:addStream("DNG", core.Bar, name .. ".DN^", "DN^", instance.parameters.GrowColor, Dfirst, Dextent);
    HDG:setPrecision(math.max(2, instance.source:getPrecision()));
        HDF = instance:addStream("DNF", core.Bar, name .. ".DNv", "DNv", instance.parameters.FallColor, Dfirst, Dextent);
    HDF:setPrecision(math.max(2, instance.source:getPrecision()));
        DU = instance:addInternalStream(0, Uextent);
        DD = instance:addInternalStream(0, Dextent);
    end
end

function Update(period, mode)
    alligator:update(mode);
    local p;

    if period >= Ufirst - Uextent then
        p = period + Uextent;
        UP[p] = math.abs(jaws[p] - teeth[p]);
        if not(line) then
            if p == Ufirst then
                HUG[p] = UP[p];
                DU[p] = 1;
            else
                if UP[p] > UP[p - 1] then
                    HUG[p] = UP[p];
                    DU[p] = 1;
                elseif UP[p] < UP[p - 1] then
                    HUF[p] = UP[p];
                    DU[p] = -1;
                elseif DU[p - 1] > 0 then
                    HUG[p] = UP[p];
                    DU[p] = 1;
                else
                    HUF[p] = UP[p];
                    DU[p] = -1;
                end
            end
        end
    end
    if period >= Dfirst - Dextent then
        p = period + Dextent;
        DOWN[p] = math.abs(teeth[p] - lips[p]);
        if not(line) then
            if p == Ufirst then
                HDG[p] = -DOWN[p];
                DD[p] = 1;
            else
                if DOWN[p] > DOWN[p - 1] then
                    HDG[p] = -DOWN[p];
                    DD[p] = 1;
                elseif DOWN[p] < DOWN[p - 1] then
                    HDF[p] = -DOWN[p];
                    DD[p] = -1;
                elseif DD[p - 1] > 0 then
                    HDG[p] = -DOWN[p];
                    DD[p] = 1;
                else
                    HDF[p] = -DOWN[p];
                    DD[p] = -1;
                end
            end
        else
            DOWN[p] = -DOWN[p];
        end
    end
end
