-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59580
-- Id: 10073

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
    indicator:name("Candles by size indicator");
    indicator:description("Paint the candles by size.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addInteger("HL_Level", "High-Low level (in pips)", "", 20);
    indicator.parameters:addString("HL_Method", "High-Low method", "", "0");
    indicator.parameters:addStringAlternative("HL_Method", "H-L<Level", "", "0");
    indicator.parameters:addStringAlternative("HL_Method", "H-L>Level", "", "1");
    indicator.parameters:addInteger("OC_Level", "Open-Close level (in pips)", "", 10);
    indicator.parameters:addString("OC_Method", "Open-Close method", "", "0");
    indicator.parameters:addStringAlternative("OC_Method", "O-C<Level", "", "0");
    indicator.parameters:addStringAlternative("OC_Method", "C-C>Level", "", "1");
    indicator.parameters:addBoolean("OC_Abs", "Use absolute value for Open-Close", "", true);
    
    indicator.parameters:addColor("clrDefaultUp", "Default UP bar color", "Default UP bar color", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDefaultDn", "Default DN bar color", "Default DN bar color", core.COLOR_DOWNCANDLE);
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));    
end

local first;
local source = nil;
local HL_Level;
local HL_Method;
local OC_Level;
local OC_Method;
local OC_Abs;
local open=nil;
local close=nil;
local high=nil;
local low=nil;

function Prepare(nameOnly)
    source = instance.source;
    HL_Level=instance.parameters.HL_Level*source:pipSize();
    HL_Method=tonumber(instance.parameters.HL_Method);
    OC_Level=instance.parameters.OC_Level*source:pipSize();
    OC_Method=tonumber(instance.parameters.OC_Method);
    OC_Abs=instance.parameters.OC_Abs;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ColorCandle", "", open, high, low, close);
end

function Update(period, mode)
    if (period>first) then
     open[period]=source.open[period];
     close[period]=source.close[period];
     high[period]=source.high[period];
     low[period]=source.low[period];
     
     local HL=source.high[period]-source.low[period];
     local OC;
     if OC_Abs then
      OC=math.abs(source.open[period]-source.close[period]);
     else
      OC=source.open[period]-source.close[period];
     end
     
     if ((HL_Method==0 and HL<HL_Level) or (HL_Method==1 and HL>HL_Level)) and ((OC_Method==0 and OC<OC_Level) or (OC_Method==1 and OC>OC_Level)) then
      open:setColor(period, instance.parameters.clr);
     else
      if source.close[period]>source.open[period] then
       open:setColor(period, instance.parameters.clrDefaultUp);
      else
       open:setColor(period, instance.parameters.clrDefaultDn);
      end
     end
    end 
end

