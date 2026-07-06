-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71582

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

-- The indicator corresponds to the Relative Strength Index indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 6 "Momentum and Oscillators" (page 133-134)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Dots");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    



    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Length", "Length","", 10, 1, 1000);
    indicator.parameters:addInteger("Filter", "Filter","", 0, 0, 1000);
    indicator.parameters:addDouble("Deviation", "Deviation","", 0, 0, 1000);	
    indicator.parameters:addDouble("Cycle", "Cycle","", 4, 0, 1000);	
	
    indicator.parameters:addGroup("Style");
	
   -- indicator.parameters:addInteger("Size", "Match Size","", 10);
	
    indicator.parameters:addColor("Up", "Up Color","", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Color","", core.rgb(255, 0, 0)); 
    indicator.parameters:addColor("Neutral", "Neutral Color","", core.rgb(0, 0, 255)); 
	
	indicator.parameters:addInteger("width", "Line width", "", 3, 1, 5); 
   
 
	
	
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Length, Filter,Deviation;

local first;
local source = nil;
local Line ;
 
 
local Coeff,Phase, Len,Cycle ; 
local g; 
-- Routine
function Prepare(nameOnly)
   
   
   Up= instance.parameters.Up;
   Down= instance.parameters.Down;
   Neutral= instance.parameters.Neutral;
   
   Length= instance.parameters.Length;
   Filter= instance.parameters.Filter;
   Deviation= instance.parameters.Deviation;
   Cycle= instance.parameters.Cycle;
  
    Coeff = 3 * math.pi;
    Phase = Length - 1;
    Len=Length*Cycle+Phase;   
 
    source = instance.source;
    first = source:first() +Length ;

    local name = profile:id() .. "(" .. source:name() .. ", " .. Length .. ", " .. Filter.. ", " .. Deviation .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
 
	Line = instance:addStream("Line1", core.Dot, "Up", "Up", Up, 0) 
	Line :setWidth(instance.parameters.width);  
	

	
	--instance:ownerDrawn(true);
end

	

-- Indicator calculation routine
function Update(period)
 
    if period < first then
	return;
    end	  
 
    --local MABuffer_prev=0;
	--local MABuffer=0;
 
      local Weight=0; Sum=0; t=0;
      local g,beta,alfa;
	  local trend=0;
	  
	  
      for i=0, Len-1, 1 do
    
		g=1.0/(Coeff*t+1);
		if(t<= 0.5) then g = 1; end
		
		beta = math.cos( math.pi * t);
		alfa = g * beta; 
	
 
				 Sum=Sum+alfa*source[period-i];
				 Weight=Weight+alfa;
				 if(t<1) then
				 t=t+1.0/(Phase-1);
				 elseif(t<Len-1) then		 
				 t=t+(2*Cycle-1)/(Cycle*Length-1);
				 end
      end
	  
      -- MABuffer_prev=MABuffer;
	  
      if(Weight>0) then Line[period]=(1.0+Deviation/100)*Sum/Weight; end
	  
 
    
      if (Line[period]-Line[period-1])/source:pipSize() >Filter then
	  trend=1; 
      elseif (Line[period]-Line[period-1])/source:pipSize() <-Filter then
	  trend=-1;
	  else
	  trend=0;	  
	  end
	  --if(MABuffer_prev-MABuffer>Filter*Point)
	  
	  if trend ==1  then
      Line:setColor(period, Up);  
	  elseif trend ==-1  then
      Line:setColor(period, Down);   
	  else
      Line:setColor(period, Neutral);  
	  end
 
    
end

--[[

local init = false;
 
function Draw(stage, context)
 
	  if stage~= 2 then
	  return;
	  end
	
       if not init then
         
            init = true;
			

				context:createFont (11, "Wingdings", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);

			
     end
	 
	 
 
	local Start = math.max(context:firstBar(), first );
	local End = math.min(context:lastBar(), source:size() - 1);
 

	for period = Start, End, 1 do --i
 
	x1, x, x = context:positionOfBar (period);
 
	
	width, height = context:measureText (11, "\174" ,  context.CENTER);
	
        if Line1[period]~= nil then
		visible, y1 = context:pointOfPrice (Line1[period]);
		context:drawText (11, "\174", Up, -1, x1-width/2, y1-height/2 , x1+width/2 , y1+height/2,  context.CENTER);
	    end
        if Line2[period]~= nil then	
    	visible, y1 = context:pointOfPrice (Line2[period]);		
		context:drawText (11, "\174", Down, -1, x1-width/2, y1-height/2 , x1+width/2 , y1+height/2,  context.CENTER);
	    end
	end
	 
end		
 

 ]]