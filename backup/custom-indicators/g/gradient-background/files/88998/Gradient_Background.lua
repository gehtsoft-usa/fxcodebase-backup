-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59343
-- Id: 9823

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
    indicator:name("Gradient background");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addString("Method", "Method", "", "0");
    indicator.parameters:addStringAlternative("Method", "2-colors", "", "0");
    indicator.parameters:addStringAlternative("Method", "4-colors", "", "1");
    indicator.parameters:addColor("TLclr", "Top-Left Color", "", core.rgb(0, 128, 255));
    indicator.parameters:addColor("BLclr", "Bottom-Left Color", "", core.rgb(128, 255, 0));
    indicator.parameters:addColor("TRclr", "Top-Right Color", "", core.rgb(0, 128, 255));
    indicator.parameters:addColor("BRclr", "Bottom-Right Color", "", core.rgb(128, 255, 0));
    indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100);
end

local source = nil;
local color;
local transparency;
local Method;
local TLclr, BLclr, TRclr, BRclr;

-- initializes the instance of the indicator
function Prepare(onlyName)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end

    instance:ownerDrawn(true);
    
    Method = tonumber(instance.parameters.Method);
    TLclr = instance.parameters.TLclr;
    BLclr = instance.parameters.BLclr;
    if Method==0 then
     TRclr = instance.parameters.TLclr;
     BRclr = instance.parameters.BLclr;
    else
     TRclr = instance.parameters.TRclr;
     BRclr = instance.parameters.BRclr;
    end 
    instance:setLabelColor(TLclr);
end

function Update(period)
end

local init = false;

function Draw(stage, context)
    if stage == 0 then
    
        if not init then
            transparency=context:convertTransparency(instance.parameters.transparency);
            init = true;
        end
        local top, bottom, left, right = context:top(), context:bottom(), context:left(), context:right();
        context:drawGradientRectangle (left, top, TLclr, right, top, TRclr, right, bottom, BRclr, left, bottom, BLclr, transparency);
    end
end



