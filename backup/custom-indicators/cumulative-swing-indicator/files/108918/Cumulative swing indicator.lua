-- Id: 16958
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64059&p=108918#p108918

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
    indicator:name("Cumulative swing indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Depth", "Depth", "The minimal amount of bars where there will not be the second maximum", 12);
    indicator.parameters:addInteger("Deviation", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5);
    indicator.parameters:addInteger("Backstep", "Backstep", "The minimal amount of bars between maximums/minimums", 3);
		
		
		
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up,Down, Neutral;
local first;
local source = nil;


local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local Signal;
 local ZigZag, Depth, Deviation, Backstep; 
function Prepare(nameOnly)

    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
   	source = instance.source;
	
	Depth= instance.parameters.Depth;
	Deviation= instance.parameters.Deviation;
	Backstep= instance.parameters.Backstep;

    local name = profile:id() .. "(" .. source:name() .. ", " .. source:barSize()	
	instance:name(name);
	if nameOnly then
		return;
	end
	
	Signal = instance:addInternalStream(0, 0);
	
	ZigZag = core.indicators:create("ZIGZAG", source , Depth, Deviation, Backstep, core.rgb(0, 255, 0), core.rgb(255, 0, 0));
	first=ZigZag.DATA:first()+1;  

    	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
	
	open:setPrecision(math.max(2, instance.source:getPrecision()));
	high:setPrecision(math.max(2, instance.source:getPrecision()));
	low:setPrecision(math.max(2, instance.source:getPrecision()));
	close:setPrecision(math.max(2, instance.source:getPrecision()));
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end

local Last=nil;
-- Indicator calculation routine
function Update(period, mode)
	
	if period < first then
	Last=nil;
	end
	
	if period == source:size()-1 
	and Last~= source:serial(period) 
	then
	ZigZag:update(core.UpdateAll );
	else
	return;
	end
	
	 if period < first then
     return;
     end	 
	
	 if Last== nil then
	 FindAll(period); 
	 CalculateAll()
	 else
	 FindLast(period);
	 Calculate(period)
	 end
	 
	 
	 local S1= FindActive(period);
	 CalculateActive( S1, period)
	
	 Last= source:serial(period); 
 
		
				

		
 end
 
 function CalculateActive ( In, End)
 
                        for i = In, End, 1 do
 
                                    if ZigZag.DATA[In] ==  source.low[In]  then
									open[i] = source.open[i]-source.low[In];
									close[i] = source.close[i]-source.low[In];
									high[i] = source.high[i]-source.low[In];
									low[i] = source.low[i]-source.low[In];
									else
									open[i] = source.open[i]-source.high[In];
									close[i] = source.close[i]-source.high[In];
									high[i] = source.high[i]-source.high[In];
									low[i] = source.low[i]-source.high[In];
									end
                   end
 
 end
 
function CalculateAll()

     local In, Out;
	 local LastOut;
    for period= first, source:size()-1, 1 do
	   
				In, Out = FindLastTwo(period);
				
				if In~= nil
				and Out ~= nil
				and LastOut~=Out 
				then
				   
				LastOut=Out;
				
				    	 for i= In , Out, 1 do
				
									if ZigZag.DATA[In] <  ZigZag.DATA[Out]  then
									open[i] = source.open[i]-source.low[In];
									close[i] = source.close[i]-source.low[In];
									high[i] = source.high[i]-source.low[In];
									low[i] = source.low[i]-source.low[In];
									else
									open[i] = source.open[i]-source.high[In];
									close[i] = source.close[i]-source.high[In];
									high[i] = source.high[i]-source.high[In];
									low[i] = source.low[i]-source.high[In];
									end
							end
				 
				end
				
				
			
				
	   
	  
	   
	end
	
end
 
 function Calculate(period)
   
    local In, Out = FindLastTwo(period);
	
	if In== nil
	or Out == nil then
	return;
	end
	
	
	for i= In, Out, 1 do
	
			if ZigZag.DATA[In] <  ZigZag.DATA[Out]  then
			open[i] = source.open[i]-source.low[In];
			close[i] = source.close[i]-source.low[In];
			high[i] = source.high[i]-source.low[In];
			low[i] = source.low[i]-source.low[In];
			else
			open[i] = source.open[i]-source.high[In];
			close[i] = source.close[i]-source.high[In];
			high[i] = source.high[i]-source.high[In];
			low[i] = source.low[i]-source.high[In];
			end
	end
	


end

function FindActive(Start)
  local Return;

   for period = Start, first, -1 do
    
                  if  ZigZag.DATA[period]~= nil
				  and (( ZigZag.DATA:colorI(period) ==  core.rgb(0, 255, 0)  and ZigZag.DATA:colorI(period-1) ~=  core.rgb(0, 255, 0) )
				  or  ( ZigZag.DATA:colorI(period) ==  core.rgb(255, 0, 0) 	 and ZigZag.DATA:colorI(period-1) ~=  core.rgb(255, 0, 0) ))
	              then
				  Return=period;
				  break;
				  end 
				  
	 
   end
   
   return  Return;
end


function FindLastTwo(Start)
  
  local Return={};
  local Count=0;
   for period = Start, first, -1 do
   
       if Signal:hasData(period) then
		   if  Signal[period]~=0 then
		   Count=Count+1;
		   Return[Count]=period;
		   end
       end
	   
	   if Count== 2 then
	   break;
	   end
   
   end
   
   return Return[2], Return[1];

end
 function FindLast(Start) 
 
 
     for period = Start, first, -1 do
	         if ZigZag.DATA:hasData(period) then
				 if  ZigZag.DATA[period]~= nil
				 and ZigZag.DATA:colorI(period) ==  core.rgb(0, 255, 0)
				 and ZigZag.DATA:colorI(period-1) ~=  core.rgb(0, 255, 0) 
				 then
				 Signal[period]=1;
				 break;
				 elseif ZigZag.DATA[period]~= nil
				 and ZigZag.DATA:colorI(period) ==  core.rgb(255, 0, 0)
				 and ZigZag.DATA:colorI(period-1) ~=  core.rgb(255, 0, 0) 
				 then
				 Signal[period]=-1;
				 break;
				 end
			 end
     end   
end



function FindAll() 
 
 
     for period = first, source:size()-1, 1  do
	         if ZigZag.DATA:hasData(period) then
				 if  ZigZag.DATA[period]~= nil
				 and ZigZag.DATA:colorI(period) ==  core.rgb(0, 255, 0)
				 and ZigZag.DATA:colorI(period-1) ~=  core.rgb(0, 255, 0) 
				 then
				 Signal[period]=1;				 
				 elseif ZigZag.DATA[period]~= nil
				 and ZigZag.DATA:colorI(period) ==  core.rgb(255, 0, 0)
				 and ZigZag.DATA:colorI(period-1) ~=  core.rgb(255, 0, 0) 
				 then
				 Signal[period]=-1;
				 end
			 end
     end   
end
