-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10478

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
    indicator:name("Advanced Fractal Envelops");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  

     indicator.parameters:addGroup("Calculation");
  indicator.parameters:addInteger("Period", "Fractal Envelop Period", "", 3 , 1 , 100);	 
  indicator.parameters:addInteger("Frame", "Number of fractals (Odd)", "Number of fractals (Odd)", 5, 5,99);
    	
	indicator.parameters:addGroup("Style");
	
    indicator.parameters:addColor("UP", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("DOWN", "Down fractal color", "Down fractal color", core.rgb(255,0,0));		
	indicator.parameters:addInteger("Size", "Font Size", "", 10, 1 , 100);	 	
	
	 indicator.parameters:addColor("BOTTOM_color", "Color of TOP Line", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("CENTRAL_color", "Color of CENTRAL Line", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("TOP_color", "Color of BOTTOM Line", "", core.rgb(255, 0, 0));
	 indicator.parameters:addBoolean("Central", "Show Central Line", "", true);

	
	    indicator.parameters:addString("Show", "Show", "Search for ", "Envelop");
	 indicator.parameters:addStringAlternative("Show", "Fractal", "", "Fractal");
    indicator.parameters:addStringAlternative("Show", "Envelop", "", "Envelop");
    indicator.parameters:addStringAlternative("Show", "Both", "", "Both");
end


local TOP = nil;
local CENTRAL = nil;
local BOTTOM = nil;

local Central;

local source;
local up, down;
local frame=0;
local Rez=0;
local Size;
local first;
local Show;
local Period;
 

function Prepare(nameOnly)   
    Central= instance.parameters.Central;
    Period= instance.parameters.Period;
	frame=instance.parameters.Frame
	 Size = instance.parameters.Size;
	Show= instance.parameters.Show;
	
	source = instance.source;
	first= source:first()+ frame;
	
		 if math.mod(frame, 2) ~= 0 then
		 frame=frame+1;
		 end
 
  
  local name = profile:id() .. " ( " .. frame-1 .. " )";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
    
	
	if Show ~= "Envelop"  then
    up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.UP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.DOWN, 0);
	end
	
	 UP = instance:addInternalStream(0, 0); 
     DOWN =  instance:addInternalStream(0, 0);	  
	
	
  	
  	
	
   if Show ~= "Fractal"  then
	 TOP = instance:addStream("TOP", core.Line, name .. ".TOP", "TOP", instance.parameters.TOP_color, first);
	 if Central  then
     CENTRAL = instance:addStream("CENTRAL", core.Line, name .. ".CENTRAL", "CENTRAL", instance.parameters.CENTRAL_color, first);
	 else
	  CENTRAL =  instance:addInternalStream(0, 0);
	 end
     BOTTOM = instance:addStream("BOTTOM", core.Line, name .. ".BOTTOM", "BOTTOM", instance.parameters.BOTTOM_color, first);
	 
	 
	 else
	 
	  TOP = instance:addInternalStream(0, 0); 
      CENTRAL =  instance:addInternalStream(0, 0);	  
      BOTTOM =  instance:addInternalStream(0, 0); 
	 end
	 
	 
 
	 
	 
end

 local DownSum =0; 
 local UpSum =0;   

function Update(period, mode)

 

      local test=0;
   
	     local hof=frame;
	     local i;
	     local count=0;
	 
		 for  i= 1 , frame , 1 do
		 
			 if hof >1 then
			 hof= hof-2;
			 count = count +1;
			 else
			 count=count-1;
			 break;
			 end
		 
		 end 
 
    if (period < frame) then
	return;
	end
	
	
	test=0;		
	     local x = period - count*2;
	
        local curr = source.high[period - count];
	
		
		
         for i= x, period, 1 do
		
		     if  curr > source.high[i] and i ~=(period - count) then
			 test=test+1;
			 end
			
		 end	
		 
		 
		 
		 
		 
		 if test == period-x then
		   if Show ~= "Envelop"  then 
 		   up:set(period - count, source.high[period - count], "\226");
		   end
		   UP[period - count]=1;
		   
         
		  
		  end 
		   
        test=0;		 
       
	     curr = source.low[period - count];
		
		  
          for i= x , period, 1 do
		
		     if  curr < source.low[i] and i ~=(period -count) then
			 test=test+1;
			 end
			
		 end	
		 
		
	   
	      if test ==period-x then
			  if Show ~= "Envelop"  then  
			  down:set(period - count, source.low[period - count], "\225");
			  end
		      DOWN[period - count]=1;
				 
		  end
		  
		  
		  
		  Calculate(period);
		  		  
		 
	 
			 if BOTTOM[period]~= nil and TOP[period]~= nil then
		     CENTRAL[period]= BOTTOM[period] +( (  TOP[period]- BOTTOM[period])/2);
			 
			 end
       
end


function Calculate(period) 

local C1=0;
local C2=0;
local Sum1=0;
local Sum2=0;


for i= period, first, -1 do


if  C1<Period and UP[i]==1 then
C1=C1+1;
Sum1=Sum1+source.high[i];
end

if  C2<Period and DOWN[i]==1  then
C2=C2+1;
Sum2=Sum2+source.low[i];
end


if C1>=Period and C2>=Period  then
break;
end
 
end



TOP[period]=Sum1/Period;
BOTTOM[period]=Sum2/Period;


end