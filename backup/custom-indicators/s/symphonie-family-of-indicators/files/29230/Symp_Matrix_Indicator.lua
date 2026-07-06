-- Id: 6246
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15511

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

--                                 Symphonie Matrix Indicator v3.0 

function Init()
    indicator:name("Symphonie Matrix indicator");
    indicator:description("Symphonie Matrix indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Emotion_SSP", "SSP (Emotion)", "", 7);
    indicator.parameters:addDouble("Emotion_Kmax", "Kmax (Emotion)", "", 50.6);

    indicator.parameters:addInteger("Extreme_r", "r (Extreme)", "", 12);
    indicator.parameters:addInteger("Extreme_s", "s (Extreme)", "", 12);
    indicator.parameters:addInteger("Extreme_u", "u (Extreme)", "", 5);

    indicator.parameters:addInteger("Sentiment_Period", "Period (Sentiment)", "", 12);

    indicator.parameters:addInteger("Trendline_CCI_Period", "Period of CCI (Trendline)", "", 63);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UpClr", "Up Color", "Up Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DnClr", "Dn Color", "Dn Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);
end

local first;
local source = nil;
local Ind_Symp_Emotion;
local Ind_Symp_Extreme;
local Ind_Symp_Sentiment;
local Ind_Symp_Trendline;
local Symp_Emotion;
local Symp_Extreme;
local Symp_Sentiment;
local Symp_Trendline;

function Prepare(nameOnly)
    source = instance.source;
   
	
	assert(core.indicators:findIndicator("SYMP_EMOTION_INDICATOR") ~= nil, "Please, download and install SYMP_EMOTION_INDICATOR.LUA indicator");   
	
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Ind_Symp_Emotion = core.indicators:create("SYMP_EMOTION_INDICATOR", source, instance.parameters.Emotion_SSP, instance.parameters.Emotion_Kmax);
    assert(core.indicators:findIndicator("SYMP_EXTREME_INDICATOR") ~= nil, "SYMP_EXTREME_INDICATOR" .. " indicator must be installed");
    Ind_Symp_Extreme = core.indicators:create("SYMP_EXTREME_INDICATOR", source, instance.parameters.Extreme_r, instance.parameters.Extreme_s, instance.parameters.Extreme_u);
    assert(core.indicators:findIndicator("SYMP_SENTIMENT_INDICATOR") ~= nil, "SYMP_SENTIMENT_INDICATOR" .. " indicator must be installed");
    Ind_Symp_Sentiment = core.indicators:create("SYMP_SENTIMENT_INDICATOR", source, instance.parameters.Sentiment_Period);
    Ind_Symp_Trendline = core.indicators:create("CCI", source, instance.parameters.Trendline_CCI_Period);
    first = math.max(Ind_Symp_Emotion.DATA:first(),Ind_Symp_Extreme.DATA:first(),Ind_Symp_Sentiment.DATA:first(),Ind_Symp_Trendline.DATA:first());
    Symp_Sentiment = instance:addStream("Symp_Sentiment", core.Dot, name .. ".Symp_Sentiment", "Symp_Sentiment", instance.parameters.UpClr, first);
    Symp_Sentiment:setPrecision(math.max(2, instance.source:getPrecision()));
    Symp_Emotion = instance:addStream("Symp_Emotion", core.Dot, name .. ".Symp_Emotion", "Symp_Emotion", instance.parameters.UpClr, first);
    Symp_Emotion:setPrecision(math.max(2, instance.source:getPrecision()));
    Symp_Trendline = instance:addStream("Symp_Trendline", core.Dot, name .. ".Symp_Trendline", "Symp_Trendline", instance.parameters.UpClr, first);
    Symp_Trendline:setPrecision(math.max(2, instance.source:getPrecision()));
    Symp_Extreme = instance:addStream("Symp_Extreme", core.Dot, name .. ".Symp_Extreme", "Symp_Extreme", instance.parameters.UpClr, first);
    Symp_Extreme:setPrecision(math.max(2, instance.source:getPrecision()));
    Symp_Emotion:setWidth(instance.parameters.DotSize);
    Symp_Extreme:setWidth(instance.parameters.DotSize);
    Symp_Sentiment:setWidth(instance.parameters.DotSize);
    Symp_Trendline:setWidth(instance.parameters.DotSize);
    Symp_Emotion:addLevel(0);
    Symp_Emotion:addLevel(5);
end

function Update(period, mode)
   if (period>first) then
    Ind_Symp_Emotion:update(mode);
    Ind_Symp_Extreme:update(mode);
    Ind_Symp_Sentiment:update(mode);
    Ind_Symp_Trendline:update(mode);
    Symp_Sentiment[period]=1;
    Symp_Emotion[period]=2;
    Symp_Trendline[period]=3;
    Symp_Extreme[period]=4;
    if Ind_Symp_Sentiment.DATA[period]>=0 then
     Symp_Sentiment:setColor(period,instance.parameters.UpClr);
    else
     Symp_Sentiment:setColor(period,instance.parameters.DnClr);
    end
    if period>first+instance.parameters.Emotion_SSP then
     if Ind_Symp_Emotion.DATA[period]>=Ind_Symp_Emotion.DATA[period-instance.parameters.Emotion_SSP] then
      Symp_Emotion:setColor(period,instance.parameters.UpClr);
     else
      Symp_Emotion:setColor(period,instance.parameters.DnClr);
     end
    end
    if Ind_Symp_Trendline.DATA[period]>=0 then
     Symp_Trendline:setColor(period,instance.parameters.UpClr);
    else
     Symp_Trendline:setColor(period,instance.parameters.DnClr);
    end
    if Ind_Symp_Extreme.DATA[period]>=Ind_Symp_Extreme.DATA[period-1] then
     Symp_Extreme:setColor(period,instance.parameters.UpClr);
    else
     Symp_Extreme:setColor(period,instance.parameters.DnClr);
    end
   end 
end

