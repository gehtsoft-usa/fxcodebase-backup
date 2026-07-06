-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63162

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Wide Body Range Support and Resistancee");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
  
    	indicator.parameters:addGroup("Calculation");
  
     
	indicator.parameters:addInteger("Lookback", "Lookback Period ", "Period", 14);
	indicator.parameters:addDouble("MinimumSize", "Minimum Body Size in Pips", "Minimum Size", 0);
	indicator.parameters:addInteger("Lenght", "Line Length", "", 50, 1, 1000);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("R_color", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("S_color", "Down fractal color", "Down fractal color", core.rgb(255,0,0));
	indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 2, 1, 5);
	  indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
   
	

end
local Lookback,MinimumSize,Range;
local source; 
local Lenght; 
 
local Rez=0;
local Size;
local id;
local  ID; 
local LEVEL={};
local COLOR={};
local FIRST={};


function Prepare(nameOnly)
    source = instance.source;
	Lookback = instance.parameters.Lookback;
	MinimumSize = instance.parameters.MinimumSize;
	Lenght= instance.parameters.Lenght;
	
    Size = instance.parameters.Size;
	Range = instance:addInternalStream(0, 0); 	
 
   first =source:first()+Lookback;
   
  local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Lookback).. ", " .. tostring(MinimumSize) .. ")";
  instance:name(name);
  
if   (nameOnly) then
        return;
end
  
   
	
    instance:ownerDrawn(true);

	id=0;
end

function Update(period )
 
	Range[period]=source.high[period]-source.low[period];	
    period=period-1;
	
	if period < first then 
	id=0;
	return;
	end
	
	local max=mathex.max(Range,period-Lookback, period-1); 
	
	if  Range [period]<max then
	return;
	end
			 
 
		 
		 if  source.close[period] > source.open[period]  then		 
         
          id=id+1; 
			 LEVEL[id]=source.high[period];
             COLOR[id]= true;
             FIRST[id]= source:date(period);	 
		 end

      
	      
		
		 
	   
	      if source.close[period] <source.open[period]  then	      
		
			 id=id+1;
			  
			 LEVEL[id]=source.low[period];
			 COLOR[id]= false;
             FIRST[id]= source:date(period);	 
		  end
        
     
 
 
end


local init = false;


function Draw(stage, context)



  if stage~= 1 then
	 return;
	end
	
        if not init then
            context:createPen (1, context.SOLID, 1, instance.parameters.R_color)
			context:createPen (2, context.SOLID, 1, instance.parameters.S_color)
            init = true;
        end


		
	 local Index;	

   for period = context:firstBar (), context:lastBar (),  1 do

			for i= 1, id, 1  do			  
			
			   Index= core.findDate (source, FIRST[i], false);		
			   
			     if Index ~= -1 
			   and  (period- Index) < Lenght 
			   and  period>= Index
			   then
			    
			 
									  
				visible, y = context:pointOfPrice (LEVEL[i]);		 
                x, x1, x2=  context:positionOfBar (period);
													  if  COLOR[i]   then   
														 context:drawLine (1, x1, y, x2, y);
													 elseif not COLOR[i]  then     
														 context:drawLine (2, x1, y, x2, y);
													  end
													 
										 
               end
             
 
		 end
	 
	end
end
