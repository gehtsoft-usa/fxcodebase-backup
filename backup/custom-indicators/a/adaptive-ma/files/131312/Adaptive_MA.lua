-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69415

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


function Init()
    indicator:name("Adaptive MA indicator");
    indicator:description("Adaptive MA indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 100);
    indicator.parameters:addInteger("Fast_Period", "Fast period", "", 2);
    indicator.parameters:addInteger("Slow_Period", "Slow period", "", 10);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Fast_Period;
local Slow_Period;
local NoiseSt;
local Slow_SC, Fast_SC;
local Adapt_MA=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Fast_Period=instance.parameters.Fast_Period;
    Slow_Period=instance.parameters.Slow_Period;
    first = source:first()+2;
    NoiseSt = instance:addInternalStream(first, 0);
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Fast_Period .. ", " .. instance.parameters.Slow_Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
    Adapt_MA = instance:addStream("Adapt_MA", core.Line, name .. ".Adapt_MA", "Adapt_MA", instance.parameters.clr, first);
    Adapt_MA:setWidth(instance.parameters.widthLinReg);
    Adapt_MA:setStyle(instance.parameters.styleLinReg);
    Slow_SC=2/(1+Slow_Period);
    Fast_SC=2/(1+Fast_Period);
end

function Update(period, mode)
   if period>first then
    NoiseSt[period]=math.abs(source[period]-source[period-1]);
    Adapt_MA[period]=nil;
    if period>first+Period then
     local Signal=math.abs(source[period]-source[period-Period]);
     local Noise=mathex.sum(NoiseSt, period-Period+1, period);
     local ER=1;
     if Noise>0 then
      ER=Signal/Noise;
     end
     local SSC=math.pow(Slow_SC+ER*(Fast_SC-Slow_SC), 2);
     Adapt_MA[period]=SSC*source[period]+(1-SSC)*Adapt_MA[period-1];
    elseif period==first+Period then
     Adapt_MA[period]=source[period]; 
    end
   end 
end

