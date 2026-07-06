-- Id: 18818
-- More information about this indicator can be found at:
-- http://http://fxcodebase.com/code/viewtopic.php?f=17&t=64987


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
    indicator:name("ALMA MACD");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Sigma", "Sigma", "",  4);
    indicator.parameters:addDouble("Offset", "Offset", "",  0.85);
	indicator.parameters:addInteger("Fast", "Fast", "",  12);
	indicator.parameters:addInteger("Slow", "Slow", "",  26);
	indicator.parameters:addInteger("Signal", "Signal", "",  9);
	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("color1", "MACD Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
		indicator.parameters:addColor("color2", "Signal Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	

end

local first;
local Price = nil;
local Sigma, Offset, Fast, Slow, Signal;
local m, s, n, t;
local SignalLine,MACDLine;
function Prepare(nameOnly)
    Price = instance.source;
    Sigma=instance.parameters.Sigma;
	Offset=instance.parameters.Offset;
	Fast=instance.parameters.Fast;
	Slow=instance.parameters.Slow;
	Signal=instance.parameters.Signal;
	
     m = (Offset * (Fast - 1));
     s = Fast/Sigma;
	 n = (Offset * (Slow - 1));
     t = Slow/Sigma;	 
	 q = (Offset * (Signal - 1))
     w = Signal/Sigma
	 
	 first=Price:first()+ math.max(Fast, Slow);
 
 
    local name = profile:id() .. "(" .. Price:name() .. ", " .. instance.parameters.Sigma .. ", " .. instance.parameters.Offset .. ", " .. instance.parameters.Fast .. ", " .. instance.parameters.Slow .. ", " .. instance.parameters.Signal .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
     MACDLine= instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.color1, first);
    MACDLine:setPrecision(math.max(2, instance.source:getPrecision()));
     MACDLine:setWidth(instance.parameters.width1);
     MACDLine:setStyle(instance.parameters.style1);
	 
	 SignalLine= instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.color2, first+Signal);
    SignalLine:setPrecision(math.max(2, instance.source:getPrecision()));
     SignalLine:setWidth(instance.parameters.width2);
     SignalLine:setStyle(instance.parameters.style2);
end
 

function Update(period, mode)
 
 
 
 if period < first then
 end
 
--Fast MA

local WtdSum = 0;
local CumWt = 0;
for k = 0 , Fast - 1 , 1 do
Wtd = math.exp (-((k-m)*(k-m))/(2*s*s));
WtdSum = WtdSum + Wtd * Price[period-Fast + 1 + k];
CumWt = CumWt + Wtd;
end

FastMA = WtdSum / CumWt;
 
 
 
--Slow MA

local SWtdSum = 0;
local SCumWt = 0;
for k = 0 ,  Slow - 1, 1 do
SWtd =  math.exp(-((k-n)*(k-n))/(2*t*t));
SWtdSum = SWtdSum + SWtd * Price[period-Slow + 1 + k];
SCumWt = SCumWt + SWtd;
end
SlowMA = SWtdSum / SCumWt;


--MACD
MACDLine[period] = FastMA-SlowMA;


--Signal MA
if period < first+Signal then
return;
end


SWtdSum = 0
SCumWt = 0
for k = 0 , Signal - 1 , 1 do
SWtd = math.exp(-((k-q)*(k-q))/(2*w*w))
SWtdSum = SWtdSum + SWtd *MACDLine[period-Signal + 1 + k]
SCumWt = SCumWt + SWtd
end
SignalLine[period] = SWtdSum / SCumWt
 
 end
 
