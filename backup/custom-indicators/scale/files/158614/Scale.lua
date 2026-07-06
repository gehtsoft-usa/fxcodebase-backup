-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=75713

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
    indicator:name("Scale");
    indicator:description("Scale");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addString("ScaleType", "Scale Type", "", "Pips");
    indicator.parameters:addStringAlternative("ScaleType", "Pips", "", "Pips");
    indicator.parameters:addStringAlternative("ScaleType", "Value", "", "Value");
    indicator.parameters:addStringAlternative("ScaleType", "Percentage", "", "Percentage"); 	
    indicator.parameters:addDouble("Value", "Value", "", 10);
	indicator.parameters:addBoolean("Current", "Current Candle", "Current Candle", true);	
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0)); 
    indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0)); 	
 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local PERIOD;

local first;
local source = nil;

-- Streams block
local LRL = nil;

-- Routine
function Prepare(nameOnly)
    ScaleType = instance.parameters.ScaleType;
	Value = instance.parameters.Value;
	Current= instance.parameters.Current;
 
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if   nameOnly  then
	return;
	end
	
 
 
   
   instance:ownerDrawn(true);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not source:hasData(period) then
	return;
	end
	 
end

local init = false;

function Draw (stage, context)

    if stage  ~= 0 
    or source:size()-1<=0
	then
	return;
	end
 
   
        if not init then
		     context:createPen (1, context.SOLID, 1, instance.parameters.Up)       
			context:createSolidBrush(2, instance.parameters.Up);
			
		     context:createPen (3, context.SOLID, 1, instance.parameters.Down)       
			context:createSolidBrush(4, instance.parameters.Down);		 
            init = true;
        end
    
	

    if Current then
    open_price= source.open[source:size()-1]
	else
    open_price= source.open[source:size()-2]	
	end
	
	visible, y1 =  context:pointOfPrice (open_price) 
	
	
	if ScaleType== "Pips" then
	visible, y2= context:pointOfPrice (open_price + (Value*source:pipSize())) 
	visible, y3= context:pointOfPrice (open_price - (Value*source:pipSize()))    
    elseif ScaleType=="Value" then
	visible, y2= context:pointOfPrice (open_price +Value) 
	visible, y3= context:pointOfPrice (open_price - Value)   
	else
	visible, y2= context:pointOfPrice (open_price + (open_price/100)*Value) 
	visible, y3= context:pointOfPrice (open_price - (open_price/100)*Value)		
	end

 
	
			x0, x1, x2 = context:positionOfBar (source:size()-1); 
            candle= x2-x1;
			
			
			context:drawRectangle (1, 2, x2+candle, y2, x2+2*candle, y1 );
 			context:drawRectangle (3, 4, x2+candle, y1, x2+2*candle, y3  );		 
end

-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=75713

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