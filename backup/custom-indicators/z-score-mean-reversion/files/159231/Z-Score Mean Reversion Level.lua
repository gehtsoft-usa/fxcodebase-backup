-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75931

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 
-- Indicator profile
function Init()
    indicator:name("Z-Score Mean Reversion Level")
    indicator:description("Mean reversion strategy using Z-score")
    indicator:requiredSource(core.Tick)
    indicator:type(core.Oscillator)
    
	
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "SMA and STD Period", "", 20)
    indicator.parameters:addDouble("EntryZ", "Z-score Entry Threshold", "", 200)
    indicator.parameters:addDouble("ExitZ", "Z-score Exit Threshold", "", 50)
	
    indicator.parameters:addGroup("Style");	
    indicator.parameters:addInteger("width", "Line Width", "Width of the line", 2, 1, 5)
    indicator.parameters:addInteger("style", "Style", "Style of the oscillator line", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Neutral Line Color", "", core.rgb(128, 128, 128));
    indicator.parameters:addGroup("Levels");	 
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);			
end

-- Prepare
local source, sma, stddev, zscore
local Period, entryZ, exitZ

function Prepare(nameOnly)
    source = instance.source
    Period = instance.parameters.Period
    entryZ = instance.parameters.EntryZ
    exitZ = instance.parameters.ExitZ
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Neutral = instance.parameters.Neutral;
	
    local name =  profile:id() .."(".. Period ..   ")"
    instance:name(name)	
	
    if nameOnly then
        return;
    end		

    sma = core.indicators:create("MVA", source, Period)
    --stddev = core.indicators:create("STDDEV", source, period)
    
	first=source:first()+Period
    zscore = instance:addStream("ZScore", core.Line, "Z-Score", "ZScore", Neutral, first)
    zscore:setWidth(instance.parameters.width)
    zscore:setStyle(instance.parameters.style)	
	
    zscore:setPrecision(math.max(2, instance.source:getPrecision()));	
	
	zscore:addLevel(entryZ, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	zscore:addLevel(-entryZ, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);	
	zscore:addLevel(exitZ, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	zscore:addLevel(-exitZ, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);		
	
end

-- Update
function Update(periodIndex, mode)
    sma:update(mode)
    

    if periodIndex < Period then
        zscore[periodIndex] = nil
        return
    end

    local s = sma.DATA[periodIndex]
    local std = mathex.stdev(source, periodIndex-Period+1, periodIndex)
    if std == 0 or std == nil then
        zscore[periodIndex] = nil
        return
    end

    local z = (source[periodIndex] - s) / (std /100)
    zscore[periodIndex] = z
	
	if zscore[periodIndex] <-entryZ then
    zscore:setColor(periodIndex, Up);		
	elseif zscore[periodIndex] > entryZ then	
    zscore:setColor(periodIndex, Down);	
	else
    zscore:setColor(periodIndex, Neutral);	
    end	
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75931

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+