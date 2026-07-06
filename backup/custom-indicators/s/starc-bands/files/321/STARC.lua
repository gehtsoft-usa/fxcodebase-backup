
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=228

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

--- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("STARC Band");
    indicator:description("Indicates upper and lower limits of price movement.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
    indicator.parameters:addDouble("USM", "Multiplier", "The deviation multiplier", 2);
    indicator.parameters:addInteger("SMA_N", "Number of MVA periods", "The number of periods used in the Moving Average calculation", 6);
    indicator.parameters:addInteger("ATR_N", "Number of ATR periods", "The number of periods used in the Average True Range calculation", 14);
    
    indicator.parameters:addColor("UB_color", "Upper line color", "The color of the upper line", core.rgb(0, 255, 0));
    indicator.parameters:addColor("LB_color", "Lower line color", "The color of the lower line", core.rgb(255,0,0));
    indicator.parameters:addColor("AL_color", "Average line color", "The color of the average line", core.rgb(192,192,192));
end

-- Parameters block
local USM;

local first;
local source = nil;

-- internal indicators
local SMA = nil;
local ATR = nil;

-- Streams block
local UB = nil;
local LB = nil;
local AL = nil;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
function Prepare(nameOnly)
    USM = instance.parameters.USM;
    source = instance.source;    
    local SMA_N = instance.parameters.SMA_N;
    local ATR_N = instance.parameters.ATR_N;
    local PriceType = instance.parameters.SMA_source;
    
    local name = profile:id() .. "(" .. source:name() .. ", ".. USM .. ", ".. SMA_N .. ", ".. ATR_N .. ")";
    instance:name(name);  

    if   (nameOnly) then
        return;
    end	
    
    local pricestream = source.close;
    
    SMA = core.indicators:create("MVA", pricestream, SMA_N);
    ATR = core.indicators:create("ATR", source, ATR_N);
    first = math.max(SMA.DATA:first(), ATR.DATA:first());
    UB = instance:addStream("UB", core.Line, name, "Uppper Band", instance.parameters.UB_color, first);	
    LB = instance:addStream("LB", core.Line, name, "Lower Band", instance.parameters.LB_color, first);
    AL = instance:addStream("AL", core.Line, name, "Average", instance.parameters.AL_color, first);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    SMA:update(mode);
    ATR:update(mode);

    if period >= first and source:hasData(period) then
        local smaVal = SMA.DATA[period];
        local atrVal = USM * ATR.DATA[period];

        UB[period] = smaVal + atrVal;
        LB[period] = smaVal - atrVal;
        AL[period] = smaVal;
    end
end