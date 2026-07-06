-- Id: 2766
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3080

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
    indicator:name("Relative Stength Index with zone and trend highlighting");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addInteger("N", "Number of Periods", "", 17, 2, 1000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrRSI", "Line (neutral)", "", core.rgb(0, 255, 255));
    indicator.parameters:addColor("clrRSIUp", "Line (uptrend)", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrRSIDn", "Line (downtrend)", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthRSI", "Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("styleRSI", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleRSI", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("fill", "Highlight Areas over/under levels", "", true);
    indicator.parameters:addInteger("transparency", "Highlight transparency (%)", "", 30);
    indicator.parameters:addColor("clrFill", "Over Level Fill Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addColor("clrBg", "Background Fill Color", "Leave this parameter in its default value", core.COLOR_BACKGROUND);

    indicator.parameters:addGroup("Levels");
    indicator.parameters:addInteger("overbought", "Overbought level", "", 60, 0, 100);
    indicator.parameters:addInteger("oversold", "Oversold level", "", 40, 0, 100);
    indicator.parameters:addInteger("level_overboughtsold_width", "Level Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Level Line Style", "", core.LINE_DOT);
    indicator.parameters:addColor("level_overboughtsold_color", "","", core.COLOR_CUSTOMLEVEL);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
 

 
end
 



local n;
local source;
local first1, first2;
local pos, neg;
local wmap, wman;
local rsi;
local clr, clrUp, clrDn;
local trend;

local fill, clrFill, clrBg;
local ob_level;
local ob_highlight1;
local ob_highlight2;
local os_level;
local os_highlight1;
local os_highlight2;
local Signal;
function Prepare(onlyName)
     source = instance.source;
	n = instance.parameters.N;
	
	 local name;
    name = profile:id() .. "(" .. source:name() .. "," .. n .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end
	
 
    first1 = source:first() + 1;
    pos = instance:addInternalStream(first1, 0);
    neg = instance:addInternalStream(first1, 0);
    wmap = core.indicators:create("WMA", pos, n);
    wman = core.indicators:create("WMA", neg, n);
    first2 = wmap.DATA:first();

    clr = instance.parameters.clrRSI;
    clrUp = instance.parameters.clrRSIUp;
    clrDn = instance.parameters.clrRSIDn;


    RSI = instance:addStream("RSI", core.Line, name, "RSI", clr, first2);
    RSI:setWidth(instance.parameters.widthRSI);
    RSI:setStyle(instance.parameters.styleRSI);
    RSI:setPrecision(2);
	
	Signal = instance:addInternalStream(0, 0);

    trend = instance:addInternalStream(0, 0);

    RSI:addLevel(0, core.LINE_NONE);
    RSI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    RSI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    RSI:addLevel(100, core.LINE_NONE);

    fill = instance.parameters.fill;
    if fill then
        clrFill = instance.parameters.clrFill;
        clrBg = instance.parameters.clrBg;
        ob_level = instance.parameters.overbought;
        ob_highlight1 = instance:addInternalStream(first2, 0);
        ob_highlight2 = instance:addInternalStream(first2, 0);
        instance:createChannelGroup("ob", "ob", ob_highlight1, ob_highlight2, clrFill, 100 - instance.parameters.transparency);
        os_level = instance.parameters.oversold;
        os_highlight1 = instance:addInternalStream(first2, 0);
        os_highlight2 = instance:addInternalStream(first2, 0);
        instance:createChannelGroup("os", "os", os_highlight1, os_highlight2, clrFill, 100 - instance.parameters.transparency);
    end
	
	 
	
end

 


function Update(period, mode)
    
	
	
	Calculate (period, mode)	
	 
end


function Calculate (period, mode)

    if period >= first1 then
        local diff = source[period] - source[period - 1];
        if diff >= 0 then
            pos[period] = diff;
            neg[period] = 0;
        else
            neg[period] = -diff;
            pos[period] = 0;
        end
    end
    wmap:update(mode);
    wman:update(mode);
    if period >= first2 then
        local p, n, rs;
        p = wmap.DATA[period];
        n = wman.DATA[period];

        if n == 0 then
            RSI[period] = 0;
        else
            rs = p / n;
            RSI[period] = 100 - (100 / (1 + rs));
        end
        local t;
        t = trend[period - 1];

        if RSI[period - 1] <= ob_level and
           RSI[period] > ob_level then
            t = 1;
        elseif RSI[period - 1] >= os_level and
               RSI[period] < os_level then
            t = -1;
        end

        if t == 0 then
            RSI:setColor(period, clr);
			Signal[period]=0;
        elseif t == 1 then
            RSI:setColor(period, clrUp);
			Signal[period]=1;
        elseif t == -1 then
            RSI:setColor(period, clrDn);
			Signal[period]=-1;
        end

        trend[period] = t;
    else
        trend[period] = 0;
    end

    if fill and period >= first2 then
        ob_highlight1[period] = RSI[period];
        ob_highlight1:setColor(period, clrFill);
        ob_highlight2[period] = ob_level;
        if RSI[period] < ob_level then
            if RSI[period - 1] < ob_level then
                ob_highlight1[period] = nil;
            else
                ob_highlight1:setColor(period, clrBg);
            end
        else
            if RSI[period - 1] < ob_level then
                ob_highlight1[period - 1] = RSI[period - 1];
                ob_highlight1:setColor(period - 1, clrBg);
            end
        end
        os_highlight1[period] = RSI[period];
        os_highlight1:setColor(period, clrFill);
        os_highlight2[period] = os_level;

        if RSI[period] > os_level then
            if RSI[period - 1] > os_level then
                os_highlight1[period] = nil;
            else
                os_highlight1:setColor(period, clrBg);
            end
        else
            if RSI[period - 1] > os_level then
               os_highlight1[period - 1] = RSI[period - 1];
               os_highlight1:setColor(period - 1, clrBg);
            end
        end
    end
end


 
 
 

