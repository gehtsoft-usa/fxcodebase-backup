-- Id: 25467
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68635

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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


-- Indicator profile initialization routine

function Init()
    indicator:name("Multi Z-Score analysis");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 20, 1, 2000);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");    
	
    indicator.parameters:addInteger("Definition", "Definition", "", 20, 1, 2000);
	
 
 
	
	indicator.parameters:addGroup("Global Z-Score Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("Z-Score Style"); 	
    indicator.parameters:addColor("colorUp", "Up Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("colorDown", "Down Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addInteger("width2", "Down Width", "", 1, 1, 5);
	
	
	indicator.parameters:addGroup("Average Line Style"); 	
    indicator.parameters:addColor("color3", "Line Color", "", core.rgb(255, 128, 0));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period,Definition; 
local first;
local source = nil;
local globalz; 
local Line, Dot;  
local avg={}; 
local zscore={}; 
local Method; 
local Average;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
    Definition= instance.parameters.Definition;
	Method= instance.parameters.Method;
	
	local Parameters= Period..", ".. Method..", "..Definition;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	first=source:first();
	for i = 1 ,  Definition, 1 do
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	avg[i]= core.indicators:create(Method, source, Period*i);
	first=math.max(avg[i].DATA:first(),first);
	
	zscore[i] = instance:addStream("zscore"..i , core.Dot, i.. ". zscore",i.. ". zscore",instance.parameters.colorUp, first +Period );
    zscore[i]:setPrecision(math.max(2, instance.source:getPrecision()));
	zscore[i]:setWidth(instance.parameters.width2);
	 
	end
	
    
	
	globalz= instance:addInternalStream(0, 0);
  
   
 
	Line = instance:addStream("Line" , core.Line, " Line"," Line",instance.parameters.color1, first +Period );
	Line:setWidth(instance.parameters.width1);
    Line:setStyle(instance.parameters.style1);
    Line:setPrecision(math.max(2, source:getPrecision()));
	
	
	Average = instance:addStream("Average" , core.Line, " Average"," Average",instance.parameters.color3, first +Period );
	Average:setWidth(instance.parameters.width3);
    Average:setStyle(instance.parameters.style3);
    Average:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

    
 
    if period < first then
	return;
	end
	
	
	globalz[period]=0;
	
	local st;
	
	local Sum=0;
	for i = 1 ,  Definition, 1 do
	
	if i== 1 then
	globalz[period]=0;
	zscore[i][period]=0;
	end
	
	avg[i]:update(mode);
	st=mathex.stdev(source, period-Period*i+1, period);	
	zscore[i][period] = (source[period]-avg[i].DATA[period])/st; 
	
	if zscore[i][period] >0 then
	zscore[i]:setColor(period, instance.parameters.colorUp);
	else
	zscore[i]:setColor(period, instance.parameters.colorDown);
	end
	
	Sum=Sum+zscore[i][period];
	
	 globalz[period]=(globalz[period]+zscore[i][period]*i)/Definition;
	end
	
	  if period < first +Period then
	return;
	end
		
     Line[period]= mathex.avg(globalz, period-Period+1, period);
	 
	 
	 Average[period]=Sum/Definition;
				  
end

 
