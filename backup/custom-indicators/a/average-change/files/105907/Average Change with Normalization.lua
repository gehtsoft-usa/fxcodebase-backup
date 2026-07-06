-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/download/file.php?id=15920
-- Id: 15977

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+


function Init()
    indicator:name("Average Change with Normalization");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 14, 2, 5000);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addBoolean("Show", "Show Raw Data", "", true);
	
	indicator.parameters:addInteger("NormalizationPeriod", "Normalization Period", "", 14, 2, 5000);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Line color", "Line Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line Line style", "Line style", core.LINE_SOLID);
	
	indicator.parameters:addColor("color2", "Line color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line Line style", "Line style", core.LINE_SOLID);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 80);
    indicator.parameters:addDouble("oversold","Oversold Level","", 20);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first;
local source;
local Period;
local MA,ma;
local Change;
local Method;
local Show;
local NormalizationPeriod;
local Raw;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	NormalizationPeriod= instance.parameters.NormalizationPeriod;
	Method= instance.parameters.Method;
	Show= instance.parameters.Show;
    source = instance.source;
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ", " .. Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	Raw = instance:addInternalStream( 0, 0);

	if Show then
    Change = instance:addStream("Change", core.Line, name .. ".Change", "Change", instance.parameters.color1, source:first()+1);
	Change:setWidth(instance.parameters.width1);
    Change:setStyle(instance.parameters.style1); 
	else
	Change = instance:addInternalStream( source:first()+1, 0);
	end
	
	Change:setPrecision(10);
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    ma = core.indicators:create(Method, Change, Period); 
    first=ma.DATA:first();	
	
	
    MA = instance:addStream("MA", core.Line, name .. ".MA", "MA", instance.parameters.color2, first+NormalizationPeriod);
	MA:setWidth(instance.parameters.width2);
    MA:setStyle(instance.parameters.style2); 
	
	MA:setPrecision(10);
	MA:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	MA:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
end

-- Indicator calculation routine
function Update(period, mode)
    
	Raw[period]= source[period]-source[period-1];
		
	if period < (source:first()+1 + NormalizationPeriod)  then
	return;
	end
	
	local min,max=mathex.minmax(Raw, period-NormalizationPeriod+1, period);
	Change[period]= ((Raw[period] - min)/ (max-min))*100; 
	
    ma:update(mode);

    if period < first   then
	return;
	end
	
	MA[period]= ma.DATA[period];
	
		
	
end






