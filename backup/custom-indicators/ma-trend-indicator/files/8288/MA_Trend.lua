-- Id: 3175
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3481

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("MA Trend indicator");
    indicator:description("MA Trend indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
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
    indicator.parameters:addInteger("Start_Period", "Start period", "", 10);
    indicator.parameters:addInteger("Step_Period", "Step period", "", 10);
    indicator.parameters:addInteger("Count_MA", "Count of MAs", "", 50);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Lineclr", "Color of line", "Color of line", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(0, 0, 255));
end

local first;
local source = nil;
local Method;
local Start_Period;
local Step_Period;
local Count_MA;
local MAs={};
local i;
local LineBuff=nil;
local UPBuff=nil;
local DNBuff=nil;

function Prepare(nameOnly)
    source = instance.source;
    Method=instance.parameters.Method;
    Start_Period=instance.parameters.Start_Period;
    Step_Period=instance.parameters.Step_Period;
    Count_MA=instance.parameters.Count_MA;
    first=source:first()
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");   
	 
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.Start_Period .. ", " .. instance.parameters.Step_Period .. ", " .. instance.parameters.Count_MA .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    
    for i=1,Count_MA,1 do
        MAs[i]=core.indicators:create("AVERAGES", source, Method, Start_Period+(i-1)*Step_Period, false);
        first = math.max(first,  MAs[i].DATA:first()) ;
    end
    
    LineBuff = instance:addStream("LineBuff", core.Line, name .. ".Line", "Line", instance.parameters.Lineclr, first);
    LineBuff:setPrecision(math.max(2, instance.source:getPrecision()));
    UPBuff = instance:addStream("UPBuff", core.Bar, name .. ".UP", "UP", instance.parameters.UPclr, first);
    UPBuff:setPrecision(math.max(2, instance.source:getPrecision()));
    DNBuff = instance:addStream("DNBuff", core.Bar, name .. ".DN", "DN", instance.parameters.DNclr, first);
    DNBuff:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if period<first then
   return;
   end
   
	   local Sum=0;
		for i=1,Count_MA,1 do
		 MAs[i]:update(mode);
		 if source[period]>MAs[i].DATA[period] then
		  Sum=Sum+1;
		 elseif source[period]<MAs[i].DATA[period] then 
		  Sum=Sum-1;
		 end
    end
	
    LineBuff[period]=Sum/Count_MA;
    if LineBuff[period]>0 then
     UPBuff[period]=LineBuff[period];
     DNBuff[period]=nil;
    else
     DNBuff[period]=LineBuff[period];
     UPBuff[period]=nil;
    end
   
end

