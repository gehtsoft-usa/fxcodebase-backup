-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=14929

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
    indicator:name("Linear Regression Line");
    indicator:description("Linear Regression Line");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PERIOD", "Period", "Perios",20);
	
	
    indicator.parameters:addString("Presentation", "Presentation", "", "Slope");
    indicator.parameters:addStringAlternative("Presentation", "Slope", "", "Slope");
    indicator.parameters:addStringAlternative("Presentation", "Price", "", "Price");
	indicator.parameters:addBoolean("Line", "Show Line", "", true);
	indicator.parameters:addBoolean("Candles", "Show Candles", "", true);		
	indicator.parameters:addBoolean("Background", "Background", "", true);		
   
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of Up Trend", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn", "Color of Down Trend", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("UpB", "Background Color of Up Trend", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("DnB", "Background Color of Down Trend", "", core.rgb(88, 88, 88));	
	indicator.parameters:addInteger("style", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("width", "Width", "", 1, 1, 5);
	
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
    PERIOD = instance.parameters.PERIOD;
	Presentation = instance.parameters.Presentation;
	Candles = instance.parameters.Candles;
	Line = instance.parameters.Line;
	Background = instance.parameters.Background;
    source = instance.source;
    first = source:first()+PERIOD;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(PERIOD) .. ")";
    instance:name(name);

    if   nameOnly  then
	return;
	end
	
	if Line then
    LRL = instance:addStream("LRL", core.Line, name, "LRL", instance.parameters.Up, first);
	LRL:setWidth(instance.parameters.width);
    LRL:setStyle(instance.parameters.style);
	else
	LRL= instance:addInternalStream(0, 0);
	end
		
	if Candles then	
    open = instance:addStream("open", core.Line, name .. ".open", "open", instance.parameters.Up, first)	
    high = instance:addStream("high", core.Line, name .. ".high", "high", instance.parameters.Up , first)	
    low = instance:addStream("low", core.Line, name .. ".low", "low", instance.parameters.Up, first)	
    close = instance:addStream("close", core.Line, name .. ".close", "close", instance.parameters.Up, first)
    instance:createCandleGroup("Candles", "Candles", open, high, low, close);	
    end	
 
   
   instance:ownerDrawn(true);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not source:hasData(period) then
	return;
	end
	
	
	if Candles then	
        open[period] =  source.open[period] ;
        close[period] =   source.close[period] ;
        high[period] =   source.high[period] ;
        low[period] =   source.low[period] ; 		
	end


     LRL[period] =   mathex.lreg(source.close, period - PERIOD + 1, period)
	 
	 
	if Presentation == "Slope" then 
			if  LRL[period] >  LRL[period-1] then
			LRL:setColor(period, instance.parameters.Up);
				if Candles then
				open:setColor(period, instance.parameters.Up);
				end
			else
			LRL:setColor(period, instance.parameters.Dn);
				if Candles then
				open:setColor(period, instance.parameters.Dn);
				end			
            end
	elseif Presentation == "Price" then 
	
			if  source.close[period] >  LRL[period] then
			LRL:setColor(period, instance.parameters.Up);
				if Candles then
				open:setColor(period, instance.parameters.Up);
				end			
			else
			LRL:setColor(period, instance.parameters.Dn);
				if Candles then
				open:setColor(period, instance.parameters.Dn);
				end			
            end	
	end
	
  
end

local init = false;

function Draw (stage, context)

    if stage  ~= 0 or not Background then
	return;
	end
	 
    

    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		     context:createPen (1, context.SOLID, 1, instance.parameters.UpB)       
			context:createSolidBrush(2, instance.parameters.UpB);
			
			 context:createPen (3, context.SOLID, 1, instance.parameters.DnB)       
			context:createSolidBrush(4, instance.parameters.DnB);
			
		  
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
 
	 
		 
	
        local period;
		
			 for period= first, last, 1 do	   
			   x0, x1, x2 = context:positionOfBar (period);
			   
			
						if Presentation == "Slope" then 
								if  LRL[period] >  LRL[period-1] then								 
									C2=2;
									C1=1;
								else
									C2=4;
									C1=3;	
								end
						elseif Presentation == "Price" then 
						
								if  source.close[period] >  LRL[period] then
									C2=2;
									C1=1;	
								else
									C2=4;
									C1=3;	
								end	
						end
									 
		 
													 
		 
						
			           context:drawRectangle (C1, C2, x1, context:top(), x2, context:bottom()  );
       end					
				 
				
	
end

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=14929

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