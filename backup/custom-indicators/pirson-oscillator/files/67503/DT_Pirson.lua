-- More information about this indicator can be found at:
-- http://fxcodebase.com/
-- Id: 9316

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
 
function Init()
    indicator:name("Pirson oscillator");
    indicator:description("Pirson oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local MVA;
local StdDev;
local Pirson=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("STDDEV") ~= nil, "Please, download and install STDDEV.LUA indicator");  
    MVA = core.indicators:create("MVA", source.close, Period);
    StdDev = core.indicators:create("STDDEV", source.close, Period);
	first = MVA.DATA:first();
    Pirson = instance:addStream("Pirson", core.Line, name .. ".Pirson", "Pirson", instance.parameters.clr, first);
    Pirson:setWidth(instance.parameters.widthLinReg);
    Pirson:setStyle(instance.parameters.styleLinReg);
	
	Pirson:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
  
    MVA:update(mode);
    StdDev:update(mode);
	
   if period<first  then
   return;
   end
   
    local i;
    local Sum=0;
    for i=0, Period-1, 1 do
     Sum=Sum+(source.close[period-i]-MVA.DATA[period])*(source.close[period-i-1]-MVA.DATA[period-1]);
    end
    local Res=Period*StdDev.DATA[period]*StdDev.DATA[period-1];
    if (Res==0) then
     Pirson[period]=1;
    else
     Pirson[period]=Sum/Res;
    end
   
end

