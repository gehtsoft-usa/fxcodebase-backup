-- Id: 3734
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Stochastic RSI");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 
   indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods for RSI", "", 14, 1, 200);
    indicator.parameters:addInteger("K", "%K Stochastic Periods", "", 14, 1, 200);
    indicator.parameters:addInteger("KS", "%K Slowing Periods", "", 5, 1, 200);
    indicator.parameters:addInteger("D", "%D Slowing Stochastic Periods", "", 3, 1, 200);
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

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    K = instance.parameters.K;
    KS = instance.parameters.KS;
    D = instance.parameters.D;
    source = instance.source;
    first = source:first();

    RSI = core.indicators:create("RSI", source, N);
    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. K .. ", " .. KS ..", " .. D .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    firstSKI = RSI.DATA:first() + K;
    SKI = instance:addInternalStream(firstSKI, 0);
    MVA1 = core.indicators:create("MVA", SKI, KS);
    firstK = MVA1.DATA:first();
    SK = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.K_color, firstK);
	SK:setWidth(instance.parameters.K_width);
    SK:setStyle(instance.parameters.K_style);
    SK:addLevel(20);
    SK:addLevel(50);
    SK:addLevel(80);
    MVA2 = core.indicators:create("MVA", SK, D);
    firstD = MVA2.DATA:first();
    SD = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.D_color, firstD);
	SD:setWidth(instance.parameters.D_width);
    SD:setStyle(instance.parameters.D_style);
	
	SK:setPrecision(math.max(2, instance.source:getPrecision()));
	SD:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
function Update(period, mode)
    RSI:update(mode);

    if (period >= firstSKI) then
        local min, max;
       -- local range;
      --  range = core.rangeTo(period, K);
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

