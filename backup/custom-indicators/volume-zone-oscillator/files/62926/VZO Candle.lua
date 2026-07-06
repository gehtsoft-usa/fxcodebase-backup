-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22397
-- Id: 9178

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("VZO Candle");
    indicator:description("VZO Candle");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("Period", "VZO Period", "VZO Period", 6);
	
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 40);
    indicator.parameters:addDouble("oversold","Oversold Level","", -40);
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
local Period;

local first;
local source = nil;

-- Streams block
local Open = nil;
local Close = nil;
local High = nil;
local Low = nil;
local VA;
local open, close, low, high;
local O, C, L, H; 
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	open= instance:addInternalStream(0, 0);
	close= instance:addInternalStream(0, 0);
	low= instance:addInternalStream(0, 0);
	high= instance:addInternalStream(0, 0);
	
		
	VA = core.indicators:create("EMA", source.volume, Period);
	O = core.indicators:create("EMA", open, Period);
	C = core.indicators:create("EMA", close, Period);
	L = core.indicators:create("EMA", low, Period);
	H = core.indicators:create("EMA", high, Period);
   
	first = math.max(VA.DATA:first(),C.DATA:first() );
    Open = instance:addStream("Open", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
    Close = instance:addStream("Close", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
    High = instance:addStream("High", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
    Low = instance:addStream("Low", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
	instance:createCandleGroup("CCI", "CCI Candle", Open, High, Low, Close);
	
	Open:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Open:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);   
	
	Open:setPrecision(math.max(2, instance.source:getPrecision()));
	Close:setPrecision(math.max(2, instance.source:getPrecision()));
	High:setPrecision(math.max(2, instance.source:getPrecision()));
	Low:setPrecision(math.max(2, instance.source:getPrecision()));
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)


    if source.open[period] > source.open[period-1] then
	open[period]= source.volume[period];
	else
	open[period]= -source.volume[period];
	end
	
	
	if source.close[period] > source.close[period-1] then
	close[period]= source.volume[period];
	else
	close[period]= -source.volume[period];
	end
	
	
	if source.high[period] > source.high[period-1] then
	high[period]= source.volume[period];
	else
	high[period]= -source.volume[period];
	end
	
	
	if source.low[period] > source.low[period-1] then
	low[period]= source.volume[period];
	else
	low[period]= -source.volume[period];
	end
	
	 if period < first   then
	return;
	end	
   


    O:update(mode);
	C:update(mode);
	L:update(mode);
	H:update(mode);
	VA:update(mode);

   
   
    
	
 	
        Open[period] = 100 * (O.DATA[period]/ VA.DATA[period]);
        Close[period] = 100 * (C.DATA[period]/ VA.DATA[period]);
        High[period] =   100 * (H.DATA[period]/ VA.DATA[period]) 
        Low[period] =   100 * (L.DATA[period]/ VA.DATA[period] )
   
end
 
