-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=65332

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
    indicator:name("N-Period Breakouts");
    indicator:description("N-Period Breakouts");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period", "Period", 4);
 
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP", "Up color", "Color", core.rgb(0, 255, 0));
   indicator.parameters:addColor("clrDN", "Down color", "Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Size", "Size", "Size", 15  );
end

local first;
local source = nil;
--local  Period; 
local Up,Down,Size;
local Pattern;

function Prepare(nameOnly)  
    source = instance.source;  
	Pattern = instance:addInternalStream(0, 0);
	  
    Period=instance.parameters.Period;
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
	 
	
	local UpCount=0;
	local DownCount=0;
	
	for i= 0, Period-1, 1 do 
		 if source.close[period-i] > source.open[period-i] then
		 UpCount=UpCount+1;
		 end
		  if source.close[period-i] < source.open[period-i] then
		  DownCount=DownCount+1;
		 end
	end
    if UpCount==Period then
    Pattern[period]=1;
	elseif DownCount==Period then
    Pattern[period]=-1;
    end 
 
     if Pattern[period]==1 and Pattern[period-1]~=1 then     	 
	 Up:set(period, source.high[period], "\217");
	 elseif Pattern[period]==-1 and Pattern[period-1]~=-1 then     	 
	 Down:set(period, source.low[period], "\218");
	 end
	    
end

