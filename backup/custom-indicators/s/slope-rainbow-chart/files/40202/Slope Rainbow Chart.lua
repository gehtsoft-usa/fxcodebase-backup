-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23356

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
function Init()
    indicator:name("Slope Rainbow Chart");
    indicator:description("Slope Rainbow Chart");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 50);
	indicator.parameters:addString("Type", "Calculation Mode", "", "S");
    indicator.parameters:addStringAlternative("Type", "Simple Slope", "", "S");
    indicator.parameters:addStringAlternative("Type", "Linear Regression Slope", "", "L");
	
	indicator.parameters:addString("Mode", "Presentation Mode", "", "R");
    indicator.parameters:addStringAlternative("Mode", "Relativ", "", "R");
    indicator.parameters:addStringAlternative("Mode", "Absolute", "", "A");
	
	indicator.parameters:addBoolean("ON", "Use Averaging", "", false);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Type;
local Mode;
local first;
local source = nil;
local Indicator={};
local Raw={};
local Color={};
 local ON;
local Value={}; 
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+Period+1;
    ON = instance.parameters.ON;
	
	Mode= instance.parameters.Mode; 
	Type = instance.parameters.Type;
	
	 
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);
    if   (nameOnly) then
        return;
    end
  
	   for i = 2, Period, 1 do
	    Value[i] =instance:addInternalStream(0, 0);
		Indicator[i] =instance:addInternalStream(0, 0);
	    Raw[i] =instance:addInternalStream(0, 0);  
		Color[i] =instance:addInternalStream(0, 0);   	    
		end
    
	
	instance:ownerDrawn(true);

end


function Calculation (i, period)
   
	
            if Type == "S" then
				Value[i][period] =(source[period]-source[period-i])/(period-(period-i));
			 else	
				Value[i][period] = mathex.lregSlope (source, period-i+1, period)
			 end	
			 
		if Mode== "R" then 	 
			 
			 local min, max  = mathex.minmax (Value[i], period-Period+1, period);
			 
			 if max < 0 then 
			 max=0;
			 end
			 
			  if min  > 0 then 
			 min =0;
			 end
			 
			 local Scale = math.max((0-min), max);
			 
			 local Percent =Scale/100;
			 
			 
			Indicator[i][period] = ((Value[i][period] / Percent)+100)/2;
		else
		
		    if Value[i][period] > 0 then
			 Indicator[i][period] = 100;
			 elseif Value[i][period] < 0 then
			 Indicator[i][period] = 0;
			 else
			  Indicator[i][period] = 50;
			 end
        
        end		
			 
	
	 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    if period < first then
	return;
	end

   	for i = 2, Period, 1 do
	   Calculation(i, period); 	
	end	

	
	
	if period < source:size()-2 
	or period < first 
	then
	return;
	elseif period == source:size()-2  
	then	
		for i = first, source:size()-3 , 1 do
		 Averaging (0, 100, 1, Period, i);		
		end
	elseif  period == source:size()-1 then 
	   
	   for i = source:size()-2, source:size()-1 , 1 do
	  	Averaging (0, 100, 1, Period, i);		
		end 
	
	end
     
end
 
function Draw(stage, context)
    if stage~= 2 then
	return;
	end
	 
	local i;	
	
	local First= math.max(first, context:firstBar ());
	local Last= math.min(source:size()-1, context:lastBar ());
	
 
	local yCell = (context:bottom () -context:top ()) /Period
	
	for i = 2, Period, 1 do
	    y1= context:bottom () -(i)*yCell;
		y2= context:bottom () -(i-1)*yCell;
	    for period = First, Last, 1 do		   
        
		
			x, x1, x2 = context:positionOfBar (period);			
		    color1 = Color[i][period]
			color2 =Color[i][period]
			color3 = Color[i][period]
			color4 = Color[i][period]
		    context:drawGradientRectangle (x1, y1, color1, x2, y1, color2, x2, y2, color3, x1, y2, color4);
		end
	end
	
end

function Averaging (min, max, FIRST, LAST, period)


   local i;	
   FIRST=FIRST+1;
  
	
	for i = FIRST, LAST , 1 do
	local count = 0;
	   
	            Raw[i][period] =  Indicator[i] [period];   --5
				count=count+1;
			 
			 
		if ON   then	 
				if i > FIRST then
				Raw[i][period] = Indicator[i-1] [period];  -- 2
				count=count+1;
				end
				
				if i < LAST then
				Raw[i][period] = Indicator[i+1] [period];  --8
				count=count+1;
				end
		
				if period < source:size()-1 then
				       
					   Raw[i][period] =  Raw[i][period] + Indicator[i] [period+1];   --6
						count=count+1;
					 
						if i > FIRST then
						Raw[i][period] =Raw[i][period] + Indicator[i-1] [period+1];  -- 3
						count=count+1;
						end
						
						if i < LAST then
						Raw[i][period] =Raw[i][period] + Indicator[i+1] [period+1];  --9
						count=count+1;
						end
				end
				if period > first then
				
						 Raw[i][period] =  Raw[i][period] + Indicator[i] [period-1];   --4
						count=count+1;
					 
						if i > FIRST then
						Raw[i][period] =Raw[i][period] + Indicator[i-1] [period-1];  -- 1
						count=count+1;
						end
						
						if i < LAST then
						Raw[i][period] =Raw[i][period] + Indicator[i+1] [period-1];  --7
						count=count+1;
						end
				end
	    
		  Raw[i][period] = Raw[i][period] / count;
		
		end
		  if Raw[i][period] == nil then
		  return;
		  end
		  
		  Color[i][period] = Coloring (Raw[i][period], 50);	   
	end


end


function Coloring (value, mid)

 local color;

 if value <= mid then
 color = core.rgb(255 * (value / mid), 255, 0) 
 else 
 color = core.rgb(255, 255 - 255 * ((value - mid) / mid), 0)
 end
 

return  color;

end

