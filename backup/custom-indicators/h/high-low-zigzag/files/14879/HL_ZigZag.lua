-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6514

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
    indicator:name("High-Low Zig Zag");
    indicator:description("High-Low Zig Zag");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local PrevEx=nil;
local MinStream=nil;
local MaxStream=nil;
local ZZ=nil

function Prepare(nameOnly)
    source = instance.source;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    PrevEx = instance:addInternalStream(first, 0);
    MinStream = instance:addInternalStream(first, 0);
    MaxStream = instance:addInternalStream(first, 0);
    ZZ = instance:addStream("ZZ", core.Line, name .. ".ZZ", "ZZ", instance.parameters.clr, first);
    ZZ:setWidth(instance.parameters.widthLinReg);
    ZZ:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if (period>first and period<source:size()-1) then
    local MaxPr=core.max(source.low,core.range(PrevEx[period-1],period-1));
    local MinPr=core.min(source.high,core.range(PrevEx[period-1],period-1));
    local MaxPr2,MaxPos2=mathex.max(source.high,core.range(PrevEx[period-1]+1,period));
    local MinPr2,MinPos2=mathex.min(source.low,core.range(PrevEx[period-1]+1,period));
    PrevEx[period]=PrevEx[period-1];
    local i;
    if source.high[period]<MaxPr and MaxStream[PrevEx[period]]~=source.high[PrevEx[period]] then
     for i=MaxPos2,period,1 do
      PrevEx[i]=MaxPos2;
     end
     MaxStream[MaxPos2]=source.high[MaxPos2];
     if PrevEx[MaxPos2-1]~=first then
      core.drawLine(ZZ,core.range(PrevEx[MaxPos2-1],MaxPos2),MinStream[PrevEx[MaxPos2-1]],PrevEx[MaxPos2-1],MaxStream[MaxPos2],MaxPos2);
     end
    elseif source.low[period]>MinPr and MinStream[PrevEx[period]]~=source.low[PrevEx[period]] then
     for i=MinPos2,period,1 do
      PrevEx[i]=MinPos2;
     end
     MinStream[MinPos2]=source.low[MinPos2];
     if PrevEx[MinPos2-1]~=first then
      core.drawLine(ZZ,core.range(PrevEx[MinPos2-1],MinPos2),MaxStream[PrevEx[MinPos2-1]],PrevEx[MinPos2-1],MinStream[MinPos2],MinPos2);
     end
    end
   elseif period==first then
    PrevEx[period]=first; 
   end 
end

