-- Id: 23443
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67185

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

function Init()
    indicator:name("Probability of Reversal");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");  
 
    indicator.parameters:addInteger("Period", "Period", "Use -1 to fetch all", -1);
	
	indicator.parameters:addString("Method", "Method", "Method" , "Delta");
    indicator.parameters:addStringAlternative("Method", "Up", "Up" , "Up");
    indicator.parameters:addStringAlternative("Method", "Down", "Down" , "Down");
	indicator.parameters:addStringAlternative("Method", "Both", "Both" , "Both");
	indicator.parameters:addStringAlternative("Method", "Delta", "Delta" , "Delta");
	
	indicator.parameters:addInteger("BoxSize", "Size of price box in pips", "", 50);
	
 	indicator.parameters:addBoolean("Reversal", "Reversal", "", false);
	
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addInteger("NumberOfPoints", "Number of points", "Number of points to display histogram", 200); 
	indicator.parameters:addDouble("transparency", "Transparency", "Transparency", 50); 
	
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local BoxSize;
local Period;
local first;
local source = nil;
local NumberOfPoints,  transparency;
local Last; 
local Up_TPO;
local Down_TPO;
local Method;
local Up_max = 0;
local Down_max = 0;
local Up, Down;
local Reversal;
-- Routine
 function Prepare(nameOnly)   
 
    Period= instance.parameters.Period;
	
	
	local Parameters= Period ;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
	Method = instance.parameters.Method;
	
	BoxSize = instance.parameters.BoxSize;
    NumberOfPoints = instance.parameters.NumberOfPoints;
	transparency = instance.parameters.transparency;
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Reversal = instance.parameters.Reversal;
    
			
    source = instance.source;
    first=source:first();
  
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
   -- Indicator[1] = core.indicators:create(Method1, source[Price1], Period1);
  
	 
    instance:setLabelColor(instance.parameters.Up);
   instance:ownerDrawn(true);
   
            Up_TPO = {};
			Down_TPO = {};
            Up_max = 0;
			Down_max=0;
	
end

-- Indicator calculation routine
function Update(period, mode)

 
    if source:serial(source:first()) ~= Init then
		    Up_TPO = {};
			Down_TPO = {};
            Up_max = 0;
			Down_max=0;
			
		  Init=source:serial(source:first()) ;
		 end
		 
		 if Period == -1 then
		 
			 if period <= source:size()-2 then			
			 Calculate(period);
			 Last = source:serial(period);	
			 elseif  Last ~=  source:serial(period-2) and period-2 == source:size()-2 then	
			 Last = source:serial(period-2);	 	
			  Calculate(period-2);		 
			 end
		elseif Period  ~= -1  and period <= source:size()-2 then
		
		    if period >=  source:size()-2 -Period+1 then			
			 Calculate(period);
			 Last = source:serial(period);	
			 elseif  Last ~=  source:serial(period-2)  and period-2 == source:size()-2 then	
			 Last = source:serial(period-2);	 	
			  Calculate(period-2);		 
			 end
		 
		end		
				  
end


local init = false;


function Draw (stage, context)

    if stage  ~= 2 then
	return;
	end		
	
	 
	NumberOfPoints = instance.parameters.NumberOfPoints; 
	
	if not init then
	init=true;
	context:createPen (1, 1, 1, Up);
	context:createSolidBrush (2, Up);
	
	context:createPen (3, 1, 1, Down);
	context:createSolidBrush (4, Down);
	Transparency= context:convertTransparency (instance.parameters.transparency)
	end
	
	local Box= context:priceWidth (0, BoxSize*source:pipSize());
	
	if Method == "Up" then
		for k, v in pairs(Up_TPO) do
		 
		 
		length = (v / Up_max) * NumberOfPoints;
        
		
		visible, y1 = context:pointOfPrice (k * source:pipSize());
		visible, y2 = context:pointOfPrice (k * source:pipSize());	
		x1= context:right ()-length;
		x2= context:right ();
		context:drawRectangle (-1, 2, x1, y1 , x2, y2-Box,Transparency)
		end
	
	elseif Method == "Down" then
	    for k, v in pairs(Down_TPO) do
 
		 length = (v / Down_max) * NumberOfPoints; 
		 
		visible, y1 = context:pointOfPrice (k * source:pipSize());
		visible, y2 = context:pointOfPrice (k * source:pipSize());	
		x1= context:right ()-length;
		x2= context:right ();
		context:drawRectangle (-1, 4, x1, y1  , x2, y2-Box,Transparency)
		end
	elseif Method == "Both" then
	    local Start={};
        for k, v in pairs(Up_TPO) do
		 
		length = (v / Up_max) * NumberOfPoints; 
		 
		visible, y1 = context:pointOfPrice (k * source:pipSize());
		visible, y2 = context:pointOfPrice (k * source:pipSize());			
		x1= context:right ()-length;
		x2= context:right ();
		Start[k]=x1;
		context:drawRectangle (-1, 2, x1, y1 , x2, y2-Box,Transparency)
		end
		
		 for k, v in pairs(Down_TPO) do
		 
		length = (v / Down_max) * NumberOfPoints; 
		 
		visible, y1 = context:pointOfPrice (k * source:pipSize());
		visible, y2 = context:pointOfPrice (k * source:pipSize());		
			if Start[k]~= nil then		
			x1= Start[k]-length;
			x2= Start[k];
			else
			x1= context:right ()-length;
			x2= context:right ();
			end
		context:drawRectangle (-1, 4, x1, y1 , x2, y2-Box,Transparency)
		end
	else
	
	
	    local Start={};
        for k, v in pairs(Up_TPO) do
		 
		length = (math.abs(v) / Up_max) * NumberOfPoints; 
		 
		visible, y1 = context:pointOfPrice (k * source:pipSize());
		visible, y2 = context:pointOfPrice (k * source:pipSize());			
		x1= context:right ()-length;
		x2= context:right ();
		Start[k]=x1;
			if v > 0 then
			context:drawRectangle (-1, 2, x1, y1 , x2, y2-Box,Transparency)
			else
			context:drawRectangle (-1, 4, x1, y1 , x2, y2-Box,Transparency)
			end
		end
		
		
	
	end

end	 

function Calculate (period)
        local open;
        open = source.open[period] / source:pipSize();
        open = open - open % BoxSize;
		
		
		
		if Method == "Delta" then
		
		           local v = rawget(Up_TPO, open);
					if v == nil then
						v = 0;
					end
					
					
					if  Reversal then 
					
					      if source.close[period]> source.open[period] 
						  and source.close[period-1]< source.open[period-1] 
						  then
							v = v + 1;
							end
							
							if source.close[period]< source.open[period]
							and source.close[period-1]> source.open[period-1] 
							then
							v = v - 1;
							end
					
					else
					
					
							if source.close[period]> source.open[period] then
							v = v + 1;
							end
							
							if source.close[period]< source.open[period] then
							v = v - 1;
							end
					end
					
					if math.abs(v) > Up_max then
						Up_max = math.abs(v);
					end
					
					local v = rawset(Up_TPO, open, v);
		
		
		else
		
					
					
					local v = rawget(Up_TPO, open);
					if v == nil then
						v = 0;
					end
					
				    if Reversal then 
					    if source.close[period]> source.open[period] 
						and source.close[period-1]< source.open[period-1] 
						then
						v = v + 1;
						end
						
					else
					
						if source.close[period]> source.open[period] then
						v = v + 1;
						end
					end
					
					
				
						if v > Up_max then
							Up_max = v;
						end
				 
					
					local v = rawset(Up_TPO, open, v);
					
					
					local v = rawget(Down_TPO, open);
					if v == nil then
						v = 0;
					end
					if Reversal  then
						if source.close[period]< source.open[period]
						and  source.close[period-1]> source.open[period-1]
						then
						v = v + 1;
						end
					else
					   if source.close[period]< source.open[period] then
						v = v + 1;
						end
					end
					
					if v > Down_max then
						 Down_max = v;
					end
					
					local v = rawset(Down_TPO, open, v);
		
		
		end
    
				
end

