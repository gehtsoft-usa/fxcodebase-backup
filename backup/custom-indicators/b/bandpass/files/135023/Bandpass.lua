-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=70030

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                           mario.jemic@gmail.com  |
--|                          https://AppliedMachineLearning.systems  |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                                  Patreon: https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Bandpass");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addInteger("Period", "Period", "", 20);
    indicator.parameters:addDouble("Bandwidth", "Bandwidth", "", 0.1);
    indicator.parameters:addInteger("Length", "Length", "", 10);

    indicator.parameters:addColor("bp_color", "BP Color", "Color", core.colors().Green);
    indicator.parameters:addInteger("bp_width", "BP Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("bp_style", "BP Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("bp_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("bpt_color", "BP Truncated Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("bpt_width", "BP Truncated Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("bpt_style", "BP Truncated Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("bpt_style", core.FLAG_LINE_STYLE);
end

local source, L1, G1, S1, bp, bpt, Length;
local Trunc={};
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
	
	Trunc={};
    Length = instance.parameters.Length;
    Period = instance.parameters.Period;
    L1 = math.cos(2 * math.pi / Period);
    G1 = math.cos(instance.parameters.Bandwidth * 2 * math.pi / Period);
    S1 = 1 / G1 - math.sqrt(1 / (G1 * G1) - 1);
	
 

    bp = instance:addStream("BP", core.Line, "BP", "BP", instance.parameters.bp_color, source:first() , 0);
    bp:setWidth(instance.parameters.bp_width);
    bp:setStyle(instance.parameters.bp_style);

    bpt = instance:addStream("BPT", core.Line, "BPT", "BPT", instance.parameters.bpt_color, source:first() + Length + 1, 0);
    bpt:setWidth(instance.parameters.bpt_width);
    bpt:setStyle(instance.parameters.bpt_style);
end

function Update(period, mode)


    if period < source:first()+2 then
	    bp[period]=0;
        return;
    end


    bp[period] = 0.5 * (1 - S1) * (source[period] - source[period - 2]) + L1 * (1 + S1) * bp[period-1] - S1 * bp[period-2];
  
    if period < bpt:first() then
        return;
    end
	
	
	  for i = 1, Length+2, 1 do
	   Trunc[i ]=0;
      end
	 
    for i = Length, 1, -1 do
        t1 = Trunc[i + 1];
        t2 =  Trunc[ i + 2];
        Trunc[i] = 0.5 * (1 - S1) * (source[period - i +1] - source[period - i-1 ]) + L1 * (1 + S1) * t1 - S1 * t2;
    end
	
	
    bpt[period] = Trunc[1];
end


--[[



For count = 100 DownTo 2 Begin
Trunc[count] = Trunc[count - 1];
End;


Trunc[Length + 2] = 0;
Trunc[Length + 1] = 0;

For count = Length DownTo 1 Begin
Trunc[count] = .5*(1 - S1)*(Close[count - 1] - Close[count + 1]) +L1*(1 + S1)*Trunc[count + 1] - S1*Trunc[count + 2];
End;


]]