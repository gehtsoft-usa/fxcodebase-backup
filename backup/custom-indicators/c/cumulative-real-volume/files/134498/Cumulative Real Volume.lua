-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69952

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
	
	indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addBoolean("Show", "Show Raw Data", "", false);
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
    indicator.parameters:addString("Method", "Method", "Method" , "Midpoint");
    indicator.parameters:addStringAlternative("Method", "Midpoint", "Midpoint" , "Midpoint");
    indicator.parameters:addStringAlternative("Method", "Cumulative", "Cumulative" , "Cumulative");
	indicator.parameters:addStringAlternative("Method", "Ratio", "Ratio" , "Ratio");
    indicator.parameters:addStringAlternative("Method", "Cumulative Ratio", "Cumulative Ratio" , "Cumulative_Ratio");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Volume Color", "Color", core.colors().Green);
	indicator.parameters:addColor("Down", "Down Volume Color", "Color", core.colors().Red);
    indicator.parameters:addColor("Delta", "Delta Volume Color", "Color", core.colors().Blue);
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end
local Show;
local Method;
local Raw;
local Period;
local Up, Down, Delta;
local source, vol ;
local first;
local last_first=0;
local FIRST=true;
local buy_stream, sell_stream;
function Prepare(nameOnly)
    source = instance.source;
 
	 Period=instance.parameters.Period;
	 Method=instance.parameters.Method;
	 Show=instance.parameters.Show;
	
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end	
	
	FIRST=true;
	
	first=source:first()+Period;
	
    if Show then
    Up = instance:addStream("Up", core.Bar, "Up", "Up", instance.parameters.Up, first, 0); 
	Down = instance:addStream("Down", core.Bar, "Down", "Down", instance.parameters.Down, first, 0); 	
	else
	Up = instance:addInternalStream(0, 0);
	Down = instance:addInternalStream(0, 0);
	end
	
	
	Delta = instance:addStream("Delta", core.Line, "Delta", "Delta", instance.parameters.Delta, first, 0);
	Delta:setWidth(instance.parameters.width);
	Delta:setStyle(instance.parameters.style);	
    
    vol = core.indicators:create("DIRECTIONAL_REAL_VOLUME", source);	

     buy_stream = vol:getStream(0);
    sell_stream = vol:getStream(1);
 

   core.host:execute("setTimer", 100, 1);
end

function Update(period, mode)

    if period < first
	then
	return;
	end
	
	 
    vol:update(mode);
	
		 if not buy_stream:hasData(period) or not  sell_stream:hasData(period) then
		 return;
		 end
		 
		  Up[period]=buy_stream[period];
		  
	      Down[period]=sell_stream[period]
		  
		  if Method == "Midpoint" then	
	      Delta[period]=Up[period]+Down[period];
		  elseif Method == "Ratio" then	
		          if Up[period] >  math.abs(Down[period]) then	 
				   Delta[period]=Up[period]/math.abs(Down[period]);
				  else
				   Delta[period]=-(Up[period]/math.abs(Down[period]));
				   end
		  elseif  Method ==  "Cumulative" or Method == "Ratio" or Method == "Cumulative_Ratio" then
		  
		          UpValue=mathex.sum(buy_stream, period-Period+1, period);
				  DownValue=mathex.sum(sell_stream, period-Period+1, period);
				  
				  if Method ==  "Cumulative" then		
				  Delta[period]=UpValue + DownValue; 
				  elseif  Method ==  "Cumulative_Ratio" then	
						  if UpValue >  math.abs(DownValue) then				  
						  Delta[period]= UpValue / math.abs(DownValue);
						  else
						  Delta[period]=-( UpValue / math.abs(DownValue));
						  end
		          end
		  end
 
    
end

function GetFirstSerial()
    for i = 0, source:size() - 1,1 do
        if source:hasData(i)  then
            return source:serial(i);
        end
    end
   
end

function GetFirstSerial()
    for i = 0, buy_stream:size() - 1 do
        if buy_stream:hasData(i) and buy_stream[i] ~= 0 then
            return buy_stream:serial(i);
        end
    end
    return nil;
end
local last_first;
function AsyncOperationFinished(cookie, success, message)
    if cookie == 100 then
        local first = GetFirstSerial();
        if last_first ~= first then
            instance:updateFrom(0);
            last_first = first;
        end
    end
end

