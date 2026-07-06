-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=74560

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
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
    indicator:name("4 Line Tick Influx");
    indicator:description("Tick Influx");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("1. Line Calculation");
 
    indicator.parameters:addInteger("Fast1", "Fast MA Duration in seconds", "Fast MA Duration in seconds", 60);
    indicator.parameters:addInteger("Slow1", "Slow MA Duration in seconds", "Slow MA Duration in seconds", 120);
 
    indicator.parameters:addGroup("2. Line Calculation");
    indicator.parameters:addInteger("Fast2", "Fast MA Duration in seconds", "Fast MA Duration in seconds", 120);
    indicator.parameters:addInteger("Slow2", "Slow MA Duration in seconds", "Slow MA Duration in seconds", 240);

    indicator.parameters:addGroup("3. Line Calculation");	
    indicator.parameters:addInteger("Fast3", "Fast MA Duration in seconds", "Fast MA Duration in seconds", 240);
    indicator.parameters:addInteger("Slow3", "Slow MA Duration in seconds", "Slow MA Duration in seconds", 480);

    indicator.parameters:addGroup("4. Line Calculation");
    indicator.parameters:addInteger("Fast4", "Fast MA Duration in seconds", "Fast MA Duration in seconds", 480);
    indicator.parameters:addInteger("Slow4", "Slow MA Duration in seconds", "Slow MA Duration in seconds", 960);	
	

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color1", "Color of 1. MACD Line", "Color of MACD", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Color2", "Color of 2. MACD Line", "Color of MACD", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Color3", "Color of 3. MACD Line", "Color of MACD", core.rgb(0, 0, 255));
    indicator.parameters:addColor("Color4", "Color of 4. MACD Line", "Color of MACD", core.rgb(128, 128, 128));
	
	indicator.parameters:addInteger("Width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;

-- Streams block
local RawFast={};
local RawSlow={};
local Fast={};
local Slow={}; 
 
local MACD={}; 

local Second =(1/86400);

local DurationFast={};
local DurationSlow={};
local Color={}
-- Routine
function Prepare(nameOnly)
 
    source = instance.source;
    first=source:first();
	
	for i= 1, 4, 1 do
	DurationFast[i]=instance.parameters:getInteger("Fast" .. i)*Second
	DurationSlow[i]=instance.parameters:getInteger("Slow" .. i)*Second
	Color[i]=instance.parameters:getColor("Color" .. i)
	
    RawFast[i]= instance:addInternalStream(0, 0);
    RawSlow[i]= instance:addInternalStream(0, 0); 
	end
	
    if nameOnly then
	return;
	end
	
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
 
		
	for i= 1, 4, 1 do		
        MACD[i] = instance:addStream("MACD"..i, core.Line, i.. ". MACD", "MACD", Color[i], source:first());
		MACD[i]:setWidth(instance.parameters.Width);
        MACD[i]:setStyle(instance.parameters.Style);
		MACD[i]:setPrecision (source:getPrecision());
		MACD[i]:addLevel(0);		
	end	
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

	
	if period <= first then
	return;
	end
	
 
	for i= 1, 4, 1 do	
    MACD[i][period]=Calculate(i, period);
	end 
		
	 
end

function Calculate(i, period)

	 
	local P1= core.findDate (source, source:date(period)-DurationFast[i], false);
	local P2= core.findDate (source, source:date(period)-DurationSlow[i], false);
	
	if P1==-1 or P2==-1 
	or P1<= first or P2<= first
	or P1> period
	or P2> period
    then
    return;
    end
	
    RawFast[i][period] = mathex.avg(source ,P1, period);
    RawSlow[i][period]  = mathex.avg(source ,P2, period);
		 
		
	local FastMA= mathex.avg(RawFast[i],P1, period);
	local SlowMA=  mathex.avg( RawSlow[i], P2, period);
		
    local Fast= RawFast[i][period] + RawFast[i][period] - FastMA;
    local Slow= RawSlow[i][period] + RawSlow[i][period] - SlowMA;
	 	
	return Fast-Slow;
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