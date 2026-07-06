-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66222
-- Id: 

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine

function Init()
    indicator:name("ADXVMA (NT7)");
    indicator:description("Port from NT7 ana ADXVMA");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Length", "Length", "", 6, 2, 2000);
 
    indicator.parameters:addGroup("Style");     
    indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Neutral Line Color", "", core.rgb(0, 0, 255));
    
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);    
    indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
    
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Length;

local Up, Down, Neutral;

local first;

local Price = nil;
local ADXVMA;
local k;
local volatility;
local up;
local down;
local ups;
local downs;
local index;
local trend;
-- Routine
function Prepare(nameOnly) 
    Length = instance.parameters.Length;
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " .. Length .. ")";
    instance:name(name); 
    if   (nameOnly) then
        return;
    end
    
    Up = instance.parameters.Up;
    Down = instance.parameters.Down;
    Neutral = instance.parameters.Neutral;
    Price = instance.source;

    first = Price:first() + Length + 1;
 
    k = 1.0 / Length;
    up = instance:addInternalStream(0, 0);
    down = instance:addInternalStream(0, 0);
    ups = instance:addInternalStream(0, 0);
    downs = instance:addInternalStream(0, 0);
    index = instance:addInternalStream(0, 0);
    trend = instance:addInternalStream(0, 0);
    volatility = core.indicators:create("ATR", Price, 200);
    ADXVMA = instance:addStream("ADXVMA", core.Line, " ADXVMA"," ADXVMA", Neutral, first, -1);
    ADXVMA:setWidth(instance.parameters.width);
    ADXVMA:setStyle(instance.parameters.style);
end

local epsilon;
-- Indicator calculation routine
function Update(period, mode)
    volatility:update(mode);
    if period < first then
        return;
    elseif period == first then
        ADXVMA[period - 1] = Price[period];
    end
    local currentUp = math.max(Price[period] - Price[period - 1], 0);
    local currentDown = math.max(Price[period - 1] - Price[period], 0);
    up[period] = (1 - k) * up[period - 1] + k * currentUp;
    down[period] = (1 - k) * down[period - 1] + k * currentDown;
    local sum = up[period] + down[period];
    local fractionUp = 0.0;
    local fractionDown = 0.0;
    if (sum ~= 0) then
        fractionUp = up[period] / sum;
        fractionDown = down[period] / sum;
    end
    ups[period] = (1 - k) * ups[period - 1] + k * fractionUp;
    downs[period] = (1 - k) * downs[period - 1] + k * fractionDown;
    
    local normDiff = math.abs(ups[period] - downs[period]);
    local normSum = ups[period] + downs[period];
    local normFraction = 0.0;
    if (normSum ~= 0) then
        normFraction = normDiff / normSum;
    end
    index[period] = (1 - k) * index[period - 1] + k * normFraction;
    
    epsilon = 0.1 * volatility.DATA[period - 1];
    local hhp = mathex.max(index, period - 1 - Length, period - 1);
    local llp = mathex.min(index, period - 1 - Length, period - 1);
    local hhv = math.max(index[period], hhp);
    local llv = math.min(index[period], llp);
    
    local vDiff = hhv - llv;
    local vIndex = 0;
    if (vDiff ~= 0) then
        vIndex = (index[period] - llv) / vDiff;
    end
    
    ADXVMA[period - 1] = (1 - k * vIndex) * ADXVMA[period - 2] + k * vIndex * Price[period];
    if (trend[period - 1] > -0.5 and ADXVMA[period - 1] > ADXVMA[period - 2] + epsilon) then
        trend[period] = 1.0;
        ADXVMA:setColor(period - 1, Up);
    elseif (trend[period - 1] < 0.5 and ADXVMA[period - 1] < ADXVMA[period - 2] - epsilon) then
        trend[period] = -1.0;
        ADXVMA:setColor(period - 1, Down);
    else
        trend[period] = 0.0;
        ADXVMA:setColor(period - 1, Neutral);
    end
   
end

