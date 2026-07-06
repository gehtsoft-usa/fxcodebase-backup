-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74697

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
    indicator:name("RSI Donchian");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("RSIPeriod", "RSI Period", "", 14, 1, 2000);
	indicator.parameters:addBoolean("ApplySmoothing", "Apply MA Smoothing to RSI", "", true);
    indicator.parameters:addInteger("Period", "RSI Smoothing Period", "", 8, 1, 2000); 

 
	indicator.parameters:addString("Method", "RSI Smoothing Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");	
    indicator.parameters:addInteger("DonchianPeriod", "Donchian Channel Lookback Period	", "", 28, 1, 2000); 
	
	 indicator.parameters:addGroup("Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));	
	
	 indicator.parameters:addColor("color1", "RSI Line Color", "", core.rgb(64, 128, 255)); 	 
	 indicator.parameters:addColor("color2", "Donchian Channel Color", "", core.rgb(0, 0, 255));  
	 indicator.parameters:addColor("color3", "Central Line Color", "", core.rgb(255, 128, 64)); 
	 indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
	 
    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 30);
	indicator.parameters:addDouble("Level2", "2. Level","", 50);
	indicator.parameters:addDouble("Level3", "3. Level","", 70); 
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);		
	
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local ApplySmoothing, RSIPeriod,Period, Method, DonchianPeriod; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	RSIPeriod=instance.parameters.RSIPeriod;
	Period=instance.parameters.Period;
	Method=instance.parameters.Method;
	ApplySmoothing=instance.parameters.ApplySmoothing;
	DonchianPeriod=instance.parameters.DonchianPeriod;
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	
   Transparency= instance.parameters.Transparency;
   Transparency= 100-Transparency;
   
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  RSIPeriod .. "," .. Period .. "," .. Method  .. "," .. DonchianPeriod.. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

  
	
	Indicator1= core.indicators:create("RSI", source.close, RSIPeriod);
	Indicator2= core.indicators:create(Method, Indicator1.DATA, Period);	
	
	if not ApplySmoothing then
	first=Indicator1.DATA:first(); 	
	else
	first=Indicator2.DATA:first() ; 
    end
	
	
	--Stream = instance:addInternalStream(0, 0);
 
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color1, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style); 
	Line:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Line:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    Line:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	
    Top = instance:addInternalStream(0, 0);
    Top:setPrecision(math.max(2, instance.source:getPrecision())); 

    Bottom  = instance:addInternalStream(0, 0);
    Bottom:setPrecision(math.max(2, instance.source:getPrecision())); 
	
	Central = instance:addStream("Central", core.Line, name, "Central", instance.parameters.color3, first );
    Central:setPrecision(math.max(2, instance.source:getPrecision()));
    Central:setWidth(instance.parameters.width);
    Central:setStyle(instance.parameters.style); 


 	instance:createChannelGroup("ChannelGroup","ChannelGroup" , Top, Bottom, instance.parameters.color2, Transparency);
	
	open = instance:addStream("open", core.Line, name, "", core.COLOR_LABEL, first);
    high = instance:addStream("high", core.Line, name, "", core.COLOR_LABEL, first);
    low = instance:addStream("low", core.Line, name, "", core.COLOR_LABEL, first);
    close = instance:addStream("close", core.Line, name, "", core.COLOR_LABEL, first);
    instance:createCandleGroup("CandleGroup", "CandleGroup", open, high, low, close);	
	
    core.host:execute ("attachOuputToChart", "CandleGroup")	
	
	
	Trend=instance:addInternalStream(0, 0);
	
	top=instance:addInternalStream(0, 0);
	bottom=instance:addInternalStream(0, 0); 
	instance:createChannelGroup("Background","Background" , top, bottom, Neutral, Transparency);	
end


function Update(period, mode)
   
	Indicator1:update(mode); 
	
	if ApplySmoothing then
	Indicator2:update(mode);
	end
	
	
	
	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end

    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
	top[period]=100;
	bottom[period]=0;	
	
	if not ApplySmoothing then  	
	Line[period]= Indicator1.DATA[period];
	else
	Line[period]= Indicator2.DATA[period];
    end	
 	
	if period <= first + DonchianPeriod
	or  not source:hasData(period) 
	then
	return;
	end	
 
	
	local min, max= mathex.minmax(Line, period-DonchianPeriod+1, period);
    Top[period]=max;
    Bottom[period]=min;	
    Central[period] = (min+max)/2

    if Line[period]> Top[period-1] then
	Trend[period]=1
    elseif Line[period]< Bottom[period-1] then
	Trend[period]=-1
    else
	Trend[period]=0
	end
	
	
	if Trend[period]~=0 
	and
	(
	(Line[period]>= Central[period-1] and Line[period-1]< Central[period-2]  )
	or
	(Line[period]<= Central[period-1] and Line[period-1]> Central[period-2]  )
	)
	then
	
	Trend[period]=0;
	end
	

	if Trend[period]==1 then
	open:setColor(period, Up);
	top:setColor(period, Up);	
	elseif Trend[period]==-1 then
	open:setColor(period, Down);
	top:setColor(period, Down);	
	else
	open:setColor(period, Neutral);	
	top:setColor(period, Neutral);	
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

 