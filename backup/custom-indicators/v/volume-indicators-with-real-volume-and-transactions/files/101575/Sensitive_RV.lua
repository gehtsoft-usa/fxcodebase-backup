-- Id: 14554

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
    indicator:name("Sensitive oscillator with Real volume/Transactions");
    indicator:description("Sensitive oscillator with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
    indicator.parameters:addInteger("Period", "Period", "", 150);
    indicator.parameters:addInteger("Sensitive", "Sensitive", "", 7);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Period;
local Sensitive;
local Buff=nil;
local MAopen;
local MAclose;
local MAhigh;
local MAlow;
local Ind;

local FirstStart;
local LastTime;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Sensitive=instance.parameters.Sensitive;
    first = source:first()+2;
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Sensitive .. ")";
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
    MAopen=core.indicators:create("MVA", source.open, Period);
    MAclose=core.indicators:create("MVA", source.close, Period);
    MAhigh=core.indicators:create("MVA", source.high, Period);
    MAlow=core.indicators:create("MVA", source.low, Period);
   
    Buff = instance:addStream("Buff", core.Bar, name .. ".Sensitive", "Sensitive", instance.parameters.UPclr, first);
    Buff:setPrecision(math.max(2, instance.source:getPrecision()));
end

function AsyncOperationFinished(cookie, success, message)

end

function Update(period, mode)
   if (period>first+Period+Sensitive) then
        Ind:update(mode);
        if not(Ind.DATA:hasData(period)) then
            if period==first+Period+Sensitive+1 then
                FirstStart=true;
            end    
            return;
        elseif FirstStart then
            FirstStart=false;
            instance:updateFrom(first+Period+Sensitive+1);    
        elseif LastTime~=source:date(period) and period==source:size()-1 then
            LastTime=source:date(period);
            instance:updateFrom(period-10);
        end
    MAopen:update(mode);
    MAclose:update(mode);
    MAhigh:update(mode);
    MAlow:update(mode);
    local max=mathex.max(source.high,core.rangeTo(period,Sensitive));
    local min=mathex.min(source.low,core.rangeTo(period,Sensitive));
    Buff[period]=(5*MAclose.DATA[period]-5*MAopen.DATA[period]+max+min-MAhigh.DATA[period]-MAlow.DATA[period])*Ind.DATA[period];
    if Buff[period]>0 then
     Buff:setColor(period,instance.parameters.UPclr);
    else
     Buff:setColor(period,instance.parameters.DNclr);
    end
   end 
end

