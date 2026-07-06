-- More information about this indicator can be found at:
-- http://fxcodebase.com/
-- Id: 9327

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
    indicator:name("SSL channel");
    indicator:description("SSL channel");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 13);
    indicator.parameters:addBoolean("NRTR", "NRTR mode", "", false);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Transparency", "Transparency", "", 50,0,100);
end

local first;
local source = nil;
local Period;
local NRTR;
local Ubuff=nil;
local Lbuff=nil;
local HMA;
local LMA;
local trend;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    NRTR=instance.parameters.NRTR;
  
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    trend=instance:addInternalStream(0, 0);
    HMA = core.indicators:create("LWMA", source.high, Period);
    LMA = core.indicators:create("LWMA", source.low, Period);
	
	first = LMA.DATA:first()+2;
    Pbuff = instance:addStream("Pbuff", core.Line, name .. ".Pbuff", "Pbuff", instance.parameters.UPclr, first);
    Mbuff = instance:addStream("Mbuff", core.Line, name .. ".Mbuff", "Mbuff", instance.parameters.UPclr, first);
    instance:createChannelGroup("TC","TC" , Pbuff, Mbuff, instance.parameters.UPclr, 100-instance.parameters.Transparency);
end

function Update(period, mode)
   if period>first then
    HMA:update(mode);
    LMA:update(mode);
    if source.close[period]>HMA.DATA[period-1] then
     trend[period]=1;
    elseif source.close[period]<LMA.DATA[period-1] then
     trend[period]=-1;
    else
     trend[period]=trend[period-1];
    end
    if trend[period]==-1 then
     if NRTR then
      Pbuff[period]=math.min(HMA.DATA[period-1], Pbuff[period-1]);
      Mbuff[period]=math.min(LMA.DATA[period-1], Mbuff[period-1]);
     else
      Pbuff[period]=HMA.DATA[period-1];
      Mbuff[period]=LMA.DATA[period-1];
     end
    else
     if NRTR then
      Pbuff[period]=math.max(LMA.DATA[period-1], Pbuff[period-1]);
      Mbuff[period]=math.max(HMA.DATA[period-1], Mbuff[period-1]);
     else
      Mbuff[period]=HMA.DATA[period-1];
      Pbuff[period]=LMA.DATA[period-1];
     end
    end
    if Mbuff[period]>Pbuff[period] then
     Pbuff:setColor(period, instance.parameters.UPclr);
     Mbuff:setColor(period, instance.parameters.UPclr);
    else
     Pbuff:setColor(period, instance.parameters.DNclr);
     Mbuff:setColor(period, instance.parameters.DNclr);
    end
   end 
end

