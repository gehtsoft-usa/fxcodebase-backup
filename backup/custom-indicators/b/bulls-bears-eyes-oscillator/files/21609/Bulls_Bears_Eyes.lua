-- Id: 5395
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10400

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
    indicator:name("Bulls-Bears Eyes indicator");
    indicator:description("Bulls-Bears Eyes indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("Period", "Period", "", 13);
    indicator.parameters:addDouble("Gamma", "Gamma", "", 0.6);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Gamma;
local BBE=nil;
local Bulls;
local Bears;
local L0;
local L1;
local L2;
local L3;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Gamma=instance.parameters.Gamma;
 
	
	assert(core.indicators:findIndicator("BULLS") ~= nil, "Please, download and install BULLS.LUA indicator");    
	assert(core.indicators:findIndicator("BEARS") ~= nil, "Please, download and install BEARS.LUA indicator");
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Gamma .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Bulls = core.indicators:create("BULLS", source, Period);
    Bears = core.indicators:create("BEARS", source, Period);
	
	first = Bulls.DATA:first();
	 
    L0=instance:addInternalStream(first, 0);
    L1=instance:addInternalStream(first, 0);
    L2=instance:addInternalStream(first, 0);
    L3=instance:addInternalStream(first, 0);
    BBE = instance:addStream("BBE", core.Line, name .. ".Bulls-Bears Eyes", "Bulls-Bears Eyes", instance.parameters.clr, first);
    BBE:setWidth(instance.parameters.widthLinReg);
    BBE:setStyle(instance.parameters.styleLinReg);
    BBE:addLevel(0);
    BBE:addLevel(0.25);
    BBE:addLevel(0.5);
    BBE:addLevel(0.75);
    BBE:addLevel(1);
	
	BBE:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
   
    Bulls:update(mode);
    Bears:update(mode);
    L0[period]=(1-Gamma)*(Bulls.DATA[period]+Bears.DATA[period])+Gamma*L0[period-1];
    L1[period]=-Gamma*L0[period]+L0[period-1]+Gamma*L1[period-1];
    L2[period]=-Gamma*L1[period]+L1[period-1]+Gamma*L2[period-1];
    L3[period]=-Gamma*L2[period]+L2[period-1]+Gamma*L3[period-1];
    local CU=0;
    local CD=0;
    if L0[period]>=L1[period] then
     CU=L0[period]-L1[period];
    else
     CD=L1[period]-L0[period];
    end
    if L1[period]>=L2[period] then
     CU=CU+L1[period]-L2[period];
    else
     CD=CD+L2[period]-L1[period];
    end
    if L2[period]>=L3[period] then
     CU=CU+L2[period]-L3[period];
    else
     CD=CD+L3[period]-L2[period];
    end
    local result=0;
    if CU+CD~=0 then
     result=CU/(CU+CD);
    end
    BBE[period]=result;
   
end

