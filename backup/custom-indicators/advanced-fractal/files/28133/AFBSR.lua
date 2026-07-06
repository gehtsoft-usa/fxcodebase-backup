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
    indicator:name("Advanced Fractal Based Support/Resistance lines");
    indicator:description("Predicts a reversal in the current trend.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
  
    	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Fractals", "Number of fractals", "", 3, 5,99);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("R_color", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("S_color", "Down fractal color", "Down fractal color", core.rgb(255,0,0));
	indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 2, 1, 5);
   
	

end

local source;
local S,R;
local Fractals=0;
local Rez=0;
local Size;

function Prepare()
    source = instance.source;
    Size = instance.parameters.Size;
   
	Fractals=instance.parameters.Fractals
  	
 
   first = source:first()+Fractals;
   
  local name = profile:id() .. " ( " .. Fractals .. " )";
  instance:name(name);
  
    if (not (nameOnly)) then
  
    R = instance:addStream("R", core.Dot, name .. ".R", "R", instance.parameters.R_color, first);		
    S = instance:addStream("S", core.Dot, name .. ".S", "S", instance.parameters.S_color, first);
	
	R:setWidth(instance.parameters.widthLinReg);   
	S:setWidth(instance.parameters.widthLinReg);
  
	
	end
	
    
end

function Update(period, mode)

	if period <= first then
	return;
	end

      
 
 
	
	     local x = period - Fractals;
	
 
	test=true;
	
		
         for i= 1, Fractals, 1 do
		
		     if  source.high[x]  < source.high[x+i]
			 or  source.high[x] < source.high[x-i]
			 then
			 test=false;
			 end
			
		 end	
		 
		 if test   then 
          R[period] = source.high[x];
		 else
			    
		  R[period] = R[period - 1];
			 
		 end

	test=true; 
       
	    
		
		  
          for i= 1, Fractals, 1 do
		
		  
		     if  source.low[x] > source.low[x+i]
			 or  source.low[x] > source.low[x-i]
			 then
			 test=false;
			 end
		 end	
	   
	      if test  then
          S[period] = source.low[x];
		  else			 
		  S[period] = S[period - 1];
		  end
        
    
end
