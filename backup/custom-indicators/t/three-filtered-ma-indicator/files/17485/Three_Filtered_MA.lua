-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7883

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
    indicator:name("Three Filtered MA indicator");
    indicator:description("Three Filtered MA indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 10);
    indicator.parameters:addString("Method", "Method", "", "Two-Pole Butterworth Filter");
    indicator.parameters:addStringAlternative("Method", "Two-Pole Butterworth Filter", "", "Two-Pole Butterworth Filter");
    indicator.parameters:addStringAlternative("Method", "Three-Pole Butterworth Filter", "", "Three-Pole Butterworth Filter");
    indicator.parameters:addStringAlternative("Method", "Three-Pole Super Smoother Filter", "", "Three-Pole Super Smoother Filter");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Method;
local FMA=nil;
local Method_;
local updateParams;
local UpdateFunction;

function Prepare(onlyName)
    source = instance.source;
    Period=instance.parameters.Period;
    Method=instance.parameters.Method;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Method .. ")";
    instance:name(name);
    if onlyName then
        return;
    end
    if Method=="Two-Pole Butterworth Filter" then
     Method_="M1";
    elseif Method=="Three-Pole Butterworth Filter" then
     Method_="M2";
    else
     Method_="M3";
    end
    if onlyName then
        return ;
    end

    updateParams = _G[Method_ .. "Init"](source, Period);
    UpdateFunction = _G[Method_ .. "Update"];

    FMA = instance:addStream("FMA", core.Line, name .. ".FMA", "FMA", instance.parameters.clr, first);
    FMA:setWidth(instance.parameters.widthLinReg);
    FMA:setStyle(instance.parameters.styleLinReg);

    first = updateParams.first;
    updateParams.buffer = FMA;
end

function Update(period, mode)
   if (period>=first) then
    UpdateFunction(updateParams, period, mode);
   end 
end

function M1Init(source,n)
 local p={};
 p.first=source:first();
 p.n=n;
 p.source=source;
 local sqrt2=math.sqrt(2);
 local a1=math.exp(-sqrt2*math.pi/Period);
 p.coeff2=2*a1*math.cos(sqrt2*math.pi/Period);
 p.coeff3=-a1*a1;
 p.coeff1=(1-p.coeff2+a1*a1)/4;
 return p;
end

function M1Update(params,period,mode)
 if period>=params.first+2 then
  params.buffer[period]=params.coeff1*(params.source[period]+2*params.source[period-1]+params.source[period-2])+params.coeff2*params.buffer[period-1]+params.coeff3*params.buffer[period-2];
 else
  params.buffer[period]=params.source[period];
 end 
end

function M2Init(source,n)
 local p={};
 p.first=source:first();
 p.n=n;
 p.source=source;
 local a1=math.exp(-math.pi/Period);
 local b1=2*a1*math.cos(math.sqrt(3)*math.pi/Period);
 local c1=a1*a1;
 p.coeff2=b1+c1;
 p.coeff3=-(c1+b1*c1);
 p.coeff4=c1*c1;
 p.coeff1=(1-b1+c1)*(1-c1)/8;
 return p;
end

function M2Update(params,period,mode)
 if period>=params.first+3 then
  params.buffer[period]=params.coeff1*(params.source[period]+3*params.source[period-1]+3*params.source[period-2]+params.source[period-3])+params.coeff2*params.buffer[period-1]+params.coeff3*params.buffer[period-2]+params.coeff4*params.buffer[period-3];
 else
  params.buffer[period]=params.source[period];
 end 
end

function M3Init(source,n)
 local p={};
 p.first=source:first();
 p.n=n;
 p.source=source;
 local a1=math.exp(-math.pi/Period);
 local b1=2*a1*math.cos(math.sqrt(3)*math.pi/Period);
 local c1=a1*a1;
 p.coeff2=b1+c1;
 p.coeff3=-(c1+b1*c1);
 p.coeff4=c1*c1;
 p.coeff1=1-p.coeff2-p.coeff3-p.coeff4;
 return p;
end

function M3Update(params,period,mode)
 if period>=params.first+3 then
  params.buffer[period]=params.coeff1*params.source[period]+params.coeff2*params.buffer[period-1]+params.coeff3*params.buffer[period-2]+params.coeff4*params.buffer[period-3];
 else
  params.buffer[period]=params.source[period];
 end 
end

