-- Id: 14604

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62412

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
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
    indicator:name("VPCI indicator with Real volume/Transactions");
    indicator:description("VPCI indicator with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
    indicator.parameters:addInteger("Slow_Period", "Slow_Period", "", 50);
    indicator.parameters:addInteger("Fast_Period", "Fast_Period", "", 10);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
end

local first;
local source = nil;
local Slow_Period;
local Fast_Period;
local Buff=nil;
local CV;
local Ind;

local FirstStart;
local LastTime;

function Prepare(nameOnly)
    source = instance.source;
    Slow_Period=instance.parameters.Slow_Period;
    Fast_Period=instance.parameters.Fast_Period;
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Slow_Period .. ", " .. instance.parameters.Fast_Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
     if instance.parameters.Ind=="Volume" then
      Ind=core.indicators:create("REAL VOLUME", source);
     else
      Ind=core.indicators:create("TRANSACTIONS", source);
     end
     FirstStart=true;
     LastTime=0;
    first = source:first()+2;
    CV = instance:addInternalStream(first, 0);
   
	
    Buff = instance:addStream("Buff", core.Line, name .. ".VPCI", "VPCI", instance.parameters.clr, first);
    Buff:setPrecision(math.max(2, instance.source:getPrecision()));
    Buff:addLevel(0);
end

function AsyncOperationFinished(cookie, success, message)

end

function Update(period, mode)
   if (period>first+math.max(Slow_Period,Fast_Period)) then
        Ind:update(mode);
        if not(Ind.DATA:hasData(period)) then
            if period==first+math.max(Slow_Period,Fast_Period)+1 then
                FirstStart=true;
            end    
            return;
        elseif FirstStart then
            FirstStart=false;
            instance:updateFrom(first+math.max(Slow_Period,Fast_Period));    
        elseif LastTime~=source:date(period) and period==source:size()-1 then
            LastTime=source:date(period);
            instance:updateFrom(period-10);
        end
   CV[period]=source.close[period]*Ind.DATA[period];
    local Volume_Slow=core.sum(Ind.DATA,core.rangeTo(period,Slow_Period));
    local Volume_Fast=core.sum(Ind.DATA,core.rangeTo(period,Fast_Period));
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
   end 
end

