-- Id: 23030
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67033
-- Id:  

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

-- Indicator profile initialization routine
 
function Init()
    indicator:name("Double average Volume Candlesticks");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 125);
	 indicator.parameters:addDouble("Multiplier", "Multiplier", "", 2);
    indicator.parameters:addString("Method", "MA Method", "Method" , "WMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addBoolean("Color", "Candle Color", "", true);
	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up Color","Up Color", core.COLOR_UPCANDLE );
	indicator.parameters:addColor("Down", "Down Color","Down Color", core.COLOR_DOWNCANDLE );
	indicator.parameters:addColor("Neutral", "Neutral Color","Neutral Color", core.rgb(128,128,128));
	indicator.parameters:addColor("Label", "Label Color","Label Color", core.COLOR_LABEL);
	indicator.parameters:addInteger("Size", "Label Size","Size Color", 15);
	
	indicator.parameters:addColor("Bullish", "Bullish Color","Bullish Color", core.rgb(0,128,255) );
	indicator.parameters:addColor("Bearish", "Bearish Color","Bearish Color", core.rgb(255,128,0));

	
end 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Period, Method,MA;
 

local first;
local source = nil;

-- Streams block
 
local open=nil;
local close=nil;
local high=nil;
local low=nil;
local Up, Down, Neutral,Label,Color,Bearish,Bullish;
local font,Size;
local Multiplier;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    Method= instance.parameters.Method;
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Neutral = instance.parameters.Neutral; 
	Color = instance.parameters.Color;
	Multiplier= instance.parameters.Multiplier;
	
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", "  .. Period .. ", " .. Method .. ", " .. Multiplier.. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	Label = instance.parameters.Label;
	Size = instance.parameters.Size;
	Bearish = instance.parameters.Bearish;
	Bullish = instance.parameters.Bullish;
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    MA = core.indicators:create(Method, source.volume, Period);
    first = MA.DATA:first() ;	
	
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
	
	font = core.host:execute("createFont", "Courier", Size, true, false);
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);
end
	   

-- Indicator calculation routine
function Update(period, mode)


    MA:update(mode);
	
	
	high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	
	
	
	
	core.host:execute ("removeLabel", source:serial(period));
	
	
	
	
	
	if period < first   then
	open:setColor(period, Neutral);		
	return;
	end 
 
	
	if not Color then
		if source.close[period]> source.open[period] then
		open:setColor(period, Up);		
		elseif source.close[period]< source.open[period] then
		open:setColor(period, Down);
		else
		open:setColor(period, Neutral);	
		end
	end
	
	if  (source.volume[period] < (Multiplier*MA.DATA[period])) then
	
	    if source.close[period]> source.open[period] then
		open:setColor(period, Up);		
		elseif source.close[period]< source.open[period] then
		open:setColor(period, Down);
		else
		open:setColor(period, Neutral);	
		end
	
	return;
	end
	
	local Ratio =  source.volume[period]/MA.DATA[period];
	
	
	if source.close[period]> source.open[period] then
	core.host:execute ("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.high[period],core.CR_CHART,core.H_Center, core.V_Top, font, Label, win32.formatNumber(Ratio, false, 0));  
		if Color then
		open:setColor(period, Bullish);	
		end
	else 
	core.host:execute ("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.high[period],core.CR_CHART,core.H_Center, core.V_Bottom, font, Label, win32.formatNumber(Ratio, false, 0)) ; 
		if Color then
		open:setColor(period, Bearish);	
		end	
		
	end
				  
 end
 
 