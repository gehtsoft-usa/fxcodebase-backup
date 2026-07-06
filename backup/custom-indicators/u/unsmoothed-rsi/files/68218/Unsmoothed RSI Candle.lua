-- Id: 13797

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41810

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
    indicator:name("Unsmoothed RSI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
   
   
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "RSI Period", "", 14, 2, 1000);
    
		
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 80);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

	

end
 
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;
local Period;

-- Streams block
local Open = nil;
local Close = nil;
local High = nil;
local Low = nil;

 
-- Routine
function Prepare(nameOnly)
    
    source = instance.source;
	Period=instance.parameters.Period;
	 
    local name = profile:id() .. "(" .. source:name() .. ", " .. Period   .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
  
    assert(core.indicators:findIndicator("UNSMOOTHED RSI") ~= nil, "Please, download and install XEP.LUA indicator");
    
    RSIOpen = core.indicators:create("UNSMOOTHED RSI", source.open, Period);
	RSIHigh = core.indicators:create("UNSMOOTHED RSI", source.high, Period);
	RSILow = core.indicators:create("UNSMOOTHED RSI", source.low, Period);
	RSIClose = core.indicators:create("UNSMOOTHED RSI", source.close, Period);	
	
	first= RSIOpen.DATA:first();

	Open = instance:addStream("Open", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
    Close = instance:addStream("Close", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
    Close:setPrecision(math.max(2, instance.source:getPrecision()));
    High = instance:addStream("High", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
    High:setPrecision(math.max(2, instance.source:getPrecision()));
    Low = instance:addStream("Low", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
    Low:setPrecision(math.max(2, instance.source:getPrecision()));
	instance:createCandleGroup("RSI", "RSI Candle", Open, High, Low, Close);
	
	Open:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Open:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
    
	Open:setPrecision(math.max(2, instance.source:getPrecision()));
end

 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode )  

    RSIOpen:update(mode);
	RSIClose:update(mode);
	RSIHigh:update(mode);
	RSILow:update(mode);
 
	
    if period < first or not  source:hasData(period) then
	return;
	end
	
	
	
        Open[period] = RSIOpen.DATA[period];
        Close[period] = RSIClose.DATA[period];
        High[period] = math.max(Open[period],Close[period],RSIHigh.DATA[period]) ;
        Low[period] = math.min(Open[period],Close[period],RSILow.DATA[period]) ;
	 
end
 
 
