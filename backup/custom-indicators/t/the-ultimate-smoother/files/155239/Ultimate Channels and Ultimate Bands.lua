-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74838

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
    indicator:name(" Ultimate Channels and Ultimate Bands");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period1", "1. MA", "", 20, 1, 2000);
    indicator.parameters:addInteger("Period2", "2. MA", "", 20, 1, 2000);
    indicator.parameters:addDouble("Multiplier", "Multiplier", "", 1, 0, 2000);	
 
	indicator.parameters:addString("Method", "Method", "Method" , "Channel");
    indicator.parameters:addStringAlternative("Method", "Channel", "Channel" , "Channel");
    indicator.parameters:addStringAlternative("Method", "Bands", "Bands" , "Bands");	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Method;
local tAbs = math.abs;	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Multiplier=instance.parameters.Multiplier;
	Method=instance.parameters.Method;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2 .. "," ..  Multiplier  .. "," ..   Method .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	assert(core.indicators:findIndicator("THE ULTIMATE SMOOTHER") ~= nil, "Please, download and install THE ULTIMATE SMOOTHER.LUA indicator"); 
	
	Indicator1= core.indicators:create("THE ULTIMATE SMOOTHER", source.close, Period1 );
	first=Indicator1.DATA:first(); 
	
	

 
	if Method == "Channel" then
	TrueRange = instance:addInternalStream(0, 0);	
	Indicator2= core.indicators:create("THE ULTIMATE SMOOTHER", TrueRange, Period2 );
    else
	Source = instance:addInternalStream(0, 0);	
	Indicator2= core.indicators:create("MVA", Source, Period2 );	
	end
	
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color1, Indicator2.DATA:first() );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style); 
 
    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color2, Indicator2.DATA:first()  );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style); 
end


function Update(period, mode)


	Indicator1:update(mode); 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	

	
	
	if Method == "Channel" then	
	TrueRange[period]=getTrueRange(period);
	else
	Source[period]=math.pow(source.close[period] - Indicator1.DATA[period], 2);
	end

	
	Indicator2:update(mode); 	
	if period <= Indicator2.DATA:first()  
	then
	return;
	end	  
 
    if Method == "Channel" then
    UltimateChannel(period);
    else
    UltimateBands(period);
	end
 	
end

function getTrueRange(period)
    local hl = tAbs(source.high[period] - source.low[period]);
    local hc = tAbs(source.high[period] - source.close[period - 1]);
    local lc = tAbs(source.low[period] - source.close[period - 1]);

    local tr = hl;
    if (tr < hc) then
        tr = hc;
    end
    if (tr < lc) then
        tr = lc;
    end
    return tr;
end


function  UltimateChannel(period) 
 
    local  str = Indicator2.DATA[period] * Multiplier;
    Top[period]= Indicator1.DATA[period] + str;
	Bottom[period]= Indicator1.DATA[period] - str;
end	
 
function  UltimateBands(period) 
 
    local  sd  = math.sqrt(Indicator2.DATA[period]) * Multiplier; 
    Top[period]= Indicator1.DATA[period] + sd;
	Bottom[period]= Indicator1.DATA[period] - sd;	
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