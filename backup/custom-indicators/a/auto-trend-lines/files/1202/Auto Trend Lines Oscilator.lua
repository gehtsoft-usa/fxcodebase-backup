
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=647&sid=08ab4875f1b7dcdac5560651dde3697d&start=50

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

    indicator:name("Trend Lines");
    indicator:description("Trend Lines");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addInteger("tolerated", "Tolerated", "Tolerated", 0,0, 250);
	indicator.parameters:addInteger("frame", "Frame Size", "Frame Size", 100,6,750);
	indicator.parameters:addInteger("cd", "Convergence Divergence", "Convergence Divergence", 50,0,100);
	
	
	indicator.parameters:addString("Whole", "Test Whole Frame", "Whole Y/N" , "No");
    indicator.parameters:addStringAlternative("Whole", "Test Whole Yes", "Whole Yes" , "Yes");
	indicator.parameters:addStringAlternative("Whole", "Test Whole No", "Whole No" , "No");
	
	indicator.parameters:addString("Pfractal", "Fractal", "Fractal Y/N" , "Yes");
    indicator.parameters:addStringAlternative("Pfractal", "Fractal Yes", "Fractal Yes" , "Yes");
	indicator.parameters:addStringAlternative("Pfractal", "Fractal No", "Fractal No" , "No");
	
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("top_color", "Color of Top", "Color of Top", core.rgb(0, 255, 0));
    indicator.parameters:addColor("bottom_color", "Color of Bottom", "Color of Bottom", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);


end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first = nil;
local source = nil;
local line_id = 1;
local width, style;
--Variable
local upy = nil;
local downy = nil;
local frame = nil;
local last_period = -1;
local tolerated=0;
local Pfractal;
local HighLowClose=nil;
local Whole=nil;
local cd=0;
local size =nil;
local compare_source_high;
local compare_source_low;


-- Routine
function Prepare(nameOnly)
    width = instance.parameters.width;
	style = instance.parameters.style;
    frame = instance.parameters.frame;	 
	tolerated = instance.parameters.tolerated;
	Pfractal = instance.parameters.Pfractal;
	Whole=instance.parameters.Whole;
	cd=(instance.parameters.cd);
	cd=cd/100;
	
    source = instance.source;
    first = source:first();
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. frame .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    upy = instance:addInternalStream(0, 0);
    downy = instance:addInternalStream(0, 0);

	
    
	
	size =source:size(period);

	end

-- calculate fractals
function fractal(p)
    upy[p] = 0;
    downy[p] = 0;

    curr = source[p - 2];

    if (curr >= source[p - 4] and curr >= source[p - 3] and
        curr >= source[p - 1] and curr >= source[p]) then
        upy[p - 2] = source[p-2];
    end

    curr = source[p - 2];
    if (curr <= source[p - 4] and curr <= source[p - 3] and
        curr <= source[p - 1] and curr <= source[p]) then
        downy[p - 2] = source[p-2];
    end

    upy[p - 1] = 0;
    downy[p - 1] = 0;
    upy[p] = 0;
    downy[p] = 0;
end

-- get line equation coefficients
function getline(x1, y1, x2, y2)
    local a, b;

    a = ((y2 - y1) / (x2 - x1));
    b = (y1 - a * x1);
    return a, b;
end

-- draws line based on two fractals 
function drawline(x1, y1, x2, y2, color)

 local date1=0;
 local date2=0;
 date1 = source:date(x1);
 date2 = source:date(x2);

core.host:execute("drawLine", line_id, date1, y1, date2, y2, color,style, width);
    line_id = line_id + 1;
	
		
end

-- find last two up and down fractals


-- find last two up and down fractals
function Draw(period, frame)
    local i=0;
	local j=0;
	

	
	  -- ng: remove string comparison out of two loops
   

    if Whole == "Yes" then
        whole = true;
    else
        whole = false;
    end
	
	

        compare_source_high = source;
        compare_source_low = source;
   
	
	
			for i=period-frame+1, period-1,1 do  
			  
			         
					   if upy[i]~=0   then
						   for j=i+1, period,1 do
						   Process(true, i, j);
						   end
					   end	    
                       if downy[i]~=0   then
						   for j=i+1, period,1 do
						   Process(false,i, j);				   
						   end
               		   end			
			end	
end

function Process(Flag,i, j)
local x=0;
local a=0;
local b=0;
local tu=0;
local k1=0;	 
local Data;
local  compare_source;	
local Color; 
local period = source:size()-2

					if Flag then
					Data=upy;
					compare_source=compare_source_high;
					Color=instance.parameters.top_color;
					else
					Data=downy;
					compare_source=compare_source_low;
					Color=instance.parameters.bottom_color;
					end
					
			if Data[j]==0   then	 
			return;
			end
			 	
		     												 
			 a,b = getline(i,Data[i], j,Data[j]); 
			 
 								
												   
											if (a==0 or b==0) then
											return;
											end
								
											
											
											            if whole then 
										                x=period-frame;
										                else
														x=i;
														end   
														
														
													if Flag then	
															
														 for x = x, period, 1 do													 
															 
															   
																if compare_source[x] >  a * x + b  then
																		tu = tu + 1;
																end
																
																if  tu > tolerated then
 															  return;
															   end
														end
													else
													       for x = x, period, 1 do	
														   
														       
																 
																if compare_source[x] <  a * x + b  then
																		tu = tu + 1;
																end	
																
																  if  tu > tolerated then
 															   return;
															   end 
														end
                                                    end													

		   										  if tu > tolerated then
												  return;
												  end
														
														    k1= a* period + b;
														  
															 if  ( math.abs(k1 -source[period])/math.abs(Data[i] - source[period]) )< 1/cd then
															 drawline(i, Data[i], period, k1, Color);
															 end
													 	 
												
													
													  tu=0; a=0; b=0; 
												 						
end


local last_period = nil;
	
	
function Update(period)

   
    if period < source:first() then
	return;
	end
 
    local size = source:size();

    if Pfractal == "Yes" then
        if period < 6 then
		return;
		end
            fractal(period);
       
    else
        
        if period < size - frame then
		return;
		end
            upy[period] = source[period];
            downy[period] = source[period];
       

    
    end
  
    if source:size() < frame or period ~= source:size() - 1 then
	return;
	end
      
        if last_period ~= nil and last_period == source:serial(period) then        
            return ;
        end
        last_period = source:serial(period);
       
        period = period - 1;
        core.host:execute("removeAll");
   

    if period == source:size()-2 then   
        Draw(period, frame);
    end
end	