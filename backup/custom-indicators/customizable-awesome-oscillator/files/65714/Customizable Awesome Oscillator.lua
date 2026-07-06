-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=40068
-- Id: 9259

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


function Init()
    indicator:name("Customizable Awesome Oscillator");
    indicator:description("Awesome Oscillator with alternative choice of moving averages.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Bill Williams");
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FM", "","", 5, 2, 10000);
    indicator.parameters:addInteger("SM", "","", 35, 2, 10000);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("GO_color","Higher Bars","", core.rgb(0, 255, 0));
    indicator.parameters:addColor("RO_color", "Lower Bars","", core.rgb(255, 0, 0));
end

local FM;
local SM;
local SC;
local Method;
local first;
local source = nil;

-- Streams block
local CL = nil;

local FMVA = nil;
local SMVA = nil;
local GO, RO;

function Prepare(nameOnly)
    FM = instance.parameters.FM;
    SM = instance.parameters.SM;
    SC = instance.parameters.SC;
	Method = instance.parameters.Method;

    assert(FM < SM, "Number of periods for the fast MA must be less than for the slow MA.");

    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. FM .. ", " .. SM .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    -- Create the median stream
    FMVA = core.indicators:create(Method, source, FM);
    SMVA = core.indicators:create(Method, source, SM);
	
	first = math.max(FMVA.DATA:first(),SMVA.DATA:first());

    CL = instance:addStream("AO", core.Bar, name .. ".AO", "AO", instance.parameters.GO_color, first);
    CL:addLevel(0);
    GO = instance.parameters.GO_color;
    RO = instance.parameters.RO_color;
	
	CL:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
    FMVA:update(mode);
    SMVA:update(mode);

    if (period  <first) then
	return;
	end
        CL[period] = FMVA.DATA[period] - SMVA.DATA[period];
    
    if (period >= first + 1) then
        if (CL[period] > CL[period - 1]) then
            CL:setColor(period, GO);
        elseif (CL[period] < CL[period - 1]) then
            CL:setColor(period, RO);
        else
            CL:setColor(period, CL:colorI(period - 1));
        end
    end
end

