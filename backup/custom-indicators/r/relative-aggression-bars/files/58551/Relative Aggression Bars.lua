-- Id: 8953

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34335

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

-- Indicator profile initialization routine
-- If the current bars of AC and AO are green, it shows that the zone is green.
-- If the current bars of �� and �� red, it shows that the zone is red.
-- If the bars of AC and AO are differently directed then the bar is colored grey (grey zone).
function Init()
    indicator:name("Relative Aggression Bars");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Selector");
	
	indicator.parameters:addString("Method", "Select Filter Method", "", "Percentage");
	indicator.parameters:addStringAlternative("Method", "Percentage", "", "Percentage");
    indicator.parameters:addStringAlternative("Method", "ATR", "", "ATR");
    indicator.parameters:addStringAlternative("Method", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Method", "Absolute ATR", "", "AATR");
    indicator.parameters:addStringAlternative("Method", "Absolute Volume", "", "AVolume");
		
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14); 
 

	indicator.parameters:addDouble("Level1", "Extrem Level", "Top x Percentage", 5);
    indicator.parameters:addDouble("Level2", "Strong Level", "Top x Percentage", 10);
	indicator.parameters:addDouble("Level3", "Moderate Level", "Top x Percentage", 20);
	
	indicator.parameters:addGroup("Style");
	
	indicator.parameters:addColor("Up", "Up Bar","Up Bar", core.rgb(128,128,128));
	indicator.parameters:addColor("Down", "Down Bar","Down Bar", core.rgb(200,200,200));
	
	indicator.parameters:addColor("BA3", "Moderate Buying Aggression","Moderate Buying Aggression", core.rgb(192,255,203));
	indicator.parameters:addColor("BA2", "Strong Buying Aggression","Strong Buying Aggression", core.rgb(0,255,0));
	indicator.parameters:addColor("BA1", "Extrem Buying Aggression","Extrem  Buying Aggression", core.rgb(0, 255, 255));
	
	indicator.parameters:addColor("SA3", "Moderate Selling Aggression","Moderate Selling Aggression", core.rgb(255, 192, 203));
	indicator.parameters:addColor("SA2", "Strong Selling Aggression","Strong Selling Aggression", core.rgb(255,0,0));
	indicator.parameters:addColor("SA1", "Extrem Selling Aggression","Extrem Selling Aggression", core.rgb(255, 0, 255));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local ATRMethod;
local first;
local source = nil;
local Method;
-- Streams block
local Up, Down , BA1, BA2, BA3, SA1, SA2, SA3;
local Period, atr;
local Level1, Level2, Level3;
local open=nil;
local close=nil;
local high=nil;
local low=nil;
 
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period; 
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Method = instance.parameters.Method; 
	BA1 = instance.parameters.BA1;
	BA2 = instance.parameters.BA2;
	BA3 = instance.parameters.BA3;
	SA1 = instance.parameters.SA1;
	SA2 = instance.parameters.SA2;
	SA3 = instance.parameters.SA3;
	Period = instance.parameters.Period;
	Level1 = instance.parameters.Level1;
	Level2 = instance.parameters.Level2;
	Level3 = instance.parameters.Level3;
	
	
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. Method .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	 
	 if Method== "ATR" or Method== "AATR"then
     atr = core.indicators:create("ATR", source, Period);
    first = atr.DATA:first() +Period;	
	 else
    first=source:first()+Period;
	end
   
   
	
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
	
	
end

-- Indicator calculation routine
function Update(period, mode)


   
	high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	
     
	if period < source:first()  then			
    return;
    end 
	
	if close[period]> open[period] then
	open:setColor(period, Up);
	else
	open:setColor(period, Down);
	end
	
	Calculation (period, mode); 				   
				  
    end

	
function Calculation (period, mode)

	
	if Method== "Volume" then 
	     VOLUME (period, mode)
	elseif Method== "ATR" then
	    ATR (period, mode)
	elseif Method== "AVolume" then 
	     AVOLUME (period, mode)
	elseif Method== "AATR" then
	    AATR (period, mode)		
	elseif Method== "Percentage" then 	
	     Percentage (period, mode)		 
	end
    
end

function VOLUME (period, mode)

   local max= MAX(period, source.volume);	 	 
	  
	  local value = math.abs(source.volume[period] - source.volume[period-1]);
	  Draw(value ,max,  period);

end

function Percentage(period, mode)

    local max= MAX(period, source.close);	  
	  local value =  math.abs(source.close[period] - source.open[period]);
	  Draw(value,max,  period);
end

function ATR (period, mode)

    atr:update(mode);
	
	if period < first then 
	return;
	end  
	  local max= MAX(period, atr.DATA);	 	 
	   local value =  math.abs(atr.DATA[period] - atr.DATA[period-1]);
	  Draw(value,max,  period);
	   
end





function AVOLUME (period, mode)

   if period < first then 
	return;
	end  

   local max= mathex.max(source.volume, period-Period+1, period);	 	 
	  
	  local value = source.volume[period];
	  Draw(value ,max,  period);

end

function AATR (period, mode)


    atr:update(mode);
	
	if period < first then 
	return;
	end  
	  local max=   mathex.max( atr.DATA, period-Period+1, period); 
	   local value = atr.DATA[period];
	  Draw(value,max,  period);
	   
end

function  MAX(period, DATA)

local i;
local M=0;

	for i = period, period-Period+1, -1 do
		if    M <  math.abs(DATA[i] -   DATA[i-1]) then
		M =math.abs(DATA[i] -   DATA[i-1]);
		end
	end
	
	return M;
end

function Draw (value,max,  period) 


				   
 
       if   ToPercentage(value,max) >= (100 -Level1)	 then
			  if  source.close[period]	 >= source.open[period] then
			  open:setColor(period, BA1);
			 else
			 open:setColor(period, SA1);  	  
			 end
			 
	    elseif  ToPercentage(value,max) >= (100 -Level2)	 then
			  if  source.close[period]	 >=  source.open[period] then
			  open:setColor(period, BA2);
			 else
			 open:setColor(period, SA2);  	  
			 end
			 
	     elseif   ToPercentage(value,max) >= (100 -Level3)	 then
			  if  source.close[period]	 >=  source.open[period] then
			  open:setColor(period, BA3);
			 else
			 open:setColor(period, SA3);  	  
			 end
			 
	   end 
	   
	   	   		        
end

function ToPercentage (value, max)

 local Rez = math.abs(value/(max/100));
 return  Rez;

end