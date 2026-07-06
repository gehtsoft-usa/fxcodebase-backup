-- Id: 869
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1290

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
    indicator:name("KDJ indicator");
    indicator:description("KDJ indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("nPeriod", "nPeriod", "nPeriod", 9);
    indicator.parameters:addDouble("factor_1", "factor_1", "factor_1", 0.6666666);
    indicator.parameters:addDouble("factor_2", "factor_2", "factor_2", 0.3333333);
	
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr_K", "Color K", "Color K", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clr_D", "Color D", "Color D", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clr_J", "Color J", "Color J", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local nPeriod;
local factor_1;
local factor_2;
local buff_K=nil;
local buff_D=nil;
local buff_J=nil;
local RSV;

function Prepare(nameOnly)
    source = instance.source;
    nPeriod=instance.parameters.nPeriod;
    factor_1=instance.parameters.factor_1;
    factor_2=instance.parameters.factor_2;
    first = source:first()+nPeriod;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.nPeriod .. ", " .. instance.parameters.factor_1 .. ", " .. instance.parameters.factor_2 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    RSV = instance:addInternalStream(0, 0);
    buff_K = instance:addStream("buff_K", core.Line, name .. ".K", "K", instance.parameters.clr_K, first);
    buff_K:setPrecision(math.max(2, instance.source:getPrecision()));
	buff_K:setWidth(instance.parameters.width1);
    buff_K:setStyle(instance.parameters.style1);
	
    buff_D = instance:addStream("buff_D", core.Line, name .. ".D", "D", instance.parameters.clr_D, first);
    buff_D:setPrecision(math.max(2, instance.source:getPrecision()));
	buff_D:setWidth(instance.parameters.width2);
    buff_D:setStyle(instance.parameters.style2);
	
    buff_J = instance:addStream("buff_J", core.Line, name .. ".J", "J", instance.parameters.clr_J, first);
    buff_J:setPrecision(math.max(2, instance.source:getPrecision()));
	buff_J:setWidth(instance.parameters.width3);
    buff_J:setStyle(instance.parameters.style3);
end

function Update(period, mode)
    if (period<first) then
	return;
	end
	
     local Cn=source.close[period];
     local Ln=Cn;
     local Hn=Cn;
     for i=0,nPeriod-1,1 do
      Ln=math.min(Ln,source.low[period-i]);
      Hn=math.max(Hn,source.high[period-i]);
     end
     if Hn-Ln~=0. then
      RSV[period]=(Cn-Ln)/(Hn-Ln)*100.;
     else
      RSV[period]=50.;
     end
     buff_K[period]=factor_1*buff_K[period-1]+factor_2*RSV[period];
     buff_D[period]=factor_1*buff_D[period-1]+factor_2*buff_K[period];
     buff_J[period]=3.*buff_D[period]-2.*buff_K[period];

      
end

