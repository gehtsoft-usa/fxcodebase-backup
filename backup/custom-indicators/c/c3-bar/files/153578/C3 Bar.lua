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
    indicator:name("C3 Bar");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addBoolean("Engulf", "Engulf High/Low", "", false); 	
    indicator.parameters:addBoolean("Signal", "Signal Mode", "", false); 
	
	indicator.parameters:addGroup("Line Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
   indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);	
	indicator.parameters:addColor("color", "Bar Color", "", core.rgb(0, 0, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local Signal        ;	
local first;
local source = nil; 
local Indicator;
local Bar;	
local up, down;
-- Routine
 function Prepare(nameOnly)   
  
	source = instance.source
	
	Signal=instance.parameters.Signal; 
	Engulf=instance.parameters.Engulf;
 
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
    Bar = instance:addStream("Bar", core.Bar, name, "Bar", instance.parameters.color, first );
    Bar:setPrecision(math.max(2, instance.source:getPrecision())); 
    Bar:addLevel(0);	
	else
    Bar = instance:addInternalStream(0, 0);	
	end
	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top , instance.parameters.clrDN, 0);
 
end


function Update(period, mode)

    up:setNoData(period);
    down:setNoData(period);
	 
	
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
	
	
	if BullCondition
	then
	    Bar[period]= 1;
		if Bar[period-1]~= 1 then
		up:set(period, source.low[period] , "\217");	
		end
	elseif BearCondition
    then	
	
	    Bar[period]= -1; 
	    if Bar[period-1]~= -1 then 
        down:set(period, source.high[period] , "\218");	
		end
		
	Bar[period]= -1;
    else
	Bar[period]= 0;	
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