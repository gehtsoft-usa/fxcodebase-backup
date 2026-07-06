-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74256

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
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
    indicator:name("RANGE_BREAK");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addInteger("Begin", "Range Start Time", "", 0, 0, 244); 
 	indicator.parameters:addInteger("End", "Range End Time", "", 1, 0, 24);   
	
 
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("high", "High Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("low", "Low Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("range", "Range Color", "", core.rgb(0, 0, 255));

    indicator.parameters:addInteger("transparency", "Transparency", "", 75,0,100);	
	
	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	local first;
	local source = nil;      
	local dayoffset;
	local weekoffset;
	local Source;
	local loading = false;   
	local Begin, End;
    local Hour,Minute;

-- Routine

function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Begin=instance.parameters.Begin;
	End=instance.parameters.End;
	
	Hour=1/24;
    Minute=Hour/60;
	
    source = instance.source;
    first = source:first();	
	 
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle("D1", 0, 0, 0);
    assert ((e1 - s1) < (e2 - s2), "The chosen time frame must be smaller than the D1 time frame!");
	
	 
	
	Source = core.host:execute("getSyncHistory", source:instrument(), "D1", source:isBid(), 0, 100, 101);
	loading=true;
	
	
    instance:ownerDrawn(true);
end


function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);

  
    if loading or Source:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

  
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


local init = false; 

function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        init = true;
        context:createPen(1, context:convertPenStyle (instance.parameters.style), instance.parameters.width, instance.parameters.high);
        context:createPen(2, context:convertPenStyle (instance.parameters.style), instance.parameters.width, instance.parameters.low);
        context:createSolidBrush (3, instance.parameters.range);
        transparency= context:convertTransparency (instance.parameters.transparency)		
		
    end

    local from_date = source:date(math.max(source:first(), context:firstBar()));
    local to_date = source:date(math.min(context:lastBar(), source:size() - 1));

    local from_bar = math.max(0, core.findDate(Source, from_date, false));
    local to_bar = math.min(math.max(0, core.findDate(Source, to_date, false)), Source:size() - 1);

	
    for i = from_bar, to_bar, 1 do 
	
        local day_start, day_end = core.getcandle(Source:barSize(), Source:date(i), dayoffset, weekoffset);
	 

        local x, x1, x = context:positionOfDate (day_start)    
        local x, x, x2 = context:positionOfDate (day_end)    
    
        local x, X1, x = context:positionOfDate (day_start+ Hour*Begin-Minute)    
        local x, x, X2 = context:positionOfDate (day_start+ Hour*End-Minute)

        local period1=context:indexOfBar (X1);
        local period2=context:indexOfBar (X2);

        local low, high= mathex.minmax(source, period1, math.min(period2, source:size()-1)); 		
		
        local _, y_high = context:pointOfPrice(high);
        local _, y_low = context:pointOfPrice(low); 
     
            context:drawRectangle(-1, 3, X1, y_high, X2, y_low, transparency);
            context:drawLine(1, x1, y_high, x2, y_high);
            context:drawLine(2, x1, y_low, x2, y_low);
 
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