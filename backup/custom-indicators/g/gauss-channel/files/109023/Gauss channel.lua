-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64090&p=109023#p109023

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
    indicator:name("Gauss channel");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");

    indicator.parameters:addInteger("bars_back", "Period", "", 125);
	indicator.parameters:addInteger("m", "m", "", 2);
	indicator.parameters:addInteger("i", "i", "", 0);
	indicator.parameters:addDouble("kstd", "kstd", "", 2);
	

	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Color of Central Line", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "Color of Top Line", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("color3", "Color of Bottom Line", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("color4", "Color of Standard deviation Top Line", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("color5", "Color of Standard deviation Bottom Line", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width5", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style5", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style5", core.FLAG_LINE_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local first;
local source = nil;
local Top;
local Bottom;
local DevTop;
local DevBottom;
local Central;
-- Streams block
local bars_back, m, i , kstd;
local p;
local nn;
-- Routine
local sx={};
local b={};
local ai={};
local x={};
function Prepare(nameOnly)
    
    source = instance.source;
   
	
	bars_back= instance.parameters.bars_back;
	m= instance.parameters.m;
	i= instance.parameters.i;
	kstd= instance.parameters.kstd;
	p=bars_back;	
	nn = m + 1;

    local name = profile:id() .. "(" .. source:name()   .. ")";
    instance:name(name);
	
	 first = source:first()+ i +  p+1 ;
    for ii = 1, nn, 1 do	
     ai[ii]={};
     end
	  

    if (not (nameOnly)) then
	    Central = instance:addStream("Central", core.Line, name, "Central Line", instance.parameters.color1, first);
		Central:setWidth(instance.parameters.width1);
        Central:setStyle(instance.parameters.style1);
        Top = instance:addStream("Top", core.Line, name, "Top Line", instance.parameters.color2, first);
		Top:setWidth(instance.parameters.width2);
        Top:setStyle(instance.parameters.style2);
		Bottom = instance:addStream("Bottom", core.Line, name, "Bottom Line", instance.parameters.color3, first);
		Bottom:setWidth(instance.parameters.width3);
        Bottom:setStyle(instance.parameters.style3);
		
		DevTop = instance:addStream("DevTop", core.Line, name, "Dev Top Line", instance.parameters.color4, first);
		DevTop:setWidth(instance.parameters.width4);
        DevTop:setStyle(instance.parameters.style4);
		DevBottom = instance:addStream("DevBottom", core.Line, name, "Dev Bottom Line", instance.parameters.color5, first);
		DevBottom:setWidth(instance.parameters.width5);
        DevBottom:setStyle(instance.parameters.style5);
    end
end



-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
	
   if period < source:size()-1
   or period < first
   then
   return;
   end
   
   

	sx[1] = p + 1;
	
	for mi = 1,(nn * 2 - 2 ),  1 do    
      sum = 0;
				
                   for  n = i, (i + p ) , 1 do			  
					 sum =sum+ math.pow(n, mi);
				  end
      sx[mi + 1] = sum;
      end
	
	
	--===============syx===============
	  for mi = 1,   nn , 1  do
  
      sum = 0.00000;
		  for n = i,(i + p ) , 1  do
			 if mi == 1  then
				sum =sum+ source[source:size()-1-n];
			 else
				sum =sum+ source[source:size()-1-n] * math.pow(n, (mi - 1));
		     end		
		  end
		  b[mi] = sum;   
	
	  end
	  
	  --===============Matrix===============
	  for jj = 1, nn, 1 do      
	           for ii = 1, nn, 1 do
	            kk = ii + jj - 1;
				 ai[ii][jj] = sx[kk];
			  end
       end
	   
	   
	  --===============Gauss=================== 
	  
	  
   for kk = 1 , (nn - 1) ,1  do
   
      ll = 0;
	  mm = 0;
	  
      for ii = kk,   nn, 1 do
     
         if (math.abs(ai[ii][kk]) > mm) then         
            mm = math.abs(ai[ii][ kk]);
            ll = ii;
         end
     end
	  
	  
      if ll == 0  then
        return;   
     end
	  
      if ll ~= kk  then
       
			 for jj = 1, nn , 1 do
			 
				tt = ai[kk ][ jj];
				ai[kk][ jj] = ai[ll][ jj];
				ai[ll][ jj] = tt;
			 end
			 tt = b[kk]; 
			 b[kk] = b[ll];
			 b[ll] = tt;
      end
	  
      for ii = kk + 1 ,  nn , 1 do
      
         qq = ai[ii][ kk] / ai[kk][ kk];
			 for jj = 1,  nn, 1 do
			
				if jj == kk then
				   ai[ii][ jj] = 0;
				else
				   ai[ii][ jj] = ai[ii][ jj] - qq * ai[kk][ jj];
			     end			 
			 end
			 b[ii] = b[ii] - qq * b[kk];
	  end
   end 
   
    x[nn] = b[nn] / ai[nn][ nn];
   
	   
	   for ii = nn - 1, 1, -1 do	   
		  tt = 0;
		  for jj = 1, nn - ii,  1 do		  
			 tt = tt + ai[ii][ ii + jj] * x[ii + jj];
			 x[ii] = (1 / ai[ii ][ii]) * (b[ii] - tt);
		  end
	   end 
	   
--===========================================================================================================================
    
  
  for n = i , (i + p ), 1 do
      sum = 0;
      for kk = 1 ,   m , 1  do             
		  sum =sum+  x[kk + 1] * math.pow(n, kk);
      end      
	  
		Central[source:size()-1 - n] = x[1] + sum;
   end
-------------------------------------Std-----------------------------------------------------------------------------------
   sq = 0.0;
   for n = source:size()-1-i , source:size()-1-i-  p , -1  do 
      sq =sq + math.pow((source[n] - Central[n]), 2);
   end
   sq = math.sqrt(sq / (p + 1)) * kstd;
    -- std = iStdDev(NULL, 0, p, MODE_SMA, 0, PRICE_CLOSE, i) * kstd;
    std= mathex.stdev (source, period-i-p, period-i);
    for n = source:size()-1-i , source:size()-1-i-  p , -1  do 
    
      Top[n] = Central[n] + sq;
      Bottom[n] = Central[n] - sq;
      DevTop[n] = Central[n] + std;
      DevBottom[n] = Central[n] - std;
    end
		 
    
end
