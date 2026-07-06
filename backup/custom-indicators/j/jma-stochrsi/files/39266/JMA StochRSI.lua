-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22755
-- Id: 7209

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
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("JMA Smoothed Stochastic RSI");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 
   indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods for RSI", "", 14, 1, 200);
    indicator.parameters:addInteger("K", "%K Stochastic Periods", "", 14, 1, 200);
	
    indicator.parameters:addGroup("K Line JMA Calculation");
    indicator.parameters:addInteger("N1", "Number of periods to smooth", "", 8, 1, 10000);
    indicator.parameters:addInteger("P1", "Phase", "", 100, -1000, 1000);
	
	 indicator.parameters:addGroup("D Line JMA Calculation");
    indicator.parameters:addInteger("N2", "Number of periods to smooth", "", 8, 1, 10000);
    indicator.parameters:addInteger("P2", "Phase", "", 100, -1000, 1000);
	
   	indicator.parameters:addGroup("K Line Style");
	 indicator.parameters:addColor("K_color", "Color of K", "Color of K", core.rgb(0, 255, 0));
	 indicator.parameters:addInteger("K_width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("K_style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("K_style", core.FLAG_LINE_STYLE);
	indicator.parameters:addGroup("D Line Style");
    indicator.parameters:addColor("D_color", "Color of D", "Color of D", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("D_width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("D_style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("D_style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine

-- Parameters block
local N;
local K;
local KS;
local D;

local firstSKI;
local firstK;
local firstD;
local source = nil;

-- Streams block
local SKI = nil;
local SK = nil;
local SD = nil;
local RSI = nil;
local MVA1 = nil;
local MVA2 = nil;
local N1, N2, P1,P2;
-- Routine
function Prepare(nameOnly)
    K = instance.parameters.K;
    N = instance.parameters.N;
    N1= instance.parameters.N1;
	P1= instance.parameters.P1;
	N2= instance.parameters.N2;
	P2= instance.parameters.P2;

    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. K .. ", " .. N1 ..", " .. P1 .. ", " .. N2 ..", " .. P2.. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    RSI = core.indicators:create("RSI", source, N);
    firstSKI = RSI.DATA:first() + K;
    SKI = instance:addInternalStream(firstSKI, 0);
	
	assert(core.indicators:findIndicator("JMA") ~= nil, "Please, download and install JMA.LUA indicator");
    MVA1 = core.indicators:create("JMA", SKI,  N1,P2 );
    firstK = MVA1.DATA:first();
    SK = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.K_color, firstK);
    SK:setPrecision(math.max(2, instance.source:getPrecision()));
	SK:setWidth(instance.parameters.K_width);
    SK:setStyle(instance.parameters.K_style);
    SK:addLevel(20);
    SK:addLevel(50);
    SK:addLevel(80);
    MVA2 = core.indicators:create("JMA", SK,  N2,P2 );
    firstD = MVA2.DATA:first();
    SD = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.D_color, firstD);
    SD:setPrecision(math.max(2, instance.source:getPrecision()));
	SD:setWidth(instance.parameters.D_width);
    SD:setStyle(instance.parameters.D_style);
end

-- Indicator calculation routine
function Update(period, mode)
    RSI:update(mode);

    if (period >= firstSKI) then
        local min, max;
      --  local range;
       -- range = core.rangeTo(period, K);
        min,max = mathex.minmax(RSI.DATA, period-K+1, period);
        --max = core.max(RSI.DATA, range);
        if (min == max) then
            SKI[period] = 100;
        else
            SKI[period] = (RSI.DATA[period] - min) / (max - min) * 100;
        end
    end

    MVA1:update(mode);

    if period >= firstK then
        SK[period] = MVA1.DATA[period];
    end

    MVA2:update(mode);

    if (period >= firstD) then
        SD[period] = MVA2.DATA[period];
    end
end

