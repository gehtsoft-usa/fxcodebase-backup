-- Id: 8489
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=31949

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
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("MACD OF RELATIVE STRENGTH");
    indicator:description("MACD OF RELATIVE STRENGTH");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addString("Index", "Index instrument", "", "");
    indicator.parameters:setFlag("Index", core.FLAG_INSTRUMENTS);
	


     indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Length", "Length", "Length", 10);
	
    indicator.parameters:addInteger("FastMA", "FastMA", "FastMA", 12);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addInteger("SlowMA", "SlowMA", "SlowMA", 25);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addInteger("MacdMA", "MacdMA", "MacdMA", 9);
	indicator.parameters:addString("Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
	
	 indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("MACD_color", "Color of MACD", "Color of MACD", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("SIGNAL_color", "Color of SIGNAL", "Color of SIGNAL", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("HISTOGRAM_color", "Color of HISTOGRAM", "Color of HISTOGRAM", core.rgb(0, 0, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Length;
local FastMA;
local SlowMA;
local MacdMA;

local first;
local source = nil;
local Index;
-- Streams block
local MACD = nil;
local SIGNAL = nil;
local Method3,Method2, Method1;
local loading;
local Source;
local offset, weekoffset;
local MA1,MA2, MA3, RS,HISTOGRAM;
-- Routine
function Prepare(nameOnly)


	Method3 = instance.parameters.Method3;
	Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
	
    Length = instance.parameters.Length;
    FastMA = instance.parameters.FastMA;
    SlowMA = instance.parameters.SlowMA;
    MacdMA = instance.parameters.MacdMA;
	Index = instance.parameters.Index;
    source = instance.source;
    first = source:first()+Length;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Length) .. ", " .. tostring(FastMA).. ", " .. tostring(Method1) .. ", " .. tostring(SlowMA).. ", " .. tostring(Method2) .. ", " .. tostring(MacdMA).. ", " .. tostring(Method3) .. ")";
    instance:name(name);

	if   (nameOnly) then
        return;
    end
	
	offset = core.host:execute("getTradingDayOffset");
    weekoffset =  core.host:execute("getTradingWeekOffset");
	
	 Source = core.host:execute("getSyncHistory", Index, source:barSize(), source:isBid(), math.min(300,Length) ,  2 , 1);
	 loading = true;  
	 

	RS = instance:addInternalStream(0, 0); 
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
	MA1 = core.indicators:create(Method1, RS, FastMA);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
	MA2 = core.indicators:create(Method2, RS, SlowMA);
	


 
        MACD = instance:addStream("MACD", core.Line, name .. ".Diff", "Diff", instance.parameters.MACD_color, first);
    MACD:setPrecision(math.max(2, instance.source:getPrecision()));
		MACD:setWidth(instance.parameters.width1);
        MACD:setStyle(instance.parameters.style1);
		
    assert(core.indicators:findIndicator(Method3) ~= nil, Method3 .. " indicator must be installed");
		MA3 = core.indicators:create(Method3, MACD, MacdMA);
        SIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".Signal", "Signal", instance.parameters.SIGNAL_color, first);
    SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
		SIGNAL:setWidth(instance.parameters.width2);
        SIGNAL:setStyle(instance.parameters.style2);
		
		HISTOGRAM = instance:addStream("HISTOGRAM", core.Bar, name .. ".Histogram", "Histogram", instance.parameters.HISTOGRAM_color, first);
    HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
  
	core.host:execute ("setStatus", "")
	
	if loading then
	core.host:execute ("setStatus", "Loading")
	return;
    else
    core.host:execute ("setStatus", "Loaded")
	end
	
	if period < first then
	return;
	end
	
	
	 local p1 =  Initialization(period); 
	 local p2 =  Initialization(period-Length); 
     
	 if not p1 
	 or not p2  
	 or p1 < first 
	 or p2 < first 	 
	 then
	 return;
	 end
	
	

	local RSFAgo = source.close[period-Length]/  Source.close[p2];	
	local RSF = (source.close[period] / Source.close[p1]) * 100;	
	 RS[period] = RSFAgo / RSF;
	 
	 
   MA1:update(mode);
   MA2:update(mode);

	if period < MA1.DATA:first() 
	or period < MA2.DATA:first()
	then
	return
	end
	
	
	
        MACD[period] = MA1.DATA[period]- MA2.DATA[period];
		
		MA3:update(mode);
		
	if period < MA3.DATA:first() 
	then
	return
	end	
		
        SIGNAL[period] =  MA3.DATA[period];
		HISTOGRAM[period]= MACD[period]-SIGNAL[period];
    
end


function AsyncOperationFinished(cookie)

			 
			  if cookie == 1 then
			  loading = true;
			  core.host:execute ("setStatus", "Loading")
		      elseif  cookie == 2 then
			  loading = false;  
			  instance:updateFrom(0);			  
			  end
		       
       	   

    return core.ASYNC_REDRAW ;
end


function   Initialization(period)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), offset, weekoffset);

  
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

