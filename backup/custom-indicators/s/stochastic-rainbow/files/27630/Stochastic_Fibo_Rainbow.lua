-- Id: 5977
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Stochastic Fibo Rainbow indicator");
    indicator:description("Stochastic Fibo Rainbow indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("K_Period", "Initial K_Period", "", 8);
    indicator.parameters:addInteger("D_Period", "Initial D_Period", "", 5);
    indicator.parameters:addInteger("D_Slowing", "Initial D_Slowing", "", 3);
    indicator.parameters:addInteger("StNumber", "Number of stochastic", "", 5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 0, 128));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local K_Period;
local D_Period;
local D_Slowing;
local FiboK;
local Ind_St={};
local St={};

function Prepare()
    source = instance.source;
    K_Period=instance.parameters.K_Period;
    D_Period=instance.parameters.D_Period;
    D_Slowing=instance.parameters.D_Slowing;
    StNumber=instance.parameters.StNumber;
     
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.K_Period .. ", " .. instance.parameters.D_Period .. ", " .. instance.parameters.D_Slowing .. ", " .. instance.parameters.StNumber .. ")";
    local K_P=K_Period;
    local D_P=D_Period;
    local D_S=D_Slowing;
    FiboK=(1+math.sqrt(5))/2;
	
    for i=1,StNumber,1 do
     Ind_St[i]=core.indicators:create("STOCHASTIC", source, K_P, D_S, D_P,"MVA","MVA");
     K_P=math.floor(K_P*FiboK+0.5);
     D_P=math.floor(D_P*FiboK+0.5);
     D_S=math.floor(D_S*FiboK+0.5);
     St[i]=instance:addStream("St" .. i, core.Line, name .. ".St" .. i, "St" .. i, instance.parameters.clr, Ind_St[i].D:first());
    St[i]:setPrecision(math.max(2, instance.source:getPrecision()));
     St[i]:setWidth(instance.parameters.widthLinReg);
     St[i]:setStyle(instance.parameters.styleLinReg);
    end
end

function Update(period, mode)
    
    for i=1,StNumber,1 do
     Ind_St[i]:update(mode);
	  if period > Ind_St[i].D:first() then
     St[i][period]=Ind_St[i].D[period];
	 end
    end
   
end

