-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=43376

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
    indicator:name("InsideBar Support Resistance");
    indicator:description(".");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
  
    	indicator.parameters:addGroup("Calculation");
  
     
  
	 indicator.parameters:addInteger("Lenght", "Line Length", "", 50, 1, 1000);
	indicator.parameters:addInteger("Period", "Period", "", 5 ); 
	indicator.parameters:addBoolean("Filter", "Use Filter", "", true);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("R_color", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("S_color", "Down fractal color", "Down fractal color", core.rgb(255,0,0));
	indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 2, 1, 5);
	  indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
   
	

end
local Live, Filter;
 local source; 
 local Period;
local Rez=0;
local Size;
local id;
local  ID; 
local LEVEL={};
local Lenght;  
local COLOR={};
local FIRST={};
local Range;
function Prepare(nameOnly)
    source = instance.source;
    Size = instance.parameters.Size;
	Lenght = instance.parameters.Lenght; 
	Filter= instance.parameters.Filter;
   
	Period=instance.parameters.Period
 
   first =source:first()+Period+1;
   
  local name = profile:id() .. " ( " .. Period .. " )";
  instance:name(name);
	if nameOnly then
		return;
	end
  
     
	if Filter then
	Range = instance:addInternalStream(0, 0);
	end
	 
	
    instance:ownerDrawn(true);

	id=0;
end

function Update(period )
 

	if Filter   then	
	Range[period]=source.high[period]-source.low[period];	 
	end
	
  
	
	if period < first then 
	id=0;
	return;
	end
	
	period=period-1;
	
	if Filter and  (mathex.min(Range, period-Period+1, period) == Range[period]) then
	return;
	end
  
		 
		 
	if not (source.high[period] < source.high[period-1]  and source.low[period] >  source.low[period-1] ) then
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


        if not init then
            context:createPen (1, context.SOLID, 1, instance.parameters.R_color)
			context:createPen (2, context.SOLID, 1, instance.parameters.S_color)
            init = true;
        end


		
		

   for period = context:firstBar (), context:lastBar (),  1 do

			for i= 1, id, 1  do			  
			   local Index= core.findDate (source, FIRST[i], false);				            
			 
			 
			   
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
