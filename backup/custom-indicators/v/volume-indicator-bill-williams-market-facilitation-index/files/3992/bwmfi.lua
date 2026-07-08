-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1968

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+
 

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Market Facilitation Index");
    indicator:description("Bill Williams' Market facilitation index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("RANGE", "Range", "Multiplication factor, which brings the difference in points down to whole", 1, 0.00001, 100);

    indicator.parameters:addGroup("Style");
    local colors = core.colors();
    indicator.parameters:addColor("MUVU_Color", "MFI Up/Volume Up Color", "", colors.Lime);
    indicator.parameters:addColor("MDVD_Color", "MFI Down/Volume Down Color", "", colors.SaddleBrown);
    indicator.parameters:addColor("MUVD_Color", "MFI Up/Volume Down Color", "", colors.Blue);
    indicator.parameters:addColor("MDVU_Color", "MFI Down/Volume Up Color", "", colors.Pink);
end

local source;
local RANGE;
local first;
local first1;
local MFI;
local point;
local MUVU;
local MDVD;
local MUVD;
local MDVU;
local MU;
local VU;

function Prepare(nameOnly)  
    source = instance.source;
    first = source:first() + 1;
    first1 = source:first();
    RANGE = instance.parameters.RANGE;
    point = source:pipSize();


    local name;
    name = profile:id() .. "(" .. source:name() .. "," .. RANGE .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
	end
	
	  assert(source:supportsVolume(), "The source must have volume");

    MFI   = instance:addStream("MUVU", core.Bar, name .. ".MFI", "MFI", instance.parameters.MUVU_Color, first);
    MFI:setPrecision(5);
    MU = instance:addInternalStream(0, 0);
    VU = instance:addInternalStream(0, 0);
 
end

function Update(period, mode)
   
    MU[period] = 0;
    VU[period] = 0;

    if period >= first1 then
        MFI[period] = RANGE * (source.high[period] - source.low[period]) / (source.volume[period] * point);
    end

    if period >= first then
        local mu, vu;

        mu = MU[period - 1];
        vu = VU[period - 1];

        if MFI[period] > MFI[period - 1] then
            mu = 1;
        elseif MFI[period] < MFI[period - 1] then
            mu = -1;
        end

        if source.volume[period] > source.volume[period - 1] then
            vu = 1;
        elseif source.volume[period] < source.volume[period - 1] then
            vu = -1;
        end

        MU[period] = mu;
        VU[period] = vu;

        if mu > 0 and vu > 0 then
             MFI:setColor(period, instance.parameters.MUVU_Color);  
        elseif mu < 0 and vu < 0 then
             MFI:setColor(period, instance.parameters.MDVD_Color);  
        elseif mu > 0 and vu < 0 then
             MFI:setColor(period, instance.parameters.MUVD_Color);  
        elseif mu < 0 and vu > 0 then
             MFI:setColor(period, instance.parameters.MDVU_Color);  
        end
    end
end
