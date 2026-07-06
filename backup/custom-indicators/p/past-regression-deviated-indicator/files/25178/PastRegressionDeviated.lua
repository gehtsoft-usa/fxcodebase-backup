-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=12837

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
    indicator:name("PastRegressionDeviated indicator");
    indicator:description("PastRegressionDeviated indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 55);
    indicator.parameters:addDouble("StdChannel1", "StdChannel1", "", 1);
    indicator.parameters:addDouble("StdChannel2", "StdChannel2", "", 2);
    indicator.parameters:addDouble("StdChannel3", "StdChannel3", "", 3);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Uclr", "Upper lines Color", "Upper lines Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Lclr", "Lower lines Color", "Lower lines Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Mclr", "Middle line Color", "Middle line Color", core.rgb(128, 128, 0));
    indicator.parameters:addColor("TLclr", "Trend line Color", "Trend line Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Lines width", "Lines width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Lines style", "Lines style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("TLwidth", "Trend line width", "Trend line width", 1, 1, 5);
    indicator.parameters:addInteger("TLstyle", "Trend line style", "Trend line style", core.LINE_SOLID);
    indicator.parameters:setFlag("TLstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local StdChannel1;
local StdChannel2;
local StdChannel3;
local Mean;
local U1=nil;
local U2=nil;
local U3=nil;
local L1=nil;
local L2=nil;
local L3=nil;
local Mean=nil;
local sumx, sumx2, c;
local StdDev;

 function Prepare(nameOnly)  
    source = instance.source;
    Period=instance.parameters.Period;
    StdChannel1=instance.parameters.StdChannel1;
    StdChannel2=instance.parameters.StdChannel2;
    StdChannel3=instance.parameters.StdChannel3;
    first = source:first()+Period;
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.StdChannel1 .. ", " .. instance.parameters.StdChannel2 .. ", " .. instance.parameters.StdChannel3 .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("STDDEV") ~= nil, "Please, download and install STDDEV.LUA indicator");   
	
    StdDev=core.indicators:create("STDDEV", source, Period);
   
    U1 = instance:addStream("U1", core.Line, name .. ".U1", "U1", instance.parameters.Uclr, first);
    U2 = instance:addStream("U2", core.Line, name .. ".U2", "U2", instance.parameters.Uclr, first);
    U3 = instance:addStream("U3", core.Line, name .. ".U3", "U3", instance.parameters.Uclr, first);
    L1 = instance:addStream("L1", core.Line, name .. ".L1", "L1", instance.parameters.Lclr, first);
    L2 = instance:addStream("L2", core.Line, name .. ".L2", "L2", instance.parameters.Lclr, first);
    L3 = instance:addStream("L3", core.Line, name .. ".L3", "L3", instance.parameters.Lclr, first);
    Mean = instance:addStream("Mean", core.Line, name .. ".Mean", "Mean", instance.parameters.Mclr, first);
    U1:setWidth(instance.parameters.widthLinReg);
    U1:setStyle(instance.parameters.styleLinReg);
    U2:setWidth(instance.parameters.widthLinReg);
    U2:setStyle(instance.parameters.styleLinReg);
    U3:setWidth(instance.parameters.widthLinReg);
    U3:setStyle(instance.parameters.styleLinReg);
    L1:setWidth(instance.parameters.widthLinReg);
    L1:setStyle(instance.parameters.styleLinReg);
    L2:setWidth(instance.parameters.widthLinReg);
    L2:setStyle(instance.parameters.styleLinReg);
    L3:setWidth(instance.parameters.widthLinReg);
    L3:setStyle(instance.parameters.styleLinReg);
    Mean:setWidth(instance.parameters.widthLinReg);
    Mean:setStyle(instance.parameters.styleLinReg);
    sumx=(Period+1)*Period/2;
    sumx2=Period*(Period+1)*(2*Period+1)/6;
    c=sumx2*(Period)-sumx*sumx;
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    local sumy=0;
    local sumxy=0;
    local i;
    for i=1,Period,1 do
     sumy=sumy+source[period-i];
     sumxy=sumxy+source[period-i]*i;
    end
    local b=(sumxy*(Period)-sumx*sumy)/c;
    local a=(sumy-sumx*b)/(Period);
    local Price2=a;
    local Price1=a+b*(Period);
    Mean[period]=Price2;
    StdDev:update(mode);
    U1[period]=Mean[period]+StdChannel1*StdDev.DATA[period];
    U2[period]=Mean[period]+StdChannel2*StdDev.DATA[period];
    U3[period]=Mean[period]+StdChannel3*StdDev.DATA[period];
    L1[period]=Mean[period]-StdChannel1*StdDev.DATA[period];
    L2[period]=Mean[period]-StdChannel2*StdDev.DATA[period];
    L3[period]=Mean[period]-StdChannel3*StdDev.DATA[period];
    core.host:execute("drawLine", 1, source:date(period-Period), Price1, source:date(period), Price2, instance.parameters.TLclr, instance.parameters.TLstyle, instance.parameters.TLwidth);
    
end

