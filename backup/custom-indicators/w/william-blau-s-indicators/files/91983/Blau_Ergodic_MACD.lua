-- Id: 10872
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10878


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
function Init()
    indicator:name("William Blau Ergodic MACD");
    indicator:description("William Blau Ergodic MACD");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Smooth_Period1", "Smooth period 1", "", 20);
    indicator.parameters:addInteger("Smooth_Period2", "Smooth period 2", "", 5);
    indicator.parameters:addInteger("Smooth_Period3", "Smooth period 3", "", 3);
    indicator.parameters:addInteger("Signal_Period", "Signal period", "", 3);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(128, 128, 128));
    indicator.parameters:addColor("Sclr", "Signal color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Smooth_Period1;
local Smooth_Period2;
local Smooth_Period3;
local Signal_Period;
local MACD;
local EMA1, EMA2, EMA3;
local Signal_EMA;
local Blau_MACD=nil;

function Prepare(nameOnly)  
    source = instance.source;
    Smooth_Period1=instance.parameters.Smooth_Period1;
    Smooth_Period2=instance.parameters.Smooth_Period2;
    Smooth_Period3=instance.parameters.Smooth_Period3;
    Signal_Period=instance.parameters.Signal_Period;
    first = source:first()+2;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Smooth_Period1 .. ", " .. instance.parameters.Smooth_Period2 .. ", " .. instance.parameters.Smooth_Period3 .. ", " .. instance.parameters.Signal_Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    MACD = instance:addInternalStream(first, 0);
    EMA1 = core.indicators:create("EMA", source, Smooth_Period1);
    EMA2 = core.indicators:create("EMA", source, Smooth_Period2);
    EMA3 = core.indicators:create("EMA", MACD, Smooth_Period3);
    
	
    Blau_MACD = instance:addStream("Blau_MACD", core.Bar, name .. ".Blau_MACD", "Blau_MACD", instance.parameters.clr, EMA3.DATA:first());
    Signal_EMA = core.indicators:create("EMA", Blau_MACD, Signal_Period);
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Sclr,Signal_EMA.DATA:first());
    Signal:setWidth(instance.parameters.widthLinReg);
    Signal:setStyle(instance.parameters.styleLinReg);
	
	Blau_MACD:setPrecision(math.max(2, instance.source:getPrecision()));
	Signal_EMA:setPrecision(math.max(2, instance.source:getPrecision()));
	Signal:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if period>first then
    EMA1:update(mode);
    EMA2:update(mode);
    MACD[period]=EMA2.DATA[period]-EMA1.DATA[period];
    EMA3:update(mode);
    Blau_MACD[period]=EMA3.DATA[period];
    Signal_EMA:update(mode);
    Signal[period]=Signal_EMA.DATA[period];
   end 
end

