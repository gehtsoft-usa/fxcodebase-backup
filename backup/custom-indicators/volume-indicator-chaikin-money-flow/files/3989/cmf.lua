-- Id: 1377
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1965

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
    indicator:name("Chaikin Money Flow");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Periods", "", 21, 1, 1000);
    --indicator.parameters:addBoolean("Prev", "Incremental A/D", "If the parameter is true, then A/D's previous bar value is added to A/D's current bar value", false);
	
	 indicator.parameters:addString("Method", "Method","", "CI");
    indicator.parameters:addStringAlternative("Method", "Method_Classic", "", "CS");
    indicator.parameters:addStringAlternative("Method", "Method_ClassicIncremental", "", "CI");
    indicator.parameters:addStringAlternative("Method", "TradeStation", "", "TS");
	

    indicator.parameters:addGroup("Style");
    indicator.parameters:addString("Display", "Display indicator as", "", "L");
    indicator.parameters:addStringAlternative("Display", "Line", "", "L");
    indicator.parameters:addStringAlternative("Display", "Histogram", "", "H");
    indicator.parameters:addColor("clrCMF", "Indicator Line Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthCMF", "Indicator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleCMF", "Indicator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleCMF", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrHU", "Up histogram color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrHD", "Down histogram color", "", core.rgb(255, 0, 0));
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 0);
    indicator.parameters:addDouble("oversold","Oversold Level","", 0);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

local first;
local N;
local AD;
local line;
local CMF;
local U, D;
local Method;
function Prepare(nameOnly)
    source = instance.source;
	Method= instance.parameters.Method;

    assert(source:supportsVolume(), "The source must have volume");

    assert(core.indicators:findIndicator("AD") ~= nil, "The A/D indicator must be installed");
    N = instance.parameters.N;

    local name;
    name = profile:id() .. "(" .. source:name() .. "," .. instance.parameters.N.. "," .. instance.parameters.Method;
    instance:name(name);
    if nameOnly then
        return;
    end

    AD = core.indicators:create("AD", source, Method);

    first = math.max(AD.DATA:first() + N, source:first() + N);

    if instance.parameters.Display == "L" then
        line = true;
        CMF = instance:addStream("CMF", core.Line, name, "CMF", instance.parameters.clrCMF, first);
        CMF:setPrecision(4);
        CMF:setWidth(instance.parameters.widthCMF);
        CMF:setStyle(instance.parameters.styleCMF);
        CMF:addLevel(0);
		CMF:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		CMF:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		CMF:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);     
    else
        line = false;
        CMF = instance:addStream("CMF", core.Bar, name, "CMF", instance.parameters.clrCMF, first);        
        CMF:setPrecision(4);
        CMF:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		CMF:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);      
        CMF:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);     
    end
end

function Update(period, mode)
    AD:update(mode);

    if period >= first then
        local range = core.rangeTo(period, N);
        local a, b;
        a = core.sum(AD.DATA, range);
        b = core.sum(source.volume, range);
        if b ~= 0 then
            CMF[period] = a / b;
        else
            CMF[period] = 0;
        end

        if not(line) then
            if CMF[period] > 0 then
                CMF:setColor(period, instance.parameters.clrHU);
            else
                CMF:setColor(period, instance.parameters.clrHD);
            end
        end
    end
end
