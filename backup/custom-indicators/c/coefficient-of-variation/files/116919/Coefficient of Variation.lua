-- Id: 20312
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65614

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Coefficient of Variation");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	 indicator.parameters:addGroup("Calculation");
 
	 indicator.parameters:addInteger("Period", "Period","",21);
	 indicator.parameters:addInteger("Signal", "Signal","",5);
	 
	 indicator.parameters:addGroup("Line Style");
    indicator.parameters:addColor("Up", "Up Color","", core.rgb(0,255,0));
	indicator.parameters:addColor("Down", "Down Color","", core.rgb(255,0,0));
	indicator.parameters:addColor("Neutral", "Neutral Color","", core.rgb(0,0,0));
	indicator.parameters:addColor("SignalColor", "Signal Color","", core.rgb(0,0,255));
	
 
end

local source;
local  Period,Signal;
local first;
local cv;
local EMA,signal;
local SignalColor, Up,Down,Neutral;
 
function Prepare(nameOnly)
    source = instance.source;
    local name = profile:id();
	instance:name(name);
	if nameOnly then
		return;
	end
	 
	Period= instance.parameters.Period;
	Signal= instance.parameters.Signal;
	
	SignalColor= instance.parameters.SignalColor;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Neutral= instance.parameters.Neutral;
 
	first=source:first()+ Period;
	
     
    cv = instance:addStream("CV", core.Bar, name .. ".CV", "CV", Up, first);
	EMA= core.indicators:create("EMA", cv, Signal);  
   
   signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", SignalColor, first +Signal);
   cv:setPrecision(math.max(2, instance.source:getPrecision()));
   signal:setPrecision(math.max(2, instance.source:getPrecision()));
   
    
end
    
function Update(period, mode)
  -- average:update(core.UpdateLast);

if period < first then
return;
end
  
 
local sma  = mathex.avg(source.typical, period-Period+1, period)
local dev  = mathex.stdev(source.typical, period-Period+1, period)
 
cv[period] = dev/sma;


  if period < first+ Period/2  then
return;
end
  
local cvl, cvh=mathex.minmax(cv, period-Period/2+1, period);


 
if (cv[period]==cvh) then
cv:setColor(period, Up)
elseif (cv[period]==cvl) then
cv:setColor(period, Down)
else
cv:setColor(period, Neutral)
end

if  period < first+Signal then
return;
end

EMA:update(mode);
 
signal[period] = EMA.DATA[period];
   
end
