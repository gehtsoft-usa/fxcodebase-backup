-- Available @  https://fxcodebase.com/code/viewtopic.php?f=17&t=75958

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
    indicator:name("Opening Candle Range");
    indicator:description("Opening Candle Range");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
	
    indicator.parameters:addInteger("hour", "Hour", "Hour at start of which the line must be drawn", 9, 0, 23); 
	indicator.parameters:addInteger("minute", "Minutes", "Minute at start of which the line must be drawn", 30, 0, 59);
	
	indicator.parameters:addString("timeframe", "Candle Time Frame", "", "m30");
	indicator.parameters:setFlag("timeframe", core.FLAG_PERIODS);	
	
	--[[
    indicator.parameters:addInteger("zone", "Time Zone", "", 4);
    indicator.parameters:addIntegerAlternative("zone", "EST", "", 1);
    indicator.parameters:addIntegerAlternative("zone", "Coordinated Universal Time", "", 2);
    indicator.parameters:addIntegerAlternative("zone", "The user's local time zone", "", 3);
    indicator.parameters:addIntegerAlternative("zone","The display time zone", "", 4);
    indicator.parameters:addIntegerAlternative("zone", "Server time zone", "", 5);
    indicator.parameters:addIntegerAlternative("zone", "Financial time ", "", 6); ]]
	
	indicator.parameters:addBoolean("extend", "Extend", "", true);	

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
	
	hour=instance.parameters.hour;
	shift=instance.parameters.shift;
	minute=instance.parameters.minute;
	zone=instance.parameters.zone;
	timeframe=instance.parameters.timeframe;
	extend=instance.parameters.extend;
	
    up=instance.parameters.up;
    down=instance.parameters.down;	
    s, e = core.getcandle("H1",0, 0, 0);
	HourTimeFrameSize= e-s;	
	
    s, e = core.getcandle("m1",0, 0, 0);
	MinuteTimeFrameSize= e-s;	
	
	
    s, e = core.getcandle(timeframe,0, 0, 0);
	TimeFrameSize= e-s;
 
    s, e = core.getcandle("D1",0, 0, 0);
	DayTimeFrameSize= e-s;	

    first = source:first()+1;
    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	

	
	
	Source = core.host:execute("getSyncHistory", source:instrument(), timeframe, source:isBid(), first, 100, 101);
	loading=true;	
	
	
	
   --  opening_session = CreateSession(hour, shift, color, "OpeningSession", "OpeningSession");	
 
 
   	style=instance.parameters.style;
	color=instance.parameters.color;
	width=instance.parameters.width;
	
	instance:ownerDrawn(true);	
end


-- Create the session description
-- from - the offset in hours again 0:00 of the EST canlendar day
-- len - length of the session in hours
-- color - color for lines and fill area
-- name - of the session
-- iname - the name of the indicator
function CreateSession(from, len, color, name, iname)
    local session = {};
    local n;
    session.name = name;
    session.from = from;
    session.len = len;
	
	--[[
    n = name .. "_H";
    session.high = instance:addStream(n, core.Line, iname .. "." .. n, n, color, first);
    n = name .. "_L";
    session.low = instance:addStream(n, core.Line, iname .. "." .. n, n, color, first);
    n = name .. "_HB";
    session.highband = instance:addStream(n, core.Line, iname .. "." .. n, n, color, first);
    n = name .. "_LB";
    session.lowband = instance:addStream(n, core.Line, iname .. "." .. n, n, color, first);
    session.begin = instance:addInternalStream(0, 0);
    instance:createChannelGroup(name, name, session.highband, session.lowband, color, 100 - instance.parameters.HL);]]
    return session;
end

function Update(period, mode) 
   
   if (period<first) then
   return;
   end 

end



-- Process the specified session
function Process(session, period)
    if session == nil then
        return ;
    end
    -- find the start of the session
    local date = source:date(period);       -- bar date;
    local sfrom, sto;

    -- 1) calculate the session to which the specified date belongs
    local t;
    t = math.floor(date * 86400 + 0.5);     -- date/time in seconds

    -- shift the date so it is in the virtual time zone in which 0:00 is the begin of the session
    t = t - session.from * 3600;
    -- truncate to the day only.
    t = math.floor(t / 86400 + 0.5) * 86400;
    -- and shift it back to est time zone
    t = t + session.from * 3600;

    sfrom = t;                          -- begin of the session
    sto = sfrom + session.len * 3600;   -- end of the session

    sfrom = sfrom / 86400;
    sto = sto / 86400;
	
	
	
end	

local init =true;

function Draw(stage, context)
    if stage ~=	0  
	then
	return;
	end
	
    transparency = context:convertTransparency(instance.parameters.transparency); 
  
  --  local from, to= Process(opening_session, source:size()-1)

   
    --local date = core.host:execute("convertTime", zone, core.TZ_UTC, date); 
	
	local date= source:date(source:size()-1);
  --  local begin = core.getcandle("D1", date, core.host:execute("getTradingDayOffset"), core.host:execute("getTradingWeekOffset"));
   
   local begin = core.getcandle("D1", date,0,0);
   
   local startdate=  begin+hour*HourTimeFrameSize+minute*MinuteTimeFrameSize;
   local enddate=  begin+hour*HourTimeFrameSize+minute*MinuteTimeFrameSize +  TimeFrameSize   ;
   
   
   if source:date(source:size()-1)< startdate  then 
   startdate=startdate-DayTimeFrameSize
   enddate=enddate-DayTimeFrameSize
   end
  
    p=core.findDate (Source, startdate, false)  
	
	if p<=0 then
	return;
	end
  
    x1, x, x = context:positionOfDate (startdate)
    x2, x, x = context:positionOfDate (enddate)
    x3, x, x = context:positionOfDate (startdate+DayTimeFrameSize)	   
 
    visible, y1 = context:pointOfPrice (Source.high[p])
    visible, y2 = context:pointOfPrice (Source.low[p])
	context:createSolidBrush(1 , up);
	context:createSolidBrush(2 , down);
	
    if not extend then 
	    if Source.open[p] > Source.close[p] then
        context:drawRectangle(-1, 1 , x1, y1, x2, y2,transparency)
		else
        context:drawRectangle(-1, 2, x1, y1, x2, y2,transparency)		
		end
	
	else
	    if Source.open[p] > Source.close[p] then
        context:drawRectangle(-1, 1, x1, y1, x3, y2,transparency)
		else
        context:drawRectangle(-1, 2, x1, y1, x3, y2,transparency)		
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
-- Available @  https://fxcodebase.com/code/viewtopic.php?f=17&t=75958

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