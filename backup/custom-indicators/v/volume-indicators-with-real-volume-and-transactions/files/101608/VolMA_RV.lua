
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
    indicator:name("VolMA indicator with Real volume/Transactions");
    indicator:description("VolMA indicator with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
    indicator.parameters:addInteger("RSIVolumePeriod", "Volume RSI Period", "", 20);
    indicator.parameters:addInteger("Period", "Period", "", 50);
    indicator.parameters:addString("Price", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price", "close", "", "close");
    indicator.parameters:addStringAlternative("Price", "open", "", "open");
    indicator.parameters:addStringAlternative("Price", "high", "", "high");
    indicator.parameters:addStringAlternative("Price", "low", "", "low");
    indicator.parameters:addStringAlternative("Price", "median", "", "median");
    indicator.parameters:addStringAlternative("Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price", "weighted", "", "weighted");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local RSIVolumePeriod;
local Period;
local Price;
local VolumeRSI;
local VolMA=nil;
local p;
local Ind;

local FirstStart;
local LastTime;

function Prepare(nameOnly)
    source = instance.source;
    RSIVolumePeriod=instance.parameters.RSIVolumePeriod;
    Period=instance.parameters.Period;
    Price=instance.parameters.Price;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.RSIVolumePeriod .. ", " .. instance.parameters.Period .. ")";
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
    VolumeRSI = core.indicators:create("RSI", Ind.DATA, RSIVolumePeriod);
    
	
	
    VolMA = instance:addStream("VolMA", core.Line, name .. ".VolMA", "VolMA", instance.parameters.clr, first);
    VolMA:setWidth(instance.parameters.widthLinReg);
    VolMA:setStyle(instance.parameters.styleLinReg);
    if Price=="close" then
     p=source.close;
    elseif Price=="open" then
     p=source.open;
    elseif Price=="high" then
     p=source.high;
    elseif Price=="low" then
     p=source.low;
    elseif Price=="median" then
     p=source.median;
    elseif Price=="typical" then
     p=source.typical;
    else
     p=source.weighted;
    end 
end

function AsyncOperationFinished(cookie, success, message)

end

function Update(period, mode)
   if (period>first+RSIVolumePeriod) then
        Ind:update(mode);
        if not(Ind.DATA:hasData(period)) then
            if period==first+RSIVolumePeriod+1 then
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
    VolumeRSI:update(mode);
    local PeriodMA=math.floor(VolumeRSI.DATA[period]*Period/100);
    PeriodMA=math.max(PeriodMA,1);
    local StartBar=period-PeriodMA+1;
    if StartBar<first then
     VolMA[period]=nil;
    else 
     VolMA[period]=mathex.avg(p,core.range(StartBar,period));
    end 
   end 
end

