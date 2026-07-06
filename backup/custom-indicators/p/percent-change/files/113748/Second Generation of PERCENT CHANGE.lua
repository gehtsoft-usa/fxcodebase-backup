-- Id: 18742
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6522

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
    indicator:name("Second Generation of PERCENT CHANGE");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	   indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addString("Mode", "The Indicator Mode", "", "N");
    indicator.parameters:addStringAlternative("Mode", "Net Change", "", "N");
    indicator.parameters:addStringAlternative("Mode", "Percent Change", "", "P");
	indicator.parameters:addInteger("PERIOD", "Period", "", 14);
	
	 indicator.parameters:addGroup("MA Calculation");
	 indicator.parameters:addInteger("Period", "MA Period", "Period" , 14);
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
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("Up", "Color of the Up oscillator line", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of the Down oscillator line", "", core.rgb(255, 0, 0));
	
	 indicator.parameters:addGroup("MA Line Style");
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("MA1", "Color of the MA of Up oscillator line", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("MA2", "Color of the MA of Down oscillator line", "", core.rgb(0, 0, 255));
end
 

local source;
local Mode;
local OUT;
local PERIOD;
local Up,Down;
local MA1,ma1;
local MA2,mA2;
local Period,Method;
function Prepare(nameOnly)  
   PERIOD = instance.parameters.PERIOD;
   Period= instance.parameters.Period;
   Method= instance.parameters.Method;
    Mode = instance.parameters.Mode;
	 source = instance.source;
	 
	   
    first = source:first()+PERIOD;
	

    local name;
    name = profile:id() .. "(" .. source:name() .. "," .. Mode.. "," .. PERIOD .. "," .. Period.. "," .. Method.. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	OUT= instance:addInternalStream(0, 0);
    Up = instance:addStream("Up", core.Line, name .. ".Up", "Up", instance.parameters.Up, first);
	Up:setWidth(instance.parameters.width1);
    Up:setStyle(instance.parameters.style1);
	Up:setPrecision (math.max(2, source:getPrecision ()));
	
	Down = instance:addStream("Down", core.Line, name .. ".Down", "Down", instance.parameters.Down, first);
	Down:setWidth(instance.parameters.width1);
    Down:setStyle(instance.parameters.style1);
	Down:setPrecision (math.max(2, source:getPrecision ()));
	
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	ma1 = core.indicators:create(Method, Up, Period);
	ma2 = core.indicators:create(Method, Down, Period);
	
	MA1 = instance:addStream("MA1", core.Line, name .. ".MA1", "MA1", instance.parameters.MA1,  ma1.DATA:first() );
	MA1:setWidth(instance.parameters.width2);
    MA1:setStyle(instance.parameters.style2);
	MA1:setPrecision (math.max(2, source:getPrecision ()));
	
	MA2 = instance:addStream("MA2", core.Line, name .. ".MA2", "MA2", instance.parameters.MA2,  ma1.DATA:first() );
	MA2:setWidth(instance.parameters.width2);
    MA2:setStyle(instance.parameters.style2);
	MA2:setPrecision (math.max(2, source:getPrecision ()));
end



function Update(period,mode)
  
    if period < first then
	return;
	end

    if Mode == "P" then
        OUT[period] = (source[period] - source[period-PERIOD]) / (source[period-PERIOD]/ 100);
    else
        OUT[period] = (source[period] - source[period-PERIOD]) / source:pipSize();
    end
	
	local Top,Bottom=Last(period);
	if Top== 0 or Bottom== 0 then
	return;
	end
	
	for p= Top, period,1 do
	Up[period]=OUT[period]/OUT[Top];
	end
	
	for p= Bottom, period,1 do
	Down[period]=OUT[period]/OUT[Bottom];
	end
	
	
	ma1:update(mode);
	ma2:update(mode);
	
	if period < ma1.DATA:first() then
	return;
	end
	
	MA1[period]=ma1.DATA[period];
	MA2[period]=ma2.DATA[period];
	
	
end
 

function Last (x)
local Top=0;
local Bottom=0;

for period =x, first, -1 do

if Top==0 and OUT[period] > 0 and OUT[period-1]<=0 then
Top=period;
end

if Bottom==0 and OUT[period]< 0 and OUT[period-1]>=0 then
Bottom=period;
end

if Top~=0 and Bottom~= 0 then
break;
end


end




return Top,Bottom;


end