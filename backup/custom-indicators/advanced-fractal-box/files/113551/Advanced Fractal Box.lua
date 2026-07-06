-- Id: 18686
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64919&p=113551#p113551

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Advanced Fractal Box");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Frame", "Number of fractals (Odd)", "Number of fractals (Odd)", 5, 5,99);
	indicator.parameters:addBoolean("ReCalculate", "Re-Calculate", "", true);  

    indicator.parameters:addGroup("Style");
	
	indicator.parameters:addColor("Color1", "Color of Since Up", "Color of Since", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style1", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("Color2", "Color of Since Down ", "Color of Since", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style2", core.FLAG_LINE_STYLE);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;
local SignalUp, SignalDown;
local  SignalUp, SignalDown;
local Up, Down;
local ReCalculate;
-- Routine
function Prepare(nameOnly)
  
    source = instance.source;
	
	
	frame=instance.parameters.Frame
	ReCalculate=instance.parameters.ReCalculate;
  	
  		 if math.mod(frame, 2) ~= 0 then
		 frame=frame+1;
		 end
		 
		 
		 
    first=source:first()+frame;
	
	
	local name;
    name = profile:id() .. "( " .. source:name()  ..  " )";
    instance:name(name);
	
	
		 
	
	
    if (not (nameOnly)) then
	
	    SignalUp = instance:addInternalStream(0, 0);
		SignalDown = instance:addInternalStream(0, 0);


		Up = instance:addStream("Up", core.Line, name .. ".Since Up", "Since Up", instance.parameters.Color1, source:first());
		Up:setWidth(instance.parameters.Width1);
        Up:setStyle(instance.parameters.Style1);
		
		Down = instance:addStream("Down", core.Line, name .. ".Since Down", "Since Down", instance.parameters.Color2, source:first());
		Down:setWidth(instance.parameters.Width2);
        Down:setStyle(instance.parameters.Style2);
      
    end
end

local Last;
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

   if (period < first) then
   return;
   end
   

   
   
   ------------------------------------------------------------------------------------------------------------------
   
    local test=0;
   
	     local hof=frame;
	     local i;
	     local count=0;
	 
		 for  i= 1 , frame , 1 do
		 
			 if hof >1 then
			 hof= hof-2;
			 count = count +1;
			 else
			 count=count-1;
			 break;
			 end
		 
		 end 
 

	
	     local x = period - count*2;
		 
		 
   SignalUp[period]=0;
   SignalDown[period]=0;   
   SignalUp[period-count]=0;
   SignalDown[period-count]=0;
   
	
        local curr = source.high[period - count];
	
		
		
         for i= x, period, 1 do
		
		     if  curr > source.high[i] and i ~=(period - count) then
			 test=test+1;
			 end
			
		 end	
		 
		 if test == period-x then
		 SignalUp[period - count]=1;
		 end

        test=0;		 
       
	     curr = source.low[period - count];
		
		  
          for i= x , period, 1 do
		
		     if  curr < source.low[i] and i ~=(period -count) then
			 test=test+1;
			 end
			
		 end	
	   
	      if test ==period-x then	    
		  SignalDown[period - count]=1;
		  end
        

   
   -----------------------------------------------------------------------------------------------------------------
 

   
	
    local pT1, pT2, pB1, pB2 = findLast(period);
	
	if pT1 == nil 
	or pT2 == nil 
	or pB1 == nil 
	or pB2 == nil
	then
	return;
	end
	
	
	if not ReCalculate then
	Up[period]=Up[period-1];
	Down[period]=Down[period-1];
	Up[period]=source.high[pT2];
	Down[period]=source.low[pB2];
	else
	 core.drawLine(Up, core.range(pT1, pT2), source.high[pT1], pT1, source.high[pT1], pT2, instance.parameters.Color1);
	 core.drawLine(Down, core.range(pB1, pB2), source.low[pB1], pB1, source.low[pB1], pB2, instance.parameters.Color2);
	   
	 if period == source:size()-1 then
	 core.drawLine(Up, core.range(pT2, source:size()-1), source.high[pT2], pT2, source.high[pT2], source:size()-1, instance.parameters.Color1);
	 core.drawLine(Down, core.range(pB2, source:size()-1), source.low[pB2], pB2, source.low[pB2], source:size()-1, instance.parameters.Color2);
	 end
	end
end

 

function findLast(Start)

  local T1=nil;
  local T2=nil;
  local B1=nil;
  local B2=nil;
  
  for period= Start, first, -1 do
  
      if SignalUp[period]==1 and  T2==nil then
	  T2=period;
	  end
	  
	  if SignalUp[period]==1 and  T1==nil and T2~=nil and T2 ~= period then
	  T1=period;
	  end
	  
      if SignalDown[period]==1 and  B2==nil then
	  B2=period;
	  end
	  
	  if SignalDown[period]==1 and  B1==nil and B2~=nil and B2 ~= period then
	  B1=period;
	  end
	  
	  
	  if T1~= nil and T2~= nil 
	  and B1~= nil and B2~= nil 
	  then
	  break;
	  end
  end
  
  
  return T1, T2, B1, B2;
	
 end