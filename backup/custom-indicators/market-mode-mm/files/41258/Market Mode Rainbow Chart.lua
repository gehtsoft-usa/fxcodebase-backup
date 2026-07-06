-- Id: 7556
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=24002

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
    indicator:name("Market Mode Rainbow Chart");
    indicator:description("Market Mode Rainbow Chart");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Rainbow Chart Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 50);

	indicator.parameters:addGroup("Indicator Calculation");
    indicator.parameters:addDouble("D", "Delta", "Delta", 0.1);
    indicator.parameters:addDouble("F", "Fract", "Fract", 0.25);
	
	

	indicator.parameters:addGroup("Style");
    --indicator.parameters:addInteger("width", "width", "width", 2);
	indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "No Trend Color", "", core.rgb(255, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local D,F;
local first;
local source = nil;
local MA={};

-- Streams block
local Out={};
local Color={};

 
local Mode={};
local High={};
local Low={};
 
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
  
	D= instance.parameters.D;
	F= instance.parameters.F;
	
	  local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(D).. ", " .. tostring(F) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("MM") ~= nil, "Please, download and install MM.LUA indicator");
	
	local i;
	 first = source:first();
	 
	for i = 2, Period, 1 do	
	MA[i] = core.indicators:create("MM", source , i,D,F);
	
	Mode[i] = MA[i]:getStream(0);
	High[i] = MA[i]:getStream(1);
	Low[i] = MA[i]:getStream(2);
	
	first = math.max(first, Mode[i]:first(), High[i]:first(), Low[i]:first());
	end
	

  

   
	   for i = 2, Period, 1 do
		Color[i] =instance:addInternalStream(0, 0); 
		end
   
	
	instance:ownerDrawn(true);
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



-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not source:hasData(period) then
	return;
	end
	
	local i;	
	
	for i = 2, Period, 1 do 
	   MA[i]:update(mode);  
	end	
	
	for i = 2, Period , 1 do
	
		 
	      if Mode[i][period]  > High[i][period] then		 		  
		  Color[i][period] = instance.parameters.Up;
		  elseif Mode[i][period]  < Low[i][period] then		 		  
		  Color[i][period] =instance.parameters.Down;
		  else
		  Color[i][period] =instance.parameters.No;
		  end
	 
	
	end
	
	
end


 