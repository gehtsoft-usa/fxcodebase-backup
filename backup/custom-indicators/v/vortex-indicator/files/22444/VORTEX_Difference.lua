-- Id: 5500
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=277

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+
 

-- Indicator profile initialization routine
function Init()
    indicator:name("The Vortext Difference Indicator");
    indicator:description("The indicator was described in Jan, 10 issue of the 'Stock and Commodites' Magazin");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("N", "Length of the vortex", "No description", 14);
    indicator.parameters:addColor("VID_color", "Color of VID", "Color of VID", core.rgb(0, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
local N;

local first;
local source = nil;

-- Streams block
local VID = nil;
local iVIP = nil;
local iVIN = nil;
local iATR = nil;

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
    N = instance.parameters.N;
    source = instance.source;
    iATR = core.indicators:create("ATR", instance.source, 1);
 
    first = iATR.DATA:first() + N; 

    
    VID = instance:addStream("VID", core.Line, name .. ".VID", "VID", instance.parameters.VID_color, first);
    VID:setPrecision(math.max(2, instance.source:getPrecision()));

    iVID = instance:addInternalStream(1, 0)
    iVIP = instance:addInternalStream(1, 0);
    iVIM = instance:addInternalStream(1, 0);
end

-- Indicator calculation routine
function Update(period, mode)
    iATR:update(mode);
    if period >= 1 then
        iVIP[period] = math.abs(source.high[period] - source.low[period - 1]);
        iVIM[period] = math.abs(source.low[period] - source.high[period - 1]);
    end
    if period >= first then
        local svip, svim, satr;
        local range;
        range = core.rangeTo(period, N);
        svip = core.sum(iVIP, range);
        svim = core.sum(iVIM, range);
        satr = core.sum(iATR.DATA, range);
		
        VID[period] = svip / satr * 100 - svim / satr * 100;
    end
end

