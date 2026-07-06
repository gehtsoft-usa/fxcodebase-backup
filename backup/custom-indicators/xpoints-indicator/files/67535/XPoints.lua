-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41307
-- Id: 9347

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("XPoints indicator");
    indicator:description("XPoints indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 3);
    indicator.parameters:addDouble("xrate", "xrate", "", 1.5);
    indicator.parameters:addDouble("xsize", "xsize", "", 5);
    indicator.parameters:addDouble("xslope", "xslope", "", 0);
    indicator.parameters:addDouble("xminupdn", "xminupdn", "", 10);
    indicator.parameters:addInteger("xindent", "xindent", "", 15);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Uclr", "Upper line color", "Upper line color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Mclr", "Middle line color", "Middle line color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Lclr", "Lower line color", "Lower line color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("UPclr", "UP arrow color", "UP arrow color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN arrow color", "DN arrow color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("ArrowSize", "Arrow size", "Arrow size", 10);
end

local first;
local source = nil;
local Period;
local xrate;
local xsize;
local xslope;
local xminupdn;
local xindent;
local Upper=nil;
local Lower=nil;
local Middle=nil;
local UpArrow=nil;
local DnArrow=nil;
local pipSize;
local xslopeP;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    xrate=instance.parameters.xrate;
    xsize=instance.parameters.xsize;
    xslope=instance.parameters.xslope;
    xminupdn=instance.parameters.xminupdn;
    xindent=instance.parameters.xindent;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.xrate .. ", " .. instance.parameters.xsize .. ", " .. instance.parameters.xslope .. ", " .. instance.parameters.xminupdn .. ", " .. instance.parameters.xindent .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Upper = instance:addStream("Upper", core.Line, name .. ".Upper", "Upper", instance.parameters.Uclr, first);
    Middle = instance:addStream("Middle", core.Line, name .. ".Middle", "Middle", instance.parameters.Mclr, first);
    Lower = instance:addStream("Lower", core.Line, name .. ".Lower", "Lower", instance.parameters.Lclr, first);
    Upper:setWidth(instance.parameters.widthLinReg);
    Upper:setStyle(instance.parameters.styleLinReg);
    Middle:setWidth(instance.parameters.widthLinReg);
    Middle:setStyle(instance.parameters.styleLinReg);
    Lower:setWidth(instance.parameters.widthLinReg);
    Lower:setStyle(instance.parameters.styleLinReg);
    UpArrow = instance:createTextOutput ("UpArrow", "UpArrow", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Top, instance.parameters.UPclr, 0);
    DnArrow = instance:createTextOutput ("DnArrow", "DnArrow", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Top, instance.parameters.DNclr, 0);
    pipSize=source:pipSize();
    xslopeP=xslope*pipSize;
end

function Update(period, mode)
   if period>first then
    local Min, Max = mathex.minmax(source, period-Period+1, period);
    Upper[period]=Max;
    Lower[period]=Min;
    Middle[period]=(Max+Min)/2;
    
    local HeightHL0 = (source.high[period]-source.low[period])/pipSize; 
    local HeightHL1 = (source.high[period-1]-source.low[period-1])/pipSize;

    local HeightCO0 = (source.close[period]-source.open[period])/pipSize; 
    local HeightCO1 = (source.close[period-1]-source.open[period-1])/pipSize; 

    local CenterHL0 = (source.high[period]+source.low[period])/2;
    local CenterHL1 = (source.high[period-1]+source.low[period-1])/2;
      
    local CenterCO0 = (source.open[period]+source.close[period])/2; 
    local CenterCO1 = (source.open[period-1]+source.close[period-1])/2; 
    
    if HeightHL1>=xsize then
     local xrate1=HeightCO1/HeightHL1;
     if math.abs(xrate1)<=1/xrate then
      if source.low[period-1]<=Lower[period-1] and source.high[period-1]<Upper[period-1] and source.low[period]>=source.low[period-1]+xslopeP and (CenterCO1<=Middle[period-1] or CenterCO0>=CenterCO1+xslopeP or CenterHL0>=CenterHL1+xslopeP) then
       UpArrow:set(period, source.low[period]-xindent*pipSize, "\225");
      else
       UpArrow:setNoData(period);
      end
      if source.high[period-1]>=Upper[period-1] and source.low[period-1]>Lower[period-1] and source.high[period]<=source.high[period-1]-xslopeP and (CenterCO1>=Middle[period-1] or CenterCO0<=CenterCO1-xslopeP or CenterHL0<=CenterHL1-xslopeP) then
       DnArrow:set(period, source.high[period]+xindent*pipSize, "\226");
      else
       DnArrow:setNoData(period);
      end
     end
    end
    
   end 
end

