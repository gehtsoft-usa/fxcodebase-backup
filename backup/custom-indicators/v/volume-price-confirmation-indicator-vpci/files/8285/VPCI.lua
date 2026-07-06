-- Id: 3171
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3478

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("VPCI indicator");
    indicator:description("VPCI indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Slow_Period", "Slow_Period", "", 50);
    indicator.parameters:addInteger("Fast_Period", "Fast_Period", "", 10);

    indicator.parameters:addGroup("Style");
	
	indicator.parameters:addString("Method", "Line Method", "Method" , "Line");
    indicator.parameters:addStringAlternative("Method", "Line", "Line" , "Line");
    indicator.parameters:addStringAlternative("Method", "Bar", "Bar" , "Bar");
	
    indicator.parameters:addColor("UpColor", "Up Color", "Color", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("DownColor", "Down Color", "Color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Slow_Period;
local Fast_Period;
local Buff=nil;
local CV;
local Method;
function Prepare(nameOnly)
    source = instance.source;
    Slow_Period=instance.parameters.Slow_Period;
    Fast_Period=instance.parameters.Fast_Period;
	Method=instance.parameters.Method;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Slow_Period .. ", " .. instance.parameters.Fast_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    first = source:first()+math.max(Slow_Period,Fast_Period);
    CV = instance:addInternalStream(0, 0);
	if Method == "Line" then
    Buff = instance:addStream("Buff", core.Line, name .. ".VPCI", "VPCI", instance.parameters.UpColor, first);
    else
	Buff = instance:addStream("Buff", core.Bar, name .. ".VPCI", "VPCI", instance.parameters.UpColor, first);
	end
    Buff:setPrecision(math.max(2, instance.source:getPrecision()));
    Buff:addLevel(0);
end

function Update(period, mode)
   CV[period]=source.close[period]*source.volume[period];
   
   if  period<=first then
   return;
   end
   
    local Volume_Slow=core.sum(source.volume,core.rangeTo(period,Slow_Period));
    local Volume_Fast=core.sum(source.volume,core.rangeTo(period,Fast_Period));
    local VWMA_Slow=core.sum(CV,core.rangeTo(period,Slow_Period))/Volume_Slow;
    local VWMA_Fast=core.sum(CV,core.rangeTo(period,Fast_Period))/Volume_Fast;
    local SMA_Slow=core.avg(source.close,core.rangeTo(period,Slow_Period));
    local SMA_Fast=core.avg(source.close,core.rangeTo(period,Fast_Period));
    local VPC=VWMA_Slow-SMA_Slow;
    local VPR=1;
    if SMA_Fast~=0 then
     VPR=VWMA_Fast/SMA_Fast;
    end
    local VM=1;
    if Volume_Slow~=0 then
     VM=(Volume_Fast*Slow_Period)/(Volume_Slow*Fast_Period);
    end
    Buff[period]=VPC*VPR*VM;
  
   if Buff[period]> Buff[period-1] then
   Buff:setColor(period, instance.parameters.UpColor);
   else
   Buff:setColor(period, instance.parameters.DownColor);
   end
   
end

