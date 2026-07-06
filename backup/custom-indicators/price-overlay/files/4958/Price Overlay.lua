-- Id: 1835
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=2324&hilit=overlay

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Price Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("AUTO", "Auto", "", false);
   	indicator.parameters:addString("Pair", "Pair", "", "EUR/USD");
    indicator.parameters:setFlag("Pair",  core.FLAG_INSTRUMENTS);
	
	indicator.parameters:addGroup("Mode");
	indicator.parameters:addString("MODE", "Mode", "Line" , "Line");
    indicator.parameters:addStringAlternative("MODE", "Line", "" , "Line");
	indicator.parameters:addStringAlternative("MODE", "Candle", "" , "CANDLE");	
    indicator.parameters:addBoolean("INVERTED", "Invert", "", true); 
	indicator.parameters:addBoolean("Normalize", "Normalize", "", true); 
	 
	 indicator.parameters:addGroup("Style");	 
     indicator.parameters:addInteger("style", "style", "style", core.LINE_SOLID);
	  indicator.parameters:addInteger("Size", "Font Size", "", 10);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	indicator.parameters:addBoolean("Monochromatic", "Use Monochromatic Candles", "", true); 
    indicator.parameters:addColor("color", "Line/Candle Color", "", core.rgb(255, 0, 0));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local MODE; 
local first;
local source = nil;
local host;
local SourceData;
local Monochromatic;  
local loading = false;
local offset;
local weekoffset;  
local open, close, high, low;

local AUTO;
local iPair,Pair;
local INVERTED;
local RATIO= nil; 
local o,c,h,l;
local Init;
local color;
local Normalize;
-- Routine
function Prepare(nameOnly)
    color = instance.parameters.color;
    Monochromatic = instance.parameters.Monochromatic;
	AUTO = instance.parameters.AUTO;	
	MODE= instance.parameters.MODE;
	 Pair= instance.parameters.Pair;
	INVERTED= instance.parameters.INVERTED;	
	Normalize= instance.parameters.Normalize;
    source = instance.source;
	 
    host = core.host; 
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
  
	if AUTO then	
	iPair=source:instrument();
	else
	iPair=Pair;
	end 

	local name;
	

	name = profile:id() .. ", " .. iPair ;
	
	instance:name(name);
	if nameOnly then
		return;
	end
	
	close = instance:addStream("close", core.Line, name, "close", color, source:first());	
	close:setWidth(instance.parameters.width);
    close:setStyle(instance.parameters.style);
    close:setPrecision(math.max(2, instance.source:getPrecision()));
	
	if MODE =="CANDLE" then
    open = instance:addInternalStream(0, 0);
    high= instance:addInternalStream(0, 0);
    low= instance:addInternalStream(0, 0);
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    high:setPrecision(math.max(2, instance.source:getPrecision()));
    low:setPrecision(math.max(2, instance.source:getPrecision()));	
	
	instance:createCandleGroup("Candle", "Candle", open, high, low, close);
	end 
	SourceData = core.host:execute("getSyncHistory", iPair, source:barSize(), source:isBid(), 1, 100, 101);
	loading=true; 
	Init = true; 
	
	
	instance:ownerDrawn(Normalize);

end

local init=true;
local Size;
function Draw(stage, context)
    if stage ~= 2 or RATIO== nil  then
	return;
	end
	
	-- Point= core.host:findTable("offers"):find("Instrument", iPair).PointSize;	
	
	if init then
	init=false;
	Size = context:pointsToPixels (instance.parameters.Size);
	context:createFont (1, "Arial", Size, Size, 0)
	end 
	
	local min= context:minPrice ()
	local max= context:maxPrice ()
	Step=(max-min)/10;
	
	 for i= 1, 10, 1 do 
	 
	   Price =  (min+ Step*i)/RATIO;
	   visible, y = context:pointOfPrice (min+ Step*i);
	   
	   Text= win32.formatNumber(Price, false, SourceData:getPrecision());
	   width, height = context:measureText (1,  Text, 0);  
      context:drawText (1, Text, color, -1, context:right()-width, y-height, context:right(), y, context.RIGHT );
	  end
end	

 

function   Initialization(period)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), offset, weekoffset);

  
    if loading or SourceData:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	
 
function Update(period)
	
    if period   <= source:first() then
	return;
	end
	
        local p =  Initialization(period) 
     
	    if not p then
		return;
		end
		
	o=SourceData.open[p];
	h=SourceData.high[p];
	l=SourceData.low[p];
	c=SourceData.close[p];

   
 
		        if Normalize then
						 if  Init   then
						 Init = false;
								 if  not AUTO   then
								  
										  if INVERTED then
										  RATIO= source.close[period]/(1/c); 
										  else
										   RATIO= source.close[period]/c; 
										  end
						        else   
						     							
                            						 
									      if INVERTED then
										  RATIO= source.close[period]/(1/source.close[period]);
																						  
										  else
										   RATIO= source.close[period]/source.close[period];
																   
										  end
						       end
		                
	       
                       end
		        else
				RATIO =1;
				end
		        
				if AUTO   then
				        if INVERTED then
						        close[period]=(1/source.close[period])*RATIO;
								if  MODE == "CANDLE" then
								open[period]= (1/source.open[period])*RATIO;
								high[period]= (1/source.high[period])*RATIO;
								low[period]= (1/source.low[period])*RATIO;		
								end
						
						else
								 close[period]= (source.close[period])*RATIO;
								if  MODE == "CANDLE" then
								open[period]= (source.open[period])*RATIO;
								high[period]= (source.high[period])*RATIO;
								low[period]= (source.low[period])*RATIO;		
								end
						end
				
				
				else
											
				                             if INVERTED then
													close[period]= (1/c)*RATIO;
													if  MODE == "CANDLE" then
													open[period]=(1/o)*RATIO;
													high[period]= (1/h)*RATIO;
													low[period]= (1/l)*RATIO;		
													end						       
											else				
													close[period]= (c)*RATIO;
													if  MODE == "CANDLE" then
													open[period]= (o)*RATIO;
													high[period]= (h)*RATIO;
													low[period]= (l)*RATIO;		
													end
											end
				                       end
				
				 if Monochromatic and MODE =="CANDLE"  then
				 open:setColor(period, color);
	             end
				 
	if period == source:size()-1 then
	 Text= win32.formatNumber( close[close:size()-1]/RATIO, false, SourceData:getPrecision());
	core.host:execute ("drawLabel", 1, source:date(source:size()-1), close[close:size()-1], Text);
    end	
			
end
 

function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end

