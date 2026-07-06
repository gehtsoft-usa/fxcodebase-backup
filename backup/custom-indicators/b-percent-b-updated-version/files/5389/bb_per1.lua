-- Id: 2040
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2464

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

-- The indicator corresponds to the Bollinger Bands indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 5 "Trend System" (page 91-94)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Bollinger Band - Percentage Oscillator");
    indicator:description("Provides a percentage display between two Bollinger Bands.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Parameters");
    indicator.parameters:addInteger("N", "Number of periods", "Number of periods", 20);
    indicator.parameters:addDouble("Dev", "Number of standard deviations", "Number of standard deviations", 2);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrBBP", "Line color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthBBP", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleBBP", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleBBP", core.FLAG_LINE_STYLE);

    indicator.parameters:addGroup("Levels");
    indicator.parameters:addColor("clrL", "Line color", "", core.rgb(192, 192, 192));
    indicator.parameters:addInteger("widthL", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleL", "Line style", "", core.LINE_DOT);
    indicator.parameters:setFlag("styleL", core.FLAG_LINE_STYLE);
    indicator.parameters:addBoolean("customLevels", "Show Custom Levels", "You can specify two levels in addition to 0/50/100", false);
    indicator.parameters:addDouble("customLevel1", "First custom level", "", 40, 0, 100);
    indicator.parameters:addDouble("customLevel2", "Second custom level", "", 60, 0, 100);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local D;

local firstPeriod;
local source = nil;

-- Streams block
local TL = nil;
local AL = nil;
local BL = nil;

local PL = nil;

-- Routine
function Prepare(nameOnly)  
    N = instance.parameters.N;
    D = instance.parameters.Dev;
    source = instance.source;
    firstPeriod = source:first() + N - 1;

    local name;
    name = profile:id() .. "(" .. source:name() .. "," .. N .. "," .. D .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    -- TOP LINE AND BOTTOM LINE INTERNAL STREAMS
    TL = instance:addInternalStream(firstPeriod)
    BL = instance:addInternalStream(firstPeriod)
    AL = instance:addInternalStream(firstPeriod)

    -- PERCENTAGE LINE
    PL = instance:addStream("P", core.Line, name .. ".P", "P", instance.parameters.clrBBP, firstPeriod);
    PL:setPrecision(math.max(2, instance.source:getPrecision()));
    PL:setWidth(instance.parameters.widthBBP);
    PL:setStyle(instance.parameters.styleBBP);

    PL:addLevel(0, instance.parameters.styleL, instance.parameters.widthL, instance.parameters.clrL);
    PL:addLevel(50, instance.parameters.styleL, instance.parameters.widthL, instance.parameters.clrL);
    PL:addLevel(100, instance.parameters.styleL, instance.parameters.widthL, instance.parameters.clrL);

    if (instance.parameters.customLevels) then
        PL:addLevel(instance.parameters.customLevel1, instance.parameters.styleL, instance.parameters.widthL, instance.parameters.clrL);
        PL:addLevel(instance.parameters.customLevel2, instance.parameters.styleL, instance.parameters.widthL, instance.parameters.clrL);
    end
end

-- Indicator calculation routine
function Update(period)
    -- CALCULATE "Bollinger Bands" INTERNAL STREAMS
    if(period >= firstPeriod) then
        local p = core.rangeTo(period, N);
        local ml = core.avg(source, p);
        local d = core.stdev(source, p);

        TL[period] = ml + D * d;
        BL[period] = ml - D * d;
        AL[period] = ml;
    end

    -- CALCULATE "Bollinger Bands" PERCENTAGE STREAM
    if(period >= firstPeriod) then
        PL[period] = ((source[period] - BL[period]) / (TL[period] - BL[period])) * 100;
    end
end





