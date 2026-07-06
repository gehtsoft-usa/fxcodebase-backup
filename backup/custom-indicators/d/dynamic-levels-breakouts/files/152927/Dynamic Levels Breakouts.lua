-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74251

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
    indicator:name("Dynamic Levels Breakouts");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("length", "Length", "", 20, 1, 2000);
	
	
    indicator.parameters:addBoolean("Consecutive", "Show Consecutive Signals", "", false); 	
    indicator.parameters:addBoolean("Signal", "Signal Mode", "", false); 
	
	indicator.parameters:addGroup("Arrow  Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
    indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);		
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "Max Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "Min Line Color", "", core.rgb(255, 0, 0)); 
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local length;  
	
-- Routine
 function Prepare(nameOnly)   
 
 	Signal=instance.parameters.Signal;   
	Consecutive=instance.parameters.Consecutive;
	length=instance.parameters.length;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  length  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

 
	first=source:first() +length; 
 
	
	if  not Signal then
    max_level = instance:addStream("max_level", core.Line, name, "max_level", instance.parameters.color1, first );
    max_level:setPrecision(math.max(2, instance.source:getPrecision()));
    max_level:setWidth(instance.parameters.width);
    max_level:setStyle(instance.parameters.style);
 
    min_level = instance:addStream("min_level", core.Line, name, "min_level", instance.parameters.color2, first );
    min_level:setPrecision(math.max(2, instance.source:getPrecision()));
    min_level:setWidth(instance.parameters.width);
    min_level:setStyle(instance.parameters.style); 
   
    else
	
    max_level = instance:addInternalStream(0, 0);	
    min_level = instance:addInternalStream(0, 0);	
	
	end
	

	if Signal then
    Bar = instance:addStream("Bar", core.Bar, name, "Bar", instance.parameters.color1, first );
    Bar:setPrecision(math.max(2, instance.source:getPrecision())); 
    Bar:addLevel(0);	
	else
    Bar = instance:addInternalStream(0, 0);	
	end
	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top , instance.parameters.clrDN, 0);
 
 
 
end


function Update(period, mode)

	 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
	if not Signal then
    up:setNoData(period);
    down:setNoData(period);
	end
	  
	local min, max= mathex.minmax(source, period-length+1, period);
    min_level[period]=min;
    max_level[period]=max;
	
	
 	if min_level[period]~=min_level[period-1] then
	min_level:setBreak (period, true);
	else
	min_level:setBreak (period, false);	
	end
	
	
 	if max_level[period]~=max_level[period-1] then
	max_level:setBreak (period, true);
	else
	max_level:setBreak (period, false);	
	end
	
	
	
	if core.crossesOver  (source.close, max_level[period-1], period) then  
	
	    if Bar[period-1]<= 0 then
 	    Bar[period]= 1;
		else
		Bar[period]=Bar[period-1]+1;
		end
		
		 
		if (Bar[period-1]<=0   or Consecutive) and not Signal then
		up:set(period, source.low[period] , "\217");
		end	
	elseif core.crossesUnder (source.close, min_level[period-1], period) then
	    if Bar[period-1]>= 0 then
		Bar[period]= -1;
		else
		Bar[period]= Bar[period] -1;		
		end
		if (Bar[period-1]>= -1 or Consecutive ) and not Signal then	
        down:set(period, source.high[period] , "\218");	
		end
    else  
	Bar[period]= Bar[period-1];  
    end	
 
	
 
end

 


--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--| USDT Donations                                                                                 |
--+------------------------------------------------+-----------------------------------------------+
--| Network                                        |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--| ERC20 (ETH Ethereum)                           |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--| TRC20 (Tron)                                   |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--| BEP20 (BSC BNB Smart Chain)                    |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--| Matic Polygon                                  |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--| SOL Solana                                     |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--| ARBITRUM Arbitrum One                          |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+

 