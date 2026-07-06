-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=12226
-- Id: 5627

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("RBVI oscillator");
    indicator:description("RBVI oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
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

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return
    end
    ATR = core.indicators:create("ATR", source, Period);
	first = ATR.DATA:first();
    Positive=instance:addInternalStream(0, 0);
    Negative=instance:addInternalStream(0, 0);
    RBVI = instance:addStream("RBVI", core.Line, name .. ".RBVI", "RBVI", instance.parameters.clr, first);
    RBVI:setPrecision(math.max(2, instance.source:getPrecision()));
    RBVI:setWidth(instance.parameters.widthLinReg);
    RBVI:setStyle(instance.parameters.styleLinReg);
    RBVI:addLevel(0);
    RBVI:addLevel(40);
    RBVI:addLevel(60);
    RBVI:addLevel(100);
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    ATR:update(mode);
    local rel=ATR.DATA[period]*source.volume[period]-ATR.DATA[period-1]*source.volume[period-1];
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
  
end

