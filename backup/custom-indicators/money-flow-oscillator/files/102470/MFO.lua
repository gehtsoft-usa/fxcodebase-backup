-- Id: 14843
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62692


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
    indicator:name("Money Flow oscillator");
    indicator:description("Money Flow oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local MFV;
local MFV_MA, Vol_MA;
local MFO=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    MFV=instance:addInternalStream(first, 0);
    MFV_MA=core.indicators:create("MVA", MFV, Period);
    Vol_MA=core.indicators:create("MVA", source.volume, Period);
    MFO = instance:addStream("MFO", core.Line, name .. ".MFO", "MFO", instance.parameters.clr, first);
    MFO:setWidth(instance.parameters.widthLinReg);
    MFO:setStyle(instance.parameters.styleLinReg);
	MFO:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if period<first then
   return;
   end
   
    local Multiplier=((source.high[period]-source.low[period-1])-(source.high[period-1]-source.low[period]))/((source.high[period]-source.low[period-1])+(source.high[period-1]-source.low[period]));
    MFV[period]=Multiplier*source.volume[period];

    MFV_MA:update(mode);
    Vol_MA:update(mode);
	
    if period<MFV_MA.DATA:first() then
    return;
    end
	
    MFO[period]=MFV_MA.DATA[period]/Vol_MA.DATA[period];
   
end

