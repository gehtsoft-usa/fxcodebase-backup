-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6402

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
    indicator:name("LastTicks indicator");
    indicator:description("LastTicks indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("TicksCount", "Count of last ticks", "", 5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addString("Font", "Font", "", "Arial");
    indicator.parameters:addInteger("FontSize", "FontSize", "", 10);
end

local first;
local source = nil;
local TicksCount;
local Label;
local LastPrices={};

function Prepare(nameOnly)
    source = instance.source;
    TicksCount=instance.parameters.TicksCount;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.TicksCount .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Label = instance:createTextOutput ("Label", "Label", instance.parameters.Font, instance.parameters.FontSize, core.H_Center, core.V_Top, instance.parameters.clr, 0);
    local i;
    for i=1,TicksCount+1,1 do
     LastPrices[i]=nil;
    end
end

function Update(period, mode)
   if (period==source:size()-1) then
    local i;
    for i=TicksCount,1,-1 do
     LastPrices[i+1]=LastPrices[i];
    end
    LastPrices[1]=source.close[period];
    local Str="";
    for i=TicksCount,1,-1 do
     if LastPrices[i+1]~=nil then
      if Str~="" then
       Str=Str .. "\13\10";
      end
      local Diff=(LastPrices[i]-LastPrices[i+1])/source:pipSize();
      Diff=math.floor(Diff*10+0.5)/10;
      Str=Str .. Diff;
      Label:set(period,source.close[period],Str);
	
	  
     end
    end
   end 
end

