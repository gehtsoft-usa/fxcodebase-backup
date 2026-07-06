-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32541
-- Id: 8617

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
    indicator:name("Special slow stochastic");
    indicator:description("Special slow stochastic");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Kperiod", "%K periods", "", 5);
    indicator.parameters:addInteger("Dslowing", "%D slowing periods", "", 3);
    indicator.parameters:addInteger("Dperiod", "%D periods", "", 3);
    indicator.parameters:addInteger("DSperiod", "%DS periods", "", 3);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Kclr", "%K line color", "%K line color", core.rgb(0, 183, 183));
    indicator.parameters:addInteger("Kwidth", "%K line width", "%K line width", 1, 1, 5);
    indicator.parameters:addInteger("Kstyle", "%K line style", "%K line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Kstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Dclr", "%D line color", "%D line color", core.rgb(219, 64, 0));
    indicator.parameters:addInteger("Dwidth", "%D line width", "%D line width", 1, 1, 5);
    indicator.parameters:addInteger("Dstyle", "%D line style", "%D line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Dstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("DSclr", "%DS line color", "%DS line color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("DSwidth", "%DS line width", "%DS line width", 1, 1, 5);
    indicator.parameters:addInteger("DSstyle", "%DS line style", "%DS line style", core.LINE_DASH);
    indicator.parameters:setFlag("DSstyle", core.FLAG_LINE_STYLE);
 
    indicator.parameters:addInteger("OBlevel", "Overbought level", "", 80);
    indicator.parameters:addInteger("OSlevel", "Oversold level", "", 20);
    indicator.parameters:addColor("Lclr", "Level line color", "Level line color", core.rgb(96, 96, 138));
    indicator.parameters:addInteger("Lwidth", "Level line width", "Level line width", 1, 1, 5);
    indicator.parameters:addInteger("Lstyle", "Level line style", "Level line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Lstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Kperiod;
local Dslowing;
local Dperiod;
local DSperiod;
local Kbuff=nil;
local Dbuff=nil;
local DSbuff=nil;
local sfk;
local Kfirst, Dfirst, DSfirst;

function Prepare(nameOnly)
    source = instance.source;
    Kperiod=instance.parameters.Kperiod;
    Dslowing=instance.parameters.Dslowing;
    Dperiod=instance.parameters.Dperiod;
    DSperiod=instance.parameters.DSperiod;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Kperiod .. ", " .. instance.parameters.Dslowing .. ", " .. instance.parameters.Dperiod .. ", " .. instance.parameters.DSperiod .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    sfk = core.indicators:create("SFK", source, Kperiod, Dslowing);
    Kfirst=sfk.D:first();
    Dfirst=Kfirst+Dperiod;
    DSfirst=Dfirst+DSperiod;
    Kbuff = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.Kclr, Kfirst);
    Kbuff:setPrecision(math.max(2, instance.source:getPrecision()));
    Kbuff:setWidth(instance.parameters.Kwidth);
    Kbuff:setStyle(instance.parameters.Kstyle);
    Dbuff = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.Dclr, Dfirst);
    Dbuff:setPrecision(math.max(2, instance.source:getPrecision()));
    Dbuff:setWidth(instance.parameters.Dwidth);
    Dbuff:setStyle(instance.parameters.Dstyle);
    DSbuff = instance:addStream("DS", core.Line, name .. ".DS", "DS", instance.parameters.DSclr, DSfirst);
    DSbuff:setPrecision(math.max(2, instance.source:getPrecision()));
    DSbuff:setWidth(instance.parameters.DSwidth);
    DSbuff:setStyle(instance.parameters.DSstyle);
    Dbuff:addLevel(0);
    Dbuff:addLevel(instance.parameters.OSlevel, instance.parameters.Lstyle, instance.parameters.Lwidth, instance.parameters.Lclr);
    Dbuff:addLevel(instance.parameters.OBlevel, instance.parameters.Lstyle, instance.parameters.Lwidth, instance.parameters.Lclr);
    Dbuff:addLevel(100);
end

function Update(period, mode)
   if period>=Kfirst then
    sfk:update(mode);
    Kbuff[period]=sfk.D[period];
   end 
   if period>=Dfirst then
    Dbuff[period]=mathex.avg(Kbuff, period-Dperiod+1, period);
   end
   if period>=DSfirst then
    DSbuff[period]=mathex.avg(Dbuff, period-DSperiod+1, period);
   end
end

