-- Id: 3367
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3685

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
    indicator:name("Smooth stochastic indicator");
    indicator:description("Smooth stochastic indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 13);
    indicator.parameters:addInteger("Slowing", "Slowing", "", 8);
    indicator.parameters:addInteger("SignalSlowing", "SignalSlowing", "", 9);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrLine", "Line Color", "Line Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("clrSignal", "Signal Color", "Signal Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Slowing;
local SignalSlowing;
local BuffLine=nil;
local BuffSignal=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Slowing=instance.parameters.Slowing;
    SignalSlowing=instance.parameters.SignalSlowing;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Slowing .. ", " .. instance.parameters.SignalSlowing .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    BuffLine = instance:addStream("BuffLine", core.Line, name .. ".Line", "Line", instance.parameters.clrLine, first);
    BuffLine:setPrecision(math.max(2, instance.source:getPrecision()));
	BuffLine:setWidth(instance.parameters.width1);
    BuffLine:setStyle(instance.parameters.style1);
    BuffSignal = instance:addStream("BuffSignal", core.Line, name .. ".Signal", "Signal", instance.parameters.clrSignal, first+Period);
    BuffSignal:setPrecision(math.max(2, instance.source:getPrecision()));
	BuffSignal:setWidth(instance.parameters.width2);
    BuffSignal:setStyle(instance.parameters.style2);
    BuffLine:addLevel(0);    
    BuffLine:addLevel(20);    
    BuffLine:addLevel(80);    
    BuffLine:addLevel(100);    
end

function Update(period, mode)
   if (period<first ) then
   return;
   end
   
    local LowPrice, HighPrice=mathex.minmax(source,period-Period+1, period );
 
    local St;
    if HighPrice~=LowPrice then
     St=100*(source.close[period]-LowPrice)/(HighPrice-LowPrice);
    else
     St=0;
    end
    local Prev=0;
    if BuffLine[period-1]~=nil then
     Prev=BuffLine[period-1];
    end
    BuffLine[period]=2/(1+Slowing)*(St-Prev)+Prev;
	
	  if (period<first + Period) then
   return;
   end
   
	 local LowLine, HighLine=mathex.minmax(BuffLine,period-Period+1, period );
  
    local St2=0;
    if HighLine~=LowLine then
     St2=100*(BuffLine[period]-LowLine)/(HighLine-LowLine);
    end
    local Prev2=0;
    if BuffSignal[period-1]~=nil then
     Prev2=BuffSignal[period-1];
    end
    BuffSignal[period]=2/(1+SignalSlowing)*(St2-Prev2)+Prev2;
   
end

