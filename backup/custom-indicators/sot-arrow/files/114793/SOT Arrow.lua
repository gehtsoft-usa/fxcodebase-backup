-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=65073

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
    indicator:name("SOT Arrow");
    indicator:description("SOT Arrow");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
 
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP", "Up color", "Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrDN", "Down color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Size", "Size", "Size", 15  );
end

local first;
local source = nil;
 
local Up,Down,Size;

function Prepare(nameOnly) 
    source = instance.source; 
    

	Size=instance.parameters.Size;
    first = source:first();
    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    Up  = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
    Down  = instance:createTextOutput ("Down", "Down", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    Up:setNoData(period);
	Down:setNoData(period);
	

	
	p1   = (source.close[period-1] - source.open[period-1]);
   SOT1 = (p1 / ( source.volume[period-1]+1))*10000;
   
   
    p2   = (source.close[period-2] - source.open[period-2]);
    SOT2 = (p2 / (source.volume[period-2]+1))*10000;
   
   
    p3 = (source.close[period-3] - source.open[period-3]);
    SOT3 = (p3 / (source.volume[period-3]+1))*10000;
   
   
    p4 = (source.close[period-4] - source.open[period-4]);
    SOT4= (p4 / (source.volume[period-4]+1))*10000 ;
   
   
    p5 = (source.close[period-5] - source.open[period-5]);
    SOT5 = (p5 / (source.volume[period-5]+1))*10000 ;
   
   
    p6 = (source.close[period-6] - source.open[period-6]);
    SOT6 = (p6 / (source.volume[period-6]+1)) *10000;
   
      
    SOTAV6 = ((SOT1+SOT2+SOT3+SOT4+SOT5+SOT6)/6);
    
    SOTAV2 = (SOTAV6*2);
	
	
	  if (SOT1>SOTAV2) and (source.close[period-2]<source.open[period-2]) and  (source.close[period-1]<source.open[period-2]) then
      Up:set(period, source.high[period], "\218");
	  end
	   
      
      if  (SOT1>SOTAV2) and (source.close[period-2] > source.open[period-2]) and  (source.close[period-1]>source.open[period-1]) then 
		 Down:set(period, source.low[period], "\217");
	  end	 
	  
	  
	 
	
	
end

