
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=16809

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
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


-- The indicator corresponds to the ADX indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 23 "Risk Control" (page 609-611)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Tick ADX");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Trend Strength");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Period", "", 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrADX", "Line Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthADX", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleADX","Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleADX", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;
local first, dmifirst;
local source = nil;
local buffer = nil;
local dmi = nil;
local ema = nil;

-- Streams block
local ADX = nil;

-- Routine
function Prepare(nameOnly)
    n = instance.parameters.N;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
    assert(core.indicators:findIndicator("TICK DMI") ~= nil, "Please, download and install TICK DMI.LUA indicator");

    dmi = core.indicators:create("TICK DMI", source, n);
    dmifirst = dmi.DIP:first();

    buffer = instance:addInternalStream(dmifirst, 0);

    ema = core.indicators:create("EMA", buffer, n);
    first = ema.DATA:first();

    ADX = instance:addStream("ADX", core.Line, name, "ADX", instance.parameters.clrADX, first)
    ADX:setPrecision(2);
    ADX:setWidth(instance.parameters.widthADX);
    ADX:setStyle(instance.parameters.styleADX);
end

-- Indicator calculation routine
function Update(period, mode)
    dmi:update(mode);

    if period >= dmifirst then
        local plus = dmi.DIP[period];
        local minus = dmi.DIM[period];

        local div = plus + minus;
        if (div == 0) then
            buffer[period] = 0;
        else
            buffer[period] = 100 * (math.abs(plus - minus) / div)
        end
    end

    if period >= first then
        ema:update(mode);
        ADX[period] = ema.DATA[period];
    end
end





