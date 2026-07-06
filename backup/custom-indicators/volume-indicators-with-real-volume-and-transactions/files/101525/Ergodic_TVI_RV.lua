-- Id: 14491

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
    indicator:name("Ergodic Tick volume indicator with Real volume/Transactions");
    indicator:description("Ergodic Tick volume indicator with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
    indicator.parameters:addInteger("Period1", "Period 1", "", 12);
    indicator.parameters:addInteger("Period2", "Period 2", "", 12);
    indicator.parameters:addInteger("Period3", "Period 3", "", 1);
    indicator.parameters:addInteger("EPeriod1", "Ergodic period 1", "", 5);
    indicator.parameters:addInteger("EPeriod2", "Ergodic period 2", "", 5);
    indicator.parameters:addInteger("EPeriod3", "Ergodic period 3", "", 5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Sclr", "Signal color", "Signal color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Swidth", "Signal line width", "Signal line width", 1, 1, 5);
    indicator.parameters:addInteger("Sstyle", "Signal line style", "Signal line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Sstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period1;
local Period2;
local Period3;
local EPeriod1;
local EPeriod2;
local EPeriod3;
local UpTicks, DnTicks;
local EMA_Up1, EMA_Dn1;
local EMA_Up2, EMA_Dn2;
local TV;
local EMA_TV;
local EMA_TVI1, EMA_TVI2, EMA_TVI3;
local TVI;
local pipSize;
local ETVI=nil;
local Signal=nil;
local Ind;

local FirstStart;
local LastTime;

function Prepare(nameOnly)
    source = instance.source;
    Period1=instance.parameters.Period1;
    Period2=instance.parameters.Period2;
    Period3=instance.parameters.Period3;
    EPeriod1=instance.parameters.EPeriod1;
    EPeriod2=instance.parameters.EPeriod2;
    EPeriod3=instance.parameters.EPeriod3;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period1 .. ", " .. instance.parameters.Period2 .. ", " .. instance.parameters.Period3 .. ", " .. instance.parameters.EPeriod1 .. ", " .. instance.parameters.EPeriod2 .. ", " .. instance.parameters.EPeriod3 .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    first = source:first()+2;
    UpTicks = instance:addInternalStream(first, 0);
    DnTicks = instance:addInternalStream(first, 0);
    TV = instance:addInternalStream(first, 0);
    TVI = instance:addInternalStream(first, 0);
    EMA_Up1 = core.indicators:create("EMA", UpTicks, Period1);
    EMA_Dn1 = core.indicators:create("EMA", DnTicks, Period1);
    EMA_Up2 = core.indicators:create("EMA", EMA_Up1.DATA, Period2);
    EMA_Dn2 = core.indicators:create("EMA", EMA_Dn1.DATA, Period2);
    EMA_TV = core.indicators:create("EMA", TV, Period3);
    EMA_TVI1 = core.indicators:create("EMA", TVI, EPeriod1);
    EMA_TVI2 = core.indicators:create("EMA", EMA_TVI1.DATA, EPeriod2);
    EMA_TVI3 = core.indicators:create("EMA", EMA_TVI2.DATA, EPeriod3);
    
	
     if instance.parameters.Ind=="Volume" then
      Ind=core.indicators:create("REAL VOLUME", source);
     else
      Ind=core.indicators:create("TRANSACTIONS", source);
     end
    ETVI = instance:addStream("ETVI", core.Line, name .. ".ETVI", "ETVI", instance.parameters.clr, first);
    ETVI:setPrecision(math.max(2, instance.source:getPrecision()));
    ETVI:setWidth(instance.parameters.width);
    ETVI:setStyle(instance.parameters.style);
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Sclr, first);
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal:setWidth(instance.parameters.Swidth);
    Signal:setStyle(instance.parameters.Sstyle);
    pipSize=source:pipSize();
    FirstStart=true;
    LastTime=0;
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
            instance:updateFrom(period-2);
        end
    UpTicks[period]=(Ind.DATA[period]+(source.close[period]-source.open[period])/pipSize)/2;
    DnTicks[period]=Ind.DATA[period]-UpTicks[period];
    EMA_Up1:update(mode);
    EMA_Dn1:update(mode);
    EMA_Up2:update(mode);
    EMA_Dn2:update(mode);
    local sum=EMA_Up2.DATA[period]+EMA_Dn2.DATA[period];
    if sum~=0 then
     TV[period]=100*(EMA_Up2.DATA[period]-EMA_Dn2.DATA[period])/sum;
    end 
    EMA_TV:update(mode);
    TVI[period]=EMA_TV.DATA[period];
    EMA_TVI1:update(mode);
    EMA_TVI2:update(mode);
    EMA_TVI3:update(mode);
    ETVI[period]=EMA_TVI2.DATA[period];
    Signal[period]=EMA_TVI3.DATA[period];
   end 
end

function AsyncOperationFinished(cookie, success, message)

end
