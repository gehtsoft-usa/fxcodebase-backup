-- Id: 4294
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
 

function Init()
    indicator:name("RSI oscillator");
    indicator:description("RSI oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RSIPeriod", "RSI Period", "", 8);
    indicator.parameters:addInteger("PeriodK", "Period K", "", 8);
    indicator.parameters:addInteger("SlowPeriod", "Slow Period", "", 3);
    indicator.parameters:addString("MethodMA", "MethodMA", "", "MVA");
    indicator.parameters:addStringAlternative("MethodMA", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MethodMA", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MethodMA", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("MethodMA", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MethodMA", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("MethodMA", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("MethodMA", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("MethodMA", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MethodMA", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("MethodMA", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("MethodMA", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("MethodMA", "T3", "", "T3");
    indicator.parameters:addStringAlternative("MethodMA", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("MethodMA", "Median", "", "Median");
    indicator.parameters:addStringAlternative("MethodMA", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("MethodMA", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("MethodMA", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("MethodMA", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("MethodMA", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("MethodMA", "JSmooth", "", "JSmooth");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local RSIPeriod;
local PeriodK;
local SlowPeriod;
local MethodMA;
local RSIBuffer;
local TempBuffer;
local RSI_O=nil;
local RSI;
local MA;

function Prepare(nameOnly)
    source = instance.source;
    RSIPeriod=instance.parameters.RSIPeriod;
    PeriodK=instance.parameters.PeriodK;
    SlowPeriod=instance.parameters.SlowPeriod;
    MethodMA=instance.parameters.MethodMA;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.RSIPeriod .. ", " .. instance.parameters.PeriodK .. ", " .. instance.parameters.SlowPeriod .. ")";
    instance:name(name);
	if   (nameOnly) then
        return;
    end	
   
    RSIBuffer = instance:addInternalStream(0, 0);
    TempBuffer = instance:addInternalStream(0, 0);
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	
    RSI=core.indicators:create("RSI", source, RSIPeriod);
    MA=core.indicators:create("AVERAGES", TempBuffer, MethodMA, SlowPeriod, false);
	
	first =  MA.DATA:first(), RSI.DATA:first();

	
    RSI_O = instance:addStream("RSI_O", core.Line, name .. ".RSI_O", "RSI_O", instance.parameters.clr, first);
    RSI_O:addLevel(20);
    RSI_O:addLevel(80);
	RSI_O:setWidth(instance.parameters.width);
    RSI_O:setStyle(instance.parameters.style);
	
	
	RSI_O:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)

   if period< source:first()+PeriodK then
   return;
   end
   
    RSI:update(mode);
    RSIBuffer[period]=RSI.DATA[period];
    local LLV, HHV=mathex.minmax(RSIBuffer,period-PeriodK+1, period);
   -- local HHV=core.max(RSIBuffer,core.rangeTo(period-PeriodK+1, period);
    if HHV-LLV>0 then
     TempBuffer[period]=(RSIBuffer[period]-LLV)/(HHV-LLV)*100;
    else
     TempBuffer[period]=0;
    end
	
	if period < first then
	return;
	end
	
	
    MA:update(mode);
    RSI_O[period]=MA.DATA[period];
  
end

