-- Id: 19850
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65407

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("Round Numbers indicator");
    indicator:description("Round Numbers indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("roundLevel50", "Round level 1", "", 25);
    indicator.parameters:addInteger("roundLevel100", "Round level 2", "", 50);
    indicator.parameters:addInteger("roundLevel150", "Round level 3", "", 75);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color 1", "Color 1", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr2", "Color 2", "Color 2", core.rgb(255, 255, 0));
    indicator.parameters:addColor("clr3", "Color 3", "Color 3", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("DotSize", "Dot size", "", 3, 1, 5);
end

local first;
local source = nil;
local roundLevel50;
local roundLevel100;
local roundLevel150;

local RoundLevel1, RoundLevel2, RoundLevel3;
local rDelimeter;

function Prepare(nameOnly)
    source = instance.source;
    roundLevel50=instance.parameters.roundLevel50;
    roundLevel100=instance.parameters.roundLevel100;
    roundLevel150 = instance.parameters.roundLevel150;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    RoundLevel1 = instance:addStream("RoundLevel1", core.Dot, name .. ".RoundLevel1", "RoundLevel1", instance.parameters.clr1, first);
    RoundLevel2 = instance:addStream("RoundLevel2", core.Dot, name .. ".RoundLevel2", "RoundLevel2", instance.parameters.clr2, first);
    RoundLevel3 = instance:addStream("RoundLevel3", core.Dot, name .. ".RoundLevel3", "RoundLevel3", instance.parameters.clr3, first);
    RoundLevel1:setWidth(instance.parameters.DotSize);
    RoundLevel2:setWidth(instance.parameters.DotSize);
    RoundLevel3:setWidth(instance.parameters.DotSize);
    rDelimeter=1/source:pipSize();
end

function Update(period, mode)
    if period>first then
        local intRoundLevel=source.close[period]*rDelimeter;

        local intRemainder=math.fmod(intRoundLevel, roundLevel50);
        local toRound;
        if intRemainder>=roundLevel50/2 then
            toRound=roundLevel50;
        else
            toRound=0;
        end
        local roundLevel=(intRoundLevel-intRemainder+toRound)/rDelimeter;
        RoundLevel1[period]=roundLevel;

        intRemainder=math.fmod(intRoundLevel, roundLevel100);
        if intRemainder>=roundLevel100/2 then
            toRound=roundLevel100;
        else
            toRound=0;
        end
        roundLevel=(intRoundLevel-intRemainder+toRound)/rDelimeter;
        RoundLevel2[period]=roundLevel;

        intRemainder = math.fmod(intRoundLevel, roundLevel150);
        if intRemainder >= roundLevel150 / 2 then
            toRound = roundLevel150;
        else
            toRound = 0;
        end
        roundLevel = (intRoundLevel - intRemainder + toRound) / rDelimeter;
        RoundLevel3[period] = roundLevel;
    end 
end

