-- Id: 17280
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=894

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
    indicator:name("Chaikin's Volatility (CHV)");
    indicator:description("Chaikin's Volatility (CHV)");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SmoothPeriod", "SmoothPeriod", "Smooth period", 10);
    indicator.parameters:addInteger("ROCPeriod", "ROCPeriod", "ROC period", 10);
  --  indicator.parameters:addInteger("TypeSmooth", "TypeSmooth", "0 - MVA, 1 - EMA", 0);
  
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
    indicator.parameters:addColor("clrCHV", "Color of CHV", "Color of CHV", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local MA;
local HL;
local ROCPeriod;

function Prepare(nameOnly)
    source = instance.source;
    ROCPeriod=instance.parameters.ROCPeriod;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.SmoothPeriod .. ", " .. instance.parameters.ROCPeriod .. ", " .. instance.parameters.Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    HL = instance:addInternalStream(0, 0);
    
     MA = core.indicators:create(instance.parameters.Method, HL, instance.parameters.SmoothPeriod);
    
    
    first = MA.DATA:first()+2;
    CHV = instance:addStream("CHV", core.Line, name .. ".CHV", "CHV", instance.parameters.clrCHV, MA.DATA:first()+ROCPeriod);
	CHV:setWidth(instance.parameters.width);
    CHV:setStyle(instance.parameters.style);
	
	CHV:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
    HL[period]=source.high[period]-source.low[period];
    MA:update(mode);
    if (period>MA.DATA:first()+ROCPeriod) then
     local CurrentValue=MA.DATA[period];
     local ShiftValue=MA.DATA[period-ROCPeriod];
     CHV[period]=(CurrentValue-ShiftValue)*100/ShiftValue;
    end 
end

