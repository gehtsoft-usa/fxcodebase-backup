-- Id: 14516

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
    indicator:name("NVolume oscillator with Real volume/Transactions");
    indicator:description("NVolume oscillator with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
    indicator.parameters:addInteger("Period", "Period", "", 24);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Nclr", "Negative color", "Negative color", core.rgb(0, 128, 192));
    indicator.parameters:addColor("Pclr1", "Positive color 1", "Positive color 1", core.rgb(0, 128, 0));
    indicator.parameters:addColor("Pclr2", "Positive color 2", "Positive color 2", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Pclr3", "Positive color 3", "Positive color 3", core.rgb(255, 128, 64));
    indicator.parameters:addColor("Pclr4", "Positive color 4", "Positive color 4", core.rgb(255, 255, 0));
end

local first;
local source = nil;
local Period;
local MVA;
local NVolume=nil;
local Ind;

local FirstStart;
local LastTime;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
     if instance.parameters.Ind=="Volume" then
      Ind=core.indicators:create("REAL VOLUME", source);
     else
      Ind=core.indicators:create("TRANSACTIONS", source);
     end
     MVA = core.indicators:create("MVA", Ind.DATA, Period);
     FirstStart=true;
     LastTime=0;
    NVolume = instance:addStream("NVolume", core.Bar, name .. ".NVolume", "NVolume", instance.parameters.Nclr, first);
    NVolume:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if period>first then
        Ind:update(mode);
        if not(Ind.DATA:hasData(period)) then
            if period==first+1 then
                FirstStart=true;
            end    
            return;
        elseif FirstStart then
            FirstStart=false;
            instance:updateFrom(first);    
        elseif LastTime~=source:date(period) and period==source:size()-1 then
            LastTime=source:date(period);
            instance:updateFrom(period-10);
        end
    MVA:update(mode);
    NVolume[period]=Ind.DATA[period]/MVA.DATA[period]*100-100;
    if NVolume[period]<0 then
     NVolume:setColor(period, instance.parameters.Nclr);
    elseif NVolume[period]<38.2 then
     NVolume:setColor(period, instance.parameters.Pclr1);
    elseif NVolume[period]<61.8 then
     NVolume:setColor(period, instance.parameters.Pclr2);
    elseif NVolume[period]<100 then
     NVolume:setColor(period, instance.parameters.Pclr3);
    else
     NVolume:setColor(period, instance.parameters.Pclr4);
    end
   end 
end

function AsyncOperationFinished(cookie, success, message)

end
