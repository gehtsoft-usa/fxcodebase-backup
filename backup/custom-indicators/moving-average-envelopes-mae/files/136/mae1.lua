
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=126

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- The indicator corresponds to the Moving Average indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 4 "Trend Calculations" (page 67-70)

-- initializes the indicator
function Init()
    indicator:name("Moving Average Envelope (Custom Version)");
    indicator:description("Moving Average Envelope which supports 1/10 of percent in parameters");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("N", "Number of periods of Moving Average", "", 20, 2, 300);
    indicator.parameters:addDouble("W", "Band Offset in 1/10 of percent", "", 2.5, 0.001, 1000);
    indicator.parameters:addString("SM", "Show MVA?", "", "No");
    indicator.parameters:addStringAlternative("SM", "Yes", "", "Yes");
    indicator.parameters:addStringAlternative("SM", "No", "", "No");
    indicator.parameters:addColor("clrBand", "Color of envelope band", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("clrMva", "Color of moving average", "", core.rgb(255, 0, 0));
end

local first = 0;        -- first period we can calculate
local n = 0;            -- MVA parameter
local w = 0;            -- band width
local source = nil;     -- source
local mva = nil;        -- moving average
local up = nil;         -- upper band
local low = nil;        -- lower band

-- initializes the instance of the indicator
function Prepare(nameOnly)  
    source = instance.source;
    n = instance.parameters.N;
    w = instance.parameters.W;

    first = n + source:first() - 1;
    local name = profile:id() .. "(" .. source:name() .. "," .. n .. "," .. w .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    if instance.parameters.SM == "Yes" then
        mva = instance:addStream("MVA", core.Line, name .. ".MVA", "MVA", instance.parameters.clrMva,  first)
    end
    up = instance:addStream("UP", core.Line, name .. ".UP", "UP", instance.parameters.clrBand,  first)
    low = instance:addStream("LOW", core.Line, name .. ".LOW", "LOW", instance.parameters.clrBand,  first)
end

-- calculate the value
function Update(period)
    if (period < first) then
	return;
	end
	
        local v;
        v = mathex.avg(source, period- n+1, period);
        if mva ~= nil then
            mva[period] = v;
        end
        up[period] = v * (1 + w / 1000);
        low[period] = v * (1 - w / 1000);
   
end

