-- Id: 14986
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=62823


--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Average Percentage True Range");
    indicator:description("Average Percentage True Range");
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
local APTR=nil;
local PTR;
local MA;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+2;
    PTR = instance:addInternalStream(0, 0);
    MA = core.indicators:create("MVA", PTR, Period);
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
	if   (nameOnly) then
        return;
    end
	
	
    APTR = instance:addStream("APTR", core.Line, name .. ".APTR", "APTR", instance.parameters.clr,  MA.DATA:first());
    APTR:setWidth(instance.parameters.widthLinReg);
    APTR:setStyle(instance.parameters.styleLinReg);
	APTR:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if period<first then
   return;
   end
   
    local S1, S2, S3;
    S1=2*(source.high[period]-source.low[period])/(source.high[period]+source.low[period]);
    S2=2*(source.high[period]-source.close[period-1])/(source.high[period]+source.close[period-1]);
    S3=2*(source.low[period]-source.close[period-1])/(3*source.low[period]-source.close[period-1]);

    PTR[period]=100*math.max(S1, S2, S3);

    MA:update(mode);
    if period <  MA.DATA:first() then
	return;
	end
	
    APTR[period]=MA.DATA[period];
   
end

