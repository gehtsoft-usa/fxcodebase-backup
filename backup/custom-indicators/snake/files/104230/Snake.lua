
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63027

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
    indicator:name("Snake");
    indicator:description("Snake");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Snake_HalfCycle", "Snake_HalfCycle", "Snake_HalfCycle", 5);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Snake_Buffer_color", "Color of Snake_Buffer", "Color of Snake_Buffer", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Snake_HalfCycle;

local first;
local source = nil;
--local LWMA;
-- Streams block
local Snake_Buffer = nil;

-- Routine
function Prepare(nameOnly)
    Snake_HalfCycle = instance.parameters.Snake_HalfCycle;
	
    source = instance.source;
    first = source:first()+Snake_HalfCycle;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Snake_HalfCycle) .. ")";
    instance:name(name);

	if   (nameOnly) then
        return;
    end
    
        Snake_Buffer = instance:addStream("Snake_Buffer", core.Line, name, "Snake_Buffer", instance.parameters.Snake_Buffer_color, first);
		Snake_Buffer:setWidth(instance.parameters.width);
        Snake_Buffer:setStyle(instance.parameters.style);
     
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)


    if period < first or not  source:hasData(period) then
	return;
	end
	
local  i, j, w;
local    Snake_Sum=0.0;
local    Snake_Weight=0.0;
 
  if period < source:size()-1 -Snake_HalfCycle then 
  Snake(period);  
  else	  
	  for i= 0, Snake_HalfCycle, 1 do 
	  Snake(period-i);
	  end
   end
  
end


function Snake( Pos)
         
	  Snake_Buffer[Pos]=SnakeFirstCalc(Pos);
	 
end



function  SnakePrice(  Shift)
  return((2*source.close[Shift]+source.high[Shift]+source.low[Shift])/4);
end
 
function SnakeFirstCalc( Shift)
 
local  i, j, w;
local    Snake_Sum=0.0;
local    Snake_Weight=0.0;

   if((source:size()-1 -Shift)<=Snake_HalfCycle) then
    
      i=0;
      w=Shift-Snake_HalfCycle;
      while(w<=Shift) do
       
         i=i+1;
         Snake_Sum=Snake_Sum+i*SnakePrice(w);
         Snake_Weight=Snake_Weight+i;
         w=w+1;
      end
	  
      while(w<=source:size()-1) do
     
         i=i-1;
         Snake_Sum=Snake_Sum+i*SnakePrice(w);
         Snake_Weight=Snake_Weight+i;
         w=w+1;
      end
   
   else
    
      Snake_Sum_Minus=0.0;
      Snake_Sum_Plus=0.0;
	  
	  j=Shift+Snake_HalfCycle
	  i=Shift-Snake_HalfCycle
	  w=1;
      while (true) do
	 
 
          if w> Snake_HalfCycle then
		  break;
		  end
     
         Snake_Sum=Snake_Sum+w*(SnakePrice(i)+SnakePrice(j));
         Snake_Weight=Snake_Weight+2*w;
       		 
		  w=w+1;
		  j=j-1;
		  i=i+1;
      end
	  
      Snake_Sum=Snake_Sum+( Snake_HalfCycle+1)*SnakePrice(Shift);
      Snake_Weight=Snake_Weight+ Snake_HalfCycle+1;
      Snake_Sum_Minus=Snake_Sum_Minus+SnakePrice(Shift);
    end
   
   return(Snake_Sum/ Snake_Weight);

end