-- Id: 18793
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=993

--+------------------------------------------------------------------+
--|                               Copyright � 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
 

-- Elder Impulse System
-- ----------------------------------------------------------------------------------------------------
-- Copyright � 2007, http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/
-- http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/
-- MT4 info: I used code from Macd_Correct by David W. Thomas and eSignal code supplied by bentleybrian <bentleybrian@yahoo.com>
-- to build this indicator . Built by transport_david .
-- ----------------------------------------------------------------------------------------------------
function Init()
    indicator:name("Elder Impulse System");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("EMA", "EMA periods for study", "", 13, 1, 100);
    indicator.parameters:addInteger("MACDF", "MACD periods fast", "", 12, 1, 100);
    indicator.parameters:addInteger("MACDS", "MACD periods slow", "", 26, 1, 100);
    indicator.parameters:addColor("UP_color", "Color of up signal", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DOWN_color", "Color of down signal", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("NE_color", "Color of neutral signal", "", core.rgb(0, 0, 255));
end

local first;
local EIS;
local EMA;
local MACDF;
local MACDS;
local MACD;
local SIGNAL;

local alpha;
local alpha1;

function Prepare()
    alpha = 2.0 / (9 + 1.0);
    alpha1 = 1.0 - alpha;

    EMA = core.indicators:create("EMA", instance.source, instance.parameters.EMA);
    MACDF = core.indicators:create("EMA", instance.source, instance.parameters.MACDF);
    MACDS = core.indicators:create("EMA", instance.source, instance.parameters.MACDS);

    MACD = instance:addInternalStream(MACDS.DATA:first(), 0);
    SIGNAL = instance:addInternalStream(0, 0);

    first = MACDS.DATA:first() + 1;

    local name = profile:id() .. "(" .. instance.source:name() .. ", " .. instance.parameters.EMA .. ", " .. instance.parameters.MACDF .. ", " .. instance.parameters.MACDS .. ")";
    instance:name(name);

    EIS = instance:addStream("EIS", core.Bar, name .. "EIS", "EIS", instance.parameters.NE_color, first);
    EIS:setPrecision(math.max(2, instance.source:getPrecision()));
    EIS:addLevel(0);
end

function Update(period, mode)
    EMA:update(mode);
    MACDF:update(mode);
    MACDS:update(mode);

    SIGNAL[period] = 0;
	EIS[period] = 100;

    if period >= first then
        local s1v1, s1v2;
        s1v1 = EMA.DATA[period];
        s1v2 = EMA.DATA[period - 1];

        MACD[period] = MACDF.DATA[period] - MACDS.DATA[period];
        if (period == first) then
            SIGNAL[period] = MACD[period];
        else
            SIGNAL[period] = alpha * MACD[period] + alpha1 * SIGNAL[period - 1];
        end

        local s2v1, s2v2;

        s2v1 = MACD[period] - SIGNAL[period];
        s2v2 = MACD[period - 1] - SIGNAL[period - 1];

       

        if s1v1 > s1v2 and s2v1 > s2v2 then
            
             
         EIS:setColor(period, instance.parameters.UP_color);

        elseif s1v1 < s1v2 and s2v1 < s2v2 then
          EIS:setColor(period, instance.parameters.DOWN_color);

        else
   
        EIS:setColor(period, instance.parameters.NE_color);
		
        end
    end
end
