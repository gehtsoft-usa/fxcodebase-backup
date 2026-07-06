-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72345

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
    indicator:name("MTF Bear and Bull volume Histogram");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Fast MA", "", 22, 1, 2000); 
	
	indicator.parameters:addString("TF1", "1. Time Frame", "", "H1");
	indicator.parameters:setFlag("TF1", core.FLAG_PERIODS);

	indicator.parameters:addString("TF2", "2. Time Frame", "", "H4");
	indicator.parameters:setFlag("TF2", core.FLAG_PERIODS);

	indicator.parameters:addString("TF3", "3. Time Frame", "", "D1");
	indicator.parameters:setFlag("TF3", core.FLAG_PERIODS);	
	
	 
 	indicator.parameters:addGroup("Style");		
	indicator.parameters:addColor("Up", "Bull Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("Down", "Bear Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(0, 0, 255)); 	 
 
	 
	  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;  

local TF={};
local Indicator={};
local SourceData={};
local loading={};
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	TF[1]=instance.parameters.TF1;
	TF[2]=instance.parameters.TF2;
	TF[3]=instance.parameters.TF3;	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period   .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset"); 
	
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
	
	for i = 1, 3, 1 do
    s2, e2 = core.getcandle(TF[i], 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), i .. ". time frame must be equal to or bigger than the chart time frame!");
	end
	
	assert(core.indicators:findIndicator("BEAR AND BULL VOLUME INDICATOR") ~= nil, "Please, download and install BEAR AND BULL VOLUME INDICATOR.LUA indicator"); 	
 
	first=source:first() ; 

	for i = 1, 3, 1 do 
	SourceData[i] = core.host:execute("getSyncHistory", source:instrument(), TF[i], source:isBid(), 0, 100+i, 200+i);
	loading[i]=true;
	
	Indicator[i] = core.indicators:create("BEAR AND BULL VOLUME INDICATOR", SourceData[i], Period);	
	end
	
 
	
    Count = instance:addStream("bull", core.Bar, name, "Count", instance.parameters.Up, first );
    Count:setPrecision(math.max(2, instance.source:getPrecision())); 
    Count:addLevel(0);	
    
end


function Update(period, mode)

    local Loading=false;
    for i= 1 , 3 , 1 do
	Indicator[i]:update(mode);  
		if loading[i] then
		Loading=true;
		end
	end
	
	if Loading  then
	return;
	end
	
	
	if period <= first then
	return;
	end
 
	Count[period]=0;	
	local p;
	
    for i= 1 , 3 , 1 do
	
	    p =  Initialization(i, period);  
		
		if p ~= false and Indicator[i].DATA:hasData(p) then
		
			if Indicator[i].bull[p] > math.abs(Indicator[i].bear[p]) then
			Count[period]=Count[period]+1;		
			elseif Indicator[i].bull[p] < math.abs(Indicator[i].bear[p]) then
			Count[period]=Count[period]-1;	
			end
		end
	end
	
	if Count[period] > 0 then
	Count:setColor(period,  instance.parameters.Up); 
	elseif Count[period] < 0 then	
	Count:setColor(period,  instance.parameters.Down); 
	else
	Count:setColor(period, instance.parameters.Neutral);	
	end
	
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


    for i= 1 , 3 , 1 do
		if cookie == 100+i then
			loading[i] = false;
		elseif cookie == 200+i then
			loading[i] = true;
		end
	end
	
    if not loading[1] and not loading[2]and not loading[3] then
        instance:updateFrom(0);	
	end

    return core.ASYNC_REDRAW ;	
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

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   | 
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |   
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin                                                    15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |  
--|Ethereum                                           0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D   |  
--|USDT addres  ERC-20 (Ethereum) address)            0x258C74Caac21c9535A0969F169FE0271d3cE56A0   | 
--+------------------------------------------------------------------------------------------------+