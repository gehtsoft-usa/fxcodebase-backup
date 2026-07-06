-- Id: 9949
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59441

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
    indicator:name("Zero-Lag Rainbow");
    indicator:description("Zero-Lag Rainbow");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
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
	indicator.parameters:addGroup("Style");	
	indicator.parameters:addColor("Color", "Color", "Color", core.rgb(255, 0, 0));

    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Number=10;
local Color;
local Period;
local Method;
local first={};
local source = nil;
local ma={};
-- Streams block
local MA = {};
local Avg, FIRST, Zero;
local Weight={5,4,3,2,1,1,1,1,1,1};
local EMA1, EMA2;
local Period2;
-- Routine
function Prepare(nameOnly)
    Color = instance.parameters.Color;
	 
	Method1 = instance.parameters.Method1;
    Period1	 = instance.parameters.Period1;
	Method2 = instance.parameters.Method2;
    Period2	 = instance.parameters.Period2;
    source = instance.source;
	FIRST=source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Number) .. ", " .. tostring(Period1) .. ", " .. tostring(Method1)  .. ", " .. tostring(Period2) .. ", " .. tostring(Method2).. ")";
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
		--Zero = instance:addInternalStream(0, 0);
		
		 Zero = instance:addStream("Zero", core.Line, name, "Zero " ,  Color, EMA2.DATA:first());
		 Zero:setWidth(instance.parameters.width);
         Zero:setStyle(instance.parameters.style);
		
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
  
  
  --(TEMA(ZLRB, smooth)[0] + 2*StdDev(TEMA(ZLRB, smooth),stdevperiod)[0] - WMA(TEMA(ZLRB, s m o o t h ) , s t d e v p e r i o d ) [ 0 ] )  / (4*StdDev(TEMA(ZLRB,  smooth), stdevperiod)[0])*100;
end

 
