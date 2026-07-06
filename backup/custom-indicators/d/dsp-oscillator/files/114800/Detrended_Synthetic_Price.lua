-- Id: 19022
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=65075

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
    indicator:name("Detrended Synthetic Price oscillator");
    indicator:description("Detrended Synthetic Price oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("DSP_Period", "DSP period", "", 14);
    indicator.parameters:addString("DSP_Price", "DSP price", "", "median");
    indicator.parameters:addStringAlternative("DSP_Price", "Close", "", "close");
    indicator.parameters:addStringAlternative("DSP_Price", "Open", "", "open");
    indicator.parameters:addStringAlternative("DSP_Price", "High", "", "high");
    indicator.parameters:addStringAlternative("DSP_Price", "Low", "", "low");
    indicator.parameters:addStringAlternative("DSP_Price", "Median", "", "median");
    indicator.parameters:addStringAlternative("DSP_Price", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("DSP_Price", "Weighted", "", "weighted");
    indicator.parameters:addStringAlternative("DSP_Price", "Average (high+low+open+close)/4", "", "average");
    indicator.parameters:addStringAlternative("DSP_Price", "Average median body (open+close)/2", "", "medianb");
    indicator.parameters:addStringAlternative("DSP_Price", "Trend biased price", "", "tbiased");
    indicator.parameters:addStringAlternative("DSP_Price", "Trend biased (extreme) price", "", "tbiased2");
    indicator.parameters:addStringAlternative("DSP_Price", "Heiken ashi close", "", "haclose");
    indicator.parameters:addStringAlternative("DSP_Price", "Heiken ashi open", "", "haopen");
    indicator.parameters:addStringAlternative("DSP_Price", "Heiken ashi high", "", "hahigh");
    indicator.parameters:addStringAlternative("DSP_Price", "Heiken ashi low", "", "halow");
    indicator.parameters:addStringAlternative("DSP_Price", "Heiken ashi median", "", "hamedian");
    indicator.parameters:addStringAlternative("DSP_Price", "Heiken ashi typical", "", "hatypical");
    indicator.parameters:addStringAlternative("DSP_Price", "Heiken ashi weighted", "", "haweighted");
    indicator.parameters:addStringAlternative("DSP_Price", "Heiken ashi average", "", "haaverage");
    indicator.parameters:addStringAlternative("DSP_Price", "Heiken ashi median body", "", "hamedianb");
    indicator.parameters:addStringAlternative("DSP_Price", "Heiken ashi trend biased price", "", "hatbiased");
    indicator.parameters:addStringAlternative("DSP_Price", "Heiken ashi trend biased (extreme) price", "", "hatbiased2");

    indicator.parameters:addInteger("Signal_Period", "Signal period", "", 9);
    indicator.parameters:addString("Color_On", "Change color on", "", "onOuter");
    indicator.parameters:addStringAlternative("Color_On", "Change color on zero cross", "", "onZero");
    indicator.parameters:addStringAlternative("Color_On", "Change color on levels cross", "", "onOuter");
    indicator.parameters:addStringAlternative("Color_On", "Change color on opposite levels cross", "", "onOuter2");
    indicator.parameters:addStringAlternative("Color_On", "Change color on slope change", "", "onSlope");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Uclr", "Upper level color", "Upper level color", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("Uwidth", "Upper level width", "Upper level width", 1, 1, 5);
    indicator.parameters:addInteger("Ustyle", "Upper level style", "Upper level style", core.LINE_SOLID);
    indicator.parameters:setFlag("Ustyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Lclr", "Lower level color", "Lower level color", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("Lwidth", "Lower level width", "Lower level width", 1, 1, 5);
    indicator.parameters:addInteger("Lstyle", "Lower level style", "Lower level style", core.LINE_SOLID);
    indicator.parameters:setFlag("Lstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Vclr", "Value color", "Value color", core.rgb(64, 64, 64));
    indicator.parameters:addColor("VUclr", "Value 1 color", "Value 1 color", core.rgb(0, 128, 0));
    indicator.parameters:addColor("VLclr", "Value 2 color", "Value 2 color", core.rgb(128, 0, 0));
    indicator.parameters:addInteger("Vwidth", "Value width", "Value width", 3, 1, 5);
    indicator.parameters:addInteger("Vstyle", "Value style", "Value style", core.LINE_SOLID);
    indicator.parameters:setFlag("Vstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local DSP_Period;
local DSP_Price;
local Signal_Period;
local Color_On;
local HA_O, HA_C, HA_L, HA_H;
local Pr, val;
local EMA1, EMA2;

local alphas, alpham;
local levelu, leveld, state;

function Prepare(nameOnly) 
    source = instance.source;
    DSP_Period=instance.parameters.DSP_Period;
    DSP_Price=instance.parameters.DSP_Price;
    Signal_Period=instance.parameters.Signal_Period;
    Color_On=instance.parameters.Color_On;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    alphas=2/(1+Signal_Period);
    alpham=2/(1+DSP_Period);

    HA_O=instance:addInternalStream(first, 0);
    HA_C=instance:addInternalStream(first, 0);
    HA_H=instance:addInternalStream(first, 0);
    HA_L=instance:addInternalStream(first, 0);

    Pr=instance:addInternalStream(first, 0);
--    val=instance:addInternalStream(first, 0);
    state=instance:addInternalStream(first, 0);

    EMA1=core.indicators:create("EMA", Pr, DSP_Period);
    EMA2=core.indicators:create("EMA", Pr, 2*DSP_Period+1);

    levelu = instance:addStream("levelu", core.Line, name .. ".levelu", "levelu", instance.parameters.Uclr, first);
    leveld = instance:addStream("leveld", core.Line, name .. ".leveld", "leveld", instance.parameters.Lclr, first);
    val = instance:addStream("val", core.Line, name .. ".val", "val", instance.parameters.Vclr, first);
    levelu:setWidth(instance.parameters.Uwidth);
    levelu:setStyle(instance.parameters.Ustyle);
    leveld:setWidth(instance.parameters.Lwidth);
    leveld:setStyle(instance.parameters.Lstyle);
    val:setWidth(instance.parameters.Vwidth);
    val:setStyle(instance.parameters.Vstyle);
	
	levelu:setPrecision(math.max(2, instance.source:getPrecision()));
	leveld:setPrecision(math.max(2, instance.source:getPrecision()));
	val:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if period>=first then
    if period==first then
      HA_O[period]=(source.open[period-1]+source.close[period-1])/2;
    else
      HA_O[period]=(HA_O[period-1]+HA_C[period-1])/2;
    end
    HA_C[period]=(source.open[period]+source.close[period]+source.low[period]+source.high[period])/4;
    HA_H[period]=math.max(HA_O[period], HA_C[period], source.high[period]);
    HA_L[period]=math.min(HA_O[period], HA_C[period], source.low[period]);

    if DSP_Price=="close" then
      Pr[period]=source.close[period];
    elseif DSP_Price=="open" then
      Pr[period]=source.open[period];
    elseif DSP_Price=="high" then
      Pr[period]=source.high[period];
    elseif DSP_Price=="low" then
      Pr[period]=source.low[period];
    elseif DSP_Price=="median" then
      Pr[period]=(source.high[period]+source.low[period])/2;
    elseif DSP_Price=="typical" then
      Pr[period]=(source.high[period]+source.low[period]+source.close[period])/3;
    elseif DSP_Price=="weighted" then
      Pr[period]=(source.high[period]+source.low[period]+2*source.close[period])/4;
    elseif DSP_Price=="average" then
      Pr[period]=(source.high[period]+source.low[period]+source.close[period]+source.open[period])/4;
    elseif DSP_Price=="medianb" then
      Pr[period]=(source.open[period]+source.close[period])/2;
    elseif DSP_Price=="tbiased" then
      if source.close[period]>source.open[period] then
        Pr[period]=(source.high[period]+source.close[period])/2;
      else
        Pr[period]=(source.low[period]+source.close[period])/2;
      end
    elseif DSP_Price=="tbiased2" then
      if source.close[period]>source.open[period] then
        Pr[period]=source.high[period];
      elseif source.close[period]<source.open[period] then
        Pr[period]=source.low[period];
      else
        Pr[period]=source.close[period];
      end
    elseif DSP_Price=="haclose" then
      Pr[period]=HA_C[period];
    elseif DSP_Price=="haopen" then
      Pr[period]=HA_O[period];
    elseif DSP_Price=="hahigh" then
      Pr[period]=HA_H[period];
    elseif DSP_Price=="halow" then
      Pr[period]=HA_L[period];
    elseif DSP_Price=="hamedian" then
      Pr[period]=(HA_H[period]+HA_L[period])/2;
    elseif DSP_Price=="hatypical" then
      Pr[period]=(HA_H[period]+HA_L[period]+HA_C[period])/3;
    elseif DSP_Price=="haweighted" then
      Pr[period]=(HA_H[period]+HA_L[period]+2*HA_C[period])/4;
    elseif DSP_Price=="haaverage" then
      Pr[period]=(HA_H[period]+HA_L[period]+HA_C[period]+HA_O[period])/4;
    elseif DSP_Price=="hamedianb" then
      Pr[period]=(HA_O[period]+HA_C[period])/2;
    elseif DSP_Price=="hatbiased" then
      if HA_C[period]>HA_O[period] then
        Pr[period]=(HA_H[period]+HA_C[period])/2;
      else
        Pr[period]=(HA_L[period]+HA_C[period])/2;
      end
    elseif DSP_Price=="hatbiased2" then
      if HA_C[period]>HA_O[period] then
        Pr[period]=HA_H[period];
      elseif HA_C[period]<HA_O[period] then
        Pr[period]=HA_L[period];
      else
        Pr[period]=HA_C[period];
      end
    end

    EMA1:update(mode);
    EMA2:update(mode);

    val[period]=EMA1.DATA[period]-EMA2.DATA[period];

    if period==first then
      levelu[period]=0;
      leveld[period]=0;
    else
      if val[period]>0 then
        levelu[period]=levelu[period-1]+alphas*(val[period]-levelu[period-1]);
        leveld[period]=leveld[period-1];
      else
        levelu[period]=levelu[period-1];
        leveld[period]=leveld[period-1]+alphas*(val[period]-leveld[period-1]);
      end

      if Color_On=="onZero" then
        if val[period]>0 then
          state[period]=1;
        else
          state[period]=-1;
        end
      elseif Color_On=="onOuter" then
        if val[period]>levelu[period] then
          state[period]=1;
        elseif val[period]<leveld[period] then
          state[period]=-1;
        else
          state[period]=0;
        end
      elseif Color_On=="onOuter2" then
        if val[period]>levelu[period] then
          state[period]=1;
        elseif val[period]<leveld[period] then
          state[period]=-1;
        else
          state[period]=state[period-1];
        end
      elseif Color_On=="onSlope" then
        if val[period]>val[period-1] then
          state[period]=1;
        elseif val[period]<val[period-1] then
          state[period]=-1;
        else
          state[period]=state[period-1];
        end
      end
    end

    if state[period]==1 then
      val:setColor(period, instance.parameters.VUclr);
    elseif state[period]==-1 then
      val:setColor(period, instance.parameters.VLclr);
    end
   end 
    
end

