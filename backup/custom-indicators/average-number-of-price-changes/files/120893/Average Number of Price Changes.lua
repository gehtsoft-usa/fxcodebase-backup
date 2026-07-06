-- Id: 22206
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66614

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


-- Indicator profile initialization routine

function Init()
    indicator:name("Average Number of Price Changes");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addInteger("Summation_Period", "Summation Period (in minutes)", "", 1, 2, 2000);
	
	
	indicator.parameters:addGroup("MA Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 14, 2, 2000);
 
	
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
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method, Price, Period;
local Summation_Period,Data;
local first;
local source = nil;
local Source, loading;

local Oscillator;  
local MA;

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Data = instance:addInternalStream(0, 0);

    Period= instance.parameters.Period;
    Method= instance.parameters.Method;
	Summation_Period= instance.parameters.Summation_Period;
    source = instance.source;
    
  
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    MA = core.indicators:create(Method, Data, Period);
    
    first=MA.DATA:first();
	
	 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
	
	Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
	
	
	Source = core.host:execute("getSyncHistory", source:instrument(), "m1", source:isBid(), 300, 100, 101);
	loading=true;
    
	
	
end

-- Indicator calculation routine
function Update(period, mode)
 
    local begin =  source:date(period) - (1/1440)*Summation_Period;
    local p1 = core.findDate(Source, begin, false);
	local p2 = core.findDate(Source, source:date(period), false);
 
     if p1 < 0 
	 or p2 < 0
	 or not Source:hasData(p1)
	 or not Source:hasData(p2)
	 then
     return;
	 end
	 
 
    Data[period]= 0;
	
	for i= p1, p2, 1 do
		if  Source:hasData(i) then
		Data[period]=Data[period]+Source.volume[i];
		end
	end
	
	
    MA:update(mode);
	
	
    if period < first then
	return;
	end
	
		
     Oscillator[period]=mathex.avg(Data, period-Period+1, period);
				  
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end


