-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=14866
-- Id: 6077

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Two cloud trend indicator");
    indicator:description("Two cloud trend indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 50);
    indicator.parameters:addInteger("ATR_Period", "ATR_Period", "", 10);
    indicator.parameters:addInteger("D_Period", "D_Period", "", 34);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("lowess1_clr", "TCT Trend High Color", "TCT Trend High Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("lowess2_clr", "TCT Trend Low Color", "TCT Trend Low Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DH_clr", "TCT High trigger Color", "TCT High trigger Color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("DL_clr", "TCT Low trigger Color", "TCT Low trigger Color", core.rgb(0, 255, 255));
    indicator.parameters:addColor("FU_clr", "TCT Donchian High Color", "TCT Donchian High Color", core.rgb(255, 255, 0));
    indicator.parameters:addColor("FL_clr", "TCT Donchian Low Color", "TCT Donchian Low Color", core.rgb(255, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("UPclr", "UP cloud Color", "UP cloud Color", core.rgb(128, 128, 0));
    indicator.parameters:addColor("DNclr", "DN cloud Color", "DN cloud Color", core.rgb(0, 128, 128));
    indicator.parameters:addInteger("Transparency", "Transparency", "", 50,0,100);
end

local first;
local source = nil;
local Period;
local ATR_Period;
local D_Period;
local ATR;
local MA;
local lowess1=nil;
local lowess2=nil;
local DH=nil;
local DL=nil;
local FU=nil;
local FL=nil;
local n;
local p;
local co;
local MaxPeriod;
local H1, H2, L1, L2;
local w={};
local a, b, e, abe;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    n=Period*2-4;
    ATR_Period=instance.parameters.ATR_Period;
    D_Period=instance.parameters.D_Period;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.ATR_Period .. ")";
    instance:name(name);
    if nameOnly then
        return
    end
    ATR = core.indicators:create("ATR", source, ATR_Period);
    MA = core.indicators:create("MVA", source.close, n);
	
	first = math.max(ATR.DATA:first(), MA.DATA:first());
    flag=instance:addInternalStream(0, 0);
    co=instance:addInternalStream(0, 0);
    H1=instance:addInternalStream(0, 0);
    H2=instance:addInternalStream(0, 0);
    L1=instance:addInternalStream(0, 0);
    L2=instance:addInternalStream(0, 0);
    lowess1 = instance:addStream("lowess1", core.Line, name .. ".TCT Trend High", "TCT Trend High", instance.parameters.lowess1_clr, first);
    lowess2 = instance:addStream("lowess2", core.Line, name .. ".TCT Trend Low", "TCT Trend Low", instance.parameters.lowess2_clr, first);
    DH = instance:addStream("DH", core.Line, name .. ".TCT High trigger", "TCT High trigger", instance.parameters.DH_clr, first);
    DL = instance:addStream("DL", core.Line, name .. ".TCT Low trigger", "TCT Low trigger", instance.parameters.DL_clr, first);
    FU = instance:addStream("FU", core.Line, name .. ".TCT Donchian High", "TCT Donchian High", instance.parameters.FU_clr, first);
    FL = instance:addStream("FL", core.Line, name .. ".TCT Donchian Low", "TCT Donchian Low", instance.parameters.FL_clr, first);
    lowess1:setWidth(instance.parameters.widthLinReg);
    lowess1:setStyle(instance.parameters.styleLinReg);
    lowess2:setWidth(instance.parameters.widthLinReg);
    lowess2:setStyle(instance.parameters.styleLinReg);
    DH:setWidth(instance.parameters.widthLinReg);
    DH:setStyle(instance.parameters.styleLinReg);
    DL:setWidth(instance.parameters.widthLinReg);
    DL:setStyle(instance.parameters.styleLinReg);
    FU:setWidth(instance.parameters.widthLinReg);
    FU:setStyle(instance.parameters.styleLinReg);
    FL:setWidth(instance.parameters.widthLinReg);
    FL:setStyle(instance.parameters.styleLinReg);
    p=math.floor(Period/2);
    Period=2*p+1;
    MaxPeriod=math.max(p,D_Period);
    instance:createChannelGroup("HGroup","HG" , H1, H2, instance.parameters.UPclr, 100-instance.parameters.Transparency);
    instance:createChannelGroup("LGroup","LG" , L1, L2, instance.parameters.UPclr, 100-instance.parameters.Transparency);
    local i;
    a, b, e = 0, 0, 0;
    for i=1,Period,1 do
     local ww=math.abs((p-i)/p);
     ww=ww*ww*ww;
     ww=1-ww;
     w[Period-i+1]=ww*ww*ww;
     a=a+w[Period-i+1];
     b=b+w[Period-i+1]*(Period-i+1);
     e=e+w[Period-i+1]*(Period-i+1)*(Period-i+1);
    end
    abe=a*e-b*b;
end

function Update(period, mode)
   if (period<first+MaxPeriod) then
   return;
   end
   
    ATR:update(mode);
    MA:update(mode);

    co[period]=(MA.DATA[period]-MA.DATA[period-1]+source.close[period-p]/n)*n;
    
    local c, d = 0, 0;
    local i, z;
    for i=1,Period,1 do
     z=period-i+1;
     c=c+co[z]*w[i];
     d=d+co[z]*w[i]*i;
    end
    local alpha=(a*d-b*c)/abe;
    local beta=(c*e-b*d)/abe;
    local lowess=alpha*(p+1)+beta;
    lowess1[period]=lowess+ATR.DATA[period]*1.8;
    lowess2[period]=lowess-ATR.DATA[period]*1.8;
    FL[period]=mathex.min(source.low,core.rangeTo(period,D_Period));
    FU[period]=mathex.max(source.high,core.rangeTo(period,D_Period));
    local R=FU[period]-FL[period];
    DL[period]=FL[period]+R*0.236;
    DH[period]=FL[period]+R*0.786;
    H1[period]=lowess1[period];
    H2[period]=DH[period];
    L1[period]=lowess2[period];
    L2[period]=DL[period];
    if H1[period]>H2[period] then
     H1:setColor(period,instance.parameters.UPclr);
    else
     H1:setColor(period,instance.parameters.DNclr);
    end
    if L1[period]>L2[period] then
     L1:setColor(period,instance.parameters.UPclr);
    else
     L1:setColor(period,instance.parameters.DNclr);
    end
  
end

