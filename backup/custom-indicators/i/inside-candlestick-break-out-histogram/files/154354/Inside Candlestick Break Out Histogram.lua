-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74611

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
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
    indicator:name("Inside Candlestick Break Out Histogram");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
	
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "H4");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS); 
	indicator.parameters:addBoolean("Continuity", "Continuity", "", false);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("BC", "Color of Buy", "Color of Buy", core.rgb(0, 255, 0));
	indicator.parameters:addColor("SC", "Color of Sell", "Color of Sell", core.rgb(255, 0, 0));
	indicator.parameters:addColor("NC", "Color of Neutral", "Color of Neutral", core.rgb(128, 128, 128));
end

 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local first;
local source = nil;
 
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end 
	Continuity= instance.parameters.Continuity; 
	BC= instance.parameters.BC;
	SC= instance.parameters.SC;
	NC= instance.parameters.NC;
  
    source = instance.source;
    first=source:first();
	
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
    TF = instance.parameters.TF;
	
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	
 
	
	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), first, 100, 101);
	loading=true;
	

   
    Signal = instance:addStream("Signal", core.Bar, name, "Signal", NC, first);   
	Signal:setPrecision(math.max(2, instance.source:getPrecision()));
     
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


    if period <= first
	or not  source:hasData(period) then
	return;
	end

 
    local p =  Initialization(period)  
	
	
	 
	
	if not p then
	return;
	end
	
	if p<3 then
	return;
	end	
	
  

	
			if source.close[period] > Source.high[p-1]
			and Source.high[p-1]<Source.high[p-2]
			and Source.low[p-1]>Source.low[p-2]
			and Source.open[p-2]>Source.close[p-2]	
			and Source.open[p-3]>Source.close[p-3]		
			then	
				Signal[period]=1;
				Signal:setColor(period, BC);
			elseif source.close[period] < Source.high[p-1]
			and Source.high[p-1]<Source.high[p-2]
			and Source.low[p-1]>Source.low[p-2]
			and Source.open[p-2]<Source.close[p-2]	
			and Source.open[p-3]<Source.close[p-3]		
			then
				Signal[period]=-1;	
				Signal:setColor(period, SC); 	
			else
			
				if Continuity then
				Signal[period]=Signal[period-1];		
				else
				Signal[period]=0;
				end
				
				if Signal[period] > 0 then		
				Signal:setColor(period, BC);
				elseif Signal[period] < 0 then	
				Signal:setColor(period, SC);
				else
				Signal:setColor(period, NC);
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