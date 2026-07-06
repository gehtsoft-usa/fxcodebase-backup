--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
 

function Init()
    indicator:name("Advanced fractal lines 2");
    indicator:description("Advanced fractal lines 2");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Frames", "Frames", "", 5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Hclr", "High line Color", "High line Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Lclr", "Low line Color", "Low line Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Frames;
local H_Line=nil;
local L_Line=nil;
local Fr2;

function Prepare()
    source = instance.source;
    Frames=instance.parameters.Frames;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Frames .. ")";
    instance:name(name);
    H_Line = instance:addStream("H_Line", core.Line, name .. ".H_Line", "H_Line", instance.parameters.Hclr, first);
    L_Line = instance:addStream("L_Line", core.Line, name .. ".L_Line", "L_Line", instance.parameters.Lclr, first);
    H_Line:setWidth(instance.parameters.widthLinReg);
    H_Line:setStyle(instance.parameters.styleLinReg);
    L_Line:setWidth(instance.parameters.widthLinReg);
    L_Line:setStyle(instance.parameters.styleLinReg);
    local i,f=math.modf((Frames-1)/2);
    if f==0 then
     Fr2=i;
    else
     Fr2=i+1;
    end
end

function Update(period, mode)
   if (period>first+Frames+1) then
    local i;
    local UpFractal=true;
    local DnFractal=true;
    for i=1,Fr2,1 do
     if source.high[period-Fr2-i-1]>=source.high[period-Fr2-1] or source.high[period-Fr2+i-1]>=source.high[period-Fr2-1] then
      UpFractal=false;
     end
     if source.low[period-Fr2-i-1]<=source.low[period-Fr2-1] or source.low[period-Fr2+i-1]<=source.low[period-Fr2-1] then
      DnFractal=false;
     end
    end 

    if UpFractal then
     H_Line[period-Fr2-1]=source.high[period-Fr2-1];
    else
     H_Line[period-Fr2-1]=H_Line[period-Fr2-2];
    end 
    if DnFractal then
     L_Line[period-Fr2-1]=source.low[period-Fr2-1];
    else
     L_Line[period-Fr2-1]=L_Line[period-Fr2-2];
    end 
    
    if period==source:size()-1 then
     for i=period-Fr2,period,1 do
      H_Line[i]=H_Line[i-1];
      L_Line[i]=L_Line[i-1];
     end 
    end
   end 
end

