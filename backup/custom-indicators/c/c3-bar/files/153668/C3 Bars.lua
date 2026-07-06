-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74411 

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("C3 Bars");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addBoolean("Engulf", "Engulf High/Low", "", false); 
    indicator.parameters:addBoolean("Signal", "Signal Mode", "", false); 
	
	indicator.parameters:addGroup("Line Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
   indicator.parameters:addColor("Up", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("Down",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);	
	indicator.parameters:addColor("Bull", "Bull Bar Color", "", core.rgb(255, 128, 0)); 
	indicator.parameters:addColor("Bear", "Bear Bar Color", "", core.rgb(255, 128, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local first;
local source = nil; 
local Indicator;
local Bar;	
local Up, Down;
-- Routine
 function Prepare(nameOnly)   
  
	source = instance.source 
	Engulf=instance.parameters.Engulf;
	Signal=instance.parameters.Signal;
	
	Bull=instance.parameters.Bull;
	Bear=instance.parameters.Bear;
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	 
	first=source:first();  
	
	High=source.high;
	Low=source.low;
	Close=source.close;
	Open=source.open;	
	
 

	
	if Signal then
    Bar = instance:addStream("Bar", core.Bar, name, "Bar", core.COLOR_LABEL, first );
    Bar:setPrecision(math.max(2, instance.source:getPrecision())); 
    Bar:addLevel(0);	
	else
    Bar = instance:addInternalStream(0, 0);	
	end 
	
	open = instance:addStream("open", core.Line, name, "", core.COLOR_LABEL, first);
    high = instance:addStream("high", core.Line, name, "", core.COLOR_LABEL, first);
    low = instance:addStream("low", core.Line, name, "", core.COLOR_LABEL, first);
    close = instance:addStream("close", core.Line, name, "", core.COLOR_LABEL, first);
    instance:createCandleGroup("Candle", "Candle", open, high, low, close);		
 
end


function Update(period, mode)
 
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];	 
	
	if period <= first
	or not  source:hasData(period)
	then
	return;
	end
	  
    if Close[period] > Open[period] 
	and Close[period-1] < Open[period-1] 
	and Close[period-2] > Open[period-2] 
	and Close[period] > Open[period-1]
	and (Engulf and Close[period] > High[period-1] or not Engulf )	
	then
	BullCondition = true;
	else
	BullCondition = false; 
    end	
 
            
    if Close[period] < Open[period] 
	and Close[period-1] > Open[period-1] 
	and Close[period-2] < Open[period-2]  
    and Close[period] < Open[period-1]	
	and (Engulf and Close[period] < Low[period-1] or not Engulf )		
	then
	BearCondition = true;
	else
	BearCondition = false;
    end	
	
 
		--open:setColor(period,  Up);  
		--open:setColor(period, Down);
 
	   

	if BullCondition
	then
	    Bar[period]= 1;
		if Bar[period-1]~= 1 then
		    open:setColor(period,  Bull); 
		else
		    Regural(period);
		end
	elseif BearCondition
    then	
	
	    Bar[period]= -1; 
	    if Bar[period-1]~= -1 then 
            open:setColor(period,  Bear); 
		else
		    Regural(period);			
		end
		
	Bar[period]= -1;
    else
	Bar[period]= 0;	
	
	 
		    Regural(period);	
	end			
	
	
end

function Regural(period)

   if source.close[period]  > source.open[period] then
            open:setColor(period,  Up);  
   else
            open:setColor(period,  Down);    
   end
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+