-- Id: 11375
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60454

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Distance from Open");
    indicator:description("Distance from Open");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	Parameters (1 , "D1" , core.rgb(0, 255, 0) );
	Parameters (2 , "W1" , core.rgb(255, 0, 0) );	
	Parameters (3 , "M1" , core.rgb(0, 0, 255)  );
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Method", "Method", "Method" , "Pip");
    indicator.parameters:addStringAlternative("Method", "Pip", "Pip" , "Pip");
	indicator.parameters:addStringAlternative("Method", "Value", "Value" , "Value");
	indicator.parameters:addStringAlternative("Method", "Percentage", "Percentage" , "Percentage");
	indicator.parameters:addBoolean("Sign" , "Sign reversal", "", true);	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("Size", "Font Size", "", 20); 
    indicator.parameters:addColor("Color", "Label Color ", " ", core.rgb(0, 0, 0));
end


function Parameters (id , FRAME ,Color)
    indicator.parameters:addGroup(id ..". Time Frame");
	indicator.parameters:addBoolean("On"..id , "Show  This Time Frame", "", true);	

	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
	
	indicator.parameters:addColor("LineColor"..id, "Line Color ", " ",Color);
	
	indicator.parameters:addInteger("width"..id, "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style"..id, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..id, core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Method;
local first;
local source;
local Source={};
local loading={};
local On={};
local TF={};
local LineColor={};
local Num;
local Sign;
-- Streams block
local Color = nil;
local Size;
local Width={};
local Style={};
-- Routine
function Prepare(nameOnly)
    Color = instance.parameters.Color;
	Size = instance.parameters.Size;
	Method = instance.parameters.Method;
	Sign = instance.parameters.Sign;
    source = instance.source;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. Method  .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	Num=0;
	
	for i = 1 , 3 , 1 do   
	
	   On[i]=  instance.parameters:getBoolean ("On"..i);
	   
	   if On[i] then
	   Num = Num+1;
	    Width[Num]=  instance.parameters:getDouble ("width"..i);
		Style[Num]=  instance.parameters:getDouble ("style"..i);
	   LineColor[Num]=  instance.parameters:getDouble ("LineColor"..i);
	   TF[Num]=  instance.parameters:getString ("TF"..i);
	   end
   end

    for i = 1, Num, 1 do	
		 
			   Source[i] = core.host:execute("getSyncHistory", source:instrument(), TF[i], source:isBid(), 1 , 200+i , 100+i);
			   loading[i] = true;   
    end			   

	
	instance:ownerDrawn(true);

	  
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
  
end




-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

 local i;
 

		 for i = 1, Num, 1 do	
			  if cookie == ( 100 +i) then
			  loading[i] = true;
		      elseif  cookie == (200+i) then
			  loading[i] = false;            
			 		  
			  end		       
          end   
	
    local FLAG=false; 
	local Number=0;
	

		 for i = 1, Num, 1 do	

                 if loading[i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end  	
   
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading ".. Number .. " / " ..  Num  );	 
	else
	core.host:execute ("setStatus", "Loaded")
	instance:updateFrom(0);	
	end
   
        
    return core.ASYNC_REDRAW ;
end


local init = false;
 
function Draw(stage, context)

    if stage ~= 2 then
	return;
	end
	
	
    local FLAG=false;	
	local i;
	
		 for i = 1, Num, 1 do	
                 if loading[i] then
				 FLAG= true;				
				 end		 
         end  	  
	
	if FLAG then 
	return;
	end
	
	context:setClipRectangle (  context:left (), context:top(), context:right (), context:bottom());
	
        if not init then
            context:createSolidBrush(1, Color);
			context:createPen (2, context.SOLID, 1, Color);	
			context:createFont (3, "Arial", Size,  Size, 0);
			
            for i= 1, Num , 1 do
			context:createPen (10+i, context:convertPenStyle(Style[Num]), Width[i], LineColor[i]);	
            end 			
            init = true;			
		end	
		
		
		
	 x1= context:left ();
     x2= context:right ();
	 
	 local i;
	 local Shift;
	 local Number=0;
	 local Text;
	 local All ;
	 
	 for i= 1, Num , 1 do	
	 visible, y1 = context:pointOfPrice (Source[i].open[Source[i].open:size()-1]);	
	 y2= y1;	  
	  
	 
	 if Method == "Pip" then
	 Shift = (Source[i].open[Source[i].open:size()-1] - Source[i].close[Source[i].close:size()-1] )/source:pipSize() ;
	 
	 if Sign then
	 Shift= -Shift;
	 end
	 
	 Number=1;
	  Text=TF[i].. " : " .. string.format("%." .. Number .. "f", Shift ) .. " Pips";
	 elseif Method == "Percentage" then
	 Shift = (Source[i].open[Source[i].open:size()-1] - Source[i].close[Source[i].close:size()-1] )/ (Source[i].open[Source[i].open:size()-1]/100);
	 if Sign then
	 Shift= -Shift;
	 end
	 Number=2;
	 Text=TF[i].. " : " .. string.format("%." .. Number .. "f", Shift ) .. " %";
	 else
	 
	  Shift = (Source[i].open[Source[i].open:size()-1] - Source[i].close[Source[i].close:size()-1] );
	  if Sign then
	 Shift= -Shift;
	 end
	  Number=source:getPrecision ();
	  Text=TF[i].. " : " .. string.format("%." .. Number .. "f", Shift ) .. " Value";
	  
	 end
	
	 if i== 1 then
	 All=  Text;
	 else
	 All=  All .. " - " .. Text;
	 end
	
     local width, height = context:measureText (3, Text, 0)	 
	 context:drawText (3, Text , Color, -1, x2-width, y1, x2, y1+height, context.LEFT);     	 
     context:drawLine (10+i, x1, y1, x2, y2);
	 end
	 
	 core.host:execute ("setStatus", All)
 
end 


