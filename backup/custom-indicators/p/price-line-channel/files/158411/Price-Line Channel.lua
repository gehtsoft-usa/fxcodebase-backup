-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72621

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



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Price-Line Channel");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("length", "Period", "", 50, 1, 2000); 
    indicator.parameters:addBoolean("r", "Readjustement", "", true);	
    indicator.parameters:addInteger("Lookback", "Lookback period", "", 0);	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Upper Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Lower Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local length,r; 
 
	
-- Routine
 function Prepare(nameOnly)   
 
    
	length=instance.parameters.length;
	r=instance.parameters.r;
	Lookback=instance.parameters.Lookback;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  length  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	ATR= core.indicators:create("ATR", source, length);
	first=ATR.DATA:first() ; 
	
	
	sizeA = instance:addInternalStream(0, 0);
	sizeB = instance:addInternalStream(0, 0); 
	sizeC = instance:addInternalStream(0, 0);	

 	
	
    a = instance:addStream("Upper", core.Line, name, "Upper", instance.parameters.color1, first );
    a:setPrecision(math.max(2, instance.source:getPrecision()));
    a:setWidth(instance.parameters.width);
    a:setStyle(instance.parameters.style);
    a:addLevel(0);	
 
    b = instance:addStream("Lower", core.Line, name, "Lower", instance.parameters.color2, first );
    b:setPrecision(math.max(2, instance.source:getPrecision()));
    b:setWidth(instance.parameters.width);
    b:setStyle(instance.parameters.style);
    b:addLevel(0);	 
end


function Update(period, mode)

	ATR:update(mode); 
	

	b[period]=math.huge; 	

	 if period <= first 
	 or (Lookback>0 and period < source:size()-1 - Lookback)
	 then      	 
	 return;
	 end
	 
 	a[period]=0; 	 

   
  if  (a[period-1]-a[period-2]) > 0 then
  sizeA[period]= ATR.DATA[period];
  else
  sizeA[period]=  sizeA[period-1];  
  end
  
  if   (b[period-1]-b[period-2]) < 0 then
  sizeB[period]= ATR.DATA[period];
  else
  sizeB[period]=  sizeB[period-1]; 
  end
  
  if  (a[period-1]-a[period-2]) > 0 or  (b[period-1]-b[period-2]) < 0 then
  sizeC[period]= ATR.DATA[period]; 
  else
  sizeC[period]= sizeC[period-1]; 
  end
  
   if(r) then
   A=sizeC[period]/length;
   else
   A=sizeA[period]/length;
   end
   
   if(r) then
   B=sizeC[period]/length;
   else
   B=sizeB[period]/length;
   end  
   
	a[period]=math.max( a[period-1],source.close[period]) - A;
	b[period]=math.min( b[period-1],source.close[period]) + B; 	
end


-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72621

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