-- Id: 9966
-- More information about this indicator can be found at:
-- http://fxcodebase.com/

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
    indicator:name("SVEZLRBPercB");
    indicator:description("SVEZLRBPercB");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	 
    indicator.parameters:addInteger("Period1", "MA Period", "MA Period", 2);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	 indicator.parameters:addInteger("Period2", "MA Period", "MA Period", 7);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	
	 indicator.parameters:addInteger("Period3", "Deviation Period", "Deviation Period", 18)
	 
	 
	indicator.parameters:addGroup("Style");	
	indicator.parameters:addColor("Color", "Color", "Color", core.rgb(255, 0, 0));

    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 100);
    indicator.parameters:addDouble("oversold","Oversold Level","", 0);
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
local Top, Bottom;
local Number=10;
local Color;
local Period1,Period3;
local Method;
local first={};
local source = nil;
local ma={};
-- Streams block
local MA = {};
local Avg, FIRST, Zero, Out;
local Weight={5,4,3,2,1,1,1,1,1,1};
local EMA1, EMA2;
local Period2, TEMA, WMA;
-- Routine
function Prepare(nameOnly)
    Color = instance.parameters.Color;
	 
	Method1 = instance.parameters.Method1;
    Period1	 = instance.parameters.Period1;
	Period3 = instance.parameters.Period3;
	Method2 = instance.parameters.Method2;
    Period2	 = instance.parameters.Period2;
    source = instance.source;
	FIRST=source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Number) .. ", " .. tostring(Period1) .. ", " .. tostring(Method1)  .. ", " .. tostring(Period2) .. ", " .. tostring(Method2).. ", " .. tostring(Period3).. ")";
    instance:name(name);

    if (not (nameOnly)) then
		local i;
		for i = 1, Number, 1 do
			if i == 1 then
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
			ma[i] = core.indicators:create(Method1, source, Period1);
			else
			ma[i] = core.indicators:create(Method1, ma[i-1].DATA, Period1);
			end
			first[i] = ma[i].DATA:first();
			FIRST= math.max(FIRST,first[i] );
			MA[i]= instance:addInternalStream(0, 0);
        end
		Avg = instance:addInternalStream(0, 0);
		
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
		EMA1 = core.indicators:create(Method2, Avg,Period2);
		EMA2 = core.indicators:create(Method2, EMA1.DATA, Period2);		
		Zero = instance:addInternalStream(0, 0);
		
		
		ema1 = core.indicators:create("EMA", Zero, Period2);
        ema2 = core.indicators:create("EMA", ema1.DATA, Period2);
        ema3 = core.indicators:create("EMA", ema2.DATA, Period2);
		
		TEMA= instance:addInternalStream(0, 0);
		
		
		
		WMA = core.indicators:create("WMA", TEMA,Period3);
		
		Out = instance:addStream("Central", core.Line, name, "Central " ,  Color, WMA.DATA:first());
    Out:setPrecision(math.max(2, instance.source:getPrecision()));
		Out:setWidth(instance.parameters.width);
        Out:setStyle(instance.parameters.style);
		Out:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		Out:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);   

		
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if not source:hasData(period) then
	return;
	end
	
	local i;	
	local Sum=0;
	local Num=0;
	for i = 1, Number, 1 do	
	 ma[i]:update(mode); 
	 if period >= first[i]  then
	 MA[i][period] = ma[i].DATA[period];
	 Num= Num+Weight[i];
	 Sum=Sum+ma[i].DATA[period]*Weight[i] ;
	 end
	end
       
    if period <FIRST then
	return;
	end
	
	Avg[period]= Sum / Num;
	
    EMA1:update(mode); 
	EMA2:update(mode); 
	
	if period < EMA2.DATA:first() then
	return;
	end
	
 
  local diff = EMA1.DATA[period] - EMA2.DATA[period];
  Zero[period]=(EMA1.DATA[period] + diff);
  
  
    ema1:update(mode); 
	ema2:update(mode); 
	ema3:update(mode);
	
    if period < ema3.DATA:first() then
	return;
	end
	
	
    TEMA[period] = 3 * ema1.DATA[period] - 3 * ema2.DATA[period] + ema3.DATA[period];
	
	WMA:update(mode);
 
    if period < WMA.DATA:first()+ Period3 then
	return;
	end
	
	local Dev =  mathex.stdev (TEMA, period-Period3, period);
	Out[period]=  100*(TEMA[period]+2*Dev-WMA.DATA[period])/(4*Dev);
 
end

 
