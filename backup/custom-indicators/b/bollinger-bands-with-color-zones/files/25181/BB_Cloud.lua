-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=12838
-- Id: 5736

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
    indicator:name("BB Cloud indicator");
    indicator:description("BB Cloud indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20, 1, 10000);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 2.0, 0.0001, 1000.0);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("BandsClr", "Bands line color", "Bands line color", core.rgb(219, 64, 0));
    indicator.parameters:addInteger("BandsWidth", "Bands line width", "Bands line width", 1, 1, 5);
    indicator.parameters:addInteger("BandsStyle", "Bands line style", "Bands line style", core.LINE_SOLID);
    indicator.parameters:setFlag("BandsStyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("AverageClr", "Average line color", "Average line color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("AverageWidth", "Average line width", "Average line width", 1, 1, 5);
    indicator.parameters:addInteger("AverageStyle", "Average line style", "Average line style", core.LINE_SOLID);
    indicator.parameters:setFlag("AverageStyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("UpperCloudClr", "Upper cloud color", "Upper cloud color", core.rgb(128, 255, 255));
    indicator.parameters:addColor("LowerCloudClr", "Lower cloud color", "Lower cloud color", core.rgb(255, 128, 64));
    indicator.parameters:addInteger("Transparency", "Transparency", "", 80,0,100);
end

local first;
local source = nil;
local Period;
local Deviation;
local BB;
local BB_Top=nil;
local BB_Bottom=nil;
local BB_Middle=nil;
local BB_Middle2=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Deviation=instance.parameters.Deviation;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Deviation .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    BB = core.indicators:create("BB", source, Period, Deviation);
    BB_Middle2=instance:addInternalStream(first, 0);
    BB_Top = instance:addStream("BB_Top", core.Line, name .. ".Top", "Top", instance.parameters.BandsClr, first);
    BB_Bottom = instance:addStream("BB_Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.BandsClr, first);
    BB_Middle = instance:addStream("BB_Middle", core.Line, name .. ".Middle", "Middle", instance.parameters.AverageClr, first);
    BB_Top:setWidth(instance.parameters.BandsWidth);
    BB_Top:setStyle(instance.parameters.BandsStyle);
    BB_Bottom:setWidth(instance.parameters.BandsWidth);
    BB_Bottom:setStyle(instance.parameters.BandsStyle);
    BB_Middle:setWidth(instance.parameters.AverageWidth);
    BB_Middle:setStyle(instance.parameters.AverageStyle);
    instance:createChannelGroup("UpperGroup","Upper" , BB_Top, BB_Middle, instance.parameters.UpperCloudClr, 100-instance.parameters.Transparency);
    instance:createChannelGroup("LowerGroup","Lower" , BB_Middle2, BB_Bottom, instance.parameters.LowerCloudClr, 100-instance.parameters.Transparency);
end

function Update(period, mode)
   if (period>first) then
    BB:update(mode);
    BB_Top[period]=BB.TL[period];
    BB_Bottom[period]=BB.BL[period];
    BB_Middle[period]=BB.AL[period];
    BB_Middle2[period]=BB.AL[period];
   end 
end

