-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73041

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+


function Init()
    indicator:name("Every Fractal trend lines");
    indicator:description("Predicts a reversal in the current trend.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Frame", "Number of fractals)", "Number of fractals", 2, 1,99);
	indicator.parameters:addBoolean("Forward", "Extend Lines Forward", "Extend Lines", true);	 			
	indicator.parameters:addBoolean("Backward", "Extend Lines Backward", "Extend Lines", true);		
    
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("DOWN", "Down fractal color", "Down fractal color", core.rgb(255,0,0));
	
	indicator.parameters:addInteger("Size", "Font Size", "", 10, 1 , 100);	


	indicator.parameters:addGroup("Line Style");    
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);		
end

local source;
local up, down;
local Frame;
local Size;
local first;
local Forward,Backward;
function Prepare(nameOnly) 
   
	Frame = instance.parameters.Frame; 
	Forward = instance.parameters.Forward;
	Backward = instance.parameters.Backward;
  
    local name = profile:id() .. " ( " .. Frame  .. " )";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
    Size = instance.parameters.Size;
    up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.UP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.DOWN, 0);
	
    top = instance:addInternalStream(0, 0);	
    bottom = instance:addInternalStream(0, 0);

    shift_top = instance:addInternalStream(0, 0);	
    shift_bottom = instance:addInternalStream(0, 0); 	
	
    source = instance.source;
	first=source:first()+Frame*2;
	
	instance:ownerDrawn(true);
	
	
end

function Update(period, mode)
 
 
	period = period-Frame;
 
 
    
    if (period < first) then
	return;
	end
	
	 down:setNoData(period);
	 up:setNoData(period);
	 top[period]=0;
	 bottom[period]=0;	 
	

	    local test=true;
 
	
		
		
         for i= 1, Frame, 1 do
		
		     if  source.high[period] < source.high[period+i] or  source.high[period] < source.high[period-i] then
			 test=false;
			 end
			
		 end	
		 
		 if test then
		   up:set(period, source.high[period], "\108");
	       top[period]=1;		   
		 end

        test=true; 
		
        for i= 1, Frame, 1 do
		
		     if  source.low[period] > source.low[period+i] or source.low[period] > source.low[period-i] then
			 test=false;
			 end
			
		 end	
	   
	      if test then
	      down:set(period, source.low[period], "\108");
	      bottom[period]=1;				  
		  end
		  
		  
		 
		if   top[period]==1  or bottom[period]==1 then
        Previus(period);		 
		end
        
 
end



function Previus(period) 		
   
   
    Shift=0;

    if top[period]==1   then	
		for i= period-1, source:first(), -1  do
			if top[i]==1 then
			Shift=period-i;
			break;
			end
		end
		 shift_top[period]= Shift;
   end
   
   Shift=0;

	if bottom[period]==1   then
	
	    for i= period-1, source:first(), -1  do
			if bottom[i]==1 then
			Shift=period-i;
			break;
			end
		end
	
    shift_bottom[period] = Shift; 	
	end

end

 


local init = false; 
function Draw (stage, context)

    if stage  ~= 2 then
	return;
	end
 
 
	 
  
      context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
    if not init then
		init =true;
		context:createPen (1, context:convertPenStyle ( instance.parameters.style), context:pixelsToPoints ( instance.parameters.width),  instance.parameters.UP);	 
		context:createPen (2, context:convertPenStyle ( instance.parameters.style), context:pixelsToPoints ( instance.parameters.width), instance.parameters.DOWN);

	end
 
   

	

	
 
	      X , x, x = context:positionOfBar (source:size()-1);		
 
	    
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);

 

		for i=  last, first, -1 do	
		
		
		
		    if top[i]== 1 and i > shift_top[i] then
	
			 
			itis, y2= context:pointOfPrice (source.high[i]);  
			itis, y1= context:pointOfPrice (source.high[i-shift_top[i]]); 			
			 x2 , x, x = context:positionOfBar (i);	
			 x1 , x, x = context:positionOfBar (i-shift_top[i]);				
			 
					 if Forward or Backward then
					 
					 a, b, c, k =getline(x1, y1, x2, y2)
					 
					  if Backward then
					  y1= GetYofABCLine(context:left (), a, b, c)					 				  
					  x1= context:left ()
					  end
					  
 					  if Forward then
					  y2= GetYofABCLine(context:right (), a, b, c)	
					  x2= context:right ()	
                      end					  
					  
					 end
			 
				 context:drawLine (1, x1, y1,x2, y2); 		 
			
			end
			
			
		    if bottom[i]== 1 and i > shift_bottom[i] then 		 
			 
			itis, y2= context:pointOfPrice (source.low[i]);  
			itis, y1= context:pointOfPrice (source.low[i-shift_bottom[i]]); 			
			 x2 , x, x = context:positionOfBar (i);	
			 x1 , x, x = context:positionOfBar (i-shift_bottom[i]);	
			 
					 if Forward or Backward then
					 
					 a, b, c, k =getline(x1, y1, x2, y2)
					 
					  if Backward then 
					  y1= GetYofABCLine(context:left (), a, b, c)					 				  
					  x1= context:left ()
					  end
					  
 					  if Forward then					  
					  y2= GetYofABCLine(context:right (), a, b, c)	
					  x2= context:right ()	
					  end

					  
					 end
			 
			 		 context:drawLine (2, x1, y1,x2, y2); 
			end 

 
			
 
		end
		
		 
end	

function GetYofABCLine(X, a, b, c)
   return (-a * X - c) / b;
end

-- get line equation coefficients
function getline(x1, y1, x2, y2)
  
  local deltaX, deltaY; 
   local a, b, c, k;     

   deltaX = x2 - x1;                  --  X
   deltaY = y2 - y1;                  --  Y
   a = deltaY;                        -- a
   b = -deltaX;                       -- b
   c = ( y2*deltaX ) - ( x2*deltaY ); -- c
   k = -a / b;               
   
   return a, b, c, k;
   
   
	
end

 

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+