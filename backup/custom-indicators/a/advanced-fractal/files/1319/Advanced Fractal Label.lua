--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Advanced fractal");
    indicator:description("Predicts a reversal in the current trend.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  

    indicator.parameters:addColor("UP", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("DOWN", "Down fractal color", "Down fractal color", core.rgb(255,0,0));
	indicator.parameters:addInteger("Frame", "Max Fractal Number (Odd)", "", 99, 5,100);
	indicator.parameters:addInteger("Size", "Font Size", "", 10, 1 , 100);	 
end

local source;
local up, down;
local frame=0;
local Rez=0;
local Size;

function Prepare(nameOnly)
    source = instance.source;
    Size = instance.parameters.Size;
    up = instance:createTextOutput ("Up", "Up", "Arial", Size, core.H_Center, core.V_Top, instance.parameters.UP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Arial", Size, core.H_Center, core.V_Bottom, instance.parameters.DOWN, 0);
	
	frame=instance.parameters.Frame
  	
    if  (nameOnly)  then
	return;
	end 		 
  
    local name = profile:id() .. " ( " .. frame-1 .. " )";
    instance:name(name);
end

function Update(period, mode)


    local test=0;   
	local i;
	local count=frame;

	if period <= frame then
	return;
	end
	

	 local x ;
	
	if period < count then	    
		 count=period;
	end
	
	  if  ( source:size() -1 - period)  < count  then
	     
		 count=( source:size() -1 - period);		
		
	end
	

	
	
	
	     x = period;
	
        local curr = source.high[x];
	
		
		
         for i= 1, count, 1 do
		
		     if  curr > source.high[x + i] and curr > source.high[x  - i]  then
			 test=test+1;
			 else
			 break;
			 end
			
		 end	
		 
		 if test ~= 0 then
		   up:set(x, source.high[x],  tostring(test));
		 end

        test=0;		 
       
	     curr = source.low[x];
		
		  
          for i= 1 , count, 1 do
		
		     if  curr < source.low[x + i] and curr < source.low[x  - i]  then
			 test=test+1;
			  else
			 break;
			 end
			
		 end	
	   
	     if test ~= 0 then
	      down:set(x, source.low[x], tostring(test));
		end
        
    
end
