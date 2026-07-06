-- Id: 379

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=19

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


function Init()
    indicator:name("Awesome Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("FM", "Fast Moving Average", "The number of periods to calculate the fast moving average of the median price", 5, 2, 10000);
    indicator.parameters:addInteger("SM", "Slow Moving Average", "The number of periods to calculate the slow moving average of the median price", 35, 2, 10000);
    indicator.parameters:addBoolean("SC", "Show the covering line", "Shows line trough the tops of bars", false);
    indicator.parameters:addColor("CL_color", "Color for covering line", "Color for covering line", core.rgb(255, 255, 255));
    indicator.parameters:addColor("GO_color", "Color for higher bars", "Color for higher bars", core.rgb(0, 255, 0));
    indicator.parameters:addColor("RO_color", "Color for lower bars", "Color for lower bars", core.rgb(255, 0, 0));
end

local FM;
local SM;
local SC;

local first;
local source = nil;

-- Streams block
local CL = nil;
local GO = nil;
local RO = nil;

local MEDIAN = nil;
local FMVA = nil;
local SMVA = nil;

function Prepare(nameOnly)
    FM = instance.parameters.FM;
    SM = instance.parameters.SM;
    SC = instance.parameters.SC;

    assert(FM < SM, "Fast moving average parameter must be less than slow moving average");

    source = instance.source;
    first = source:first() + SM;

    -- Create the median stream
    MEDIAN = instance:addInternalStream(0, 0);
    FMVA = core.indicators:create("MVA", MEDIAN, FM);
    SMVA = core.indicators:create("MVA", MEDIAN, SM);

    local name = profile:id() .. "(" .. source:name() .. ", " .. FM .. ", " .. SM .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    if SC then
        CL = instance:addStream("AO", core.Line, name .. ".AO", "AO", instance.parameters.CL_color, first);
    else
        CL = instance:addInternalStream(first, 0);
    end
    GO = instance:addStream("GO", core.Bar, name .. ".GO", "GO", instance.parameters.GO_color, first);
    RO = instance:addStream("RO", core.Bar, name .. ".RO", "RO", instance.parameters.RO_color, first);
	
	GO:setPrecision(math.max(2, instance.source:getPrecision()));
	RO:setPrecision(math.max(2, instance.source:getPrecision()));
	CL:setPrecision(math.max(2, instance.source:getPrecision()));
    if SC then
        CL:addLevel(0);
    else
        GO:addLevel(0);
    end
end

function Update(period, mode)
    MEDIAN[period] = (source.high[period] + source.low[period]) / 2;
    FMVA:update(mode);
    SMVA:update(mode);

    if (period >= first) then
        CL[period] = FMVA.DATA[period] - SMVA.DATA[period];
    end
    if (period >= first + 1) then
        if (CL[period] > CL[period - 1]) then
            GO[period] = CL[period];
        elseif (CL[period] < CL[period - 1]) then
            RO[period] = CL[period];
        elseif GO[period - 1] > 0 then
            GO[period] = CL[period];
        else
            RO[period] = CL[period];
        end
    end
end

