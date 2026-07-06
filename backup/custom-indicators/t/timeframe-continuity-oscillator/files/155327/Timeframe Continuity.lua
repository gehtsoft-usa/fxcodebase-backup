-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74861

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
    indicator:name("Timeframe Continuity");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	



    indicator.parameters:addString("color_scheme", "Price Source", "", "Binary");
    indicator.parameters:addStringAlternative("color_scheme", "Binary", "", "Binary");
    indicator.parameters:addStringAlternative("color_scheme", "Gradient", "", "Gradient");
    indicator.parameters:addStringAlternative("color_scheme", "FTFC Only", "", "FTFC");
 
 
    indicator.parameters:addInteger("Period", "Period", "", 10, 1, 2000);
    indicator.parameters:addDouble("Deviation", "Standard Deviation", "", 2, 0, 2000);
	
	
   
    AddTimeFrame(1, "m5")
	AddTimeFrame(2, "m15")
	AddTimeFrame(3, "m30")
	AddTimeFrame(4, "H1")
	AddTimeFrame(5, "D1")	
	AddTimeFrame(6, "W1")		
 

	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128)); 
end


function AddTimeFrame(i, TF )
 
  	indicator.parameters:addGroup(i.. ". Time Frame Slot");	
	indicator.parameters:addBoolean("TimeFrame"..i, "Use This Time Frame", "", true);

	indicator.parameters:addString("TF"..i, i..". Time Frame", "", TF);
	indicator.parameters:setFlag("TF"..i, core.FLAG_PERIODS);
	
end	

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local TF={};
local Source={};
local loading={};
local Number;
local color_scheme;

local High={};
local Low={};
-- Routine1
 function Prepare(nameOnly)   
 
    
	color_scheme=instance.parameters.color_scheme;
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	
	Period=instance.parameters.Period;
	Deviation=instance.parameters.Deviation;
 
	source = instance.source
	first=source:first() ; 
	
    local name = profile:id() .. "(" ..  instance.source:name()   .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end


    local s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
	Number=0;
	
	for i= 1, 6, 1 do
    s2, e2 = core.getcandle(instance.parameters:getString("TF" .. i), 0, 0, 0);
		if (e1 - s1) <= (e2 - s2) and instance.parameters:getBoolean("TimeFrame" .. i) then
			Number=Number+1;	
			TF[Number]=instance.parameters:getString("TF" .. Number); 
		end
	end
	

	for i= 1, Number, 1 do
		Source[i] = core.host:execute("getSyncHistory", source:instrument(), TF[i], source:isBid(), 0, 100+i, 200 + i);
		loading[i]=true;
		
	end
 
 
	
	
	open = instance:addStream("openup", core.Line, name, "", core.COLOR_LABEL, first);
    high = instance:addStream("highup", core.Line, name, "", core.COLOR_LABEL, first);
    low = instance:addStream("lowup", core.Line, name, "", core.COLOR_LABEL, first);
    close = instance:addStream("closeup", core.Line, name, "", core.COLOR_LABEL, first);
    instance:createCandleGroup("CandleGroup", "CandleGroup", open, high, low, close);

end


function   Initialization(id, period)

    local Candle;
    Candle = core.getcandle(TF[id], source:date(period), dayoffset, weekoffset);

  
    if loading[id] or Source[id]:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source[id], Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

function   InitializationDate( Date)

    local Candle;
    Candle = core.getcandle(source:barSize(), Date, dayoffset, weekoffset);

   
  

    local p = core.findDate(source, Candle, false);

    -- candle is not found
    if p < source:first() then
        return false;
	else return p;	
    end
	
end	

function Update(period, mode)

    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
	if period <= first 
	or not source:hasData(period)
	then
	open:setColor(period, Neutral);	
	end
	  

	
	local up, dn=0,0;
	
	
    for i= 1, Number, 1 do	
	
	        p =  Initialization(i, period) 
			if p~=false then
				if Source[i].close[p] > Source[i].open[p] then
				up=up+1;
				elseif Source[i].close[p] < Source[i].open[p] then
				dn=dn+1;
				end
		     end
	end
	
	if up == Number then
	open:setColor(period,  Up); 
	elseif dn == Number then
	open:setColor(period,  Down);
    else
	open:setColor(period, Neutral);	
	end
	
		
 
	
end




 


 
-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


   
    for i= 1 , Number , 1 do
		if cookie == 100 +i  then
			loading[i] = false;
		elseif cookie == 200+i then
			loading[i] = true;
		end
	end
	
    local Loading=false;
	local Count=0;
	
    for i= 1 , Number , 1 do	
		if loading[i] then
		Loading=true;
		Count=Count+1;
		end
    end	
	
     	if Loading then
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		else
		core.host:execute ("setStatus", " Loaded "); 
		instance:updateFrom(0);
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

