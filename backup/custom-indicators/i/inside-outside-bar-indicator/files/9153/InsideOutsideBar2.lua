
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1838

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Inside/outside bar Indicator");
    indicator:description("Inside/outside bar Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addBoolean("ShowInside", "Show inside bar", "", true);
    indicator.parameters:addBoolean("ShowOutside", "Show outside bar", "", true);
    
    indicator.parameters:addColor("clrDefaultUp", "Default UP bar color", "Default UP bar color", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDefaultDn", "Default DN bar color", "Default DN bar color", core.COLOR_DOWNCANDLE);
    indicator.parameters:addColor("clrInUp", "Inside UP bar color", "Inside UP bar color", core.rgb(255, 255, 0));    
    indicator.parameters:addColor("clrInDn", "Inside DN bar color", "Inside DN bar color", core.rgb(128, 128, 0));
    indicator.parameters:addColor("clrOutUp", "Outside UP bar color", "Outside UP bar color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("clrOutDn", "Outside DN bar color", "Outside DN bar color", core.rgb(0, 0, 128));
end

local first;
local source = nil;
local open=nil;
local close=nil;
local high=nil;
local low=nil;

function Prepare(nameOnly)   
    source = instance.source;
    Percent=instance.parameters.Percent;
    MaxPeriod=instance.parameters.MaxPeriod;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ColorCandle", "", open, high, low, close);
end

function Update(period, mode)
    if (period>first) then
     open[period]=source.open[period];
     close[period]=source.close[period];
     high[period]=source.high[period];
     low[period]=source.low[period];
     if instance.parameters.ShowOutside==true and source.high[period]>source.high[period-1] and source.low[period]<source.low[period-1] then
      if source.close[period]>source.open[period] then
       open:setColor(period, instance.parameters.clrOutUp);
      else
       open:setColor(period, instance.parameters.clrOutDn);
      end
     elseif instance.parameters.ShowInside==true and source.high[period]<source.high[period-1] and source.low[period]>source.low[period-1] then
      if source.close[period]>source.open[period] then
       open:setColor(period, instance.parameters.clrInUp);
      else
       open:setColor(period, instance.parameters.clrInDn);
      end
     else
      if source.close[period]>source.open[period] then
       open:setColor(period, instance.parameters.clrDefaultUp);
      else
       open:setColor(period, instance.parameters.clrDefaultDn);
      end
     end
    end 
end

