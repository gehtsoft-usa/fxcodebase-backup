-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=74647

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

function Init()
	indicator:name("Trans instrument correlation average")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)
	indicator.parameters:addGroup("Calculation")

	--indicator.parameters:addString("TF", "Time Frame", "", "D1");
	--indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
	
	
	indicator.parameters:addInteger("Period", "Period", "", 14, 1, 2000)
    local List = {
        "10USNote",
        "DIA.us",
        "SPX500",
        "VOLX",
        "AAPL.us",
        "QQQ.us"
    }
	
    indicator.parameters:addString("Base"  , "Base", "", "10USNote")
    for i= 1, 6, 1 do
    indicator.parameters:addStringAlternative("Base", List[i], List[i] , List[i]);	
	end
	
	
    for i = 1, 6, 1 do
        indicator.parameters:addGroup(i .. ". Currency Pair ")
        Add(i)
    end		
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 255)); 	
 
end

function Add(id)
    local List = {
        "10USNote",
        "DIA.us",
        "SPX500",
        "VOLX",
        "AAPL.us",
        "QQQ.us"
    }

 
    indicator.parameters:addString("Pair" .. id, "Pair", "", List[id])
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS)
end

 
local Count=6; 
local first
local source = nil
local Period;
 
local Init = true
local db

  
local Source={};
local loading={};
local Pair={};
local TF;
local Base;

function Prepare(nameOnly)

	Period=instance.parameters.Period;
	Base=instance.parameters.Base; 
	source = instance.source
	first = source:first()
	
	
	    local List = {
        "10USNote",
        "DIA.us",
        "SPX500",
        "VOLX",
        "AAPL.us",
        "QQQ.us"
    }
	
	for i= 1 , 6, 1 do
		if List[i]== Base then
		Base=i;
		break;
		end
	end
	

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)
	if nameOnly then
		return
	end
 
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
    for i = 1, Count, 1 do
 
		Source[i] = core.host:execute("getSyncHistory", instance.parameters:getString("Pair" .. i), source:barSize(), source:isBid(), 0 , 2000 +  i , 1000 + i);
		loading[i] = true; 
		 
    end	
	
 
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);		
end

function   Initialization(id, period)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);

  
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

 

function Update(period)


	if period<=source:first() then
	return;
	end
  
 

 
    local p1 =  Initialization(Base, period) 
    local p2;
	
	if p1== false then
	return;
	end
	
	
    if p1 <=Period 
	then
	return;
	end
	

    for i=1,6,1 do 	
	    p2 =  Initialization(i, period)
		
		if p2~= false then 
			if p2 > Period and	i ~= Base then
			Line[period]=mathex.correl (Source[Base].close, Source[i].close, p1-Period+1, p1, p2-Period+1, p2);
			end	
		end
	end
	
	
	
	Line[period]=(Line[period])/5;
	
	
end
 
 

function AsyncOperationFinished(cookie, success, message)

	local i,j;
    for i = 1, Count, 1 do
		
		    
			  if cookie == (1000 + i) then
			  loading[i] = true;
		      elseif  cookie == (2000 + i) then
			  loading[i] = false;               
			  end
		       
        
	end    
	
	  
    local FLAG=false; 
	local Number=0;
	
	for j = 1, Count, 1 do

                 if loading[i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
       
    end
	

	
	if FLAG then	
	core.host:execute ("setStatus", "  Loading "..((Count) - Number) .. " / " .. (Count) );	
	else
	
	core.host:execute ("setStatus", "")	
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