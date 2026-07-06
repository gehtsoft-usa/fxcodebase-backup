-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64532

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams


function AddParam(id, frame )

    indicator.parameters:addGroup(id.. ". Time Frame");
	 
	
	indicator.parameters:addBoolean("USE".. id, "Use this Slot", "", true);	
	
    indicator.parameters:addString("TF" .. id,  "Time frame", "", frame);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);


end


function Init()
    indicator:name("Target Tree");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation");	
 
	
    AddParam(1, "m1");	
    AddParam(2, "m5");	
    AddParam(3, "m15");	
    AddParam(4, "m30");
    AddParam(5, "H1");
	AddParam(6, "H2");	
    AddParam(7, "H3");	
    AddParam(8, "H4");	
    AddParam(9, "H6");
    AddParam(10, "H8");
	AddParam(11, "D1");	
    AddParam(12, "W1");
    AddParam(13, "M1");
	
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Line Color", "", core.COLOR_LABEL );
	indicator.parameters:addInteger("Width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("Style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE);
	indicator.parameters:addDouble("Size", "Font Size", "", 10);
	--indicator.parameters:addDouble("Multiplier", "Multiplier", "", 50);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

	local source = nil;
	local TF={};
	local SourceData={};
	local loading={};  
	local Size;
	local USE={};
	local Count=13;
    local Number;
	local Style, Width, Color
    local Chart;
	local iLabel={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"};
	local Label={};
	--local Multiplier;
-- Routine
function Prepare(nameOnly)
    	
	
    source = instance.source;
    Shift=instance.parameters.Shift;
    Size=instance.parameters.Size;
	--Multiplier=instance.parameters.Multiplier;
	Style=instance.parameters.Style;
	Width=instance.parameters.Width;
	Color=instance.parameters.Color;
	

    local i;
    local name = profile:id() .. "(" .. source:name() ;
	 name = name .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	Number=0;
	
	
    local s1, e1, s1, e1;
    s1, e1 = core.getcandle(source:barSize(), core.now(), 0, 0);
 
   
    for i = 1, Count, 1 do	

          s2, e2 = core.getcandle(instance.parameters:getString("TF" .. i), core.now(), 0, 0);	
		
	     if instance.parameters:getBoolean("USE" .. i)   and  ((e1 - s1) <= (e2 - s2)) then
		 Number=Number+1;
		 		
			  TF[Number]= instance.parameters:getString("TF" .. i);	
			  Label[Number]=iLabel[i];
			  
		 end   
		   
	  
    end
   
   	
 	
	
	 s1, e1 = core.getcandle(source:barSize(), core.now(), 0, 0);

    for i = 1, Number, 1 do	
	
	     
	    if (TF[i] == source:barSize() )     then
		SourceData[i]=source;
		Chart=i;
		loading[i]= false;
		else 	
	    SourceData[i] = core.host:execute("getSyncHistory", source:instrument(), TF[i], source:isBid(),  0 , 200+i, 100+i);	   
		loading[i]= true;		
		end
		
	end	  
    
	instance:ownerDrawn(true);

end

 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 
	    
end

local init =true;

function Draw(stage, context)
    if stage ~= 2
	
	then
	return;
	end
	
	local Flag = false;	

	
	
	
    for j = 1, Number, 1 do			
		if loading[j] then	
		Flag=true;
		end	 
 
	end    
	
     	if Flag then
		return;
		end
		
		if init then
		context:createFont (2, "Arial", Size, Size, 0);
		init=false;
		end
      
	    local x = context:right ()  - (context:right () -context:left ())/3;		
 		    
		
		context:createPen (1, context:convertPenStyle (Style), Width, Color);
		
		for i = Number, 1, -1 do 	
		
		    visible, y1= context:pointOfPrice (SourceData[i].high[NOW]);
            visible, y2= context:pointOfPrice (SourceData[i].low[NOW]);    
			 
			if i == Number then	
			context:drawLine (1, x, y1, x, y2);			
			end
					
                
			AddLine(context, x, i);
            			
			
		 end
	 
         		 
 
		
end

function AddLine(context, x, i)

            Delta=(context:right ()-x)/Number;

            iLabel= Label[i].." H";
            visible, y1= context:pointOfPrice (SourceData[i].high[NOW]);              		 
			context:drawLine (1, x-i*Delta, y1, x, y1);	
			width, height =context:measureText (2, iLabel, 0)
			context:drawText (2, iLabel, Color, -1, x-i*Delta, y1-height, x-i*Delta+width, y1, 0);

			iLabel= Label[i].." L"; 
            visible, y1= context:pointOfPrice (SourceData[i].low[NOW]); 			
			context:drawLine (1, x, y1, x+i*Delta, y1);
			width, height =context:measureText (2, iLabel, 0)
            context:drawText (2, iLabel, Color, -1, x+i*Delta-width, y1-height, x+i*Delta, y1, 0);
			
			iLabel= Label[i].." O";
			visible, y1= context:pointOfPrice (SourceData[i].open[NOW]);              		 
			context:drawLine (1, x-i*Delta, y1, x, y1);	
			width, height =context:measureText (2, iLabel, 0)
			context:drawText (2, iLabel, Color, -1, x-i*Delta, y1-height, x-i*Delta+width, y1, 0);

			iLabel= Label[i].." C";
            visible, y1= context:pointOfPrice (SourceData[i].close[NOW]); 			
			context:drawLine (1, x, y1, x+i*Delta, y1);
			width, height =context:measureText (2, iLabel, 0)
            context:drawText (2, iLabel, Color, -1, x+i*Delta-width, y1-height, x+i*Delta, y1, 0);
end

-- the function is called when the async operation is finished

function AsyncOperationFinished(cookie)

     local j;	 
	local Flag = false;	
	local Count=0;	
	
	
	
    for j = 1, Number, 1 do
		
			  if cookie == (100+j) then
			  loading[j] = true;
		      elseif  cookie == (200+j) then
			  loading[j] = false;  
			  instance:updateFrom(0);		 
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=true;
		end	 
 
	end    
	
     	if Flag then
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		else
		core.host:execute ("setStatus", " Loaded ".. (Number-Count) .."/" .. Number);
		end
   
        
		return core.ASYNC_REDRAW ;
   
end

