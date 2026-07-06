-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65446

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
    indicator:name("TMA CG indicator");
    indicator:description("TMA CG indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Price", "Price type", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted"); 
    indicator.parameters:addInteger("HalfLength", "Half Length", "", 56);
    indicator.parameters:addDouble("BandDeviations", "Band Deviations", "", 2.5);
    indicator.parameters:addBoolean("Interpolate", "Interpolate", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("tmclr", "TM Color", "TM Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("tmwidth", "TM Line width", "TM Line width", 1, 1, 5);
    indicator.parameters:addInteger("tmstyle", "TM Line style", "TM Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("tmstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("upclr", "Up Color", "Up Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("upwidth", "Up Line width", "Up Line width", 1, 1, 5);
    indicator.parameters:addInteger("upstyle", "Up Line style", "Up Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("upstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("dnclr", "Dn Color", "Dn Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("dnwidth", "Dn Line width", "Dn Line width", 1, 1, 5);
    indicator.parameters:addInteger("dnstyle", "Dn Line style", "Dn Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("dnstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("upaclr", "Up arrow Color", "Up arrow Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("dnaclr", "Dn arrow Color", "Dn arrow Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);
end

local first;
local source = nil;
local HalfLength;
local BandDeviations;
local Interpolate;
local Price;

local tmBuffer, upBuffer, dnBuffer, dnArrow, upArrow;
local wuBuffer, wdBuffer;

function Prepare(nameOnly) 
    source = instance.source;
	
	  local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	
    Price=instance.parameters.Price;
    HalfLength=instance.parameters.HalfLength;
    BandDeviations=instance.parameters.BandDeviations;
    Interpolate=instance.parameters.Interpolate;
    first = source:first()+2*HalfLength;
    wuBuffer = instance:addInternalStream(first, 0);
    wdBuffer = instance:addInternalStream(first, 0);
  
    tmBuffer = instance:addStream("tmBuffer", core.Line, name .. ".tmBuffer", "tmBuffer", instance.parameters.tmclr, first);
    tmBuffer:setWidth(instance.parameters.tmwidth);
    tmBuffer:setStyle(instance.parameters.tmstyle);
    upBuffer = instance:addStream("upBuffer", core.Line, name .. ".upBuffer", "upBuffer", instance.parameters.upclr, first);
    upBuffer:setWidth(instance.parameters.tmwidth);
    upBuffer:setStyle(instance.parameters.tmstyle);
    dnBuffer = instance:addStream("dnBuffer", core.Line, name .. ".dnBuffer", "dnBuffer", instance.parameters.dnclr, first);
    dnBuffer:setWidth(instance.parameters.tmwidth);
    dnBuffer:setStyle(instance.parameters.tmstyle);
    dnArrow = instance:addStream("dnArrow", core.Dot, name .. ".dnArrow", "dnArrow", instance.parameters.dnaclr, first);
    upArrow = instance:addStream("upArrow", core.Dot, name .. ".upArrow", "upArrow", instance.parameters.upaclr, first);
    dnArrow:setWidth(instance.parameters.DotSize);
    upArrow:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)
   if period<first then
   return;
   end
   
    local i, j, k;
    local FullLength=2*HalfLength+1;

    local sum=(HalfLength+1)*source[Price][period];
    local sumw=HalfLength+1;

    k=HalfLength;
    for j=1, HalfLength, 1 do
      i=source:size()-1-period;
      sum=sum+k*source[Price][period-j];
      sumw=sumw+k;

      if j<=i then
        sum=sum+k*source[Price][period+j];
        sumw=sumw+k;
      end

      k=k-1;
    end
    tmBuffer[period]=sum/sumw;

    local diff=source[Price][period]-tmBuffer[period];

    if period>=first+HalfLength then
      if period==first+HalfLength then
        upBuffer[period]=tmBuffer[period];
        dnBuffer[period]=tmBuffer[period];

        if diff>=0 then
          wuBuffer[period]=diff*diff;
          wdBuffer[period]=0;
        else
          wdBuffer[period]=diff*diff;
          wuBuffer[period]=0;
        end
      else
        if diff>=0 then
          wuBuffer[period]=(wuBuffer[period-1]*(FullLength-1)+diff*diff)/FullLength;
          wdBuffer[period]=wdBuffer[period-1]*(FullLength-1)/FullLength;
        else
          wdBuffer[period]=(wdBuffer[period-1]*(FullLength-1)+diff*diff)/FullLength;
          wuBuffer[period]=wuBuffer[period-1]*(FullLength-1)/FullLength;
        end
        upBuffer[period]=tmBuffer[period-1]+BandDeviations*math.sqrt(wuBuffer[period]);
        dnBuffer[period]=tmBuffer[period-1]-BandDeviations*math.sqrt(wdBuffer[period]);

        if source.high[period-1]>upBuffer[period-1] and source.close[period-1]>source.open[period-1] and source.close[period]<source.open[period] then
          upArrow[period]=source.high[period];
        else
          upArrow[period]=nil;
        end

        if source.low[period-1]<dnBuffer[period-1] and source.close[period-1]<source.open[period-1] and source.close[period]>source.open[period] then
          dnArrow[period]=source.low[period];
        else
          dnArrow[period]=nil;
        end
      end
    end
 
end

