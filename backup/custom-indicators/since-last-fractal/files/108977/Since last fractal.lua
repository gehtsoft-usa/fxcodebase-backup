-- More information about this indicator can be found at:
-- http://fxcodebase.com/
-- Id: 16976

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Since last fractal");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);


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
-- Routine
function Prepare(nameOnly)
  
    source = instance.source;
    first=source:first()+6;
	
	
	local name;
    name = profile:id() .. "( " .. source:name()  ..  " )";
    instance:name(name);
	
	
    if (not (nameOnly)) then
	
	    SignalUp = instance:addInternalStream(0, 0);
		SignalDown = instance:addInternalStream(0, 0);


		Up = instance:addStream("Up", core.Line, name .. ".Since Up", "Since Up", instance.parameters.Color1, source:first());
    Up:setPrecision(math.max(2, instance.source:getPrecision()));
		Up:setWidth(instance.parameters.Width1);
        Up:setStyle(instance.parameters.Style1);
		
		Down = instance:addStream("Down", core.Line, name .. ".Since Down", "Since Down", instance.parameters.Color2, source:first());
    Down:setPrecision(math.max(2, instance.source:getPrecision()));
		Down:setWidth(instance.parameters.Width2);
        Down:setStyle(instance.parameters.Style2);
      
    end
end

local Last;
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

   if (period < 6) then
   return;
   end
   
   SignalUp[period]=0;
   SignalDown[period]=0;   
   SignalUp[period-2]=0;
   SignalDown[period-2]=0;
   
        local curr = source.high[period - 2];
        if (curr > source.high[period - 4] and curr > source.high[period - 3] and
            curr > source.high[period - 1] and curr > source.high[period]) then
            SignalUp[period-2]=1;        
        end
        curr = source.low[period - 2];
        if (curr < source.low[period - 4] and curr < source.low[period - 3] and
            curr < source.low[period - 1] and curr < source.low[period]) then
         
            SignalDown[period-2]=1;
      
        end
		
		
    local P1, P2 = findLast(period);
	
	if P1 == nil 
	or P2 == nil 
	then
	return;
	end
	
	Up[period]= period-P1;
	Down[period]= period-P2;
  
	
	if Last== math.max(P1,P2) then		
	return;
	end
	
	Last=math.max(P1,P2);
	
	ReCalculate(P1,P2,period);
	
	
end

function ReCalculate(P1, P2,End)


for period= math.min(P1,P2), End, 1 do 

    if period >= P1 then
    Up[period]=  period-P1;
	end
	if period >= P2 then
	Down[period]= period -P2;	
    end
 
end

end


function findLast(Start)

  local R1=nil;
  local R2=nil;
  
  
  for period= Start, first, -1 do
  
      if SignalUp[period]==1 and  R1==nil then
	  R1=period;
	  end
	  
	   if SignalDown[period]==1 and  R2==nil then
	   R2=period;
	  end
	  
	  if R1~= nil and R2~= nil then
	  break;
	  end
  end
  
  
  return R1, R2;
	
 end