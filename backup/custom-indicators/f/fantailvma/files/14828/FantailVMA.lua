-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6489

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
    indicator:name("FantailVMA indicator");
    indicator:description("FantailVMA indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("MA_Length", "MA_Length", "", 1);
    indicator.parameters:addInteger("VarMA_Length", "VarMA_Length", "", 4);
    indicator.parameters:addInteger("ADX_Length", "ADX_Length", "", 8);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local MA_Length;
local VarMA_Length;
local ADX_Length;
local FantailMA=nil;
local Alpha;
local sPDI=nil;
local sMDI=nil;
local STR=nil;
local ADX=nil;
local MaInd;
local VarMA=nil;
local dSmoothFactor;

function Prepare(nameOnly)
    source = instance.source;
    MA_Length=instance.parameters.MA_Length;
    VarMA_Length=instance.parameters.VarMA_Length;
    ADX_Length=instance.parameters.ADX_Length;
    first = source:first()+ADX_Length;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.MA_Length .. ", " .. instance.parameters.VarMA_Length .. ", " .. instance.parameters.ADX_Length .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    sPDI = instance:addInternalStream(first, 0);
    sMDI = instance:addInternalStream(first, 0);
    STR = instance:addInternalStream(first, 0);
    ADX = instance:addInternalStream(first, 0);
    VarMA = instance:addInternalStream(first, 0);
    FantailMA = instance:addStream("FantailMA", core.Line, name .. ".FantailMA", "FantailMA", instance.parameters.clr, first+ADX_Length);
    FantailMA:setWidth(instance.parameters.widthLinReg);
    FantailMA:setStyle(instance.parameters.styleLinReg);
    Alpha=1/ADX_Length;
    if VarMA_Length>0 then
     MaInd=2/(1+VarMA_Length);
    else
     MaInd=0.2;
    end
    dSmoothFactor=2/(1+MA_Length);
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    local Bulls=0;
    local Bears=0;
    if source.high[period]>source.high[period-1] then
     Bulls=1;
    end
    if source.low[period]<source.low[period-1] then
     Bears=1;
    end
    if Bulls==Bears then
      Bulls=0;
      Bears=0;
    end 
    sPDI[period]=sPDI[period-1]+Alpha*(Bulls-sPDI[period-1]);
    sMDI[period]=sMDI[period-1]+Alpha*(Bears-sMDI[period-1]);
    local TR=math.max(source.high[period]-source.low[period],source.high[period]-source.close[period-1]);
    STR[period]=STR[period-1]+Alpha*(TR-STR[period-1]);
    local PDI=0;
    local MDI=0;
    local DX=0;
    if STR[period]>0 then
     PDI=100*sPDI[period]/STR[period];
     MDI=100*sMDI[period]/STR[period];
    end
    if PDI+MDI>0 then
     DX=100*math.abs(PDI-MDI)/(PDI+MDI);
    end
    ADX[period]=ADX[period-1]+Alpha*(DX-ADX[period-1]);
	
	
	  if (period<first+ADX_Length) then
      return;
       end
	
    local ADXmin, ADXmax=mathex.minmax(ADX, period-ADX_Length+1, period);
    --local ADXmax=core.max(ADX,core.rangeTo(period,ADX_Length));
    local Diff=ADXmax-ADXmin;
    local Const=MaInd;
    if Diff>0 then
     Const=(ADX[period]-ADXmin)/Diff;
    end
    Const=math.min(Const,MaInd);
    VarMA[period]=((2-Const)*VarMA[period-1]+Const*source.close[period])/2;
    FantailMA[period]=VarMA[period]*dSmoothFactor+FantailMA[period-1]*(1-dSmoothFactor);
 
  
end

