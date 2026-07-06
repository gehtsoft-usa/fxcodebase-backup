-- Id: 10854
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
    indicator:name("William Blau Stochastic oscillator");
    indicator:description("William Blau Stochastic oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 5);
    indicator.parameters:addInteger("Smooth_Period1", "Smooth period 1", "", 20);
    indicator.parameters:addInteger("Smooth_Period2", "Smooth period 2", "", 5);
    indicator.parameters:addInteger("Smooth_Period3", "Smooth period 3", "", 3);
    indicator.parameters:addInteger("Signal_Period", "Signal period", "", 3);
    indicator.parameters:addString("Price", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price", "close", "", "close");
    indicator.parameters:addStringAlternative("Price", "open", "", "open");
    indicator.parameters:addStringAlternative("Price", "high", "", "high");
    indicator.parameters:addStringAlternative("Price", "low", "", "low");
    indicator.parameters:addStringAlternative("Price", "median", "", "median");
    indicator.parameters:addStringAlternative("Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price", "weighted", "", "weighted");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(128, 128, 128));
    indicator.parameters:addColor("Sclr", "Signal color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Smooth_Period1;
local Smooth_Period2;
local Smooth_Period3;
local Signal_Period;
local Price;
local Stoch;
local HH;
local Stoch_EMA1, Stoch_EMA2, Stoch_EMA3;
local HH_EMA1, HH_EMA2, HH_EMA3;
local TStoch_EMA;
local Blau_TStoch=nil;
local Signal=nil;

function Prepare(nameOnly)  
    source = instance.source;
    Period=instance.parameters.Period;
    Smooth_Period1=instance.parameters.Smooth_Period1;
    Smooth_Period2=instance.parameters.Smooth_Period2;
    Smooth_Period3=instance.parameters.Smooth_Period3;
    Signal_Period=instance.parameters.Signal_Period;
    Price=instance.parameters.Price;
    first = source:first()+2;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Smooth_Period1 .. ", " .. instance.parameters.Smooth_Period2 .. ", " .. instance.parameters.Smooth_Period3 .. ", " .. instance.parameters.Signal_Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    Stoch = instance:addInternalStream(first, 0);
    HH = instance:addInternalStream(first, 0);
    Stoch_EMA1 = core.indicators:create("EMA", Stoch, Smooth_Period1);
    Stoch_EMA2 = core.indicators:create("EMA", Stoch_EMA1.DATA, Smooth_Period2);
    Stoch_EMA3 = core.indicators:create("EMA", Stoch_EMA2.DATA, Smooth_Period3);
    HH_EMA1 = core.indicators:create("EMA", HH, Smooth_Period1);
    HH_EMA2 = core.indicators:create("EMA", HH_EMA1.DATA, Smooth_Period2);
    HH_EMA3 = core.indicators:create("EMA", HH_EMA2.DATA, Smooth_Period3);
    
	
    Blau_TStoch = instance:addStream("Blau_TStoch", core.Bar, name .. ".Blau_TStoch", "Blau_TStoch", instance.parameters.clr, HH_EMA3.DATA:first());
    TStoch_EMA = core.indicators:create("EMA", Blau_TStoch, Signal_Period);
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Sclr, TStoch_EMA.DATA:first());
    Signal:setWidth(instance.parameters.widthLinReg);
    Signal:setStyle(instance.parameters.styleLinReg);
	
	
	Blau_TStoch:setPrecision(math.max(2, instance.source:getPrecision()));
	Signal:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if period>first+Period then
    local Min, Max=mathex.minmax(source, period-Period+1, period);
    Stoch[period]=source[Price][period]-Min;
    HH[period]=Max-Min;
    Stoch_EMA1:update(mode);
    Stoch_EMA2:update(mode);
    Stoch_EMA3:update(mode);
    HH_EMA1:update(mode);
    HH_EMA2:update(mode);
    HH_EMA3:update(mode);
    if HH_EMA3.DATA[period]>0 then
     Blau_TStoch[period]=100*Stoch_EMA3.DATA[period]/HH_EMA3.DATA[period];
    else
     Blau_TStoch[period]=0;
    end
    TStoch_EMA:update(mode);
    Signal[period]=TStoch_EMA.DATA[period];
   end 
end

