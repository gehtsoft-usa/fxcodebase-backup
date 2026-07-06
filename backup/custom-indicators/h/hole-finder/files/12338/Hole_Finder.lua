-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=5006

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
    indicator:name("Hole finder indicator");
    indicator:description("Hole finder indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("LabelSize", "Label size", "Label size", 15);
end

local first;
local source = nil;
local Label=nil;
local LabelK=nil;

function Prepare(nameOnly)
    source = instance.source;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Label = instance:createTextOutput ("Label", "Label", "Wingdings", instance.parameters.LabelSize, core.H_Center, core.V_Top, instance.parameters.clr, 0);
    LabelK = instance:createTextOutput ("LabelK", "LabelK", "Arial", instance.parameters.LabelSize, core.H_Center, core.V_Bottom, instance.parameters.clr, 0);
end

function Update(period, mode)
   if (period>first) then
    local BarDiffTime=source:date(period)-source:date(period-1);
    local s,e;
    s, e = core.getcandle(source:barSize(), source:date(period), 0, 0);
    local EtalonDiffTime=e-s;
    if BarDiffTime~=EtalonDiffTime and EtalonDiffTime~=0 then
     local K=BarDiffTime/EtalonDiffTime;
     if K>1.5 then
      Label:set(period,source.high[period],"\239");
      Label:set(period-1,source.high[period],"\240");
      LabelK:set(period-1,source.low[period-1],math.floor(K+0.1));
     else
      Label:setNoData(period); 
      LabelK:setNoData(period); 
     end 
    else
     Label:setNoData(period); 
     LabelK:setNoData(period); 
    end
   end 
end

