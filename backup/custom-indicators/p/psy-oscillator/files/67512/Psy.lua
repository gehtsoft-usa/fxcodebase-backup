-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41291
-- Id: 9331

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
    indicator:name("Psy oscillator");
    indicator:description("Psy oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 10);
    indicator.parameters:addInteger("Level", "Level", "", 40);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Lclr", "Levels color", "Levels color", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("widthLinReg", "Level width", "Level width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Level style", "Level style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Pbuff=nil;
local Nbuff=nil;
local Pstream, Nstream;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Pstream = instance:addInternalStream(first, 0);
    Nstream = instance:addInternalStream(first, 0);
    Pbuff = instance:addStream("Pbuff", core.Bar, name .. ".Pbuff", "Pbuff", instance.parameters.UPclr, first+1+Period);
    Pbuff:setPrecision(math.max(2, instance.source:getPrecision()));
    Nbuff = instance:addStream("Nbuff", core.Bar, name .. ".Nbuff", "Nbuff", instance.parameters.UPclr, first+1+Period);
    Nbuff:setPrecision(math.max(2, instance.source:getPrecision()));
    Pbuff:addLevel(instance.parameters.Level, instance.parameters.styleLinReg, instance.parameters.widthLinReg, instance.parameters.Lclr);
    Pbuff:addLevel(-instance.parameters.Level, instance.parameters.styleLinReg, instance.parameters.widthLinReg, instance.parameters.Lclr);
end

function Update(period, mode)
   if period>first +1 then
    if source[period]>source[period-1] then
     Pstream[period]=1;
     Nstream[period]=0;
    else
     Pstream[period]=0;
     Nstream[period]=1;
    end
    if period>first+1+Period then
     local SumP=mathex.sum(Pstream, period-Period+1, period);
     local SumN=mathex.sum(Nstream, period-Period+1, period);
     Pbuff[period]=100*math.abs(SumP-SumN)/Period;
     Nbuff[period]=-Pbuff[period];
     if SumP>SumN then
      Pbuff:setColor(period, instance.parameters.UPclr);
      Nbuff:setColor(period, instance.parameters.UPclr);
     else
      Pbuff:setColor(period, instance.parameters.DNclr);
      Nbuff:setColor(period, instance.parameters.DNclr);
     end
    end
   end 
end

