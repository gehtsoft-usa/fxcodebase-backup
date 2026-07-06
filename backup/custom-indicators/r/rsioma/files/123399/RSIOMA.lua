-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67278
-- Id: 

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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

function Init()
    indicator:name("RSIOMA oscillator");
    indicator:description("RSIOMA oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "Method", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("Period", "Period", "", 10);
	
	
	indicator.parameters:addInteger("RSI_Period", "RSI Period", "", 10);
	
 
	
    indicator.parameters:addString("SMethod", "Smooth method", "", "MVA");
    indicator.parameters:addStringAlternative("SMethod", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("SMethod", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("SMethod", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("SMethod", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("SMethod", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("SMethod", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("SMethod", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("SMethod", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("SMethod", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("SMethod", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("SMethod", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("SMethod", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("SMethod", "T3", "", "T3");
    indicator.parameters:addStringAlternative("SMethod", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("SMethod", "Median", "", "Median");
    indicator.parameters:addStringAlternative("SMethod", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("SMethod", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("SMethod", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("SMethod", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("SMethod", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("SMethod", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("SPeriod", "Smooth period", "", 14);


    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "RSI Color", "RSI Color", core.rgb(0, 255, 0));
	
	indicator.parameters:addInteger("width1", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("color2", "Signal color", "Signal color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width2", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

local first;
local source = nil;
local Method;
local Period;
local SMethod;
local SPeriod;
local MomPeriod;
local HLevel;
local MLevel;
local LLevel;
local MA;
local rsi;
local SignalMA;
 
local RSI=nil;
local Signal=nil;
local RSI_Period;
function Prepare(nameOnly)
    source = instance.source;
    Method=instance.parameters.Method;
    Period=instance.parameters.Period;
    SMethod=instance.parameters.SMethod;
    SPeriod=instance.parameters.SPeriod;
 
    RSI_Period=instance.parameters.RSI_Period;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.SMethod .. ", " .. instance.parameters.SPeriod   .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator"); 
	 
	
   
     
    MA = core.indicators:create("AVERAGES", source, Method, Period, false);
    rsi = core.indicators:create("RSI", MA.DATA, RSI_Period);	
	
    RSI = instance:addStream("RSI", core.Line, name .. ".RSI", "RSI", instance.parameters.color1, rsi.DATA:first());
	RSI:setWidth(instance.parameters.width1);
    RSI:setStyle(instance.parameters.style1);   
	
	SignalMA = core.indicators:create("AVERAGES", RSI, SMethod, SPeriod, false);
	
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.color2, SignalMA.DATA:first());
    Signal:setWidth(instance.parameters.width2);
    Signal:setStyle(instance.parameters.style2);    
    
	
	Signal:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Signal:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);   
	
	Signal:setPrecision(math.max(2, instance.source:getPrecision()));
	RSI:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
 
   
    MA:update(mode);
     
	if period<MA.DATA:first() then
	return;
	end
	
	
	 rsi:update(mode);
     
	if period<rsi.DATA:first() then
	return;
	end
	 
	RSI[period]=rsi.DATA[period];
	 
	 
     SignalMA:update(mode);
	 if period < SignalMA.DATA:first() then
	 return;
	 end
	 
     Signal[period]=SignalMA.DATA[period];
 
 
end

