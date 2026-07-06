-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69949

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Volume");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addString("Method", "Method", "Method" , "Tick");
    indicator.parameters:addStringAlternative("Method", "Real", "Real" , "Real");
    indicator.parameters:addStringAlternative("Method", "Tick", "Tick" , "Tick")

    indicator.parameters:addColor("Up", "Up Volume Color", "Color", core.colors().Green);
	indicator.parameters:addColor("Down", "Down Volume Color", "Color", core.colors().Red);
 
end
local Method;
local Up, Down;
local source, vol,Volume;
local first;
 
local FIRST=true;
local buy_stream, sell_stream;
local last_first;
function Prepare(nameOnly)
    source = instance.source;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Method= instance.parameters.Method;
	
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end	
	
	last_first=nil;
	
	
	FIRST=true;
	
	first=source:first();
	
    
    Volume = instance:addStream("Volume", core.Bar, "Volume", "Volume", Up, first, 0); 
	
    if Method == "Real" then
    vol = core.indicators:create("DIRECTIONAL_REAL_VOLUME", source);	

     buy_stream = vol:getStream(0);
    sell_stream = vol:getStream(1);
	
	
	  core.host:execute("setTimer", 100, 1);
	  
	  
	end

 
end

function Update(period, mode)

    if period < first
	then
	return;
	end
	
	
    if Method == "Real" then
    vol:update(mode);
	
		 if buy_stream:hasData(period) and sell_stream:hasData(period) then
		  Volume[period]=buy_stream[period]-sell_stream[period];
		 end 
	else	
	Volume[period]=source.volume[period];
	end
	
	
	
   if source.close[period]> source.open[period] then
   Volume:setColor(period, Up);
   else
   Volume:setColor(period, Down);
   end
   
    
end

 --[[
function GetFirstSerial()
    for i = 0, source:size() - 1,1 do
        if source:hasData(i)  then
            return source:serial(i);
        end
    end
   
end]]
 
function GetFirstSerial()
    for i = 0, buy_stream:size() - 1 do
        if buy_stream:hasData(i) and buy_stream[i] ~= 0 then
            return buy_stream:serial(i);
        end
    end
    return nil;
end
 


function AsyncOperationFinished(cookie, success, message)
    if cookie == 100 then
        local First_Serial = GetFirstSerial();
        if last_first ~= First_Serial then
            instance:updateFrom(0);
            last_first = First_Serial;
        end
    end
	 
	 return core.ASYNC_REDRAW ;
end

