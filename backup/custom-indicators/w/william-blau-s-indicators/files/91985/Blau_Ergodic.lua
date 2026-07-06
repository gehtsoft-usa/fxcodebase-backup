-- Id: 10873
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
    indicator:name("William Blau Ergodic Oscillator");
    indicator:description("William Blau Ergodic Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 2);
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
local Period;
local Smooth_Period1;
local Smooth_Period2;
local Smooth_Period3;
local Signal_Period;
local Mtm;
local AbsMtm;
local EMA1, EMA2, EMA3;
local AbsEMA1, AbsEMA2, AbsEMA3;
local Signal_EMA;
local Blau_Er=nil;
local Signal=nil;

function Prepare(nameOnly)  
    source = instance.source;
    Period=instance.parameters.Period;
    Smooth_Period1=instance.parameters.Smooth_Period1;
    Smooth_Period2=instance.parameters.Smooth_Period2;
    Smooth_Period3=instance.parameters.Smooth_Period3;
    Signal_Period=instance.parameters.Signal_Period;
    first = source:first()+2;
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Smooth_Period1 .. ", " .. instance.parameters.Smooth_Period2 .. ", " .. instance.parameters.Smooth_Period3 .. ", " .. instance.parameters.Signal_Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    Mtm = instance:addInternalStream(first, 0);
    AbsMtm = instance:addInternalStream(first, 0);
    EMA1 = core.indicators:create("EMA", Mtm, Smooth_Period1);
    EMA2 = core.indicators:create("EMA", EMA1.DATA, Smooth_Period2);
    EMA3 = core.indicators:create("EMA", EMA2.DATA, Smooth_Period3);
    AbsEMA1 = core.indicators:create("EMA", AbsMtm, Smooth_Period1);
    AbsEMA2 = core.indicators:create("EMA", AbsEMA1.DATA, Smooth_Period2);
    AbsEMA3 = core.indicators:create("EMA", AbsEMA2.DATA, Smooth_Period3);
   
	
    Blau_Er = instance:addStream("Blau_Er", core.Bar, name .. ".Blau_Er", "Blau_Er", instance.parameters.clr, AbsEMA3.DATA:first());
    Signal_EMA = core.indicators:create("EMA", Blau_Er, Signal_Period);
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Sclr, Signal_EMA.DATA:first());
    Signal:setWidth(instance.parameters.widthLinReg);
    Signal:setStyle(instance.parameters.styleLinReg);
	
	Signal:setPrecision(math.max(2, instance.source:getPrecision()));
	Signal_EMA:setPrecision(math.max(2, instance.source:getPrecision()));
	Blau_Er:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if period>first+Period then
    Mtm[period]=source[period]-source[period-Period+1];
    AbsMtm[period]=math.abs(Mtm[period]);
    EMA1:update(mode);
    EMA2:update(mode);
    EMA3:update(mode);
    AbsEMA1:update(mode);
    AbsEMA2:update(mode);
    AbsEMA3:update(mode);
    if AbsEMA3.DATA[period]>0 then
     Blau_Er[period]=100*EMA3.DATA[period]/AbsEMA3.DATA[period];
    else
     Blau_Er[period]=0;
    end
    Signal_EMA:update(mode);
    Signal[period]=Signal_EMA.DATA[period];
   end 
end

