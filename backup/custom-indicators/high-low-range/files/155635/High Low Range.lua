-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74944

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                               https://appliedmachinelearning.systems/contact/  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("High Low Range");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period", "Period", "", 14, 1, 2000);
    indicator.parameters:addBoolean("Bar", "Show as Bar", "", true);	
    indicator.parameters:addBoolean("Delta", "Show as Delta", "", false);		
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Up Bar Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down bar Color", "", core.rgb(255, 0, 0)); 
     indicator.parameters:addColor("color3", "Average Line Color", "", core.rgb(0, 0, 255));	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period;  
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	Bar=instance.parameters.Bar; 
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
  
	first=source:first()+Period ; 
	 
	if instance.parameters.Delta then
	        HighLow= instance:addInternalStream(0, 0);       
	else
			
			if Bar then
			HighLow = instance:addStream("HighLow", core.Bar, name, "HighLow", instance.parameters.color1, source:first() );
			HighLow:setPrecision(math.max(2, instance.source:getPrecision()));  
			else	
			HighLow = instance:addStream("HighLow", core.Line, name, "HighLow", instance.parameters.color1, source:first() );
			HighLow:setPrecision(math.max(2, instance.source:getPrecision())); 
			HighLow:setWidth(instance.parameters.width);
			HighLow:setStyle(instance.parameters.style);	
			end	
			HighLow:addLevel(0);
	end

	if instance.parameters.Delta then
	Average= instance:addInternalStream(0, 0);
		if Bar then
		Delta = instance:addStream("Delta", core.Bar, name, "Delta", instance.parameters.color1, first );
		Delta:setPrecision(math.max(2, instance.source:getPrecision()));		
		else		
		Delta = instance:addStream("Delta", core.Line, name, "Delta", instance.parameters.color1, first );
		Delta:setPrecision(math.max(2, instance.source:getPrecision()));
		Delta:setWidth(instance.parameters.width);
		Delta:setStyle(instance.parameters.style);
		end
		Delta:addLevel(0);	
	else
    Average = instance:addStream("Average", core.Line, name, "Average", instance.parameters.color3, first );
    Average:setPrecision(math.max(2, instance.source:getPrecision()));
    Average:setWidth(instance.parameters.width);
    Average:setStyle(instance.parameters.style);
	end
end


function Update(period, mode)
 

	if period <= source:first()
	or  not source:hasData(period) 
	then
	return;
	end
	  
 
	HighLow[period]= source.high[period] - source.low[period];
	
	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
    Average[period]= mathex.avg(HighLow, period-Period+1, period)
	
	if HighLow[period] > Average[period] then
    HighLow:setColor(period, instance.parameters.color1);		
	else
    HighLow:setColor(period, instance.parameters.color2);
    end	
	
	if instance.parameters.Delta then
	Delta[period]=HighLow[period]-Average[period];
		if Delta[period] > 0 then
		Delta:setColor(period, instance.parameters.color1);		
		else
		Delta:setColor(period, instance.parameters.color2);
		end		
	
	end
	
end

 
--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
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