-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60263
-- Id: 11038

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
    indicator:name("MACD Squeeze");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 

    indicator.parameters:addGroup("MACD Calculation");
    indicator.parameters:addInteger("SN", "Short EMA", "The period of the short EMA", 8);
    indicator.parameters:addInteger("LN", "Long EMA", "The period of the Long EMA", 21);
    
	indicator.parameters:addGroup("Bollinger Calculation");
	 indicator.parameters:addInteger("N", "Bollinger Period", "", 20);
	 indicator.parameters:addDouble("NM", "Bollinger Deviation", "", 2);
	 indicator.parameters:addString("BBMethod", "Keltner MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("BBMethod", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("BBMethod", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("BBMethod", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("BBMethod", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("BBMethod", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("BBMethod", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("BBMethod", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("BBMethod", "WMA", "WMA" , "WMA");
	 
	 indicator.parameters:addGroup("Keltner Calculation");
	 indicator.parameters:addInteger("A", "Keltner Period", "", 20);
	 indicator.parameters:addDouble("AM", "Keltner Deviation", "", 1.5);
	 indicator.parameters:addInteger("AP", "ATR Period", "", 10);
	 indicator.parameters:addString("Method", "Keltner MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addGroup("MACD Style");
    indicator.parameters:addColor("MACDUP", "Color of UP MACD", "Color of UP MACD", core.rgb(0, 255, 0));
	indicator.parameters:addColor("MACDDOWN", "Color of DOWN MACD", "Color of DOWN MACD", core.rgb(255, 0, 0));
	
	
	 indicator.parameters:addGroup("Component Style");
	  indicator.parameters:addBoolean("Show", "Show Component", "", false);
	  indicator.parameters:addColor("BL", "Color of Bollinger Lines", "Color of Bollinger Lines", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("KL", "Color of Keltner Lines", "Color of Keltner Lines", core.rgb(255, 0, 0));
	 
	  indicator.parameters:addGroup("Squeeze Style");	
    indicator.parameters:addColor("In", "Color of In Squeeze", "Color of Squeeze", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Out", "Color of Out Squeeze", "Color of Squeeze", core.rgb(0, 0, 255));
	 indicator.parameters:addInteger("FontSize", "Font size", "", 10);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local SN;
local LN;
local Method; 
 local BBMethod;
local source = nil;
local first;
local EMAS = nil;
local EMAL = nil;
local Show;
-- Streams block
local MACD = nil;
local N, NM;
local A, AM;
local ATR;
--local Squeeze;
local FontSize;
local BBMA;
local BTL, BBL;
local KTL, KBL;
local In, Out;
local AP;
local font;
function ReleaseInstance()
       core.host:execute("deleteFont", font);
	   
end
-- Routine
function Prepare(nameOnly)
    In= instance.parameters.In;
	Out= instance.parameters.Out;
	AP= instance.parameters.AP;
    Show= instance.parameters.Show;
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
	Method = instance.parameters.Method;
	BBMethod = instance.parameters.BBMethod;
     
	N = instance.parameters.N;
	NM = instance.parameters.NM;
	AM = instance.parameters.AM;
	A = instance.parameters.A;
	FontSize = instance.parameters.FontSize;
    source = instance.source;
	
       local name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. LN   .. ", " .. N .. ", " .. NM .. ", " .. BBMethod .. ", " .. A .. ", " .. AM.. ", " .. AP.. ", " .. Method.. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	font = core.host:execute("createFont", "Wingdings", FontSize, false, false);
	
    assert(core.indicators:findIndicator(BBMethod) ~= nil, BBMethod .. " indicator must be installed");
	 BBMA = core.indicators:create(BBMethod, source.close, N);
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA = core.indicators:create(Method, source.close, A);
	ATR = core.indicators:create("ATR", source, AP);
	EMAS = core.indicators:create("EMA", source.close, SN);
    EMAL = core.indicators:create("EMA", source.close, LN);
	first= math.max(BBMA.DATA:first(), MA.DATA:first(),ATR.DATA:first() ,EMAS.DATA:first(),EMAL.DATA:first() );
	if Show then
	
	BTL= instance:addStream("BTL", core.Line, name .. ".BB Top Line", "BB Top Line", instance.parameters.BL, first);	
    BTL:setPrecision(math.max(2, instance.source:getPrecision()));
	BBL= instance:addStream("BBL", core.Line, name .. ".BB Bottom Line", "BB Bottom Line", instance.parameters.BL, first);	
    BBL:setPrecision(math.max(2, instance.source:getPrecision()));
	 
	
	KTL= instance:addStream("KTL", core.Line, name .. ".Keltner Top Line", "Keltner Top Line", instance.parameters.KL, first);	
    KTL:setPrecision(math.max(2, instance.source:getPrecision()));
	KBL= instance:addStream("KBL", core.Line, name .. ".Keltner Bottom Line", "Keltner Bottom Line", instance.parameters.KL, first);
    KBL:setPrecision(math.max(2, instance.source:getPrecision()));
	
    core.host:execute ("attachOuputToChart", "BTL");	
	core.host:execute ("attachOuputToChart", "BBL");	
	core.host:execute ("attachOuputToChart", "KTL");	
	core.host:execute ("attachOuputToChart", "KBL");	
	
	else
	BTL= instance:addInternalStream(0, 0);
	BBL= instance:addInternalStream(0, 0);
	
	KTL= instance:addInternalStream(0, 0);
	KBL= instance:addInternalStream(0, 0);
	end
	
	
    
	MACD = instance:addStream("MACD", core.Bar, name .. ".MACD", "MACD", instance.parameters.MACDUP, first);	
    MACD:setPrecision(math.max(2, instance.source:getPrecision()));
	end

-- Indicator calculation routine
function Update(period, mode)
   
    MA:update(mode);
 ATR:update(mode);
 EMAS:update(mode);
    EMAL:update(mode);	
	  BBMA:update(mode);
	  
	  if period < first then
	  return;
	  end
	  
	
    CalculateMACD( period);	
	BB(period);
	Keltner(period);
	
	
	if BTL[period] < KTL[period]  and  BBL[period] >KBL[period] then
	core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, 0, core.CR_CHART, core.H_Center, core.V_Center,
                             font, Out, "\108");
    else
     core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, 0, core.CR_CHART, core.H_Center, core.V_Center,
                             font, In, "\108");
	end						 
end

function Keltner(period)

        KTL[period] = MA.DATA[period] + ATR.DATA[period]*AM;
        KBL[period] = MA.DATA[period] - ATR.DATA[period]*AM;
end

function CalculateMACD (period)
	
  
	
      
         MACD[period] = EMAS.DATA[period] - EMAL.DATA[period];
   
		
			if MACD[period] > MACD[period-1] then
			MACD:setColor(period, instance.parameters.MACDUP); 
			else
			MACD:setColor(period, instance.parameters.MACDDOWN); 
			end

function BB(period)

      
		
	    if period < BBMA.DATA:first() then
		return;
		end
		
        local ml = BBMA.DATA[period];
        local d = mathex.stdev(source.close, period - N + 1, period);
        local Dd = NM * d;
        BTL[period] = ml + Dd;
        BBL[period] = ml - Dd;
       
    end

end