-- Id: 19822
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65402

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
    indicator:name("Wilders DMI indicator");
    indicator:description("Wilders DMI indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ADXPeriod", "ADX Period", "", 13);
    indicator.parameters:addDouble("Level", "Level", "", 21);
    indicator.parameters:addBoolean("DMI_Only", "Show DMI only", "", false);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("DIPclr", "DIP Color", "DIP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DIMclr", "DIM Color", "DIM Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("ADXclr", "ADX Color", "ADX Color", core.rgb(0, 0, 255));
end

local first;
local source = nil;
local ADXPeriod;
local Level;
local DMI_Only;
local DIP, DIM, ADX;
local wDIP, wDIM, wTR;
local sf;

function Prepare(nameOnly)
    source = instance.source;
    ADXPeriod=instance.parameters.ADXPeriod;
    Level=instance.parameters.Level;
    DMI_Only=instance.parameters.DMI_Only;
    first = source:first()+2;
    sf=(ADXPeriod-1)/ADXPeriod;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    wDIP = instance:addInternalStream(first, 0);
    wDIM = instance:addInternalStream(first, 0);
    wTR = instance:addInternalStream(first, 0);
    DIP = instance:addStream("DIP", core.Line, name .. ".DIP", "DIP", instance.parameters.DIPclr, first);
    DIP:setPrecision(math.max(2, instance.source:getPrecision()));
    DIM = instance:addStream("DIM", core.Line, name .. ".DIM", "DIM", instance.parameters.DIMclr, first);
    DIM:setPrecision(math.max(2, instance.source:getPrecision()));
    ADX = instance:addStream("ADX", core.Line, name .. ".ADX", "ADX", instance.parameters.ADXclr, first);
    ADX:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if period>first then
    local currTR=math.max(source.high[period], source.close[period-1])-math.min(source.low[period], source.close[period-1]);
    local DeltaHi=source.high[period]-source.high[period-1];
    local DeltaLo=source.low[period-1]-source.low[period];
    local plusDM=0;
    local minusDM=0;

    if DeltaHi>DeltaLo and DeltaHi>0 then
      plusDM=DeltaHi;
    end

    if DeltaLo>DeltaHi and DeltaLo>0 then
      minusDM=DeltaLo;
    end

    wDIP[period]=sf*wDIP[period-1]+plusDM;
    wDIM[period]=sf*wDIM[period-1]+minusDM;
    wTR[period]=sf*wTR[period-1]+currTR;

    DIP[period]=0;
    DIM[period]=0;

    if wTR[period]>0 then
      DIP[period]=100*wDIP[period]/wTR[period];
      DIM[period]=100*wDIM[period]/wTR[period];
    end

    local DX;

    if DIP[period]+DIM[period]>0 then
      DX=100*math.abs(DIP[period]-DIM[period])/(DIP[period]+DIM[period])
    else
      DX=0;
    end

    ADX[period]=sf*ADX[period-1]+DX/ADXPeriod;
   end 
end

