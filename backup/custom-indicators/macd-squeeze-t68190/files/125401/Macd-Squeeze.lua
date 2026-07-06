-- Id: 24346
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68190
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

function Init()
    indicator:name("MACD Squeeze");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
   
   indicator.parameters:addGroup("Keltner Calculation");
    indicator.parameters:addInteger("KP", "Period", "", 20);
    indicator.parameters:addDouble("KM", "Deviation", "", 1.5);
	 
    indicator.parameters:addGroup("MACD Calculation");
    indicator.parameters:addInteger("SN", "Short Period", "", 12);
    indicator.parameters:addInteger("LN", "Long Period", "", 26);
	 indicator.parameters:addInteger("SI", "Signal Period", "", 9);
    
	indicator.parameters:addGroup("RSI Calculation");
	 indicator.parameters:addInteger("RN", "RSI Period", "", 14);
	 
	 
	 indicator.parameters:addGroup("Bollinger Calculation");
	 indicator.parameters:addInteger("BN", "Bollinger Period", "", 20);
	 indicator.parameters:addDouble("BM", "Bollinger Deviation", "", 2);
 
	
    indicator.parameters:addGroup("Signal Style");
    indicator.parameters:addColor("Signal", "Line Color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE); 
	
	indicator.parameters:addGroup("MACD Style"); 
	indicator.parameters:addColor("Up1", "Up Line Color", "Line Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down1", "Down Line Color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral1", "Neutral Line Color", "Line Color", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE); 
	
    indicator.parameters:addGroup("OSMA Style"); 
	
	indicator.parameters:addColor("Up2", "Squeeze Bar Color", "Bar Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down2", "Neutral Bar Color", "Bar Color", core.rgb(255, 0, 0));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local SN;
local LN;
local SI;
local RN;

local RSI, rsi;
local MACD,macd;
local bb,BN, BM;
local KP, KM,atr,ma;
-- Routine
function Prepare(nameOnly)
   
   
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
	SI = instance.parameters.SI;
	RN = instance.parameters.RN;
	
	BN= instance.parameters.BN;
	BM= instance.parameters.BM;
	
	KP= instance.parameters.KP;
	KM= instance.parameters.KM;
	

    source = instance.source;
	
       local name = profile:id() .. "(" .. source:name()  .. ", " .. KP .. ", " .. KM .. ", " .. SN .. ", " .. LN   .. ", " ..SI  .. ", " ..BN  .. ", " ..BM.. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	 
	
    assert(core.indicators:findIndicator(BBMethod) ~= nil, BBMethod .. " indicator must be installed");
	--BBMA = core.indicators:create(BBMethod, source.close, N);
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	--MA = core.indicators:create(Method, source.close, A);
 
	macd = core.indicators:create("MACD", source.close, SN, LN, SI);
	rsi = core.indicators:create("RSI", source.close, RN);
	bb = core.indicators:create("BB", source.close, BN, BM);
	atr = core.indicators:create("ATR", source, KP);
	ma = core.indicators:create("MVA", source.close, KP);
	
	first=math.max(macd.SIGNAL:first(), rsi.DATA:first(),bb.DATA:first(),atr.DATA:first());
	
    OSMA = instance:addStream("OSMA", core.Bar, name .. ".OSMA", "OSMA", instance.parameters.Signal, first);
    OSMA:setPrecision(math.max(2, instance.source:getPrecision()));
	MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.Signal, first);
    MACD:setPrecision(math.max(2, instance.source:getPrecision()));
	MACD:setWidth(instance.parameters.width1);
    MACD:setStyle(instance.parameters.style1);
	
    SIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.Signal, first);	
    SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
	SIGNAL:setWidth(instance.parameters.width);
    SIGNAL:setStyle(instance.parameters.style);
	
	end

-- Indicator calculation routine
function Update(period, mode)
   
      macd:update(mode);
	  rsi:update(mode);
	  bb:update(mode);
	  atr:update(mode);
	  ma:update(mode);
	  
	  if period < first then
	  return;
	  end
	  
	 
	 
	 MACD[period]=macd.MACD[period];
     SIGNAL[period]=macd.SIGNAL[period];
	 OSMA[period]= MACD[period]-SIGNAL[period];
 
	 
	 if rsi.DATA[period]> 70 then
	 MACD:setColor(period, instance.parameters.Up1);
	 elseif rsi.DATA[period]< 30 then
	 MACD:setColor(period, instance.parameters.Down1);
	 else
	 MACD:setColor(period, instance.parameters.Neutral1);
	 end

	 
	  local KTL = ma.DATA[period] + atr.DATA[period]*KM
      local KBL = ma.DATA[period] - atr.DATA[period]*KM;
	  
	  
	  if (bb.BL[period]>KBL) and (bb.TL[period]<KTL) then
	  OSMA:setColor(period, instance.parameters.Up2);
	  else
	  OSMA:setColor(period, instance.parameters.Down2);
	  end
	  
	  
	 
end 