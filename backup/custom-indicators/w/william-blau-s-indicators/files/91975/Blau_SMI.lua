-- Id: 10858
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
    indicator:name("William Blau Stochastic Momentum Index");
    indicator:description("William Blau Stochastic Momentum Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 5);
    indicator.parameters:addInteger("Smooth_Period1", "Smooth period 1", "", 20);
    indicator.parameters:addInteger("Smooth_Period2", "Smooth period 2", "", 5);
    indicator.parameters:addInteger("Smooth_Period3", "Smooth period 3", "", 3);
    indicator.parameters:addString("Price", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price", "close", "", "close");
    indicator.parameters:addStringAlternative("Price", "open", "", "open");
    indicator.parameters:addStringAlternative("Price", "high", "", "high");
    indicator.parameters:addStringAlternative("Price", "low", "", "low");
    indicator.parameters:addStringAlternative("Price", "median", "", "median");
    indicator.parameters:addStringAlternative("Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price", "weighted", "", "weighted");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
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
local Price;
local Stoch;
local HH;
local Half_HH;
local EMA1, EMA2, EMA3;
local Half_EMA1, Half_EMA2, Half_EMA3;
local Blau_SMI=nil;

function Prepare(nameOnly)  
    source = instance.source;
    Period=instance.parameters.Period;
    Smooth_Period1=instance.parameters.Smooth_Period1;
    Smooth_Period2=instance.parameters.Smooth_Period2;
    Smooth_Period3=instance.parameters.Smooth_Period3;
    Price=instance.parameters.Price;
    first = source:first()+2;
	
	  local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Smooth_Period1 .. ", " .. instance.parameters.Smooth_Period2 .. ", " .. instance.parameters.Smooth_Period3 .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    HH = instance:addInternalStream(first, 0);
    EMA1 = core.indicators:create("EMA", HH, Smooth_Period1);
    EMA2 = core.indicators:create("EMA", EMA1.DATA, Smooth_Period2);
    EMA3 = core.indicators:create("EMA", EMA2.DATA, Smooth_Period3);
    Half_HH = instance:addInternalStream(first, 0);
    Half_EMA1 = core.indicators:create("EMA", Half_HH, Smooth_Period1);
    Half_EMA2 = core.indicators:create("EMA", Half_EMA1.DATA, Smooth_Period2);
    Half_EMA3 = core.indicators:create("EMA", Half_EMA2.DATA, Smooth_Period3);
  
	
    Blau_SMI = instance:addStream("Blau_SMI", core.Line, name .. ".Blau_SMI", "Blau_SMI", instance.parameters.clr, Half_EMA3.DATA:first());
    Blau_SMI:setWidth(instance.parameters.widthLinReg);
    Blau_SMI:setStyle(instance.parameters.styleLinReg);
	
	
	Blau_SMI:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if period>first+Period then
    local Min, Max=mathex.minmax(source, period-Period+1, period);
    HH[period]=source[Price][period]-(Max+Min)/2;
    Half_HH[period]=(Max-Min)/2;
    EMA1:update(mode);
    EMA2:update(mode);
    EMA3:update(mode);
    Half_EMA1:update(mode);
    Half_EMA2:update(mode);
    Half_EMA3:update(mode);
    if Half_EMA3.DATA[period]>0 then
     Blau_SMI[period]=100*EMA3.DATA[period]/Half_EMA3.DATA[period];
    else
     Blau_SMI[period]=0;
    end
   end 
end

