-- Id: 5996
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("StochasticRSI Fibo Rainbow indicator");
    indicator:description("StochasticRSI Fibo Rainbow indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("K_Period", "Initial K_Period", "", 5);
    indicator.parameters:addInteger("K_Slowing", "Initial K_Slowing", "", 3);
    indicator.parameters:addInteger("D_Slowing", "Initial D_Slowing", "", 3);
    indicator.parameters:addInteger("RSI_Period", "RSI_Period", "", 8);

    indicator.parameters:addGroup("Style");
   --  indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 0, 128)); 
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local K_Slowing;
local D_Period;
local D_Slowing;
local FiboK;
local Ind_St={};
local St={};

function Prepare()
    source = instance.source;
    K_Period=instance.parameters.K_Period;
   K_Slowing=instance.parameters.K_Slowing;
    D_Slowing=instance.parameters.D_Slowing;
    RSI_Period=instance.parameters.RSI_Period;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.RSI_Period .. ", " .. instance.parameters.K_Period .. ", " .. instance.parameters.K_Slowing .. ", " .. instance.parameters.D_Slowing .. ")";
    local K_P=K_Period;
    local K_S=K_Slowing;
    local D_S=D_Slowing;
    FiboK=(1+math.sqrt(5))/2;
	assert(core.indicators:findIndicator("STOCHASTICRSI") ~= nil, "Please, download and install STOCHASTICRSI.LUA indicator");  
	
    for i=1,RSI_Period,1 do
     Ind_St[i]=core.indicators:create("STOCHASTICRSI", source, K_P, K_S, D_P,"MVA","MVA");
     K_P=math.floor(K_P*FiboK+0.5);
     K_S=math.floor(K_S*FiboK+0.5);
     D_S=math.floor(D_S*FiboK+0.5);
     St[i]=instance:addStream("St" .. i, core.Line, name .. ".St" .. i, "St" .. i, instance.parameters.clr, Ind_St[i].D:first());
    St[i]:setPrecision(math.max(2, instance.source:getPrecision()));
	 
     St[i]:setWidth(instance.parameters.widthLinReg);
     St[i]:setStyle(instance.parameters.styleLinReg);
    end
end

function Update(period, mode)
    
    for i=1,RSI_Period,1 do
     Ind_St[i]:update(mode);
	 	  if period > Ind_St[i].D:first() then

     St[i][period]=Ind_St[i].D[period];
	 end
    end
   
end



