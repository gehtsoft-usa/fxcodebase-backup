-- Id: 14987

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
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Method;
local APTR=nil;
local PTR;
local MA;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Method=instance.parameters.Method;
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    first = source:first()+2;
    PTR = instance:addInternalStream(0, 0);
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
    MA = core.indicators:create("AVERAGES", PTR, Method, Period, false);
    
    APTR = instance:addStream("APTR", core.Line, name .. ".APTR", "APTR", instance.parameters.clr, MA.DATA:first());
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
	
   if period<MA.DATA:first() then
   return;
   end

    APTR[period]=MA.DATA[period];
  
end

