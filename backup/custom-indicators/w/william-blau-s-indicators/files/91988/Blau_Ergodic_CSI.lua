-- Id: 10880
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
    indicator:name("William Blau Ergodic Candlestick Index");
    indicator:description("William Blau Ergodic Candlestick Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 1);
    indicator.parameters:addInteger("Smooth_Period1", "Smooth period 1", "", 20);
    indicator.parameters:addInteger("Smooth_Period2", "Smooth period 2", "", 5);
    indicator.parameters:addInteger("Smooth_Period3", "Smooth period 3", "", 3);
    indicator.parameters:addString("Price1", "Price 1", "", "close");
    indicator.parameters:addStringAlternative("Price1", "close", "", "close");
    indicator.parameters:addStringAlternative("Price1", "open", "", "open");
    indicator.parameters:addStringAlternative("Price1", "high", "", "high");
    indicator.parameters:addStringAlternative("Price1", "low", "", "low");
    indicator.parameters:addStringAlternative("Price1", "median", "", "median");
    indicator.parameters:addStringAlternative("Price1", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "weighted", "", "weighted");
    indicator.parameters:addString("Price2", "Price 2", "", "open");
    indicator.parameters:addStringAlternative("Price2", "close", "", "close");
    indicator.parameters:addStringAlternative("Price2", "open", "", "open");
    indicator.parameters:addStringAlternative("Price2", "high", "", "high");
    indicator.parameters:addStringAlternative("Price2", "low", "", "low");
    indicator.parameters:addStringAlternative("Price2", "median", "", "median");
    indicator.parameters:addStringAlternative("Price2", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "weighted", "", "weighted");
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
local Price1;
local Price2;
local CM, HH;
local CM_EMA1, CM_EMA2, CM_EMA3;
local HH_EMA1, HH_EMA2, HH_EMA3;
local Blau_CSI=nil;
local Signal=nil;

function Prepare(nameOnly)  
    source = instance.source;
    Period=instance.parameters.Period;
    Smooth_Period1=instance.parameters.Smooth_Period1;
    Smooth_Period2=instance.parameters.Smooth_Period2;
    Smooth_Period3=instance.parameters.Smooth_Period3;
    Signal_Period=instance.parameters.Signal_Period;
    Price1=instance.parameters.Price1;
    Price2=instance.parameters.Price2;
    first = source:first()+2;
	
	  local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Smooth_Period1 .. ", " .. instance.parameters.Smooth_Period2 .. ", " .. instance.parameters.Smooth_Period3 .. ", " .. instance.parameters.Price1 .. ", " .. instance.parameters.Price2 .. ", " .. instance.parameters.Signal_Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    CM = instance:addInternalStream(first, 0);
    HH = instance:addInternalStream(first, 0);
    CM_EMA1 = core.indicators:create("EMA", CM, Smooth_Period1);
    CM_EMA2 = core.indicators:create("EMA", CM_EMA1.DATA, Smooth_Period2);
    CM_EMA3 = core.indicators:create("EMA", CM_EMA2.DATA, Smooth_Period3);
    HH_EMA1 = core.indicators:create("EMA", HH, Smooth_Period1);
    HH_EMA2 = core.indicators:create("EMA", HH_EMA1.DATA, Smooth_Period2);
    HH_EMA3 = core.indicators:create("EMA", HH_EMA2.DATA, Smooth_Period3);
  
	
	
    Blau_CSI = instance:addStream("Blau_CSI", core.Bar, name .. ".Blau_CSI", "Blau_CSI", instance.parameters.clr, HH_EMA3.DATA:first());
    Signal_EMA = core.indicators:create("EMA", Blau_CSI, Signal_Period);
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Sclr, Signal_EMA.DATA:first());
    Signal:setWidth(instance.parameters.widthLinReg);
    Signal:setStyle(instance.parameters.styleLinReg);
    Blau_CSI:addLevel(25);
    Blau_CSI:addLevel(-25);
	
	
	Signal:setPrecision(math.max(2, instance.source:getPrecision()));
	Signal_EMA:setPrecision(math.max(2, instance.source:getPrecision()));
	Blau_CSI:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if period>first then
    local Min, Max=mathex.minmax(source, period-Period+1, period);
    CM[period]=source[Price1][period]-source[Price2][period-Period+1];
    HH[period]=Max-Min;
    CM_EMA1:update(mode);
    CM_EMA2:update(mode);
    CM_EMA3:update(mode);
    HH_EMA1:update(mode);
    HH_EMA2:update(mode);
    HH_EMA3:update(mode);
    if HH_EMA3.DATA[period]>0 then
     Blau_CSI[period]=100*CM_EMA3.DATA[period]/HH_EMA3.DATA[period];
    else
     Blau_CSI[period]=0;
    end 
    Signal_EMA:update(mode);
    Signal[period]=Signal_EMA.DATA[period];
   end 
end

