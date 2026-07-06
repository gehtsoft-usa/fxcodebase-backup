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
    indicator:name("Unsymmetrical Fractal support resistance ");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
  
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Left", "Number of fractals (Left)", "", 5, 1,2000);
    indicator.parameters:addInteger("Right", "Number of fractals (Right) ", "", 5, 1,2000);	
    indicator.parameters:addInteger("Shift", "Shift ", "Shift", 5, 1,2000);		
	indicator.parameters:addInteger("Lenght", "Length", "", 50, 1, 2000);
	indicator.parameters:addInteger("Lookback", "Lookback Period", "", 200, 1, 10000);
	 
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("Down", "Down fractal color", "Down fractal color", core.rgb(255,0,0));
	indicator.parameters:addInteger("width", "Line width", "Line width", 2, 1, 5);
	  indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
   
	

end
local source;
local buff;
local Left, Right; 
local Size;
local Up, Down,style, width;
local Lenght;
local ID;
local count=0;
local Lookback; 
function Prepare(nameOnly)
    source = instance.source;
    Size = instance.parameters.Size;
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	width = instance.parameters.width;
	style = instance.parameters.style;
	Lenght = instance.parameters.Lenght;
	Lookback = instance.parameters.Lookback;
   
	Left=instance.parameters.Left;
	Right=instance.parameters.Right;
	Shift=instance.parameters.Shift; 
 
    first = source:first()+ Shift+Left;
   
    local name = profile:id() .. " ( " .. Left   .. " ,  " .. Right..   " ,  " .. Shift .. " )";
    instance:name(name);
	
    if  nameOnly  then
    return;
    end 
 
	buff = instance:addInternalStream(0, 0); 
          
	instance:ownerDrawn(true);
end

function Update(period, mode)

	if period <= first   then 
	return;
	end
     
	
	buff[period - Shift]=0;
 
	
 
	
        local curr = source.high[period - Shift];
	
		
		local test_left=0
		
         for i= 1, Left, 1 do
		
		     if  curr > source.high[period - Shift-i]  then
			 test_left=test_left+1;
			 end
			
		 end	
		 
		local test_right=0
		
         for i= 1, Right, 1 do
		
		     if  curr > source.high[period - Shift+i]  then
			 test_right=test_right+1;
			 end
			
		 end		 
		 
		 if test_left == Left and test_right == Right then		 
         buff[period - Shift] =  1; 	 
		 end
		 
	--/////////////////////////////////////////////////////////////////////

	
        local curr = source.low[period - Shift];
	
		
		local test_left=0
		
         for i= 1, Left, 1 do
		
		     if  curr < source.low[period - Shift-i]  then
			 test_left=test_left+1;
			 end
			
		 end	
		 
		local test_right=0
		
         for i= 1, Right, 1 do
		
		     if  curr < source.low[period - Shift+i]  then
			 test_right=test_right+1;
			 end
			
		 end		 
		 
		 if test_left == Left and test_right == Right then		 
         buff[period - Shift] =  -1; 	 
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