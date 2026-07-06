-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60370
-- Id: 11248

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
    indicator:name("Trigger lines indicator");
    indicator:description("Trigger lines indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Regression_Period", "Regression period", "", 80);
    indicator.parameters:addInteger("EMA_Period", "EMA period", "", 20);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Regression_Period;
local EMA_Period;
local LR=nil;
local Signal=nil;
local SumBars, SumSqrBars, Num2;
local EMA;

function Prepare(nameOnly)
    source = instance.source;
    Regression_Period=instance.parameters.Regression_Period;
    EMA_Period=instance.parameters.EMA_Period;
	
	SumBars=Regression_Period*(Regression_Period-1)/2;
    SumSqrBars=(Regression_Period-1)*Regression_Period*(2*Regression_Period-1)/6;
    Num2=SumBars*SumBars-Regression_Period*SumSqrBars;
	
	
    first = source:first()+Regression_Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Regression_Period .. ", " .. instance.parameters.EMA_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    LR = instance:addStream("LR", core.Line, name .. ".LR", "LR", instance.parameters.UPclr, first);
    
    LR:setWidth(instance.parameters.widthLinReg);
    LR:setStyle(instance.parameters.styleLinReg);
	
	 EMA = core.indicators:create("EMA", LR, EMA_Period);
	 
	Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.UPclr, EMA.DATA:first()); 
    Signal:setWidth(instance.parameters.widthLinReg);
    Signal:setStyle(instance.parameters.styleLinReg);
   
   
end

function Update(period, mode)
   if period<first then
   return;
   end
   
    local SumY, Sum1, Slope = 0, 0, 0;
    local i;
    for i=0, Regression_Period-1, 1 do
     SumY=SumY+source[period-i];
     Sum1=Sum1+i*source[period-i];
    end
    local Sum2=SumBars*SumY;
    local Num1=Regression_Period*Sum1-Sum2;
    Slope=Num1/Num2;
    local Intercept=(SumY-Slope*SumBars)/Regression_Period;
    LR[period]=Intercept+Slope*(Regression_Period-1);
    EMA:update(mode);
	
	if period < EMA.DATA:first() then
	return;
	end
	
    Signal[period]=EMA.DATA[period];
    if LR[period]>=Signal[period] then
     LR:setColor(period, instance.parameters.UPclr);
     Signal:setColor(period, instance.parameters.UPclr);
    else
     LR:setColor(period, instance.parameters.DNclr);
     Signal:setColor(period, instance.parameters.DNclr);
    end
   
end

