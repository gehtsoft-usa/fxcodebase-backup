-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=31126
-- Id: 8357

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
    indicator:name("BOBB1 indicator");
    indicator:description("BOBB1 indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20);
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
    indicator.parameters:addDouble("Deviation", "Deviation", "", 1);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Val1Clr", "Val 1 color", "Val 1 color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("Val2Clr", "Val 2 color", "Val 2 color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DevClr", "Dev color", "Dev color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Method;
local Deviation;
local MA;
local Val1=nil;
local Val2=nil;
local Dev=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Method=instance.parameters.Method;
    Deviation=instance.parameters.Deviation;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.Deviation .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	
    MA = core.indicators:create("AVERAGES", source, Method, Period, false);
	first =MA.DATA:first();
	
    Val1 = instance:addStream("Val1", core.Line, name .. ".Val1", "Val1", instance.parameters.Val1Clr, first+Period);
    Val2 = instance:addStream("Val2", core.Line, name .. ".Val2", "Val2", instance.parameters.Val2Clr, first+Period);
    Dev = instance:addStream("Dev", core.Line, name .. ".Dev", "Dev", instance.parameters.DevClr, first);
    Val1:setWidth(instance.parameters.widthLinReg);
    Val1:setStyle(instance.parameters.styleLinReg);
    Val2:setWidth(instance.parameters.widthLinReg);
    Val2:setStyle(instance.parameters.styleLinReg);
    Dev:setWidth(instance.parameters.widthLinReg);
    Dev:setStyle(instance.parameters.styleLinReg);
	
	
	Val1:setPrecision(math.max(2, instance.source:getPrecision()));
	Val2:setPrecision(math.max(2, instance.source:getPrecision()));
	Dev:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    local i;
    MA:update(mode);
	
    if (period<first+Period) then
   return;
   end
    local sum=0;
    for i=0,Period-1,1 do
     sum=sum+(source[period-i]-MA.DATA[period-i])*(source[period-i]-MA.DATA[period-i]);
    end
    Dev[period]=Deviation*math.sqrt(sum/Period);
    Val1[period]=(source[period]-MA.DATA[period])-Dev[period];
    Val2[period]=(MA.DATA[period]-source[period])-Dev[period];
    
end

