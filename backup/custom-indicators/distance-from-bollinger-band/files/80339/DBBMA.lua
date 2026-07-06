-- Id: 9527
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=52853

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

-- The indicator corresponds to the Bollinger Bands indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 5 "Trend System" (page 91-94)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Distance from Bollinger Band (Moving Average)");
    indicator:description("Provides a Distance  between Moving Average of Price and Bollinger Bands.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Bollinger Band Parameters");
    indicator.parameters:addInteger("N", "Number of periods", "Number of periods", 20);
    indicator.parameters:addDouble("Dev", "Number of standard deviations", "Number of standard deviations", 2);
	
	indicator.parameters:addGroup("Moving Average Parameters");
	indicator.parameters:addInteger("Period", "Number of periods", "Number of periods",10);
	
	indicator.parameters:addString("MaMethod", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("MaMethod", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MaMethod", "EMA", "EMA" , "EMA");
  indicator.parameters:addStringAlternative("MaMethod", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MaMethod", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MaMethod", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MaMethod", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MaMethod", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MaMethod", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addString("Method", "Presentation Method", "Method" , "Percentage");
    indicator.parameters:addStringAlternative("Method", "Percentage", "Percentage" , "Percentage");
    indicator.parameters:addStringAlternative("Method", "Pip", "Pip" , "Pip");
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Distance from Top Line color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("clr2", "Distance from Bottom Line color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);

    indicator.parameters:addGroup("Levels");
    indicator.parameters:addColor("clrL", "Line color", "", core.rgb(192, 192, 192));
    indicator.parameters:addInteger("widthL", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleL", "Line style", "", core.LINE_DOT);
    indicator.parameters:setFlag("styleL", core.FLAG_LINE_STYLE);
    indicator.parameters:addBoolean("customLevels", "Show Custom Levels", "You can specify two levels in addition to 0/50/100", false);
    indicator.parameters:addDouble("customLevel1", "First custom level", "", 40, 0, 100);
    indicator.parameters:addDouble("customLevel2", "Second custom level", "", 60, 0, 100);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local D;
local Method;
local firstPeriod;
local source = nil;
local Period,MaMethod;
-- Streams block
local TL = nil;
local AL = nil;
local BL = nil;
local MA;
local Bottom, Top;

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
	Period= instance.parameters.Period;
	MaMethod= instance.parameters.MaMethod;
    D = instance.parameters.Dev;
	Method = instance.parameters.Method;
    source = instance.source;
    firstPeriod = source:first() + N - 1;
	
    local name;
    name = profile:id() .. "(" .. source:name() .. "," .. N .. ", " .. D.. ", " .. Method.. ", " .. Period.. ", " ..MaMethod.. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    MA = core.indicators:create(MaMethod, source, Period);

    -- TOP LINE AND BOTTOM LINE INTERNAL STREAMS
    TL = instance:addInternalStream(firstPeriod)
    BL = instance:addInternalStream(firstPeriod)
    AL = instance:addInternalStream(firstPeriod)

    -- PERCENTAGE LINE
    Top = instance:addStream("TOP", core.Line, name .. ".Top", "Top", instance.parameters.clr1, MA.DATA:first());
    Top:setWidth(instance.parameters.width1);
    Top:setStyle(instance.parameters.style1);
	
	 Bottom = instance:addStream("BOTTOM", core.Line, name .. ".Bottom", "Bottom", instance.parameters.clr2, MA.DATA:first());
    Bottom:setWidth(instance.parameters.width2);
    Bottom:setStyle(instance.parameters.style2);
	
	
	
	

    Top:addLevel(0, instance.parameters.styleL, instance.parameters.widthL, instance.parameters.clrL);
	
	if Method ~= "Pip" then
   Top:addLevel(50, instance.parameters.styleL, instance.parameters.widthL, instance.parameters.clrL);  
   Top:addLevel(100, instance.parameters.styleL, instance.parameters.widthL, instance.parameters.clrL);
   end

    if (instance.parameters.customLevels) then
        Top:addLevel(instance.parameters.customLevel1, instance.parameters.styleL, instance.parameters.widthL, instance.parameters.clrL);
        Top:addLevel(instance.parameters.customLevel2, instance.parameters.styleL, instance.parameters.widthL, instance.parameters.clrL);
    end
	
	Top:setPrecision(math.max(2, instance.source:getPrecision()));
	Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
function Update(period, mode)
     
      

    -- CALCULATE "Bollinger Bands" INTERNAL STREAMS
    if(period >= firstPeriod) then
        local p = core.rangeTo(period, N);
        local ml = core.avg(source, p);
        local d = core.stdev(source, p);

        TL[period] = ml + D * d;
        BL[period] = ml - D * d;
        AL[period] = ml;
    end

    -- CALCULATE "Bollinger Bands" PERCENTAGE STREAM
    if(period < firstPeriod) then
	return;
	end
	
	
	 MA:update(mode);
	 
	 if(period < MA.DATA:first()) then
	return;
	end
	
	if Method ~= "Pip" then
        Top[period] = ((TL[period]-MA.DATA[period]) / (TL[period] - BL[period])) * 100;
		Bottom[period] = ((MA.DATA[period]-BL[period]) / (TL[period] - BL[period])) * 100;
   else
        Top[period] = (TL[period]-MA.DATA[period]) / source:pipSize();
		Bottom[period] = (MA.DATA[period]-BL[period]) / source:pipSize() ;
   end
end





