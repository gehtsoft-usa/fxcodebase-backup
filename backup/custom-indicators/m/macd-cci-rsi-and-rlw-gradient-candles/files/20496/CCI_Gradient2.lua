--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("CCI gradient indicator");
    indicator:description("CCI gradient indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 14);

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
    indicator.parameters:addDouble("Depth", "Depth", "", 0.005);
end

local first;
local source = nil;
local Period;
local UPclr;
local DNclr;
local Depth;
local CCI;
local open=nil;
local close=nil;
local high=nil;
local low=nil;

function Prepare()
    source = instance.source;
    Period=instance.parameters.Period;
    UPclr=instance.parameters.UPclr;
    DNclr=instance.parameters.DNclr;
    Depth=instance.parameters.Depth;
     
    CCI = core.indicators:create("CCI", source, Period);
	first = CCI.DATA:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("CCI color candle", "", open, high, low, close);
end

function Update(period, mode)
   if (period>first) then
    CCI:update(mode);
    open[period]=source.open[period];
    close[period]=source.close[period];
    high[period]=source.high[period];
    low[period]=source.low[period];
    if math.abs(CCI.DATA[period])<instance.parameters.Deviation then
     open:setColor(period,instance.parameters.NE_Color);
    else
     local R=0;
     local G=0;
     local B=0;
     local CCIvalue=CCI.DATA[period];
     if CCIvalue>0 then
      if UPclr=="Red" then
       R=math.min(CCIvalue*Depth*255,255);
      elseif UPclr=="Green" then
       G=math.min(CCIvalue*Depth*255,255);
      else
       B=math.min(CCIvalue*Depth*255,255);
      end
     else
      if DNclr=="Red" then
       R=math.min(-CCIvalue*Depth*255,255);
      elseif DNclr=="Green" then
       G=math.min(-CCIvalue*Depth*255,255);
      else
       B=math.min(-CCIvalue*Depth*255,255);
      end
     end
     open:setColor(period,core.rgb(R,G,B));
    end 
   end 
end

