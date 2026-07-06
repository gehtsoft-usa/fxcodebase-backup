-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75490 

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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

function Init()
    indicator:name("Shaded Moving Average")
    indicator:description("Plots a moving average with a shaded area based on user-defined distance.")
    indicator:requiredSource(core.Tick)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("MAPeriod", "MVA Period", "Period for the moving average.", 50, 1, 200)
    indicator.parameters:addString("ShadeDirection", "Shade Direction", "Choose to shade above or below the MVA.", "below")
    indicator.parameters:addStringAlternative("ShadeDirection", "Above", "", "above")
    indicator.parameters:addStringAlternative("ShadeDirection", "Below", "", "below")
    indicator.parameters:addStringAlternative("ShadeDirection", "Both", "", "both")	
    indicator.parameters:addDouble("Distance", "Distance (pips)", "Distance to offset from the MVA.", 50, 1, 500)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("ShadeColor", "Shade Color", "Color of the shaded area.", core.rgb(128, 128, 255))
    indicator.parameters:addColor("LineColor", "MVA Line Color", "Color of the moving average line.", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("width", "Line Width", "Width of the line", 2, 1, 5)
    indicator.parameters:addInteger("style", "Style", "Style of the oscillator line", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);	
	
	indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);	
end

local MAPeriod, ShadeDirection, Distance, ShadeColor, LineColor, LineWidth
local MVA, UpperBand, LowerBand

function Prepare(nameOnly)
    MAPeriod = instance.parameters.MAPeriod
    ShadeDirection = instance.parameters.ShadeDirection
    Distance = instance.parameters.Distance * instance.source:pipSize()
    ShadeColor = instance.parameters.ShadeColor 
	LineColor = instance.parameters.LineColor;
	
   Transparency= instance.parameters.Transparency;
   Transparency= 100-Transparency;	
	
    source = instance.source;	

    local name = string.format("Shaded MVA (%d)", MAPeriod)
    instance:name(name)

    if nameOnly then
        return
    end

    MVA = core.indicators:create("MVA", source, MAPeriod)
	if ShadeDirection == "above" or ShadeDirection == "both" then
    UpperBand = instance:addStream("UpperBand", core.Line, "Upper Band", "UB", LineColor, MVA.DATA:first())
	else
    UpperBand = instance:addInternalStream(MVA.DATA:first(), 0);	
	end
	
	if ShadeDirection == "below" or ShadeDirection == "both" then	
    LowerBand = instance:addStream("LowerBand", core.Line, "Lower Band", "LB", LineColor, MVA.DATA:first())
	else
    LowerBand = instance:addInternalStream(MVA.DATA:first(), 0);	
	end	
 
    MA = instance:addStream("MA", core.Line, "MA", "MA", LineColor, MVA.DATA:first())	
    MA:setWidth(instance.parameters.width)
    MA:setStyle(instance.parameters.style)

	
	
    if   ShadeDirection == "above"   then	 
	instance:createChannelGroup("Group","Group" , UpperBand, MA, ShadeColor, Transparency);		
	elseif ShadeDirection == "below"  then	
	instance:createChannelGroup("Group","Group" , MA, LowerBand, ShadeColor, Transparency);	
	else
	instance:createChannelGroup("Group","Group" , UpperBand, LowerBand, ShadeColor, Transparency);			
	end	
  
end

function Update(period, mode)
    if period < MAPeriod then
        return
    end

    MVA:update(mode)

    MA[period]= MVA.DATA[period]
	
    if ShadeDirection == "above" or ShadeDirection == "both" then
        UpperBand[period] = MA[period] + Distance  
    end
    if ShadeDirection == "below"  or ShadeDirection == "both" then	
        LowerBand[period] = MA[period] - Distance 
    end
	
 
end
 -- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75490

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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