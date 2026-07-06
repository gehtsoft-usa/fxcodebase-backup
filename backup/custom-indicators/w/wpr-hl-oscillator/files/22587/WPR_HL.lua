-- Id: 5511
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=11068

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
    indicator:name("WPR_HL oscillator");
    indicator:description("WPR_HL oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 14);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local WPR_HL=nil;
local HL;

 function Prepare(nameOnly)  
 
 
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+Period;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	HL=instance:addInternalStream(0, 0);
	
    WPR_HL = instance:addStream("WPR_HL", core.Line, name .. ".WPR_HL", "WPR_HL", instance.parameters.clr, first);
    WPR_HL:setPrecision(math.max(2, instance.source:getPrecision()));
    WPR_HL:setWidth(instance.parameters.widthLinReg);
    WPR_HL:setStyle(instance.parameters.styleLinReg);
    WPR_HL:addLevel(-20);
    WPR_HL:addLevel(-80);
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    HL[period]=source.high[period]-source.low[period];
    local First=math.max(first,period-Period);
    local Max=mathex.max(HL,core.range(First,period));
    local Min=mathex.min(HL,core.range(First,period));
    
    WPR_HL[period]=-100*(Max-HL[period])/(Max-Min);
 
end

