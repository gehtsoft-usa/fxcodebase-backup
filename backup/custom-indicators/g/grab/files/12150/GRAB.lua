-- Id: 4207

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
    indicator:name("Grab Candles");
    indicator:description("Grab Candles");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("MA"); 
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
-- Routine
function Prepare(nameOnly) 
    Period = instance.parameters.Period;
    source = instance.source;
	Show = instance.parameters.Show;
	Method = instance.parameters.Method;
    

    local name = profile:id() .. "(" .. source:name() .. ", " .. Method .. ", " .. Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
   
		 
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	 MA["High"] =   core.indicators:create(Method, source.high, Period);	 
	 MA["Low"] =   core.indicators:create(Method, source.low, Period);	 
	 MA["Close"] =   core.indicators:create(Method, source.close, Period);	 
	 
	 first = MA["Low"].DATA:first();
	 
	  Open = instance:addStream("O", core.Line, name .. ".Open", "Open", core.rgb(0, 0, 0), first);
    Close = instance:addStream("C", core.Line, name .. ".Close", "Close", core.rgb(0, 0, 0), first);
    High = instance:addStream("H", core.Line, name .. ".High", "High", core.rgb(0, 0, 0), first);
    Low = instance:addStream("L", core.Line, name .. ".Low", "Low", core.rgb(0, 0, 0), first);
	
	 instance:createCandleGroup("ZONE", "", Open, High, Low, Close);
	
	if Show then
	OUT["High"] = instance:addStream("High", core.Line, name .. ".High", "High", instance.parameters.Short_Up, first);
    OUT["Low"] = instance:addStream("Low", core.Line, name .. ".Low", "Low", instance.parameters.Long_Up, first);
    OUT["Close"] = instance:addStream("Close", core.Line, name .. ".Close", "Close", instance.parameters.Range_Up, first);
	else
	
	OUT["High"] =  instance:addInternalStream (0, 0);
    OUT["Low"] =  instance:addInternalStream (0, 0);
    OUT["Close"] =  instance:addInternalStream (0, 0);
	
	end
   
	 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period < first or not source:hasData(period) then
	return;
	end
	
	MA["High"]:update(mode);
	MA["Low"]:update(mode);
	MA["Close"]:update(mode);
	
	OUT["High"][period]= MA["High"].DATA[period];
	OUT["Low"][period]= MA["Low"].DATA[period];
	OUT["Close"][period]= MA["Close"].DATA[period];	
	
	    Open[period] = source.open[period];
        Close[period] = source.close[period];
        High[period] = source.high[period];
        Low[period] = source.low[period];
	
	
	if source.open[period]<= source.close[period] and source.close[period] > MA["High"].DATA[period] then
	
       Open:setColor(period, instance.parameters.Long_Up);
	elseif 	source.open[period] >= source.close[period] and source.close[period] > MA["High"].DATA[period] then
	
	 Open:setColor(period, instance.parameters.Long_Down);
		
	end	
	
	
	if source.open[period]<= source.close[period] and source.close[period] < MA["Low"].DATA[period] then
	
       Open:setColor(period, instance.parameters.Short_Up);
	elseif 	source.open[period] >= source.close[period] and source.close[period] < MA["Low"].DATA[period] then
	
	Open:setColor(period, instance.parameters.Short_Down);
	end	
    
	
	if source.open[period]<= source.close[period] and source.close[period] < MA["High"].DATA[period] and source.close[period] > MA["Low"].DATA[period] then
	
       Open:setColor(period, instance.parameters.Range_Up);
	elseif 	source.open[period] >=source.close[period] and source.close[period] < MA["High"].DATA[period] and source.close[period] > MA["Low"].DATA[period] then
	
	Open:setColor(period, instance.parameters.Range_Down);
		
	end	
end

