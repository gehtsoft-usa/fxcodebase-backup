-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69015

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Period High Low");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	
	
	
	 indicator.parameters:addGroup( "Calculation");
	 	indicator.parameters:addInteger("Period", "Period", "Period", 10); 

	indicator.parameters:addGroup( "Selector");
    Add(1, "m1", false);
	Add(2, "m5", false);
	Add(3, "m15", false);
    Add(4, "m30", false);
	Add(5, "H1", false);
	Add(6, "H2", false);
	Add(7, "H3", false);
	Add(8, "H4", false);
	Add(9, "H6", false);
	Add(10, "H8", false);
	Add(11, "D1", false);
	Add(12, "W1", true);
	Add(13, "M1", true);
	
	
	indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
   indicator.parameters:addInteger("Size", "Font Size", "", 8);
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	
	local iTF={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"} 
	
	
	indicator.parameters:addGroup("Line Style");
	for  i = 1, 13, 1 do
	
	indicator.parameters:addColor("Min"..i , iTF[i].. " Low Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Max"..i , iTF[i].. " High Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style"..i,iTF[i].. " Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..i, core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width"..i, iTF[i].." Line Width", "", 3, 1, 5);
	
	
	end
	
end

 
function Add(id, Label, IsIt)

    
 
	indicator.parameters:addBoolean("On"..id, "Use" .. tostring( Label) .. " Time Frame", "", IsIt);
	
 

  
end 
 
local iTF={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"} 
 
local Source ={};
local  TF={}; 
local first;
local source = nil;
local loading={}; 

local Number ; 
local Period;
local Label, Size;

local style={};
local width={};
local Min={};
local Max={};
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 
	
	 Period=  instance.parameters.Period;  
   
   
    Label=instance.parameters.Label;
	Size=instance.parameters.Size;   

    if   (nameOnly) then
        return;
    end
  
	  
    source = instance.source; 
 
	Number=0;
	
	local i;
		for  i = 1, 13, 1 do
			 if instance.parameters:getBoolean ("On"..i) then
			 Number=Number+1;
			
			 TF[Number]= iTF[i];
			 		
			
			 Min[Number]=instance.parameters:getColor ("Min"..i);
			 Max[Number]=instance.parameters:getColor ("Max"..i);
			 style[Number]=instance.parameters:getInteger ("style"..i);
			 width[Number]=instance.parameters:getInteger ("width"..i)
			
			
			Source[Number] = core.host:execute("getSyncHistory",source:instrument(), TF[Number], source:isBid(), math.min(300,Period), 200+Number, 100+Number);
			
			loading[Number]=true;
		  end
	end

 
    instance:ownerDrawn(true);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
 
	 

end


local init = false;
 
function Draw(stage, context)
 
	  if stage~= 2 then
	  return;
	  end
	  
	  
	  
	local Break=false;
  	
    for j = 1, Number, 1 do
		
			  
			  if loading[j]  then
              Break=true;
			  end			  
   end
   
    
	if Break then
	return;
	end
	
		  
		
			
				if not init then
				   context:createFont (25, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
					   for j = 1, Number, 1 do
					   context:createPen (j, context:convertPenStyle (style[j]), width[j],Min[j])
					   context:createPen (j+20, context:convertPenStyle (style[j]), width[j], Max[j])
					   end
				   
					init = true;
				end

	
	local min, max;		
    for j = 1, Number, 1 do
	min, max=mathex.minmax(Source[j], Source[j]:size()-1-Period+1, Source[j]:size()-1);
	visible, y_min = context:pointOfPrice (min);
	visible, y_max = context:pointOfPrice (max);
	
	
	context:drawLine (j, context:left(), y_min, context:right (), y_min);
	context:drawLine (j+20, context:left(), y_max, context:right (), y_max);
	
	 Shift=((context:right ()-context:left ())/13)*(j-1);
	--i
	 Text=TF[j].. " Max"
	 width, height = context:measureText (25, Text, 0);
     context:drawText (25,  Text, Label, -1,  context:right ()-Shift-width ,  y_max-height ,context:right ()-Shift,y_max, 0 );	
	 
	 
	  Text=  win32.formatNumber(max, false, source:getPrecision());
	  width, height = context:measureText (25, Text, 0);
     context:drawText (25,  Text, Label, -1,  context:right ()-Shift-width ,  y_max ,context:right ()-Shift,y_max+height, 0 );	
	 
	 
	  Text=TF[j]  .. "Min";
	 width, height = context:measureText (25, Text, 0);
     context:drawText (25,  Text, Label, -1,  context:right ()-Shift-width ,  y_min-height ,context:right ()-Shift,y_min, 0 );	
	 
	 
	  Text=  win32.formatNumber(min, false, source:getPrecision());
	 width, height = context:measureText (25, Text, 0);
     context:drawText (25,  Text, Label, -1,  context:right ()-Shift-width ,  y_min ,context:right ()-Shift,y_min+height, 0 );	
	end
	
	 
 
   

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
		instance:updateFrom(0);	
		end
			  
	    
   
        
		return core.ASYNC_REDRAW ;
end
 


