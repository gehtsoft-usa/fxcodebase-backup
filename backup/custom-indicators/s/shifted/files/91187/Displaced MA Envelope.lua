-- Id: 11971
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60009

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Displaced SMA Envelope");
    indicator:description("The indicator will shift MA line by the specified number of periods and/or points.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");
   indicator.parameters:addString("Method", "Method", "Method" , "Pips");
    indicator.parameters:addStringAlternative("Method", "Pips", "Pips" , "Pips");
    indicator.parameters:addStringAlternative("Method", "Value", "Value" , "Value");
	indicator.parameters:addStringAlternative("Method", "Percentage", "Percentage" , "Percentage");

	indicator.parameters:addGroup("First MA Calculation");
    indicator.parameters:addInteger("SX1", "First MA Shift in periods", "Positive is future, negative is past", -5);
    indicator.parameters:addDouble("SY1", "First MA Shift in points", "", 0);
	
	
		
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	indicator.parameters:addInteger("Period1", "Period", "Period" , 14);
	
	
	indicator.parameters:addGroup("Second MA Calculation");
	
	indicator.parameters:addInteger("SX2", "Second MA Shift in periods", "Positive is future, negative is past", 5);
    indicator.parameters:addDouble("SY2", "Second MA Shift in points", "", 0);
	
	
		indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	indicator.parameters:addInteger("Period2", "Period", "Period" , 14);
	
	
	
	indicator.parameters:addGroup("Style");
	 indicator.parameters:addColor("color1", "Color of the First MA", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1","Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color2", "Color of the First MA", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2","Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
   
end
local Method1,Method2;
local source;
local MA1,MA2,ma1,ma2;
local first1, first2;
local SX1, SY1;
local SX2, SY2;
local Method;
function Prepare(nameOnly)   
    
	Method=instance.parameters.Method;
	Method1=instance.parameters.Method1;
	Method2=instance.parameters.Method2;
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	SX1 = instance.parameters.SX1;
	SX2 = instance.parameters.SX2;
	
		if Method=="Pips" then
    SY1 = instance.parameters.SY1 * instance.source:pipSize();
	SY2 = instance.parameters.SY2 * instance.source:pipSize();
    else 
	SY1 = instance.parameters.SY1;
	SY2 = instance.parameters.SY2;
	end
	
	
	
		local name;
    name = profile:id() .. "(" .. instance.source:name()..  ", ".. Method   .. " Method "
	.."  First MA : "  ..  SX1 .. " bars " ..  SY1 .. " points ".. Method1 .. " Method ".. Period1.. " Period "
	.."  Second MA : "  ..  SX2 .. " bars " ..  SY2 .. " points ".. Method2 .. " Method ".. Period2.. " Period ";
    instance:name(name);
	 
	 if   (nameOnly) then
        return;
    end
	
	source = instance.source;
	
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
	ma1 = core.indicators:create(Method1, source, Period1);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
	ma2 = core.indicators:create(Method2, source, Period2);
	


   
    first1 = ma1.DATA:first() + SX1;
    if first1 < 0 then
        first1 = 0;
    end
	
	 first2 = ma2.DATA:first() + SX2;
    if first2 < 0 then
        first2 = 0;
    end
	
    MA1 = instance:addStream("MA1", core.Line, name .. ".MA1", "MA1", instance.parameters.color1, first1, SX1);
	MA1:setWidth(instance.parameters.width1);
    MA1:setStyle(instance.parameters.style1);
	
	MA2 = instance:addStream("MA2", core.Line, name .. ".MA2", "MA2", instance.parameters.color2, first2, SX2);
	MA2:setWidth(instance.parameters.width2);
    MA2:setStyle(instance.parameters.style2);
end

function Update(period, mode)


    ma1:update(mode);
	ma2:update(mode);
    
    if period < source:first() then
	return;
	end
	
	
    local p1 = period + SX1;
    if p1 >= 0 then
	   
	      if Method~="Percentage" then
          MA1[p1] =ma1.DATA[period] + SY1;
		  else
		  MA1[p1] =ma1.DATA[period] + (ma1.DATA[period]/100)*SY1;
		  end
    end
	
	
	local p2 = period + SX2;
    if p2 >= 0 then
	   
	      if Method~="Percentage" then
          MA2[p2] =ma2.DATA[period] + SY2;
		  else
		  MA2[p2] =ma2.DATA[period] + (ma2.DATA[period]/100)*SY2;
		  end
    end
end

