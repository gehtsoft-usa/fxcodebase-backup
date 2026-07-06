-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63707
-- Id: 18207

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
    indicator:name("Periods since last Level visit");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
 
	indicator.parameters:addGroup("Calculation");
  
 	
	 indicator.parameters:addInteger("Period", "Period","", 10);
	 indicator.parameters:addInteger("Level", "Level","", 25);
	 
	indicator.parameters:addString("Type", "Overlay Type", "", "Average");
    indicator.parameters:addStringAlternative("Type", "Average", "", "Average");
    indicator.parameters:addStringAlternative("Type", "Level", "", "Level");
	 
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up,Down, Neutral;
local first;
local source = nil;
local Type, Level;

 
local Indicator;
local Period;


local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

 
local Value,MA;


function Prepare(nameOnly)

    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
	Type= instance.parameters.Type;
	Level= instance.parameters.Level;
	Period= instance.parameters.Period;
 
	source = instance.source;
	local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
    Value=  instance:addInternalStream(0, 0);	 
    MA=  instance:addInternalStream(0, 0);	 
	first= source:first();
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)
	
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
			if period < first then
			open:setColor(period, Neutral);	
			return;
			end
	


   Value[period]= Calculate(period);  
   
   
    if period < first + Period then
	return;
	end  
	
	
	
	
	if Type == "Average" then
	
	MA[period]= mathex.avg( Value, period-Period+1, period);
		 
	

	
		if  Value[period] > MA[period] then
		open:setColor(period,Up);	   
		elseif  Value[period] < MA[period]  then
		open:setColor(period,  Down);
		else
		open:setColor(period, Neutral);			
		end
	else
	
	    if  Value[period] > MA[period] then
		open:setColor(period,Up);
		else
		open:setColor(period,Down);
		end
		

    end	
		
				

		
 end
 
 function Calculate(Index)
 
   local Now=-1;

  for period= Index-1, first, -1 do
	  if source.close[Index]<=source.high[period]
	  and source.close[Index]>=source.low[period]
	  then
	  Now=period;
	  break;
	  end  
  end  
  if Now==-1 then
  return 0;
  else
  return Index-Now;
  end
end


