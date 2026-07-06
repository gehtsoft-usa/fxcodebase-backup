-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62238


--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Overlay Template");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "D1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("UpUp", "Color of Up in Up Trend", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UpDown", "Color of Down in Up Trend", "", core.rgb(0, 200, 0));
	indicator.parameters:addColor("DownUp", "Color of Up in Down Trend", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("DownDown", "Color of Down in Down Trend", "", core.rgb(200, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local UpUp,UpDown, Neutral;
local DownUp,DownDown, Neutral;
local first;
local source = nil;


local TF; 
local dayoffset;
local weekoffset;
local SourceData;
local loading = false; 
 

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil; 
function Prepare(nameOnly)   

    UpUp = instance.parameters.UpUp;
    UpDown= instance.parameters.UpDown;
	DownUp = instance.parameters.DownUp;
    DownDown= instance.parameters.DownDown;
    Neutral= instance.parameters.Neutral;
	TF= instance.parameters.TF;
	
	source = instance.source;
   
  
    local name = profile:id() .. "(" .. source:name() .. ", " .. source:barSize()..", ".. TF ..  ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
	first= source:first();
	
	
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
    TF = instance.parameters.TF;
	
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");

    	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
	
	
	SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101);
	loading=true;
		
end


function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);

  
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




-- Indicator calculation routine
function Update(period, mode)
	
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
	if period < first then
	open:setColor(period, Neutral);	
	return;
	end 
			
			
	local p =  Initialization(period) 
     
	if not p then
	open:setColor(period, Neutral);	
	return;
	end
	
	
	if source.close[period]> SourceData.open[p] then
		if source.close[period]> source.open[period] then
		open:setColor(period, UpUp);	
		elseif source.close[period]< source.open[period] then
		open:setColor(period, UpDown);	
		else
		open:setColor(period, Neutral);	
		end
	elseif source.close[period]< SourceData.open[p] then	
	    if source.close[period]> source.open[period] then
		open:setColor(period, DownUp);	
		elseif source.close[period]< source.open[period] then
		open:setColor(period, DownDown);	
		else
		open:setColor(period, Neutral);	
		end	
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


