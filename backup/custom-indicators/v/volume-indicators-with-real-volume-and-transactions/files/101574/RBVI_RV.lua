-- Id: 14548

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
    indicator:name("RBVI oscillator with Real volume/Transactions");
    indicator:description("RBVI oscillator with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
    indicator.parameters:addInteger("Period", "Period", "", 10, 1, 1000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local ATR;
local Positive, Negative;
local RBVI=nil;
local Ind;

local FirstStart;
local LastTime;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+2;
    ATR = core.indicators:create("ATR", source, Period);
    Positive=instance:addInternalStream(first, 0);
    Negative=instance:addInternalStream(first, 0);
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
     FirstStart=true;
     LastTime=0;
    RBVI = instance:addStream("RBVI", core.Line, name .. ".RBVI", "RBVI", instance.parameters.clr, first);
    RBVI:setPrecision(math.max(2, instance.source:getPrecision()));
    RBVI:setWidth(instance.parameters.widthLinReg);
    RBVI:setStyle(instance.parameters.styleLinReg);
    RBVI:addLevel(0);
    RBVI:addLevel(40);
    RBVI:addLevel(60);
    RBVI:addLevel(100);
end

function AsyncOperationFinished(cookie, success, message)

end

function Update(period, mode)
   if (period>first) then
    ATR:update(mode);
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
    local rel=ATR.DATA[period]*Ind.DATA[period]-ATR.DATA[period-1]*Ind.DATA[period-1];
    local sumn=0;
    local sump=0;
    if rel>0 then
     sump=rel;
    else
     sumn=-rel;
    end
    Positive[period]=(Positive[period-1]*(Period-1)+sump)/Period;
    Negative[period]=(Negative[period-1]*(Period-1)+sumn)/Period;
    if Negative[period]+Positive[period]==0 then
     RBVI[period]=0;
    else
     RBVI[period]=100*Positive[period]/(Positive[period]+Negative[period]);
    end
   elseif period==first then
    Positive[period]=0;
    Negative[period]=0; 
   end 
end

