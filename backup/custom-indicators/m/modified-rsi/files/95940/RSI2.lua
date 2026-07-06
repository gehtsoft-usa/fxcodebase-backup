-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61165
-- Id: 12513

--+------------------------------------------------------------------+
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
    indicator:name("Relative Strength Index 2");
    indicator:description("Shows price strength by comparing upward and downward close-to-close movements.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "The number of periods", 14, 2, 1000);
    
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrRSI", "Line color", "The color of the Relative Strength Index line", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthRSI", "Line width", "The width of the Relative Strength Index line", 5, 1, 5);
    indicator.parameters:addInteger("styleRSI", "Line style", "The style of the Relative Strength Index line", core.LINE_SOLID);
    indicator.parameters:setFlag("styleRSI", core.FLAG_LEVEL_STYLE);


    indicator.parameters:addGroup("30");
    indicator.parameters:addBoolean("show30", "Show 30", "Show the 30 level in RSI" , true);
    indicator.parameters:addColor("color30", "Color", "The color of the 30 level", core.rgb(192, 192, 192));
    indicator.parameters:addInteger("width30", "Width", "The width of the 30 level", 2, 1, 5);
    indicator.parameters:addInteger("style30", "Style", "The style of the 30 level", core.LINE_SOLID);
    indicator.parameters:setFlag("style30", core.FLAG_LEVEL_STYLE);
    
    indicator.parameters:addGroup("40");
    indicator.parameters:addBoolean("show40", "Show 40", "Enable/disable the 40 level in RSI" , true);
    indicator.parameters:addColor("color40", "Color", "The color of the 40 level", core.rgb(192, 192, 192));
    indicator.parameters:addInteger("width40", "Width", "The width of the 40 level", 1, 1, 5);
    indicator.parameters:addInteger("style40", "Style", "The style of the 40 level", core.LINE_DOT);
    indicator.parameters:setFlag("style40", core.FLAG_LEVEL_STYLE);
    
    indicator.parameters:addGroup("50");
    indicator.parameters:addBoolean("show50", "Show 50", "Show the 50 level in RSI" , true);
    indicator.parameters:addColor("color50", "Color", "The color of the 50 level", core.rgb(192, 192, 192));
    indicator.parameters:addInteger("width50", "Width", "The width of the 50 level", 1, 1, 5);
    indicator.parameters:addInteger("style50", "Style", "The style of the 50 level", core.LINE_SOLID);
    indicator.parameters:setFlag("style50", core.FLAG_LEVEL_STYLE);
    
    indicator.parameters:addGroup("60");
    indicator.parameters:addBoolean("show60", "Show 60", "Show the 60 level in RSI" , true);
    indicator.parameters:addColor("color60", "Color", "The color of the 60 level", core.rgb(192, 192, 192));
    indicator.parameters:addInteger("width60", "Width", "The width of the 60 level", 1, 1, 5);
    indicator.parameters:addInteger("style60", "Style", "The style of the 60 level", core.LINE_DOT);
    indicator.parameters:setFlag("style60", core.FLAG_LEVEL_STYLE);
    
    indicator.parameters:addGroup("70");
    indicator.parameters:addBoolean("show70", "Show 70", "Show the 70 level in RSI" , true);
    indicator.parameters:addColor("color70", "Color", "The color of the 70 level", core.rgb(192, 192, 192));
    indicator.parameters:addInteger("width70", "Width", "The width of the 70 level", 2, 1, 5);
    indicator.parameters:addInteger("style70", "Style", "The style of the 70 level", core.LINE_SOLID);
    indicator.parameters:setFlag("style70", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;

local first;
local source = nil;
local pos = nil;
local neg = nil;

-- Streams block
local RSI = nil;

-- Routine
function Prepare(nameOnly)

    n = instance.parameters.N;
    source = instance.source;
    first = source:first() + n - 1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    pos = instance:addInternalStream(0, 0);
    neg = instance:addInternalStream(0, 0);

    RSI = instance:addStream("RSI", core.Line, name, "RSI", instance.parameters.clrRSI, first);
    RSI:setWidth(instance.parameters.widthRSI);
    RSI:setStyle(instance.parameters.styleRSI);
    RSI:setPrecision(2);


    if instance.parameters.show30 then
        RSI:addLevel(30, instance.parameters.style30, instance.parameters.width30, instance.parameters.color30);
    end
    if instance.parameters.show40 then
        RSI:addLevel(40, instance.parameters.style40, instance.parameters.width40, instance.parameters.color40);
    end
    if instance.parameters.show50 then
        RSI:addLevel(50, instance.parameters.style50, instance.parameters.width50, instance.parameters.color50);
    end
    if instance.parameters.show60 then
        RSI:addLevel(60, instance.parameters.style60, instance.parameters.width60, instance.parameters.color60);
    end
    if instance.parameters.show70 then
        RSI:addLevel(70, instance.parameters.style70, instance.parameters.width70, instance.parameters.color70);
    end   
end

-- Indicator calculation routine
function Update(period)
    if period >= first then
        local i = 0;
        local sump = 0;
        local sumn = 0;
        local positive = 0;
        local negative = 0;
        local diff = 0;
        if (period == first) then
            for i = period - n + 1, period do
                diff = source[i] - source[i - 1];
                if (diff >= 0) then
                    sump = sump + diff;
                else
                    sumn = sumn - diff;
                end
            end
            positive = sump / n;
            negative = sumn / n;
        else
            diff = source[period] - source[period - 1];
            if (diff > 0) then 
                sump = diff;
            else
                sumn = -diff;
            end
            positive = (pos[period - 1] * (n - 1) + sump) / n;
            negative = (neg[period - 1] * (n - 1) + sumn) / n;
        end
        pos[period] = positive;
        neg[period] = negative;
        if (negative == 0) then
            RSI[period] = 0;
        else
            RSI[period] = 100 - (100 / (1 + positive / negative));
        end
    end
end