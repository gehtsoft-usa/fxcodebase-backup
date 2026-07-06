-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=724

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+
function Init()
    indicator:name("Adv. Fractal support resistance ");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
  
    	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Frame", "Number of fractals (Odd)", "Number of fractals (Odd)", 5, 5,99);
	 indicator.parameters:addInteger("Lenght", "Line Length", "", 50, 1, 1000);
	 indicator.parameters:addInteger("Lookback", "Lookback Period", "", 200, 1, 1000);
	 
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("Down", "Down fractal color", "Down fractal color", core.rgb(255,0,0));
	indicator.parameters:addInteger("width", "Line width", "Line width", 2, 1, 5);
	  indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
   
	

end
local source;
local buff;
local frame=0; 
local Size;
local Up, Down,style, width;
local Lenght;
local ID;
local count=0;
local Lookback; 
function Prepare()
    source = instance.source;
    Size = instance.parameters.Size;
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	width = instance.parameters.width;
	style = instance.parameters.style;
	Lenght = instance.parameters.Lenght;
	Lookback = instance.parameters.Lookback;
   
	frame=instance.parameters.Frame
  	
  		 if math.mod(frame, 2) ~= 0 then
		 frame=frame+1;
		 end
 
   first = source:first();
   
  local name = profile:id() .. " ( " .. frame-1 .. " )";
  instance:name(name);
  
    if (not (nameOnly)) then  
	buff = instance:addInternalStream(first, 0); 
	end
	
     
	 local hof=frame;
	 
	 count=0;
	 for  i= 1 , frame , 1 do
		 
			 if hof >1 then
			 hof= hof-2;
			 count = count +1;
			 else
			 count=count-1;
			 break;
			 end
		 
		 end 
		 
		 instance:ownerDrawn(true);
end

function Update(period, mode)

	if period < first then 
	return;
	end
     
	
	buff[period]=0;
      local test=0;	    
	     local i;
	     
 
    if (period < frame) then
	return;
	end
	
	     local x = period - count*2;
	
        local curr = source.high[period - count];
	
		
		
         for i= x, period, 1 do
		
		     if  curr > source.high[i] and i ~=(period - count) then
			 test=test+1;
			 end
			
		 end	
		 
		 if test == period-x then		 
         buff[period - count] =  1; 	 
		 end

        test=0;		 
       
	     curr = source.low[period - count];
		
		  
          for i= x , period, 1 do
		
		     if  curr < source.low[i] and i ~=(period -count) then
			 test=test+1;
			 end
			
		 end	
	   
	      if test ==period-x then	      
			 buff[period - count] =  -1; 	
			 
		  end
        
    
	 
end

local init =false;


function Draw(stage, context)
    if stage ~= 2 then
    return;
	end
	 --ID=0;
	
	local First=math.max(first, context:firstBar () , source:size()-1 - Lookback);
	local Last=math.min(source:size()-2, context:lastBar ());
	
	
 

    if not init then
	init = true;
    context:createPen (1, context:convertPenStyle (instance.parameters.style), context:pixelsToPoints (instance.parameters.width), instance.parameters.Up)
    context:createPen (2, context:convertPenStyle (instance.parameters.style), context:pixelsToPoints (instance.parameters.width), instance.parameters.Down)	
    end	
    local period;
	for period = First, Last, 1 do
	
		
		if  buff[period ]== 1 or buff[period ]== -1 then
		Line(context,period, Last); 	 
		end
		
	end
	   					
						
end

function Line (context, period, Last)
 
 
    local Color1, Color2,Level, x1, x2;
	x1=period;
	x2=math.min(Last, x1+Lenght);
	x3=math.min(Last, x1+Lenght);
	
    if buff[period ]== 1 then 
	Level=source.high[period];	
	elseif buff[period ]== -1 then  
	Level=source.low[period];
	end
	
	
	local Count= 0;
	for i= period, math.min(Last, x1+Lenght), 1 do
	    if core.crosses( source.close, Level , i) then
		   Count=Count+1;
		    if Count == 1 then
			x2=i;
			elseif Count == 2 then
			x3=i;
			break;
			end
		 
		end
	end
	


	
	if x2== x3 then
	
			x1, x, x = context:positionOfBar (x1)
			x3, x, x = context:positionOfBar (x3)		
 
	
	
			if buff[period ]== 1 then
			visible, y = context:pointOfPrice (source.high[period])
			context:drawLine (1, x1, y, x3, y)
			else
			visible, y = context:pointOfPrice (source.low[period])			
			context:drawLine (2, x1, y, x3, y)		
			end
			
	else
			x1, x, x = context:positionOfBar (x1)
			x2, x, x = context:positionOfBar (x2)
			x3, x, x = context:positionOfBar (x3)		
	
			if buff[period ]== 1 then
			visible, y = context:pointOfPrice (source.high[period])			
			context:drawLine (1, x1, y, x2, y)
			context:drawLine (2, x2, y, x3, y)				
			else
			visible, y = context:pointOfPrice (source.low[period])				
			context:drawLine (2, x1, y, x2, y)
			context:drawLine (1, x2, y, x3, y)	
			end
			
 
			
	end
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+