-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70402 

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("SuperTrend Indicator");
    indicator:description("The indicator displays the buying and selling with the colors. The indicator is initially developed by Jason Robinson for MT4");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);


--ST(m15, 10, 3) and ST (h1, 10, 3)
	indicator.parameters:addGroup("1. Slot Calculation");
	
	indicator.parameters:addString("TF1", "Bar Size to display High/Low", "", "m15");
	indicator.parameters:setFlag("TF1", core.FLAG_PERIODS);
	
    indicator.parameters:addInteger("N1", "Number of periods", "", 10);
    indicator.parameters:addDouble("M1", "Multiplier", "", 3);
	
    indicator.parameters:addGroup("Signal Calculation");
	indicator.parameters:addInteger("Period", "Period", "", 14);	
		
	indicator.parameters:addGroup("2. Slot  Calculation");
	indicator.parameters:addString("TF2", "Bar Size to display High/Low", "", "H1");
	indicator.parameters:setFlag("TF2", core.FLAG_PERIODS);
    indicator.parameters:addInteger("N2", "Number of periods", "", 10);
    indicator.parameters:addDouble("M2", "Multiplier", "", 3);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "CTCD Line", "Color", core.rgb(0, 255, 0));
	 indicator.parameters:addInteger("width1", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("color2", "Signal Line", "Color", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("width2", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("color3", "Histogram Line", "Color", core.rgb(0, 0, 255));
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N={};
local M={};
local TF={};

local first;
local source = nil;
local Indicator = {};
local Source = {};
local loading={};
-- Streams block
local STCD, Signal, Histogram;
local dayoffset, weekoffset; 
local Period;
-- Routine
function Prepare(nameOnly) 

    for i= 1, 2 ,1 do
    N[i] = instance.parameters:getInteger("N" .. i);
    M[i] = instance.parameters:getInteger("M" .. i);
	TF[i] = instance.parameters:getString("TF" .. i)
	
	end
	
	Period= instance.parameters.Period;
    source = instance.source;
	
	 dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. N[1] .. ", " .. M[1] .. ", " .. N[2] .. ", " .. M[2]  .. ", " ..   Period..   ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	 assert(core.indicators:findIndicator("SUPERTREND") ~= nil, "Please, download and install SUPERTREND.LUA indicator");
	
	
	for i= 1, 2 ,1 do
	Source[i] = core.host:execute("getSyncHistory", source:instrument(), TF[i] , source:isBid(),  300 , 100*i, 100*i +1);
	loading[i]=true;
	
	
	Indicator[i] = core.indicators:create("SUPERTREND", Source[i],N[i] .. ", " .. M[i]);
	end
	
	
	
 
	
 
    STCD = instance:addStream("STCD", core.Line,   ".STCD",  ".STCD", instance.parameters.color1, source:first());    
	STCD:setWidth(instance.parameters.width1);
    STCD:setStyle(instance.parameters.style1);	
	STCD:setPrecision(math.max(2, source:getPrecision()));
	
	
	Signal = instance:addStream("Signal", core.Line,   ".Signal",  ".Signal", instance.parameters.color2, source:first());    
	Signal:setWidth(instance.parameters.width2);
    Signal:setStyle(instance.parameters.style2);	
	Signal:setPrecision(math.max(2, source:getPrecision()));
	
	Histogram = instance:addStream("Histogram", core.Bar,   ".Histogram",  ".Histogram", instance.parameters.color3, source:first());    
	Histogram:setPrecision(math.max(2, source:getPrecision()));
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

-- Indicator calculation routine
function Update(period, mode)


     if  loading[1]  or  loading[2] or period < Period  then
     return;
     end
	 
    local p={};
	
    for i= 1, 2 ,1 do
    Indicator[i]:update(mode);
	p[i]= Initialization(i, period);	
    end
	
	if  p[1]== false  or  p[2]== false then
     return;
     end
	
	STCD[period]= Indicator[1].DATA[p[1]]- Indicator[2].DATA[p[2]];
	
	Signal[period]=mathex.avg(STCD, period-Period+1, period) ;
    Histogram[period]= STCD[period] -Signal[period];
end



-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading[1] = false;
        
    elseif cookie == 101 then
        loading[1] = true;
    end
	
	if cookie == 200 then
        loading[2] = false;
        
    elseif cookie == 201 then
        loading[2] = true;
    end
	
	if loading[2]== false and loading[1]== false then
	instance:updateFrom(0);
	end
	
	
	 return core.ASYNC_REDRAW ;
end





