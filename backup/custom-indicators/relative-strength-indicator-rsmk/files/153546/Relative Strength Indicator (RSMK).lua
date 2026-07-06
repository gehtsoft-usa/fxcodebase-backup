-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=74409

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

function Init()
    indicator:name("Relative Strength Indicator (RSMK)");
    indicator:description("Relative Strength Indicator (RSMK)");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
	
	indicator.parameters:addString("instrument1", "1. Instrument", "", "AUD/JPY");
    indicator.parameters:setFlag("instrument1" , core.FLAG_INSTRUMENTS);	

	indicator.parameters:addString("instrument2", "2. Instrument", "", "AUD/USD");
    indicator.parameters:setFlag("instrument2" , core.FLAG_INSTRUMENTS);	
	
    indicator.parameters:addInteger("Period", "Period", "Period", 15);
	
	indicator.parameters:addString("Method1", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");

	
    indicator.parameters:addInteger("SmoothPeriod1", "1. Smooth Period", "Period", 2);	
	
	
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");	
	
	
	indicator.parameters:addInteger("SmoothPeriod2", "2. Smooth Period", "Period", 20);	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("RSI_color", "Color of RSI", "Color of RSI", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period , SmoothPeriod; 
local first;
local source = nil;
local loading={};
local Source={};
-- Streams block 
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period; 
	Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;	
    SmoothPeriod1 = instance.parameters.SmoothPeriod1;	
    SmoothPeriod2 = instance.parameters.SmoothPeriod2;
	instrument1 = instance.parameters.instrument1;
	instrument2 = instance.parameters.instrument2;
    source = instance.source;
    first = source:first();
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period)  .. ", " ..  tostring(Method1).. ", " ..  tostring(SmoothPeriod1)  .. ", " ..  tostring(Method1).. ", " ..  tostring(SmoothPeriod2).. ", " ..  tostring(instrument1).. ", " ..  tostring(instrument2)   .. ")";
    instance:name(name);

    if (nameOnly)  then
	return;
	end


    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
	
	Source[1] = core.host:execute("getSyncHistory", instance.parameters.instrument1, source:barSize(), source:isBid(), 0, 100, 101);
	loading[1]=true;

	Source[2] = core.host:execute("getSyncHistory", instance.parameters.instrument2, source:barSize(), source:isBid(), 0, 200, 201);
	loading[2]=true;
	
        ratio = instance:addInternalStream(0, 0); 	
        change = instance:addInternalStream(0, 0); 	
		MA1 = core.indicators:create(Method1, change, SmoothPeriod1);
		MA2 = core.indicators:create(Method2, MA1.DATA, SmoothPeriod2);		
		 
        RSI = instance:addStream("RSI", core.Line, name, "RSI", instance.parameters.RSI_color,first+Period*2+SmoothPeriod1+SmoothPeriod2);		        
		RSI:setPrecision(math.max(2, instance.source:getPrecision()));
		
		RSI:setWidth(instance.parameters.width);
        RSI:setStyle(instance.parameters.style);
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)



    if period <=source:first() then
	return;
	end
	
    local p1=Initialization(1, period);
    local p2=Initialization(2, period);
	
    if p1== false or p2==false then
    return;
    end

	

	ratio[period]= Source[1].close[p1]/Source[2].close[p2]
	if period <= first + Period   then
	return;
	end
	
    change[period]=math.log(ratio[period]) - math.log(ratio[period-Period+1])
	
	if period <= first + SmoothPeriod1 + SmoothPeriod2   then
	return;
	end

 	MA1 :update(mode);
 	MA2 :update(mode);
	
    RSI[period] = MA2.DATA[period] * 100.0;
 
    
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
	
	if not loading[1] and not loading[2] then 
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