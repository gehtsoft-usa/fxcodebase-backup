-- Id: 1793
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2298

--+------------------------------------------------------------------+
--|                               Copyright � 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

 
-- The formula is from here: http://forum.vtsystems.com/index.php?showtopic=9941
-- {Provided By: Visual Trading Systems, LLC & Capital Market Services, LLC � Copyright 2008}
-- {Description: The Asymmetrical RSI (ARSI) Indicator}
-- {Notes: T.A.S.C., October 2008 - "ARSI, The Asymmetrical RSI" by Sylvain Vervoort}
-- {vt_ARSI Version 1.0}
--
-- UpCount:= sum(if(roc(Price,1,points)>=0,1,0),Period);
-- DnCount:= Period-UpCount;
-- UpMove:= wilders(if(roc(Price,1,points)>=0,roc(Price,1,points),0),UpCount);
-- DnMove:= wilders(if(roc(Price,1,points)<0,abs(roc(Price,1,points)),0),DnCount);
-- RS:= UpMove/DnMove;
-- ARSI:= 100-(100/(1+RS));


function Init()
    indicator:name("Sylvain Vervoort's Asymmetrical RSI");
    indicator:description("Sylvain Vervoort's Asymmetrical RSI");
    indicator:type(core.Oscillator);
    indicator:requiredSource(core.Tick);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "", 14, 2, 32);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Indicator Line Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("width", "Indicator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Indicator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

    indicator.parameters:addGroup("Levels");
    indicator.parameters:addInteger("L1", "Level1", "", 30, 1, 100);
    indicator.parameters:addInteger("L2", "Level2", "", 70, 1, 100);
    indicator.parameters:addColor("clrL", "Level Line Color", "", core.rgb(192, 192, 192));
    indicator.parameters:addInteger("widthL", "Level Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleL", "Level Line Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("styleL", core.FLAG_LINE_STYLE);
end

local n;
local upbuff;
local dnbuff;
local upcnt;
local upwma = {};
local dnwma = {};
local first1;
local source;
local pipsize;
local out;

function Prepare(onlyName)
    local name;

    name = profile:id() .. "(" .. instance.source:name() .. "," .. instance.parameters.N .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end

    assert(core.indicators:findIndicator("WMA") ~= nil, "Please download and install WMA.lua (Wilders moving average) indicator");

    n = instance.parameters.N;
    source = instance.source;
    pipsize = source:pipSize();
    first1 = source:first() + 1;
    upbuff = instance:addInternalStream(first1, 0);
    dnbuff = instance:addInternalStream(first1, 0);
    upcnt = instance:addInternalStream(first1, 0);

    local i;
    for i = 2, n, 1 do
        upwma[i] = core.indicators:create("WMA", upbuff, i);
        dnwma[i] = core.indicators:create("WMA", dnbuff, i);
    end
    first = math.max(first1 + n, upwma[n].DATA:first());

    out = instance:addStream("SVE_ARSI", core.Line, name, "SVE_ARSI", instance.parameters.clr, first);
    out:setPrecision(math.max(2, instance.source:getPrecision()));
    out:setWidth(instance.parameters.width);
    out:setStyle(instance.parameters.style);

    out:addLevel(0, core.LINE_NONE, 1, instance.parameters.clrL);
    out:addLevel(instance.parameters.L1, instance.parameters.styleL, instance.parameters.widthL, instance.parameters.clrL);
    out:addLevel(instance.parameters.L2, instance.parameters.styleL, instance.parameters.widthL, instance.parameters.clrL);
    out:addLevel(100, core.LINE_NONE, 1, instance.parameters.clrL);

end

function Update(period, mode)
    if period >= first1 then
        roc = (source[period] - source[period - 1]) / pipsize;
        upbuff[period] = math.max(roc, 0);
        dnbuff[period] = math.abs(math.min(roc, 0));
        if roc >= 0 then
            upcnt[period] = 1;
        else
            upcnt[period] = 0;
        end
    end

    if period >= first then
        local up, dn;
        local upmove, dnmove;
        local rs;

        up = core.sum(upcnt, core.rangeTo(period, n));
        dn = n - up;

        if up == 0 then
            upmove = 0;
        elseif up == 1 then
            upmove = upbuff[period];
        else
            upwma[up]:update(core.UpdateLast);
            upmove = upwma[up].DATA[period];
        end
        if dn == 0 then
            dnmove = 0;
        elseif dn == 1 then
            dnmove = dnbuff[period];
        else
            dnwma[dn]:update(core.UpdateLast);
            dnmove = dnwma[dn].DATA[period];
        end

        if dnmove == 0 then
            out[period] = 100;
        else
            out[period] = 100 - (100 / (1 + upmove / dnmove));
        end
    end
end

