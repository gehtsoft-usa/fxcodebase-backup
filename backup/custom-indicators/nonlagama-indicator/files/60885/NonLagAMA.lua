-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=36259
-- Id: 9086

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("NonLagAMA indicator");
    indicator:description("NonLagAMA indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period0", "Period", "", 12);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 0);
    indicator.parameters:addInteger("Filter", "Filter", "", 0);
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
    indicator.parameters:addInteger("Period1", "Smooth period", "", 12);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period0;
local Deviation;
local Filter;
local Method;
local Period1;
local NonLagAMA=nil;
local Cycle;
local Coeff;
local Length0;
local Len;
local res1;
local res;
local res2;
local FPoint;
local MA;
local Value={};
local Count={};
local count;

function Prepare(nameOnly)
    source = instance.source;
    Period0=instance.parameters.Period0;
    Deviation=instance.parameters.Deviation;
    Filter=instance.parameters.Filter;
    Method=instance.parameters.Method;
    Period1=instance.parameters.Period1;
	 
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period0 .. ", " .. instance.parameters.Deviation .. ", " .. instance.parameters.Filter .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.Period1 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	
    MA = core.indicators:create("AVERAGES", source, Method, Period1, false);
	first = MA.DATA:first();
    NonLagAMA = instance:addStream("NonLagAMA", core.Line, name .. ".NonLagAMA", "NonLagAMA", instance.parameters.UPclr, first);
    NonLagAMA:setWidth(instance.parameters.widthLinReg);
    NonLagAMA:setStyle(instance.parameters.styleLinReg);
    Cycle=4;
    Coeff=3*math.pi; 
    Length0=math.min(Period0-1, 2); 
    Len=Period0*Cycle+Period0;   
    res1=1/(Length0-1);   
    res=Cycle*Period0-1;
    if res==0 then
     res=1;
    end
    res2=(2*Cycle-1)/res; 
    FPoint=Filter*source:pipSize(); 
    Count[0]=0;
    count=1;
    local i;
    for i=0, Len, 1 do
     Value[i]=0;
     Count[i]=0;
    end
end

function Update(period, mode)
   
    MA:update(mode);
	if period<first then
	return;
	end
	
    Value[Count[0]]=MA.DATA[period];
    local i;
    local Weight=0;
    local Sum=0;
    local t=0;
    for i=0, Len-1, 1 do
     local g=1/(Coeff*t+1);
     if t<=0.5 then
      g=1;
     end
     local Alpha=g*math.cos(t*math.pi);
     Sum=Sum+Alpha*Value[Count[i]];
     Weight=Weight+Alpha;
     if t<1 then
      t=t+res1;
     elseif t<Len-1 then
      t=t+res2; 
     end
    end 
	
	
    if Weight~=0 then
     NonLagAMA[period]=(1+Deviation/100)*Sum/Weight;
    end
    if period==source:size()-1 and math.abs(NonLagAMA[period]-NonLagAMA[period-1])<FPoint then
     NonLagAMA[period]=NonLagAMA[period-1];
    end
    if NonLagAMA[period]>=NonLagAMA[period-1] then
     NonLagAMA:setColor(period, instance.parameters.UPclr);
    else
     NonLagAMA:setColor(period, instance.parameters.DNclr);
    end
    if period~=source:size()-1 then
     count=count-1;
     if count<0 then
      count=Len-1;
     end
     for i=0, Len-1, 1 do
      if i+count>Len-1 then
       Count[i]=i+count-Len;
      else
       Count[i]=i+count;
      end
     end 
      
    end
 
end

