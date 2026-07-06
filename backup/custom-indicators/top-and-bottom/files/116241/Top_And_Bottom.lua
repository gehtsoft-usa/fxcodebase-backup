-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65400

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
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
    indicator:name("Top And Bottom indicator");
    indicator:description("Top And Bottom indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Frame", "Frame", "", 2);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Tclr", "Top Color", "Top Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Bclr", "Bottom Color", "Bottom Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);
end

local first;
local source = nil;
local Frame;
local Top, Bottom;

function Prepare(nameOnly) 
    source = instance.source;
    Frame=instance.parameters.Frame;
    first = source:first()+Frame;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Frame .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    Top = instance:addStream("Top", core.Dot, name .. ".Top", "Top", instance.parameters.Tclr, first);
    Bottom = instance:addStream("Bottom", core.Dot, name .. ".Bottom", "Bottom", instance.parameters.Bclr, first);
    Top:setWidth(instance.parameters.DotSize);
    Bottom:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)
   if period>first+Frame then
    local i;
    local IsTop, IsBottom=true, true;

    local period2=period-Frame-1;

    for i=1, Frame, 1 do
      if source.high[period2+i-1]<=source.high[period2+i] or source.high[period2-i+1]<=source.high[period2-i] then
        IsTop=false;
      end
      if source.low[period2+i-1]>=source.low[period2+i] or source.low[period2-i+1]>=source.low[period2-i] then
        IsBottom=false;
      end
    end

    if IsTop then
      Top[period2]=source.high[period2];
    else
      Top[period2]=nil;  
    end

    if IsBottom then
      Bottom[period2]=source.low[period2];
    else
      Bottom[period2]=nil;
    end
   end 
end

