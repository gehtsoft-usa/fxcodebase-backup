
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=20495

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
    indicator:name("Custom pattern indicator");
    indicator:description("Custom pattern indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Pattern", "Pattern", "", "UND");
    indicator.parameters:addBoolean("ShowReversePattern", "Show reverse pattern", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Dclr", "Direct pattern color", "Direct pattern color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Rclr", "Reverse pattern color", "Reverse pattern color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);
end

local first;
local source = nil;
local Pattern;
local ShowReversePattern;
local Direct=nil;
local Reverse=nil;
local LengthPattern;

function Prepare(nameOnly)
    source = instance.source;
    Pattern=instance.parameters.Pattern;
	LengthPattern=string.len(Pattern);
    ShowReversePattern=instance.parameters.ShowReversePattern;
    first = source:first()+LengthPattern;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Pattern .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    Direct = instance:addStream("Direct", core.Dot, name .. ".Direct", "Direct", instance.parameters.Dclr, first);
    Direct:setWidth(instance.parameters.DotSize);
    if (ShowReversePattern) then
     Reverse = instance:addStream("Reverse", core.Dot, name .. ".Reverse", "Reverse", instance.parameters.Rclr, first);
     Reverse:setWidth(instance.parameters.DotSize);
    end
    
end

function DirectPattern(period)
 local i;
 local Fl=true;
 local s;
 for i=1,LengthPattern,1 do
  s=string.sub(Pattern,LengthPattern-i+1,LengthPattern-i+1);
  if string.upper(s)=="U" and source.close[period-i+1]<=source.open[period-i+1] then
   Fl=false;
  end
  if string.upper(s)=="D" and source.close[period-i+1]>=source.open[period-i+1] then
   Fl=false;
  end
 end
 return Fl;
end

function ReversePattern(period)
 local i;
 local Fl=true;
 local s;
 for i=1,LengthPattern,1 do
  s=string.sub(Pattern,LengthPattern-i+1,LengthPattern-i+1);
  if string.upper(s)=="U" and source.close[period-i+1]>=source.open[period-i+1] then
   Fl=false;
  end
  if string.upper(s)=="D" and source.close[period-i+1]<=source.open[period-i+1] then
   Fl=false;
  end
 end
 return Fl;
end

function Update(period, mode)
   if (period>first) then
    if DirectPattern(period) then
     Direct[period]=source.high[period];
    end
    if ShowReversePattern then
     if ReversePattern(period) then
      Reverse[period]=source.high[period];
     end
    end
   end 
end

