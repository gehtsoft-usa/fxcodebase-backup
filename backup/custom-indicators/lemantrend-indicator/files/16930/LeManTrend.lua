-- Id: 4861
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7634

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


function Init()
    indicator:name("LeManTrend indicator");
    indicator:description("LeManTrend indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Min", "Min", "", 13);
    indicator.parameters:addInteger("Middle", "Middle", "", 21);
    indicator.parameters:addInteger("Max", "Max", "", 34);
    indicator.parameters:addInteger("MA_Period", "MA_Period", "", 3);
    indicator.parameters:addString("Method", "Method", "", "MVA");
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

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("Transparency", "Transparency", "", 50,0,100);
end

local first;
local source = nil;
local Min;
local Middle;
local Max;
local MA_Period;
local Method;
local LL;
local HH;
local Bulls_MA;
local Bears_MA;
local Bulls=nil;
local Bears=nil;
local MaxPeriod;
local CloudUP=nil;
local CloudDN=nil;

function Prepare(nameOnly) 
    source = instance.source;
    Min=instance.parameters.Min;
    Middle=instance.parameters.Middle;
    Max=instance.parameters.Max;
    MA_Period=instance.parameters.MA_Period;
    Method=instance.parameters.Method;
	 MaxPeriod=math.max(Min,Middle,Max);
	 
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Min .. ", " .. instance.parameters.Middle .. ", " .. instance.parameters.Max .. ", " .. instance.parameters.MA_Period .. ", " .. instance.parameters.Method .. ")";
    instance:name(name);
	
	 if   (nameOnly) then
        return;
    end
     
    LL = instance:addInternalStream(0, 0);
    HH = instance:addInternalStream(0, 0);
    CloudUP=instance:addInternalStream(0, 0);
    CloudDN=instance:addInternalStream(0, 0);
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator"); 
	
    Bulls_MA = core.indicators:create("AVERAGES", HH, Method, MA_Period, false);
    Bears_MA = core.indicators:create("AVERAGES", LL, Method, MA_Period, false);
	
	first = source:first()+MaxPeriod;
   
	
   
    Bulls = instance:addStream("Bulls", core.Line, name .. ".Bulls", "Bulls", instance.parameters.UPclr, Bulls_MA.DATA:first());
    Bulls:setPrecision(math.max(2, instance.source:getPrecision()));
    Bears = instance:addStream("Bears", core.Line, name .. ".Bears", "Bears", instance.parameters.DNclr, Bulls_MA.DATA:first());
    Bears:setPrecision(math.max(2, instance.source:getPrecision()));
    Bulls:setWidth(instance.parameters.widthLinReg);
    Bulls:setStyle(instance.parameters.styleLinReg);
    Bears:setWidth(instance.parameters.widthLinReg);
    Bears:setStyle(instance.parameters.styleLinReg);
	
    instance:createChannelGroup("Cloud","Cloud" , CloudUP, CloudDN, instance.parameters.UPclr, 100-instance.parameters.Transparency);
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    local High1=mathex.max(source.high,core.rangeTo(period,Min));
    local High2=mathex.max(source.high,core.rangeTo(period,Middle));
    local High3=mathex.max(source.high,core.rangeTo(period,Max));
    local Low1=mathex.min(source.low,core.rangeTo(period,Min));
    local Low2=mathex.min(source.low,core.rangeTo(period,Middle));
    local Low3=mathex.min(source.low,core.rangeTo(period,Max));
	
	
	
    HH[period]=3*source.high[period]-High1-High2-High3;
    LL[period]=Low1+Low2+Low3-3*source.low[period];
	
	if period < Bulls_MA.DATA:first() then
	return;
	end
	
    Bulls_MA:update(mode);
    Bears_MA:update(mode);
    Bulls[period]=Bulls_MA.DATA[period];
    Bears[period]=Bears_MA.DATA[period];
    CloudUP[period]=Bulls[period];
    CloudDN[period]=Bears[period];
	
    if Bears[period]>Bulls[period] then
     CloudUP:setColor(period,instance.parameters.DNclr);
    else
     CloudUP:setColor(period,instance.parameters.UPclr); 
    end
    
end

