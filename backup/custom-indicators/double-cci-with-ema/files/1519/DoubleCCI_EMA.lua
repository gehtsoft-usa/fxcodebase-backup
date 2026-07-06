-- Id: 493
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=849

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

-- original indicator for MT4
-- //+------------------------------------------------------------------+
-- //|                                           DoubleCCI-With_EMA.mq4 |
-- //|                   Copyright � 2005, Jason Robinson (jnrtrading). |
-- //|                                      http://www.jnrtrading.co.uk |
-- //+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Double CCI with EMA");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("TrendCCI_N", "Number of periods for Trend CCI", "", 89);
    indicator.parameters:addInteger("EntryCCI_N", "Number of periods for entry CCI", "", 21);
    indicator.parameters:addBoolean("ShowSMA", "Show smoothed line", "", true);
    indicator.parameters:addInteger("SMA_N", "SMA periods", "", 30);
    indicator.parameters:addString("SMAOn", "Apply SMA on", "", "EntryCCI");
    indicator.parameters:addStringAlternative("SMAOn", "EntryCCI", "", "EntryCCI");
    indicator.parameters:addStringAlternative("SMAOn", "TrendCCI", "", "TrendCCI");
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("TrendCCI_color", "Color of TrendCCI", "", core.rgb(255, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("EntryCCI_color", "Color of EntryCCI", "", core.rgb(128, 128, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("SMA_color", "Color of SMA", "", core.rgb(255, 128, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("UpUp_color", "Color of up > 100", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UpDn_color", "Color of up < 100", "", core.rgb(0, 127, 0));
    indicator.parameters:addColor("DnDn_color", "Color of down  < -100", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DnUp_color", "Color of down > -100", "", core.rgb(127, 0, 0));
	
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 100);
    indicator.parameters:addDouble("oversold","Oversold Level","", -100);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local TrendCCI_N;
local EntryCCI_N;
local ShowSMA;
local SMA_N;
local SMAOn;

local first;
local source = nil;

-- Streams block
local TrendCCI = nil;
local EntryCCI = nil;
local SMA = nil;
local UpUp = nil;
local UpDn = nil;
local DnDn = nil;
local DnUp = nil;

local TCCI = nil;
local TCCI_first = nil;
local ECCI = nil;
local ECCI_first = nil;
local MA = nil;
local MA_first = nil;

-- Routine
function Prepare(nameOnly)
    TrendCCI_N = instance.parameters.TrendCCI_N;
    EntryCCI_N = instance.parameters.EntryCCI_N;
    ShowSMA = instance.parameters.ShowSMA;
    SMA_N = instance.parameters.SMA_N;
    SMAOn = instance.parameters.SMAOn;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. TrendCCI_N .. ", " .. EntryCCI_N .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    TCCI = core.indicators:create("CCI", source, TrendCCI_N);
    TCCI_first = TCCI.DATA:first();
    ECCI = core.indicators:create("CCI", source, EntryCCI_N);
    ECCI_first = TCCI.DATA:first();

    if ShowSMA then
        if SMAOn == "EntryCCI" then
            MA = core.indicators:create("MVA", ECCI.DATA, SMA_N);
        else
            MA = core.indicators:create("MVA", TCCI.DATA, SMA_N);
        end
        MA_first = MA.DATA:first();
    end
    UpUp = instance:addStream("UpUp", core.Bar, name .. ".UpUp", "UpUp", instance.parameters.UpUp_color, TCCI_first);
    UpDn = instance:addStream("UpDn", core.Bar, name .. ".UpDn", "UpDn", instance.parameters.UpDn_color, TCCI_first);
    DnDn = instance:addStream("DnDn", core.Bar, name .. ".DnDn", "DnDn", instance.parameters.DnDn_color, TCCI_first);
    DnUp = instance:addStream("DnUp", core.Bar, name .. ".DnUp", "DnUp", instance.parameters.DnUp_color, TCCI_first);
    TrendCCI = instance:addStream("TrendCCI", core.Line, name .. ".TrendCCI", "TrendCCI", instance.parameters.TrendCCI_color, TCCI_first);
	TrendCCI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	TrendCCI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
    TrendCCI:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	TrendCCI:setWidth(instance.parameters.width1);
    TrendCCI:setStyle(instance.parameters.style1);
    EntryCCI = instance:addStream("EntryCCI", core.Line, name .. ".EntryCCI", "EntryCCI", instance.parameters.EntryCCI_color, ECCI_first);
	EntryCCI:setWidth(instance.parameters.width2);
    EntryCCI:setStyle(instance.parameters.style2);
    if MA ~= nil then
        SMA = instance:addStream("SMA", core.Line, name .. ".SMA", "SMA", instance.parameters.SMA_color, MA_first);
		SMA:setWidth(instance.parameters.width3);
        SMA:setStyle(instance.parameters.style3);
    end
	
	
	 SMA:setPrecision(math.max(2, instance.source:getPrecision()));	
	 EntryCCI:setPrecision(math.max(2, instance.source:getPrecision()));	
	 TrendCCI:setPrecision(math.max(2, instance.source:getPrecision()));	
	 UpDn:setPrecision(math.max(2, instance.source:getPrecision()));	
	 UpUp:setPrecision(math.max(2, instance.source:getPrecision()));
     DnDn:setPrecision(math.max(2, instance.source:getPrecision()));	
	 DnUp:setPrecision(math.max(2, instance.source:getPrecision()));

end

-- Indicator calculation routine
function Update(period, mode)
    TCCI:update(mode);
    ECCI:update(mode);
    if MA ~= nil then
        MA:update(mode);
    end

    if period >= TCCI_first then
        local v = TCCI.DATA[period];
        TrendCCI[period] = v;
        if v > 100 then
            UpUp[period] = v;
        elseif v > 0 then
            UpDn[period] = v;
        elseif v < - 100 then
            DnDn[period] = v;
        elseif v < 0 then
            DnUp[period] = v;
        end
    end
    if period >= ECCI_first then
        EntryCCI[period] = ECCI.DATA[period];
    end
    if period >= MA_first and MA ~= nil then
        SMA[period] = MA.DATA[period];
    end

end

