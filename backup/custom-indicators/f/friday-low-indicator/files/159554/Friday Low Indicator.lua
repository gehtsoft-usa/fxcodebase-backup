-- Available @  https://fxcodebase.com/code/viewtopic.php?f=17&t=76020

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
function Init()
    indicator:name("Friday Low Indicator");
    indicator:description("Friday Low Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
 
 
	
	--indicator.parameters:addBoolean("extend", "Extend", "", true);	

 	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("up", "Up Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("down", "Down Color", "", core.rgb(255, 0, 0));	
	 indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	  indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100);	
end

local first;
local source = nil;
--local OpenHour;
local DailyOpenLine=nil;
local Last;
local Size1, Size2;
local Time;
local timeframe;
local extend;
local opening_session
function Prepare(nameOnly)  
   
    source = instance.source;
	 
	 
 
	--extend=instance.parameters.extend;
	
    up=instance.parameters.up;
    down=instance.parameters.down;	
     

    first = source:first()+1;
    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    s, e = core.getcandle("D1",0, 0, 0);
	DayTimeFrameSize= e-s;		

	
	
	Source = core.host:execute("getSyncHistory", source:instrument(), "D1", source:isBid(), first, 100, 101);
	loading=true;	
	
  
 
   	style=instance.parameters.style;
	color=instance.parameters.color;
	width=instance.parameters.width;
	
	instance:ownerDrawn(true);	
end

 

function Update(period, mode) 
   
   if (period<first) then
   return;
   end 

end



 
local init =true;

function Draw(stage, context)
    if stage ~=	0  
	then
	return;
	end
	
    transparency = context:convertTransparency(instance.parameters.transparency); 
	context:createSolidBrush(1 , up);
	context:createSolidBrush(2 , down); 
	
	
	
	for i= 1, Source:size()-1 ,1 do
	
	date= Source:date(i);
	
				if i > 3 then
			 
				
				
				begin_date = core.getcandle("D1", date, core.host:execute("getTradingDayOffset"), core.host:execute("getTradingWeekOffset"))-DayTimeFrameSize;
				end_date = begin_date+DayTimeFrameSize;  
				
				
				        if  core.dateToTable (date).wday == 2 then  

						
									if (Source.low[i-2]<Source.low[i-3]) then
									 
									
									visible, y1 = context:pointOfPrice (Source.high[i-2])
									visible, y2 = context:pointOfPrice (Source.low[i-2])

									x1, x, x = context:positionOfDate (begin_date)
									x2, x, x = context:positionOfDate (end_date)	
									  
									context:drawRectangle(-1, 1, x1, y1, x2, y2,transparency)
									end
						end
				end
 
	end
 
	
end
-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
	
		return core.ASYNC_REDRAW ;	
end
-- Available @  https://fxcodebase.com/code/viewtopic.php?f=17&t=76020

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