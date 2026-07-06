--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
 

function Init()
    indicator:name("Advanced fractal with labels");
    indicator:description("Advanced fractal with labels");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  

    indicator.parameters:addColor("UP", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("DOWN", "Down fractal color", "Down fractal color", core.rgb(255,0,0));
    indicator.parameters:addInteger("Frame", "Number of fractals (Odd)", "Number of fractals (Odd)", 5, 3,99);
    indicator.parameters:addInteger("Distance", "Min. distance for central bar", "Min. distance for central bar", 5);
    indicator.parameters:addInteger("FontSize", "Size of font", "Size of font", 10);
    indicator.parameters:addInteger("Transparency", "Transparency", "", 50,0,100);
end

local source;
local frame=0;
local Rez=0;
local UpText;
local DnText;
local first;
local UpBuff;
local DnBuff;
local Distance;
local hUP;
local hDN;
local lUP;
local lDN;

function Prepare()
    source = instance.source;
    first=source:first();
    UpBuff=instance:addInternalStream(first, 0);
    DnBuff=instance:addInternalStream(first, 0);
    
    UpText=instance:createTextOutput ("UpText", "UpText", "Arial", instance.parameters.FontSize, core.H_Center, core.V_Top, instance.parameters.UP, first);
    DnText=instance:createTextOutput ("DnText", "DnText", "Arial", instance.parameters.FontSize, core.H_Center, core.V_Bottom, instance.parameters.DOWN, first);
    hUP=instance:addInternalStream(first, 0);
    hDN=instance:addInternalStream(first, 0);
    lUP=instance:addInternalStream(first, 0);
    lDN=instance:addInternalStream(first, 0);
    instance:createChannelGroup("UpGroup","Up" , hUP, hDN, instance.parameters.UP, 100-instance.parameters.Transparency);
    instance:createChannelGroup("DnGroup","Dn" , lUP, lDN, instance.parameters.DOWN, 100-instance.parameters.Transparency);
	
    frame=instance.parameters.Frame;
    Distance=instance.parameters.Distance;
  	
  		 if math.mod(frame, 2) ~= 0 then
		 frame=frame+1;
		 end
 
  
  local name = profile:id() .. " ( " .. frame-1 .. ", " .. Distance .. " )";
    instance:name(name);
end

function DrawRect(Direction,period)
 local shift=math.floor((frame-1)/2);
 local Range=core.range(period-shift,period+shift);
 local PriceMin=core.min(source.low,Range);
 local PriceMax=core.max(source.high,Range);
 if Direction=="UP" then
  core.drawLine(hDN,Range,PriceMin,period-shift,PriceMin,period+shift);
  core.drawLine(hUP,Range,PriceMax,period-shift,PriceMax,period+shift);
 else
  core.drawLine(lDN,Range,PriceMin,period-shift,PriceMin,period+shift);
  core.drawLine(lUP,Range,PriceMax,period-shift,PriceMax,period+shift);
 end
end

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
 
    if (period > frame) then
	
	     local x = period - count*2;
	
        local curr = source.high[period - count]-Distance*source:pipSize();
	
	UpBuff[period-count]=UpBuff[period-count-1];
	DnBuff[period-count]=DnBuff[period-count-1];
		
		
         for i= x, period, 1 do
		
		     if  curr > source.high[i] and i ~=(period - count) then
			 test=test+1;
			 end
			
		 end	
		 
		 if test == period-x then
		   UpBuff[period-count]=source.high[period - count];
		   if DnBuff[period-count]~=nil then
		    UpText:set(period - count, source.high[period - count], "" .. math.floor((UpBuff[period-count]-DnBuff[period-count])/source:pipSize()));
		    DrawRect("UP",period-count);
		   end
		 end

        test=0;		 
       
	     curr = source.low[period - count]+Distance*source:pipSize();
		
		  
          for i= x , period, 1 do
		
		     if  curr < source.low[i] and i ~=(period -count) then
			 test=test+1;
			 end
			
		 end	
	   
	      if test ==period-x then
	      DnBuff[period-count]=source.low[period - count];
	      if UpBuff[period-count]~=nil then
	       DnText:set(period - count, source.low[period - count], "" .. math.floor((UpBuff[period-count]-DnBuff[period-count])/source:pipSize()));
	       DrawRect("DN",period-count);
	      end
	  end
		  
    elseif period>first and period<=frame then
    	UpBuff[period]=nil;
    	DnBuff[period]=nil;
        
    end
end
