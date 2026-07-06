-- Id: 14626
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62497

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- The indicator corresponds to the Commodity Channel Index indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 8 "Sycle Analisis" (page 209-210)

-- Indicator profile initialization routine
function Init()
    indicator:name("Smoothed CCI");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 
	
	indicator.parameters:addGroup("Pre Smoothing");
	indicator.parameters:addBoolean("PreFlag", "Use Pre Smoothing", "", false);
	
	indicator.parameters:addInteger("PrePeriod", "Period","", 14, 2, 1000);
	
	indicator.parameters:addString("PreMethod", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("PreMethod", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("PreMethod", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("PreMethod", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("PreMethod", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("PreMethod", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("PreMethod", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("PreMethod", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("PreMethod", "WMA", "WMA" , "WMA");
	

    indicator.parameters:addGroup("CCI Calculation");
    indicator.parameters:addInteger("N", "CCI Period","", 14, 2, 1000);
	
	indicator.parameters:addGroup("Post Smoothing");
	indicator.parameters:addBoolean("PostFlag", "Use Post Smoothing", "", false);
	indicator.parameters:addInteger("PostPeriod", "Period","", 14, 2, 1000);
	
	indicator.parameters:addString("PostMethod", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("PostMethod", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("PostMethod", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("PostMethod", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("PostMethod", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("PostMethod", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("PostMethod", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("PostMethod", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("PostMethod", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrCCI", "Line Color", "", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("widthCCI", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleCCI", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleCCI", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addInteger("overbought", "Overbought Level","", 100, -1000, 1000);
    indicator.parameters:addInteger("oversold", "Oversold Level","", -100, -1000, 1000);
	
    indicator.parameters:addInteger("level_overboughtsold_width", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
	 indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(255, 255, 0));
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;
local first;
local source = nil;
local Source = nil;
local PreMethod,PrePeriod,Pre;
local PostMethod,PostPeriod,Post;
local pre, post;
-- Streams block
local CCI = nil;
local RawCCI=nil;
-- Routine
function Prepare(nameOnly)  
    n = instance.parameters.N;
    source = instance.source;
	PreFlag=instance.parameters.PreFlag;
	PrePeriod=instance.parameters.PrePeriod;
	PreMethod=instance.parameters.PreMethod;
	PostFlag=instance.parameters.PostFlag;
	PostPeriod=instance.parameters.PostPeriod;
	PostMethod=instance.parameters.PostMethod;	
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	if PreFlag then
    assert(core.indicators:findIndicator(PreMethod) ~= nil, PreMethod .. " indicator must be installed");
	pre=core.indicators:create(PreMethod,source,PrePeriod);
	Source=pre.DATA;
	else	
	Source=source;
	end
	
    if PostFlag then		
	RawCCI = instance:addInternalStream(Source:first()+n-1, 0);
    post=core.indicators:create(PreMethod,RawCCI,PrePeriod); 
	first= post.DATA:first();
	else
	first= Source:first()+n-1;
	RawCCI = instance:addInternalStream(first, 0);
    end
	
    CCI = instance:addStream("CCI", core.Line, name, "CCI", instance.parameters.clrCCI, first);
    CCI:setWidth(instance.parameters.widthCCI);
    CCI:setStyle(instance.parameters.styleCCI);
    CCI:setPrecision(2);

    CCI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    CCI:addLevel(0);
    CCI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
end

-- Indicator calculation routine
function Update(period,mode)


    if PreFlag then
	pre:update(mode);
	end
	
	if period < Source:first() +n-1 then
	return;
	end
	
	
	
        local from = period - n + 1;
        local to = period;

        local mean = mathex.avg(Source, from, to);
        local meandev = mathex.meandev(Source, from, to);


		
        if (meandev == 0) then
            RawCCI[period] = 0;
        else
            RawCCI[period] = (Source[period] - mean) / (meandev * 0.015);
        end
		
		
	if PostFlag then
	post:update(mode); 
	
		if period < post.DATA:first() then
		return;
		end
	
	CCI[period]=post.DATA[period];
	else
	CCI[period]=RawCCI[period];
	end	
    
end







