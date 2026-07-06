-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=24044
-- Id: 7591

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
    indicator:name("Sentiment Zone Oscillator");
    indicator:description("Sentiment Zone Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Short Period", "Period", 14);
	 indicator.parameters:addInteger("LongPeriod", "Dynamic Levels Period ", "Period", 30);
	  indicator.parameters:addDouble("Percent", "Dynamic Levels Percent ", "Percent", 95);
	  
	  
	indicator.parameters:addGroup("Style");  
    indicator.parameters:addColor("SZO_color", "Color of SZO", "Color of SZO", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("OB_color", "Color of Dynamic Levels", "Color of Dynamic Levels", core.rgb(0, 255, 0));	
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	indicator.parameters:addBoolean("Show", "Show  Dynamic Levels", "", false);
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addInteger("overbought", "Overbought Level","", 7);
    indicator.parameters:addInteger("oversold","Oversold Level","", -7);
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period, LongPeriod;
local Show;
local first;
local source = nil;
local Percent;
-- Streams block
local SZO = nil;
local R;
local EMA1, EMA2, EMA3;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Show = instance.parameters.Show;
	Percent = instance.parameters.Percent;
	LongPeriod = instance.parameters.LongPeriod;
    source = instance.source;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(LongPeriod) .. ", " .. tostring(Percent).. ")";
    instance:name(name);

    if (not (nameOnly)) then
		R=instance:addInternalStream(source:first()+1, 0);
		
		EMA1 = core.indicators:create("EMA", R, Period);
		EMA2 = core.indicators:create("EMA", EMA1.DATA, Period);
		EMA3 = core.indicators:create("EMA", EMA2.DATA, Period);
		
		 first = EMA3.DATA:first();
        SZO = instance:addStream("SZO", core.Line, name, "SZO", instance.parameters.SZO_color, EMA3.DATA:first());
    SZO:setPrecision(math.max(2, instance.source:getPrecision()));
		SZO:setWidth(instance.parameters.width1);
        SZO:setStyle(instance.parameters.style1);
		SZO:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		SZO:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		
		if Show then
		OB = instance:addStream("OB", core.Line, name, "OB", instance.parameters.OB_color, EMA3.DATA:first() +  LongPeriod);
    OB:setPrecision(math.max(2, instance.source:getPrecision()));
		OB:setWidth(instance.parameters.width2);
        OB:setStyle(instance.parameters.style2);
		OS = instance:addStream("OS", core.Line, name, "OS", instance.parameters.OB_color, EMA3.DATA:first() +  LongPeriod);
    OS:setPrecision(math.max(2, instance.source:getPrecision()));
		OS:setWidth(instance.parameters.width2);
        OS:setStyle(instance.parameters.style2);
		end
		
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

	if period <= source:first() then
	return;
	end

	if source[period]> source[period-1] then
	R[period]= 1;
	else
	R[period]= -1;
	end
	
	 if period < first then
	return;
	end
	
	EMA1:update(mode);
    EMA2:update(mode);
    EMA3:update(mode);
	
	if period < EMA3.DATA:first() then
	return;
	end
	
	local SP =  3 * EMA1.DATA[period] - 3 * EMA2.DATA[period] + EMA3.DATA[period];
	
    SZO[period] = 100 * (SP/ Period);
	
	
	if period < EMA3.DATA:first() +  LongPeriod or not Show then
	return;
	end
	
	
	local HLP,LLP;
	LLP,HLP =  mathex.minmax (SZO, period- LongPeriod+1, period);
	local Range= HLP - LLP;
	
	local Prange= Range *(Percent/100);
    OB[period]= LLP + Prange;
    OS[period]= HLP - Prange;
	
    
end
