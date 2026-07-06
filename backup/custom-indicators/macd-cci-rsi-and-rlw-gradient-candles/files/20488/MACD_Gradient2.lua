--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("MACD gradient indicator");
    indicator:description("MACD gradient indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ShortEMA", "Short period of EMA", "", 12);
    indicator.parameters:addInteger("LongEMA", "Long period of EMA", "", 26);
    indicator.parameters:addInteger("SignalPeriod", "Signal period", "", 9);
    indicator.parameters:addString("MACD_Price", "Price for MACD", "", "close");
    indicator.parameters:addStringAlternative("MACD_Price", "close", "", "close");
    indicator.parameters:addStringAlternative("MACD_Price", "open", "", "open");
    indicator.parameters:addStringAlternative("MACD_Price", "high", "", "high");
    indicator.parameters:addStringAlternative("MACD_Price", "low", "", "low");
    indicator.parameters:addStringAlternative("MACD_Price", "median", "", "median");
    indicator.parameters:addStringAlternative("MACD_Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("MACD_Price", "weighted", "", "weighted");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addDouble("Deviation", "Deviation", "", 0);
    indicator.parameters:addColor("NE_Color", "Neutral color", "Neutral color", core.rgb(128,128,0));
    indicator.parameters:addString("UPclr", "UP color", "", "Green");
    indicator.parameters:addStringAlternative("UPclr", "Red", "", "Red");
    indicator.parameters:addStringAlternative("UPclr", "Green", "", "Green");
    indicator.parameters:addStringAlternative("UPclr", "Blue", "", "Blue");
    indicator.parameters:addString("DNclr", "DN color", "", "Red");
    indicator.parameters:addStringAlternative("DNclr", "Red", "", "Red");
    indicator.parameters:addStringAlternative("DNclr", "Green", "", "Green");
    indicator.parameters:addStringAlternative("DNclr", "Blue", "", "Blue");
    indicator.parameters:addDouble("Depth", "Depth", "", 1000);
end

local first;
local source = nil;
local ShortEMA;
local LongEMA;
local SignalPeriod;
local MACD_Price;
local UPclr;
local DNclr;
local Depth;
local MACD;
local open=nil;
local close=nil;
local high=nil;
local low=nil;

function Prepare()
    source = instance.source;
    ShortEMA=instance.parameters.ShortEMA;
    LongEMA=instance.parameters.LongEMA;
    SignalPeriod=instance.parameters.SignalPeriod;
    MACD_Price=instance.parameters.MACD_Price;
    UPclr=instance.parameters.UPclr;
    DNclr=instance.parameters.DNclr;
    Depth=instance.parameters.Depth;
    
    if MACD_Price=="close" then
     MACD = core.indicators:create("MACD", source.close, ShortEMA, LongEMA, SignalPeriod);
    elseif MACD_Price=="open" then
     MACD = core.indicators:create("MACD", source.open, ShortEMA, LongEMA, SignalPeriod);
    elseif MACD_Price=="high" then
     MACD = core.indicators:create("MACD", source.high, ShortEMA, LongEMA, SignalPeriod);
    elseif MACD_Price=="low" then
     MACD = core.indicators:create("MACD", source.low, ShortEMA, LongEMA, SignalPeriod);
    elseif MACD_Price=="median" then
     MACD = core.indicators:create("MACD", source.median, ShortEMA, LongEMA, SignalPeriod);
    elseif MACD_Price=="typical" then
     MACD = core.indicators:create("MACD", source.typical, ShortEMA, LongEMA, SignalPeriod);
    else
     MACD = core.indicators:create("MACD", source.weighted, ShortEMA, LongEMA, SignalPeriod);
    end 
	
	first = MACD.HISTOGRAM:first();
	
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.ShortEMA .. ", " .. instance.parameters.LongEMA .. ", " .. instance.parameters.SignalPeriod .. ", " .. instance.parameters.MACD_Price .. ")";
    instance:name(name);
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("MACD color candle", "", open, high, low, close);
end

function Update(period, mode)
   if (period>first) then
    MACD:update(mode);
    open[period]=source.open[period];
    close[period]=source.close[period];
    high[period]=source.high[period];
    low[period]=source.low[period];
    if math.abs(MACD.HISTOGRAM[period])<instance.parameters.Deviation then
     open:setColor(period,instance.parameters.NE_Color);
    else
     local R=0;
     local G=0;
     local B=0;
     local MACDvalue=MACD.HISTOGRAM[period];
     if MACDvalue>0 then
      if UPclr=="Red" then
       R=math.min(MACDvalue*Depth*255,255);
      elseif UPclr=="Green" then
       G=math.min(MACDvalue*Depth*255,255);
      else
       B=math.min(MACDvalue*Depth*255,255);
      end
     else
      if DNclr=="Red" then
       R=math.min(-MACDvalue*Depth*255,255);
      elseif DNclr=="Green" then
       G=math.min(-MACDvalue*Depth*255,255);
      else
       B=math.min(-MACDvalue*Depth*255,255);
      end
     end
     open:setColor(period,core.rgb(R,G,B));
    end 
   end 
end

