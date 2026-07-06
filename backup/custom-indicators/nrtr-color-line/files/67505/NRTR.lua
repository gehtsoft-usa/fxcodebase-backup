-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41285
-- Id: 9320

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("NRTR indicator");
    indicator:description("NRTR indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ATR_Period", "ATR period", "", 14);
    indicator.parameters:addDouble("Coeff", "Coeff", "", 4);
    indicator.parameters:addString("Mode", "Mode", "", "1");
    indicator.parameters:addStringAlternative("Mode", "Stops only", "", "0");
    indicator.parameters:addStringAlternative("Mode", "Signals & Stops", "", "1");
    indicator.parameters:addStringAlternative("Mode", "Signals only", "", "2");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);
end

local first;
local source = nil;
local ATR_Period;
local Coeff;
local Mode;
local UpStop=nil;
local UpSignal=nil;
local DnStop=nil;
local DnSignal=nil;
local TrendUp;
local Extremum;
local TR;

function Prepare(nameOnly)
    source = instance.source;
    ATR_Period=instance.parameters.ATR_Period;
    Coeff=instance.parameters.Coeff;
    Mode=tonumber(instance.parameters.Mode);
    first = source:first()+ATR_Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.ATR_Period .. ", " .. instance.parameters.Coeff .. ", " .. instance.parameters.Mode .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    TrendUp=instance:addInternalStream(0, 0);
    Extremum=instance:addInternalStream(0, 0);
    TR=instance:addInternalStream(0, 0);
    if Mode<2 then
     UpStop = instance:addStream("UpStop", core.Line, name .. ".UpStop", "UpStop", instance.parameters.UPclr, first);
     DnStop = instance:addStream("DnStop", core.Line, name .. ".DnStop", "DnStop", instance.parameters.DNclr, first);
    else
     UpStop=instance:addInternalStream(0, 0);
     DnStop=instance:addInternalStream(0, 0);
    end
    if Mode>0 then
     UpSignal = instance:addStream("UpSignal", core.Dot, name .. ".UpSignal", "UpSignal", instance.parameters.UPclr, first);
     DnSignal = instance:addStream("DnSignal", core.Dot, name .. ".DnSignal", "DnSignal", instance.parameters.DNclr, first);
    else
     UpSignal=instance:addInternalStream(0, 0);
     DnSignal=instance:addInternalStream(0, 0);
    end 
    UpStop:setWidth(instance.parameters.widthLinReg);
    UpStop:setStyle(instance.parameters.styleLinReg);
    DnStop:setWidth(instance.parameters.widthLinReg);
    DnStop:setStyle(instance.parameters.styleLinReg);
    UpSignal:setWidth(instance.parameters.DotSize);
    DnSignal:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)
   if period > first  then
    TR[period]=source.high[period]-source.low[period];
    if math.abs(source.high[period]-source.close[period-1])>TR[period] then
     TR[period]=math.abs(source.high[period]-source.close[period-1]);
    end
    if math.abs(source.low[period]-source.close[period-1])>TR[period] then
     TR[period]=math.abs(source.low[period]-source.close[period-1]);
    end
    local i;
    local ATR=0;
    for i=0, ATR_Period-1, 1 do
     ATR=ATR+TR[period-i]*(ATR_Period-i);
    end
    ATR=2*ATR/(ATR_Period*(ATR_Period+1));
    local ChannelWidth=Coeff*ATR;
    TrendUp[period]=TrendUp[period-1];
    Extremum[period]=Extremum[period-1];
    if TrendUp[period]==1 and source.low[period]<(Extremum[period]-ChannelWidth) then
     TrendUp[period]=0;
     Extremum[period]=source.high[period];
    end
    if TrendUp[period]==0 and source.high[period]>(Extremum[period]+ChannelWidth) then
     TrendUp[period]=1;
     Extremum[period]=source.low[period];
    end
    if TrendUp[period]==1 and source.low[period]>Extremum[period] then
     Extremum[period]=source.low[period];
    end
    if TrendUp[period]==0 and source.high[period]<Extremum[period] then
     Extremum[period]=source.high[period];
    end
    if TrendUp[period]==1 then
     UpStop[period]=Extremum[period]-ChannelWidth;
     DnStop[period]=nil;
     if TrendUp[period]~=TrendUp[period-1] then
      UpSignal[period]=Extremum[period]-ChannelWidth;
      DnSignal[period]=nil;
     end
    else
     DnStop[period]=Extremum[period]+ChannelWidth;
     UpStop[period]=nil;
     if TrendUp[period]~=TrendUp[period-1] then
      DnSignal[period]=Extremum[period]+ChannelWidth;
      UpSignal[period]=nil;
     end
    end
    
   elseif period>first then
    Extremum[period]=source.close[period];
    if source.close[period]>source.close[period-1] then
     TrendUp[period]=1;
    else
     TrendUp[period]=0;
    end
    Extremum[period]=source.close[period];
   end 
end

