-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74912

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
    indicator:name("Trend Following Breakout");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("EntryPeriod", "ENTRY H/L Period", "", 100, 1, 2000);
    indicator.parameters:addInteger("ExitPeriod", "EXIT H/L Period", "", 50, 1, 2000);
	
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Highest Price Long Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Lowest Price Long Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color3", "Lowest Price Short Line Color", "", core.rgb(0, 0, 255)); 
	 indicator.parameters:addColor("color4", "Highest Price Short Line Color", "", core.rgb(128, 128, 128));  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local EntryPeriod, ExitPeriod; 
 
	
-- Routine
 function Prepare(nameOnly)   
 
    
	EntryPeriod=instance.parameters.EntryPeriod;
	ExitPeriod=instance.parameters.ExitPeriod; 
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  EntryPeriod.. "," ..  ExitPeriod  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	 
	
 
	first=source:first() +math.max(EntryPeriod, ExitPeriod ); 
	
	
	highestpricelong = instance:addInternalStream(0, 0);
 	lowestpricelong = instance:addInternalStream(0, 0);
	lowestpriceshort = instance:addInternalStream(0, 0);
	highestpriceshort = instance:addInternalStream(0, 0);	
	
	
    highestpricelong = instance:addStream("highestpricelong", core.Line, name, "highestpricelong", instance.parameters.color1, first );
    highestpricelong:setPrecision(math.max(2, instance.source:getPrecision()));
    highestpricelong:setWidth(instance.parameters.width);
    highestpricelong:setStyle(instance.parameters.style); 
	
    lowestpricelong = instance:addStream("lowestpricelong", core.Line, name, "lowestpricelong", instance.parameters.color2, first );
    lowestpricelong:setPrecision(math.max(2, instance.source:getPrecision()));
    lowestpricelong:setWidth(instance.parameters.width);
    lowestpricelong:setStyle(instance.parameters.style); 

    lowestpriceshort = instance:addStream("lowestpriceshort", core.Line, name, "lowestpriceshort", instance.parameters.color3, first );
    lowestpriceshort:setPrecision(math.max(2, instance.source:getPrecision()));
    lowestpriceshort:setWidth(instance.parameters.width);
    lowestpriceshort:setStyle(instance.parameters.style); 
	
    highestpriceshort = instance:addStream("highestpriceshort", core.Line, name, "highestpriceshort", instance.parameters.color4, first );
    highestpriceshort:setPrecision(math.max(2, instance.source:getPrecision()));
    highestpriceshort:setWidth(instance.parameters.width);
    highestpriceshort:setStyle(instance.parameters.style); 	
	
 
end


function Update(period, mode)
 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
	
	highestpricelong[period]= mathex.max(source.high, period-EntryPeriod+1, period)
	lowestpricelong[period]= mathex.min(source.high, period-ExitPeriod+1, period) 
	lowestpriceshort[period]= mathex.min(source.low, period-EntryPeriod+1, period) 
	highestpriceshort[period]= mathex.max(source.low, period-ExitPeriod+1, period) 
	
 
end

 
--[[
highestpricelong = highest(high,entry)[1]
plot(highestpricelong, color=color.green, linewidth=2)

/////////////// BUY CLOSE PLOT
lowestpricelong = lowest(high,exit)[1]
plot(lowestpricelong, color=color.green, linewidth=2)

/////////////// SHORT OPEN PLOT
lowestpriceshort = lowest(low,entry)[1]
plot(lowestpriceshort, color=color.red, linewidth=2)

/////////////// SHORT CLOSE PLOT
highestpriceshort = highest(low,exit)[1]
plot(highestpriceshort, color=color.red, linewidth=2)

///////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// CONDITION LONG SHORT //////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////

/////////////// SHORT 

entryshort= crossunder(close, lowestpriceshort)
exitshort= crossover(close,highestpriceshort)

/////////////// LONG 

exitlong= crossover(close, lowestpricelong)
entrylong= crossover(close,highestpricelong)
]] 
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