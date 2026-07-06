-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2779

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Volume Pivots");
    indicator:description("Volume Pivots");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Lookback", "Lookback", "No description", 100, 10, 1000);
    indicator.parameters:addInteger("Number", "Number of Lines", "No description", 5, 1, 50);
	indicator.parameters:addBoolean("Fractals", "Climax High Volume", "", true);
	indicator.parameters:addBoolean("VShow", "Show Vertical Lines", "", true);
	indicator.parameters:addBoolean("HShow", "Show Horizontal Lines", "", true);
	
	indicator.parameters:addGroup("Style");

	
	indicator.parameters:addGroup("Volume Linked Vertical Lines");
	
	indicator.parameters:addColor("color10", "Max. Volume Line", "Color of Line", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width10", "Line width", "", 5, 1, 5);
    indicator.parameters:addInteger("style10", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style10", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color01", "Min. Volume Line", "Color of Line", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width01", "Line width", "", 5, 1, 5);
    indicator.parameters:addInteger("style01", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style01", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color11", "1. Zone Volume Line", "Color of Line", core.rgb(128, 128 ,128));
	indicator.parameters:addInteger("width11", "Line width", "", 5, 1, 5);
    indicator.parameters:addInteger("style11", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style11", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color21", "2. Zone Volume Line", "Color of Line", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width21", "Line width", "", 4, 1, 5);
    indicator.parameters:addInteger("style21", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style21", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color31", "3. Zone Volume Line", "Color of Line", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width31", "Line width", "", 3, 1, 5);
    indicator.parameters:addInteger("style31", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style31", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color41", "4. Zone Volume Line", "Color of Line", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width41", "Line width", "", 2, 1, 5);
    indicator.parameters:addInteger("style41", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style41", core.FLAG_LINE_STYLE);
	
 
	
	indicator.parameters:addColor("color51", "5. Zone Volume Line", "Color of Line", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width51", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style51", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style51", core.FLAG_LINE_STYLE);
	

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Lookback;
local Number;
local Fractals;
local VShow;
 local first;
local source = nil;
local C={};
local S={};
local W={};
-- Streams block
local Line = {};
local Last;
local Array={};
local Volume;
local HShow;
-- Routine
function Prepare(nameOnly)
    VShow= instance.parameters.VShow;
	HShow= instance.parameters.HShow;
    Lookback = instance.parameters.Lookback;
    Number = instance.parameters.Number;
	Fractals = instance.parameters.Fractals;
    source = instance.source;
    first = source:first();
	
	Volume = instance:addInternalStream(0, 0);

    local name = profile:id() .. "(" .. source:name() .. ", " .. Lookback .. ", " .. Number .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	for i = 1, Number , 1 do
	
			
				if  (5/Number)*i <= 1 and (5/Number)*i > 0 then
				 C[i]= instance.parameters.color11;
				 S[i]= instance.parameters.style11;
				 W[i]= instance.parameters.width11;
				end
			 if   (5/Number)*i <= 2 and (5/Number)*i > 1  then
			 C[i]= instance.parameters.color21;
			 S[i]= instance.parameters.style21;
			 W[i]= instance.parameters.width21;
			 end
			 
			 if   (5/Number)*i <= 3 and (5/Number)*i > 2  then
			C[i]= instance.parameters.color31;
			 S[i]= instance.parameters.style31;
			 W[i]= instance.parameters.width31;
			end
			
			if  (5/Number)*i <= 4  and (5/Number)*i > 3  then
			 C[i]= instance.parameters.color41;
			 S[i]= instance.parameters.style41;
			 W[i]= instance.parameters.width41;
			end
			if  (5/Number)*i <= 5 and (5/Number)*i > 4  then
			C[i]= instance.parameters.color51;
			 S[i]= instance.parameters.style51;
			 W[i]= instance.parameters.width51;
			end
	
	
	end
	
     instance:ownerDrawn(true);  
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)  
 
 local i;
  
	if period < source:size()-1 
	or source:serial(period) == Last
    or period < Lookback	
	then
			return;					
	end		
 
 	
    Last= source:serial(period);
		
	for i = source:size()-1 -Lookback, period, 1 do	
       Filter(i);
    end
	
	 Sort();
end

function Filter (period)
	
       
				
				 
						  	if Fractals then 
							
								
											if source.volume[period-2] <=  source.volume[period-1] and source.volume[period-1] >=  source.volume[period]
											and period ~= source:size()-1
											then
											  	Volume[period-1]= source.volume[period-1];
											else
											    Volume[period-1]= 0;
											end	
							 
							else
									
										Volume[period]= source.volume[period];
								
							end				
						
		 
end

function Sort()
	local max, maxpos, i;
		
	for i = 1, Number ,1 do	
	    Array[i] =0;
		max, maxpos = mathex.max (Volume, source:size()-1 -Lookback, source:size()-1);
		Array[i] =maxpos;
		Volume[maxpos]=0;
	end	
end		

 function Draw(stage, context)
    if stage~= 2 then
	 return;
	end

  local Flag= false;
  
  
  for i = 1 , Number, 1 do  
	  if Array[i] == nil 
	  or  Array[i] == 0  
	   then
	   Flag=true; 
	  end
 end
	if Flag== true then
    return;
    end	
	
	
	
	local color, style, width;
	
	 for i = 1 , Number, 1 do  
	
   		                                if i == 1 then
										 color=instance.parameters.color10 ;
										 width=instance.parameters.width10  ;
										 style=instance.parameters.style10  ;
										elseif i == Number then
										  color=instance.parameters.color01  ;
										  width=instance.parameters.width01  ;
										   style=instance.parameters.style01  ;
										else
										  color=C[i]  ;
										   width=W[i]  ;
										  style=S[i]  ;
										end
										
										
											 context:createPen(i, context:convertPenStyle (style), width, color); 
			                         
										
		end								
									
	
	
				         for i = 1 , Number, 1 do  
				
							   x, x1, x2 = context:positionOfBar (Array[i]);
							   visible, y =context:pointOfPrice (source.close[Array[i]])
				 
								 
								 
								 if VShow then
								 context:drawLine (i, x , context:top(), x , context:bottom());
								end
								  if HShow then 
								context:drawLine (i, context:left() , y, context:right() , y);
								end
						
						end
 end