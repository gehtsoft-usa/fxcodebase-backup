-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71092

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   Dogecoin : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+




-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Higher Time Frame Candle");
    indicator:description("Higher Time Frame Candle");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup(  "Calculation");	
 
    Add(1 ); 
 
	
	indicator.parameters:addGroup("Style");
	 indicator.parameters:addColor("Label", "Label Color", "Color of Label",core.COLOR_LABEL);
      indicator.parameters:addInteger("Size", "Font Size", "Font Size",10);
	  
	  indicator.parameters:addBoolean("Show", "Show Value", "", false);	
end
function Add(id )

    local TF={"m1", "m5","m15", "m30", "H1", "H2", "H3","H4", "H6", "H8", "D1", "W1", "M1"};
    indicator.parameters:addGroup(id .. ". Slot");	
	--indicator.parameters:addBoolean("On"..id, "Use This Slot", "", true);	
	
	indicator.parameters:addString("TF" .. id, "Time Frame", "", "D1");
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	
    

	 indicator.parameters:addColor("Color".. id, "Line Color", "Color of Line",core.COLOR_LABEL );
    
	
end 

 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Size, Label;
local first;
local source = nil;
local Source={};
local Number;
-- Streams block
 
local TF={};
local loading={};
 
local Color={};
local Show;
local Type;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	Size=  instance.parameters.Size;
	Label=  instance.parameters.Label;
	Show=  instance.parameters.Show;
	Type=  instance.parameters.Type;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    Number=0;
	
 
	 Number=Number+1;
	 TF[Number]=  instance.parameters:getString("TF" .. Number);	 
	 
	 Color[Number]=  instance.parameters:getColor("Color" .. Number);
     Source[Number]  = core.host:execute("getSyncHistory",  source:instrument(),  TF[Number], source:isBid(), 300, 2000 + Number , 1000 +Number);	 
 
   
	 loading[Number]  = true;  	 
 
	 core.host:execute ("setTimer", 1, 5);
	instance:ownerDrawn(true);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
end


local init = false;

function Draw (stage, context)

    if stage  ~= 2 then
	return;
	end
	 
	 
	local FLAG=false; 

    for j = 1, Number, 1 do
		     
                if loading[j] then
				FLAG= true;			
				end
				 
	end    
    
	
	if FLAG then
	return;	 
	end
 
	 
  
      context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
    if not init then
	init =true;
		for i= 1, Number, 1 do
		context:createPen (i, context.SOLID, 1, Color[i])
		end
		context:createFont (Number+1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
	end
	local Shift=0;
	local Value;
	local  i= 1;
			
			
		
			
			local Text= "Open";
			local Value=Source[Number].open[Source[Number]:size()-1]
			
			
			visible, y= context:pointOfPrice (Value);
			context:drawLine (i, context:left (), y,context:right (), y);
			
			if Show then
			Text= Text .. " : " .. string.format("%." .. source:getPrecision() .. "f", Value);
			end
			
			width, height = context:measureText (Number+1, Text, 0);
			Shift=Shift+width;
			context:drawText (Number+1, Text, Label, -1, context:right()-Shift, y-height, context:right()-Shift +width, y, 0);
			
			
			
				local Text= "Close";
			local Value=Source[Number].close[Source[Number]:size()-1]
			
			
			visible, y= context:pointOfPrice (Value);
			context:drawLine (i, context:left (), y,context:right (), y);
			
			if Show then
			Text= Text .. " : " .. string.format("%." .. source:getPrecision() .. "f", Value);
			end
			
			width, height = context:measureText (Number+1, Text, 0);
			Shift=Shift+width;
			context:drawText (Number+1, Text, Label, -1, context:right()-Shift, y-height, context:right()-Shift +width, y, 0);
			
				local Text= "High";
			local Value=Source[Number].high[Source[Number]:size()-1]
			
			
			visible, y= context:pointOfPrice (Value);
			context:drawLine (i, context:left (), y,context:right (), y);
			
			if Show then
			Text= Text .. " : " .. string.format("%." .. source:getPrecision() .. "f", Value);
			end
			
			width, height = context:measureText (Number+1, Text, 0);
			Shift=Shift+width;
			context:drawText (Number+1, Text, Label, -1, context:right()-Shift, y-height, context:right()-Shift +width, y, 0);
			
			
	      		local Text= "Low";
			local Value=Source[Number].low[Source[Number]:size()-1]
			
			
			visible, y= context:pointOfPrice (Value);
			context:drawLine (i, context:left (), y,context:right (), y);
			
			if Show then
			Text= Text .. " : " .. string.format("%." .. source:getPrecision() .. "f", Value);
			end
			
			width, height = context:measureText (Number+1, Text, 0);
			Shift=Shift+width;
			context:drawText (Number+1, Text, Label, -1, context:right()-Shift, y-height, context:right()-Shift +width, y, 0);
			
			
			
			local Text= "Median";
			local Value=Source[Number].median[Source[Number]:size()-1]
			
			
			visible, y= context:pointOfPrice (Value);
			context:drawLine (i, context:left (), y,context:right (), y);
			
			if Show then
			Text= Text .. " : " .. string.format("%." .. source:getPrecision() .. "f", Value);
			end
			
			width, height = context:measureText (Number+1, Text, 0);
			Shift=Shift+width;
			context:drawText (Number+1, Text, Label, -1, context:right()-Shift, y-height, context:right()-Shift +width, y, 0);
	
end	


function AsyncOperationFinished(cookie)

local j;
local FLAG=false; 
local Num=0; 
    for j = 1, Number, 1 do
		   
			  if cookie == (1000 + j) then
			  loading[j]  = true;
		      elseif  cookie == (2000 + j ) then
			  loading[j]  = false;     
			  end
		 
		       
                 if loading[j] then
				 FLAG= true;
				 Num=Num+1;
				 end
	end    
   

	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Number) - Num) .. " / " .. (Number) );	 
	else
	core.host:execute ("setStatus", "Loaded");
	instance:updateFrom(0);
	end
   
        
    return core.ASYNC_REDRAW ;
	
end


