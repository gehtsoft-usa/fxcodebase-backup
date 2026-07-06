-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65399

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
    indicator:name("Fractal Engulfing Candle Indicator");
    indicator:description("Fractal Engulfing Candle Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Frame", "Frame", "", 2);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Tclr", "Up Color", "Up Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Bclr", "Down Color", "Down Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);

    indicator.parameters:addGroup("Alerts Sound"); 
    indicator.parameters:addBoolean("ChartAlert", "Chart alert", "", true);  
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);  
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
    indicator.parameters:addFile("AlertSound", "Alert Sound", "", "");
    indicator.parameters:setFlag("AlertSound", core.FLAG_SOUND);
    indicator.parameters:addBoolean("SendEmail", "Send email", "", false);
    indicator.parameters:addString("Email", "Email address", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local first;
local source = nil;
local Frame;
local Top, Bottom;
local AlertTime;

function Signal(Msg)
 if AlertTime==source:date(source:size()-1) then
  return;
 end
 AlertTime=source:date(source:size()-1);
  if instance.parameters.ChartAlert then
   core.host:execute("prompt", 1, "Alert" , Msg);
  end
  
  if instance.parameters.PlaySound then
   terminal:alertSound(instance.parameters.AlertSound, instance.parameters.RecurrentSound); 
  end

  if instance.parameters.SendEmail then
    terminal:alertEmail(instance.parameters.Email, "Fractal engulfing candle alert", Msg);
  end

end

function Prepare(nameOnly) 
    source = instance.source;
    Frame=instance.parameters.Frame;
    first = source:first()+2;
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
      if source.high[period2]<=source.high[period2+i] or source.high[period2]<=source.high[period2-i] then
        IsTop=false;
      end
      if source.low[period2]>=source.low[period2+i] or source.low[period2]>=source.low[period2-i] then
        IsBottom=false;
      end
    end

    Top[period2]=nil;
    Bottom[period2]=nil;

    if IsTop and IsBottom then
      if source.close[period2]>source.open[period2] then
        Top[period2]=source.high[period2];
        if period==source:size()-1 then
          Signal("New top candle");
        end
      else
        Bottom[period2]=source.low[period2];
        if period==source:size()-1 then
          Signal("New bottom candle");
        end
      end
    end

   end 
end

function AsyncOperationFinished(cookie)

end

