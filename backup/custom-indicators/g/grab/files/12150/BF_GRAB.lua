-- Id: 19861

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4893

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
    indicator:name("Biger Time Frame Grab Candles");
    indicator:description("Grab Candles");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("MA"); 
	indicator.parameters:addString("TF", "Time frame to calculate CCI", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
    indicator.parameters:addInteger("Period", "Period", "Period", 34);   
	
		indicator.parameters:addString("Method", "Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addBoolean("Show", "Show MA Lines", "", true);
    indicator.parameters:addColor("Short_Up", "Color of Down Trend Up", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Short_Down", "Color of Down Trend Down", "", core.rgb(200, 0, 0));
    indicator.parameters:addColor("Long_Up", "Color of Up Trend Up", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("Long_Down", "Color of Up Trend Down", "", core.rgb(0, 200, 0));
    indicator.parameters:addColor("Range_Up", "Color of Range Up", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Range_Down", "Color of Range Down", "", core.rgb(100, 100, 100));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;

-- Streams block
local Open = nil;
local Close = nil;
local High = nil;
local Low = nil;
local Method;


local MA={};
local OUT={};
local Show;

local TF;
local Source;
local loading;
local dayoffset,weekoffset;
local Volume;
local Last;
-- Routine
function Prepare(nameOnly) 
    Period = instance.parameters.Period;
    source = instance.source;
	Show = instance.parameters.Show;
	Method = instance.parameters.Method;
	TF = instance.parameters.TF;
    
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. Method .. ", " .. Period .. ")";
    instance:name(name);
   
    if   (nameOnly) then
        return;
    end
	
   local s, e, s1, e1;

    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(TF, core.now(), 0, 0);
    assert ((e - s) <= (e1 - s1), "The chosen time frame must be bigger than the chart time frame!");
    
	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), Period, 100, 101);
	loading=true;
	
		 
	 MA["High"] =   core.indicators:create(Method, Source.high, Period);	 
	 MA["Low"] =   core.indicators:create(Method, Source.low, Period);	 
	 MA["Close"] =   core.indicators:create(Method, Source.close, Period);	 
	 
	 first = MA["Low"].DATA:first();
	 
	  Open = instance:addStream("O", core.Line, name .. ".Open", "Open", core.rgb(0, 0, 0), first);
    Close = instance:addStream("C", core.Line, name .. ".Close", "Close", core.rgb(0, 0, 0), first);
    High = instance:addStream("H", core.Line, name .. ".High", "High", core.rgb(0, 0, 0), first);
    Low = instance:addStream("L", core.Line, name .. ".Low", "Low", core.rgb(0, 0, 0), first);
	Volume = instance:addStream("V", core.Line, name .. ".Volume", "Volume", core.rgb(0, 0, 0), first);
	 instance:createCandleGroup("ZONE", "", Open, High, Low, Close,Volume, TF);
	
	if Show then
	OUT["High"] = instance:addStream("High", core.Line, name .. ".High", "High", instance.parameters.Short_Up, first);
    OUT["Low"] = instance:addStream("Low", core.Line, name .. ".Low", "Low", instance.parameters.Long_Up, first);
    OUT["Close"] = instance:addStream("Close", core.Line, name .. ".Close", "Close", instance.parameters.Range_Up, first);
	else
	
	OUT["High"] =  instance:addInternalStream (0, 0);
    OUT["Low"] =  instance:addInternalStream (0, 0);
    OUT["Close"] =  instance:addInternalStream (0, 0);
	
	end
    
	
	OUT:setPrecision(math.max(2, instance.source:getPrecision()));	
	
	Open:setPrecision(math.max(2, instance.source:getPrecision()));	
	Close:setPrecision(math.max(2, instance.source:getPrecision()));	
	High:setPrecision(math.max(2, instance.source:getPrecision()));	
	Low:setPrecision(math.max(2, instance.source:getPrecision()));	
	Volume:setPrecision(math.max(2, instance.source:getPrecision()));	
	
	 Last=nil;
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
local Index;
function Update(period,mode)
    
	     local p =  Initialization(period) 
     
	    if not p then
		return;
		end
		
		
	MA["High"]:update(mode);
	MA["Low"]:update(mode);
	MA["Close"]:update(mode);
	
	OUT["High"][period]= MA["High"].DATA[p];
	OUT["Low"][period]= MA["Low"].DATA[p];
	OUT["Close"][period]= MA["Close"].DATA[p];	
	
		
	if Last~=p then
	Last=p;
	Index=period;
	end
	
	
	if period < first or not source:hasData(period) then
	return;
	end
	
	
	
	    Volume[Index]=Source.volume[p]; 
	    Open[Index] = Source.open[p];
        Close[Index] = Source.close[p];
        High[Index] = Source.high[p];
        Low[Index] = Source.low[p];
	
	
	if Source.open[p]<= Source.close[p] and Source.close[p] > MA["High"].DATA[p] then
	
       Open:setColor(Index, instance.parameters.Long_Up);
	elseif 	Source.open[p] >= Source.close[p] and Source.close[p] > MA["High"].DATA[p] then
	
	 Open:setColor(Index, instance.parameters.Long_Down);
		
	end	
	
	
	if Source.open[p]<= Source.close[p] and Source.close[p] < MA["Low"].DATA[p] then
	
       Open:setColor(Index, instance.parameters.Short_Up);
	elseif 	Source.open[p] >= Source.close[p] and Source.close[p] < MA["Low"].DATA[p] then
	
	Open:setColor(Index, instance.parameters.Short_Down);
	end	
    
	
	if Source.open[p]<= Source.close[p] and Source.close[p] < MA["High"].DATA[p] and Source.close[p] > MA["Low"].DATA[p] then
	
       Open:setColor(Index, instance.parameters.Range_Up);
	elseif 	Source.open[p] >=Source.close[p] and Source.close[p] < MA["High"].DATA[p] and Source.close[p] > MA["Low"].DATA[p] then
	
	Open:setColor(Index, instance.parameters.Range_Down);
		
	end	
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



function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end
