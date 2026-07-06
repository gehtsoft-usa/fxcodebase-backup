-- Id: 13861
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62038

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Modified RSI");
    indicator:description("Modified RSI");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	 
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addDouble("Multiplier", "Multiplier", "Multiplier", 1.5);
	indicator.parameters:addString("Method", "Bar Color Method", "Method" , "Zero");
    indicator.parameters:addStringAlternative("Method", "Zero", "Zero" , "Zero");
    indicator.parameters:addStringAlternative("Method", "Previous", "Previous" , "Previous");
	indicator.parameters:addStringAlternative("Method", "Signal", "Signal" , "Signal");
    indicator.parameters:addStringAlternative("Method", "Not Used", "Not Used" , "Not Used");
	
	indicator.parameters:addInteger("MA_Period", "Signal MA Period", "Period", 14);
	
	indicator.parameters:addString("MA_Method", "Signal MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("MA_Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MA_Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MA_Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MA_Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MA_Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MA_Method", "WMA", "WMA" , "WMA");

	
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("RSI_color", "Color of RSI", "Color of RSI", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Signal_color", "Color of Signal", "Color of Signal", core.rgb(0, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Up_color", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down_color", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought1", "1. Overbought Level","",10);
    indicator.parameters:addDouble("oversold1","1. Oversold Level","", -10);
	  indicator.parameters:addDouble("overbought2", "2. Overbought Level","",50);
    indicator.parameters:addDouble("oversold2","2. Oversold Level","", -50);
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
local MA_Period, MA_Method;
local first;
local source = nil;
local Multiplier;
-- Streams block
local RSI = nil;
local rsi;
local Method;
local Signal, signal;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period; 	
    Multiplier= instance.parameters.Multiplier;
	Method= instance.parameters.Method;
	MA_Method= instance.parameters.MA_Method;
	MA_Period= instance.parameters.MA_Period;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Method).. ", " .. tostring(MA_Period) .. ", " .. tostring(MA_Method).. ")";
    instance:name(name);

    if (not (nameOnly)) then
		rsi = core.indicators:create("RSI", source, Period);
		first = rsi.DATA:first();
        RSI = instance:addStream("RSI", core.Line, name, "RSI", instance.parameters.RSI_color, first);
    RSI:setPrecision(math.max(2, instance.source:getPrecision()));
		if Method~= "Not Used" then
		Bar = instance:addStream("Bar", core.Bar, name, "Bar", instance.parameters.RSI_color, first);
    Bar:setPrecision(math.max(2, instance.source:getPrecision()));
		else
		Bar = instance:addInternalStream(0, 0);
		end
		RSI:addLevel(instance.parameters.oversold1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		RSI:addLevel(instance.parameters.overbought1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
		RSI:addLevel(instance.parameters.oversold2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		RSI:addLevel(instance.parameters.overbought2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
        RSI:setWidth(instance.parameters.width1);
        RSI:setStyle(instance.parameters.style1);
		
    assert(core.indicators:findIndicator(MA_Method) ~= nil, MA_Method .. " indicator must be installed");
		signal = core.indicators:create(MA_Method, RSI, MA_Period);

        Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.Signal_color,  signal.DATA:first() );		
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setWidth(instance.parameters.width2);
        Signal:setStyle(instance.parameters.style2);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    rsi:update(mode);
	signal:update(mode);

    if period < first or not  source:hasData(period) then
	return;
	end
	
        RSI[period] = (rsi.DATA[period]-50)*Multiplier;
        Bar[period] = RSI[period];
	
    if Method == "Zero" then	
		if RSI[period]> 0 then
		Bar:setColor(period, instance.parameters.Up_color);
	    else
		Bar:setColor(period, instance.parameters.Down_color);
		end
	elseif Method == "Previous" then
	    if RSI[period]> RSI[period-1] then
		Bar:setColor(period, instance.parameters.Up_color);
	    else
		Bar:setColor(period, instance.parameters.Down_color);
		end
	end

	
	if period < signal.DATA:first() then
	return;
	end
	
	Signal[period]= signal.DATA[period];
	
		if Method == "Signal" then
	    if RSI[period]> Signal[period] then
		Bar:setColor(period, instance.parameters.Up_color);
	    else
		Bar:setColor(period, instance.parameters.Down_color);
		end	
    end	
	
end

