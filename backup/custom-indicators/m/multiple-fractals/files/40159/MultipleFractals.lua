-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23328

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Multiple fractals indicator");
    indicator:description("Multiple fractals indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("MinFrame", "Min frame", "", 2);
    indicator.parameters:addInteger("MaxFrame", "Max frame", "", 10);
    indicator.parameters:addBoolean("UseLastBar", "Use last bar", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("FontSize", "Font size", "", 10);
end

local first;
local source = nil;
local MinFrame;
local MaxFrame;
local UseLastBar;
local Up=nil;
local Dn=nil;

 function Prepare(nameOnly) 
    source = instance.source;
    MinFrame=instance.parameters.MinFrame;
    MaxFrame=instance.parameters.MaxFrame;
    UseLastBar=instance.parameters.UseLastBar;
    first = source:first()+ MaxFrame;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.MinFrame .. ", " .. instance.parameters.MaxFrame .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    Up = instance:createTextOutput ("Up", "Up", "Arial", instance.parameters.FontSize, core.H_Center, core.V_Top, instance.parameters.UPclr, 0);
    Dn = instance:createTextOutput ("Dn", "Dn", "Arial", instance.parameters.FontSize, core.H_Center, core.V_Bottom, instance.parameters.DNclr, 0);
end

function MaxUpFr(period, MaxFr)
 local i;
 for i=1,MaxFr,1 do
  if source.high[period]<=source.high[period-i] or source.high[period]<=source.high[period+i] then
   return i-1;
  end
 end
 return MaxFr;
end

function MaxDnFr(period, MaxFr)
 local i;
 for i=1,MaxFr,1 do
  if source.low[period]>=source.low[period-i] or source.low[period]>=source.low[period+i] then
   return i-1;
  end
 end
 return MaxFr;
end

function Update(period, mode)
   if period<first then
   return;
   end
   
   
    local UpFractalStatus, DnFractalStatus;
    if period<source:size()-1-MaxFrame then
     UpFractalStatus=MaxUpFr(period, MaxFrame);
     if UpFractalStatus>=MinFrame then
      Up:set(period, source.high[period], UpFractalStatus);
     else
      Up:setNoData(period);
     end
     DnFractalStatus=MaxDnFr(period, MaxFrame);
     if DnFractalStatus>=MinFrame then
      Dn:set(period, source.low[period], DnFractalStatus);
     else
      Dn:setNoData(period);
     end
    elseif period==source:size()-1 then
     local period_;
     local MaxPeriod;
     if UseLastBar then
      MaxPeriod=period;
     else
      MaxPeriod=period-1;
     end
     for period_=source:size()-1-MaxFrame,MaxPeriod,1 do
      local MaxF=math.min(MaxFrame, MaxPeriod-period_);
      if MaxF>=MinFrame then
       UpFractalStatus=MaxUpFr(period_,MaxF);
       if UpFractalStatus>=MinFrame then
        Up:set(period_, source.high[period_], UpFractalStatus);
       else
        Up:setNoData(period_);
       end
       DnFractalStatus=MaxDnFr(period_,MaxF);
       if DnFractalStatus>=MinFrame then
        Dn:set(period_, source.low[period_], DnFractalStatus);
       else
        Dn:setNoData(period_);
       end
      end 
     end
    end
    
end

