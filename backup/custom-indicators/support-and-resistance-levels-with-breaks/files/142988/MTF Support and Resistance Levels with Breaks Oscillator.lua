-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=71374

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

function Init()
    indicator:name("MTF Support and Resistance Levels with Breaks Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addInteger("volum_period", "Volume Period", "", 7, 1, 2000);	
	indicator.parameters:addInteger("leftBars", "leftBars", "", 15, 1, 2000);
    indicator.parameters:addInteger("rightBars", "rightBars", "", 15, 1, 2000);	
    indicator.parameters:addInteger("volumeThresh", "volumeThresh", "", 20, 1, 2000);
	
	indicator.parameters:addGroup("Time Frame Selector"); 
 
 
 	indicator.parameters:addString("TF1", "1. Time Frame", "", "H1");
	indicator.parameters:setFlag("TF1", core.FLAG_PERIODS);
 	indicator.parameters:addString("TF2", "2. Time Frame", "", "H4");
	indicator.parameters:setFlag("TF2", core.FLAG_PERIODS);
 	indicator.parameters:addString("TF3", "3. Time Frame", "", "D1");
	indicator.parameters:setFlag("TF3", core.FLAG_PERIODS);
	
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

  
local first;
local source = nil;
 
local TF={}; 
local Indicator={};
local SourceData={};
local loading={};
local volume={};
local SR={};
-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    TF1= instance.parameters.TF1;
    TF2= instance.parameters.TF2;
    TF3 = instance.parameters.TF3;
	
    volum_period= instance.parameters.volum_period;
    leftBars= instance.parameters.leftBars;
    rightBars= instance.parameters.rightBars;
	volumeThresh= instance.parameters.volumeThresh;	
	
	local Parameters= TF1 ..  ", " .. TF2 ..  ", " .. TF3;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
    
			
    source = instance.source;	
	
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
    TF[1] = instance.parameters.TF1;
    TF[2] = instance.parameters.TF2;
    TF[3] = instance.parameters.TF3;	
	
	
	local s1, e1, s2, e2; 
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);


    assert(core.indicators:findIndicator("SUPPORT AND RESISTANCE LEVELS WITH BREAKS") ~= nil, "Please, download and install SUPPORT AND RESISTANCE LEVELS WITH BREAKS.LUA indicator");
 
	for i= 1, 3 , 1 do
		s2, e2 = core.getcandle(TF[i], 0, 0, 0);
		assert ((e1 - s1) <= (e2 - s2), i .. " frame must be equal to or bigger than the chart time frame!");
		SourceData[i] = core.host:execute("getSyncHistory", source:instrument(), TF[i], source:isBid(), 0, 200+i, 100+i);
		loading[i]=true;
		
        volume[i] = core.indicators:create("MVA", SourceData[i].volume, volum_period);
		SR[i] = core.indicators:create("SUPPORT AND RESISTANCE LEVELS WITH BREAKS", SourceData[i] , false, false, false, leftBars , rightBars , volumeThresh);
	end	
 
    first=source:first(); 
	
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",instance.parameters.color, first); 
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
    Oscillator:addLevel(3);	
    Oscillator:addLevel(-3);		
    Oscillator:addLevel(0);	
end


function   Initialization(id, period)

    local Candle;
    Candle = core.getcandle(TF[id], source:date(period), dayoffset, weekoffset);

  
    if loading[id] or SourceData[id]:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData[id], Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

-- Indicator calculation routine
function Update(period, mode) 
	
    if period < first then
	return;
	end
	
	Oscillator[period]=0;
	
	local p;
	
	
	for i= 1, 3 , 1 do
	
	
	    p =  Initialization(i, period) 
		
		volume[i]:update(mode);
		SR[i]:update(mode);
     
	    if p~= false and p > volum_period and SR[i].DATA:hasData(p) then 
			if SourceData[i].volume[p] > volume[i].DATA[p] 
			and SourceData[i].close[p] > SR[i].Top[p]
			and SourceData[i].close[p] > SR[i].Bottom[p]
			then 
			Oscillator[period]=Oscillator[period]+1;
			elseif SourceData[i].volume[p] > volume[i].DATA[p] 
			and SourceData[i].close[p] < SR[i].Top[p]
			and SourceData[i].close[p] < SR[i].Bottom[p]
			then 
			Oscillator[period]=Oscillator[period]-1;
			end		
        end		
		
	end
	
	
		
 
				  
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


    for i= 1, 3 , 1 do 
		if cookie == 100+i then
			loading[i] = true;
		elseif cookie == 200+i then
			loading[i] = false;
		end
	end
	
 
	
	if not loading[1] and not loading[2] and  not loading[3] then
        instance:updateFrom(0);
	end	
end


--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--| USDT Donations                                                                                 |
--+------------------------------------------------+-----------------------------------------------+
--| Network                                        |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--| ERC20 (ETH Ethereum)                           |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--| TRC20 (Tron)                                   |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--| BEP20 (BSC BNB Smart Chain)                    |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--| Matic Polygon                                  |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--| SOL Solana                                     |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--| ARBITRUM Arbitrum One                          |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+