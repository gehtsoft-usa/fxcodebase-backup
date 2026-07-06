-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27706
-- Id: 8110

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Ichimoku Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("ICH Calculation");	
	indicator.parameters:addInteger("TenkanSenPeriod", "Tenkan-sen period", "Tenkan-sen period", 9, 1, 1000);
    indicator.parameters:addInteger("KijunSenPeriod", "Kijun-sen period", "Kijun-sen period", 26, 1, 1000);
    indicator.parameters:addInteger("SenkouSpanPeriod", "Senkou Span B period", "Senkou Span B period", 52, 1, 1000);
	
	indicator.parameters:addGroup("Smoothing Calculation");
	indicator.parameters:addInteger("Period", "Period", "Period" , 7);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");

	indicator.parameters:addGroup("Style");
	 indicator.parameters:addColor("Up", "Color for Up Trend", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Color for Down Trend", "", core.rgb(255, 0, 0));	
	 indicator.parameters:addColor("Neutral", "Color for No Trend", "", core.rgb(255, 255, 0));
	 indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	 
	 indicator.parameters:addColor("Color", "IO Color", "", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Method;
local Short={};

-- Streams block
local Indicator;
local Out = nil;
local Period;
local MA;
local KS;
-- Routine
function Prepare(nameOnly)
   Period = instance.parameters.Period;
	Method = instance.parameters.Method;
    source = instance.source;
    KS= instance.parameters.KijunSenPeriod;

    local name = profile:id() .. "(" .. source:name() .. ")";
	 name = name .. ", " ..  instance.parameters.TenkanSenPeriod .. ", " .. instance.parameters.KijunSenPeriod .. ", " .. instance.parameters.SenkouSpanPeriod.. ", " .. instance.parameters.Method ..")"  ;    
    instance:name(name);
	

    if (not (nameOnly)) then
		Indicator = core.indicators:create("ICH", source,  instance.parameters.TenkanSenPeriod , instance.parameters.KijunSenPeriod , instance.parameters.SenkouSpanPeriod);
   
	   Short["TS"] = Indicator:getStream(0);
	   Short["KS"] = Indicator:getStream(1);
	   Short["CS"] = Indicator:getStream(2);
	   Short["SA"] = Indicator:getStream(3);
	   Short["SB"] = Indicator:getStream(4);
	   
	   first= math.max(Short["SA"]:first(), Short["SB"]:first(), Short["TS"]:first(), Short["KS"]:first(),  Short["CS"]:first()) ;
	   
		
        Out = instance:addStream("IO", core.Bar, name, "Ichimoku Oscillator", instance.parameters.Color, first);
    Out:setPrecision(math.max(2, instance.source:getPrecision()));
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
		MA = core.indicators:create(Method, Out,  Period);
		Singal = instance:addStream("S", core.Line, name, "Singal", instance.parameters.Neutral, MA.DATA:first());
    Singal:setPrecision(math.max(2, instance.source:getPrecision()));
		Singal:setWidth(instance.parameters.width);
        Singal:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   
	 Indicator:update(mode);
	 
	if period < first  then
	return;
	end
	
	
	
	 local   markt=(	Short["CS"][period-KS]-	Short["SA"][period+KS]);
     local   trend=(	Short["TS"][period]- 	Short["KS"][period]);

	  Out[period] =(markt-trend)/ source:pipSize();
	  
	  MA:update(mode);
	  
	if period < MA.DATA:first()  then
	return;
	end
	
    Singal[period]= MA.DATA[period];
	
	 if Singal[period]  > Singal[period-1] 	  
	 then
	   Singal:setColor(period, instance.parameters.Up);  
	  
	 elseif Singal[period]  < Singal[period-1] 	
	 then
	  Singal:setColor(period, instance.parameters.Down);  
	 else
	  Singal:setColor(period, instance.parameters.Neutral);  
	 end
	
       
    
end

