-- Id: 21750
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66309

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
    indicator:name("Spread Monitor");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	

	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Min Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("color2", "Average Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color3", "Max Color", "", core.rgb(0, 0, 255));

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Min,Average,Max; 
local first,FIRST;
local source = nil;
local bid,ask; 
local Sum,Count,Last,LastSerial;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end


    source = instance.source;
    
 
    first=source:first();
	
	 
      if source:isBid() then
     bid = source;
     ask = core.host:execute("getAskPrice");
     else
     ask = source;
     bid = core.host:execute("getBidPrice");
    end
    Max = instance:addStream("Max" , core.Bar, "Max","Max",instance.parameters.color3, first);
    Max:setPrecision(math.max(2, instance.source:getPrecision()));
	Average = instance:addStream("Average" , core.Bar, "Average","Average",instance.parameters.color2, first);
    Average:setPrecision(math.max(2, instance.source:getPrecision()));
	Min = instance:addStream("Min" , core.Bar, "Min","Min",instance.parameters.color1, first);
    Min:setPrecision(math.max(2, instance.source:getPrecision()));
	
	
    Min:addLevel(0);
	Min:addLevel(1);
	Min:addLevel(2);
	Min:addLevel(3);
	Min:addLevel(4);
	Min:addLevel(5);
	
	
end

-- Indicator calculation routine
function Update(period)

 
 
    if period <= first then
	FIRST=source:date(source:size()-1);
	return;
	end
	
	if source:date(period)< FIRST then
	return;
	end
	
     local Spread=math.abs(ask.close[period]-bid.close[period])/source:pipSize();
	 
	 
	if Min[period]==0 then
	Min[period]=Spread;
	end
	
	
	Min[period]=math.min(Min[period],Spread);
	Max[period]=math.max(Max[period],Spread);
	
	if LastSerial~=source:serial(period)then
	Sum=Spread;
	Count=1;
	LastSerial=source:serial(period);
	Last=Spread;
	end
	
	if Last~= Spread then
	Last= Spread;
	Sum=Sum+Spread;
	Count=Count+1;
	end
	
	
	
	if Count~= 0 then
	Average[period]=Sum/Count;
	end
end

