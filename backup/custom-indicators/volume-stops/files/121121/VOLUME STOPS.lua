-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66640
-- Id: 

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
    indicator:name("VOLUME STOPS");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

 

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Color", "Up Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Color", "Down Color", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Long", "Long Color", "Long Color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("Short", "Short Color", "Short Color", core.rgb(0, 0, 0));
end

local first;
local source = nil;
 
 
local redbar;

local open=nil;
local close=nil;
local high=nil;
local low=nil;

local Up, Down, Long, Short;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Average=instance.parameters.Average;
    Method=instance.parameters.Method;
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Long=instance.parameters.Long;
	Short=instance.parameters.Short;
	
    first = source:first();
    local name = profile:id() .. "(" .. source:name()   .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
  
    redbar = instance:addInternalStream(0, 0); 
	greenbar= instance:addInternalStream(0, 0); 
	
   
	
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first) 
    instance:createCandleGroup("ZONE", "ZONE", open, high, low, close );
    
end

function Update(period, mode)
   
   
    if source.open[period]>= source.close[period] then
	redbar[period]=1;
	else
	redbar[period]=0;
	end
	
	if source.open[period]<= source.close[period] then
	greenbar[period]=1;
	else
	greenbar[period]=0;
	end
	
	if source.close[period]> source.open[period] then
	open:setColor(period, Up);
	else
	open:setColor(period, Down);
	end
	
   
    high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	
   
   if period<source:first()+2  then
   return;
   end 
	 
	  
	  local long1=false;
      local long2=false;
	  local short1=false;
      local short2=false;
	  
	  if source.volume[period-2]<source.volume[period-1] and source.volume[period-1]<source.volume[period] and redbar[period-2]==1 and redbar[period-1]==1 and greenbar[period]==1 then
	  long1=true;
	  end 
	  
	  if source.volume[period-2]<source.volume[period-1] and source.volume[period-1]<source.volume[period] and greenbar[period-2]==1 and greenbar[period-1]==1 and redbar[period]==1 then
	  short1=true;
	  end 
	  
	  if source.volume[period-2]>source.volume[period-1] and source.volume[period-1]>source.volume[period] and redbar[period-2]==1 and redbar[period-1]==1 and greenbar[period]==1 then
	  long2=true;
	  end 
	  
	  if source.volume[period-2]>source.volume[period-2] and source.volume[period-1]>source.volume[period] and greenbar[period-2]==1 and greenbar[period-1]==1 and redbar[period]==1 then
	  short2=true;
	  end 
  
 
		if long1 or long2 then
		open:setColor(period, Long);
		elseif short1 or short2 then
		open:setColor(period, Short);
		end 
	 
end 