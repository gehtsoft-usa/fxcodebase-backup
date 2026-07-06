--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("RSI gradient indicator");
    indicator:description("RSI gradient indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 14);
    indicator.parameters:addString("RSI_Price", "Price for RSI", "", "close");
    indicator.parameters:addStringAlternative("RSI_Price", "close", "", "close");
    indicator.parameters:addStringAlternative("RSI_Price", "open", "", "open");
    indicator.parameters:addStringAlternative("RSI_Price", "high", "", "high");
    indicator.parameters:addStringAlternative("RSI_Price", "low", "", "low");
    indicator.parameters:addStringAlternative("RSI_Price", "median", "", "median");
    indicator.parameters:addStringAlternative("RSI_Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("RSI_Price", "weighted", "", "weighted");

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
    indicator.parameters:addDouble("Depth", "Depth", "", 0.04);
end

local first;
local source = nil;
local Period;
local RSI_Price;
local UPclr;
local DNclr;
local Depth;
local RSI;
local open=nil;
local close=nil;
local high=nil;
local low=nil;

function Prepare()
    source = instance.source;
    Period=instance.parameters.Period;
    RSI_Price=instance.parameters.RSI_Price;
    UPclr=instance.parameters.UPclr;
    DNclr=instance.parameters.DNclr;
    Depth=instance.parameters.Depth;
     
    if RSI_Price=="close" then
     RSI = core.indicators:create("RSI", source.close, Period);
    elseif RSI_Price=="open" then
     RSI = core.indicators:create("RSI", source.open, Period);
    elseif RSI_Price=="high" then
     RSI = core.indicators:create("RSI", source.high, Period);
    elseif RSI_Price=="low" then
     RSI = core.indicators:create("RSI", source.low, Period);
    elseif RSI_Price=="median" then
     RSI = core.indicators:create("RSI", source.median, Period);
    elseif RSI_Price=="typical" then
     RSI = core.indicators:create("RSI", source.typical, Period);
    else
     RSI = core.indicators:create("RSI", source.weighted, Period);
    end 
	
	first = RSI.DATA:first();
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.RSI_Price .. ")";
    instance:name(name);
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("RSI color candle", "", open, high, low, close);
end

function Update(period, mode)
   if (period>first) then
    RSI:update(mode);
    open[period]=source.open[period];
    close[period]=source.close[period];
    high[period]=source.high[period];
    low[period]=source.low[period];
    if math.abs(RSI.DATA[period]-50)<instance.parameters.Deviation then
     open:setColor(period,instance.parameters.NE_Color);
    else
     local R=0;
     local G=0;
     local B=0;
     local RSIvalue=RSI.DATA[period]-50;
     if RSIvalue>0 then
      if UPclr=="Red" then
       R=math.min(RSIvalue*Depth*255,255);
      elseif UPclr=="Green" then
       G=math.min(RSIvalue*Depth*255,255);
      else
       B=math.min(RSIvalue*Depth*255,255);
      end
     else
      if DNclr=="Red" then
       R=math.min(-RSIvalue*Depth*255,255);
      elseif DNclr=="Green" then
       G=math.min(-RSIvalue*Depth*255,255);
      else
       B=math.min(-RSIvalue*Depth*255,255);
      end
     end
     open:setColor(period,core.rgb(R,G,B));
    end 
   end 
end

