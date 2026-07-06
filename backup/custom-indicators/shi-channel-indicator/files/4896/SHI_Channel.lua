-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2305

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
    indicator:name("SHI Channel indicator");
    indicator:description("SHI Channel indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("BarsForFractal", "Bars for fractal", "", 3);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Buff1=nil;
local Fl;

function Prepare(nameOnly)
    source = instance.source;
    BarsForFractal=instance.parameters.BarsForFractal;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.BarsForFractal .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Buff1 = instance:addStream("Buff1", core.Line, name .. ".Buff1", "Buff1", instance.parameters.clr, first);
	Buff1:setWidth(instance.parameters.width);
    Buff1:setStyle(instance.parameters.style);
    Buff2 = instance:addStream("Buff2", core.Line, name .. ".Buff2", "Buff2", instance.parameters.clr, first);
	Buff2:setWidth(instance.parameters.width);
    Buff2:setStyle(instance.parameters.style);
end

function Update(period, mode)
   local BFF=(BarsForFractal-1)/2;
   --if (period>first) then
   if (period==source:size()-1) then
    local FrDir=nil;
    local FrU1=0;
    local FrU2=0;
    local FrD1=0;
    local FrD2=0;
    local i;
    local i2;
    for i=first+BFF,period-BFF,1 do
     Fl=true;
     for i2=1,BFF,1 do
      if source.high[i]<=source.high[i-i2] or source.high[i]<=source.high[i+i2] then
       Fl=false;
      end
     end
     if Fl==true then
      FrDir=1;
      FrU2=FrU1;
      FrU1=i;
     end
     
     if Fl==false then
      Fl=true;
      for i2=1,BFF,1 do
       if source.low[i]>=source.low[i-i2] or source.low[i]>=source.low[i+i2] then
        Fl=false;
       end
      end
      if Fl==true then
       FrDir=-1;
       FrD2=FrD1;
       FrD1=i;
      end
     end 
     
    end
    if FrDir==1 then
     core.drawLine(Buff1,core.range(first,period),source.high[FrU2],FrU2,source.high[FrU1],FrU1);
     core.drawLine(Buff2,core.range(first,period),source.low[FrD1],FrD1,source.low[FrD1]-(source.high[FrU2]-source.high[FrU1]),FrD1-(FrU2-FrU1));
    elseif FrDir==-1 then
     core.drawLine(Buff1,core.range(first,period),source.low[FrD2],FrD2,source.low[FrD1],FrD1);
     core.drawLine(Buff2,core.range(first,period),source.high[FrU1],FrU1,source.high[FrU1]-(source.low[FrD2]-source.low[FrD1]),FrU1-(FrD2-FrD1));
    end
   end 
    
end

