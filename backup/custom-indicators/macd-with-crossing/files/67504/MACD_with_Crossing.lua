-- Id: 9915

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41284

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
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
    indicator:name("MACD_with_Crossing oscillator");
    indicator:description("MACD_with_Crossing oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Smooth_Method", "Smooth method", "", "MVA");
    indicator.parameters:addStringAlternative("Smooth_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Smooth_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Smooth_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Smooth_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Smooth_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Smooth_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Smooth_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Smooth_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Smooth_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Smooth_Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("Fast_Period", "Fast MA period", "", 12);
    indicator.parameters:addInteger("Slow_Period", "Slow MA period", "", 26);
    indicator.parameters:addString("Signal_Method", "Signal method", "", "MVA");
    indicator.parameters:addStringAlternative("Signal_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Signal_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Signal_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Signal_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Signal_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Signal_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Signal_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Signal_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Signal_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Signal_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Signal_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Signal_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Signal_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Signal_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Signal_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Signal_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Signal_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Signal_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Signal_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Signal_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Signal_Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("Signal_Period", "Signal period", "", 9);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Transparency", "Transparency", "", 50,0,100);
    indicator.parameters:addColor("Hclr", "Histogram color", "Histogram color", core.rgb(128, 128, 128));
	indicator.parameters:addBoolean("Show", "Show Histogram", "", true);
end

local first;
local source = nil;
local Smooth_Method;
local Fast_Period;
local Slow_Period;
local Signal_Method;
local Signal_Period;
local Fast_MA, Slow_MA;
local Pbuff=nil;
local Mbuff=nil;
local pipSize;
local Signal_MA;
local Hist=nil;
local Show;
function Prepare(nameOnly)
    source = instance.source;
    Smooth_Method=instance.parameters.Smooth_Method;
	Show=instance.parameters.Show;
    Fast_Period=instance.parameters.Fast_Period;
    Slow_Period=instance.parameters.Slow_Period;
    Signal_Method=instance.parameters.Signal_Method;
    Signal_Period=instance.parameters.Signal_Period;
    
	
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Smooth_Method .. ", " .. instance.parameters.Fast_Period .. ", " .. instance.parameters.Slow_Period .. ", " .. instance.parameters.Signal_Method .. ", " .. instance.parameters.Signal_Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");   
	
	
    Fast_MA = core.indicators:create("AVERAGES", source, Smooth_Method, Fast_Period, false);
    Slow_MA = core.indicators:create("AVERAGES", source, Smooth_Method, Slow_Period, false);
	
	first = math.max(Fast_MA.DATA:first(),Slow_MA.DATA:first());
	
	
    Pbuff = instance:addStream("Pbuff", core.Line, name .. ".Pbuff", "Pbuff", instance.parameters.UPclr, first);
	
	Signal_MA = core.indicators:create("AVERAGES", Pbuff, Signal_Method, Signal_Period, false);
	
    Mbuff = instance:addStream("Mbuff", core.Line, name .. ".Mbuff", "Mbuff", instance.parameters.UPclr, Signal_MA.DATA:first());
	 Mbuff:addLevel(0, core.LINE_SOLID, 3, instance.parameters.Hclr);

	if Show then
    Hist = instance:addStream("Hist", core.Bar, name .. ".Hist", "Hist", instance.parameters.Hclr, Signal_MA.DATA:first());
	else
	Hist = instance:addInternalStream(0, 0);
	end
    
	Pbuff:setPrecision(math.max(2, instance.source:getPrecision()));
	Mbuff:setPrecision(math.max(2, instance.source:getPrecision()));
	Hist:setPrecision(math.max(2, instance.source:getPrecision()));
	
    instance:createChannelGroup("M","M" , Pbuff, Mbuff, instance.parameters.UPclr, 100-instance.parameters.Transparency);
    pipSize=source:pipSize();
end

function Update(period, mode)
   if period<first then
   return;
   end
   
    Fast_MA:update(mode);
    Slow_MA:update(mode);
    Pbuff[period]=(Fast_MA.DATA[period]-Slow_MA.DATA[period])/pipSize;
	 
    Signal_MA:update(mode);
	
   if period< Signal_MA.DATA:first() then
   return;
   end
	
    Mbuff[period]=Signal_MA.DATA[period];
    Hist[period]=Pbuff[period]-Mbuff[period];
    if Pbuff[period]>Mbuff[period] then
     Pbuff:setColor(period, instance.parameters.UPclr);
     Mbuff:setColor(period, instance.parameters.UPclr);
    else
     Pbuff:setColor(period, instance.parameters.DNclr);
     Mbuff:setColor(period, instance.parameters.DNclr);
    end
   
end

