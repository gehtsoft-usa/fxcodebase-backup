-- Id: 14479
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62450

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Slow Relative Strength Index oscillator");
    indicator:description("Slow Relative Strength Index oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 8);
    indicator.parameters:addInteger("Smoothing_Period", "Smoothing Period", "", 5);
    indicator.parameters:addDouble("OB", "Overbought level", "", 80);
    indicator.parameters:addDouble("OS", "Oversold level", "", 20);
    indicator.parameters:addDouble("ML", "Middle line", "", 50);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "SRSI Color", "SRSI Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("width", "SRSI Line width", "SRSI Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "SRSI Line style", "SRSI Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Lclr", "Overbought/Oversold Color", "Overbought/Oversold color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Lwidth", "Overbought/Oversold Line width", "Overbought/Oversold Line width", 1, 1, 5);
    indicator.parameters:addInteger("Lstyle", "Overbought/Oversold Line style", "Overbought/Oversold Line style", core.LINE_DASH);
    indicator.parameters:setFlag("Lstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Mclr", "Middle line Color", "Middle line Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Mwidth", "Middle Line width", "Middle Line width", 1, 1, 5);
    indicator.parameters:addInteger("Mstyle", "Middle Line style", "Middle Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Mstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Smoothing_Period;
local SRSI=nil;
local SF;
local NetChgAvg, TotChgAvg;
local EMA;
local OB;
local OS;
local ML;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Smoothing_Period=instance.parameters.Smoothing_Period;
    OB=instance.parameters.OB;
    OS=instance.parameters.OS;
    ML=instance.parameters.ML;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Smoothing_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    EMA = core.indicators:create("EMA", source, Smoothing_Period);
    first = EMA.DATA:first()+Period;
    NetChgAvg = instance:addInternalStream(0, 0);
    TotChgAvg = instance:addInternalStream(0, 0);
    SRSI = instance:addStream("SRSI", core.Line, name .. ".SRSI", "SRSI", instance.parameters.clr, first);
    SRSI:setPrecision(math.max(2, instance.source:getPrecision()));
    SRSI:setWidth(instance.parameters.width);
    SRSI:setStyle(instance.parameters.style);
    SF=1/Period;
    SRSI:addLevel(OB, instance.parameters.Lstyle, instance.parameters.Lwidth, instance.parameters.Lclr);
    SRSI:addLevel(OS, instance.parameters.Lstyle, instance.parameters.Lwidth, instance.parameters.Lclr);
    SRSI:addLevel(ML, instance.parameters.Mstyle, instance.parameters.Mwidth, instance.parameters.Mclr);
end

function Update(period, mode)
  if period<first then
  return;
  end
  
    EMA:update(mode);
    if period==first then
      NetChgAvg[period]=(EMA.DATA[period]-EMA.DATA[period-Period])/Period;
      TotChgAvg[period]=math.abs(EMA.DATA[period]-EMA.DATA[period-1]);
    else
      local Change;
      local ChgRatio;
      Change=EMA.DATA[period]-EMA.DATA[period-1];
      NetChgAvg[period]=NetChgAvg[period-1]+SF*(Change-NetChgAvg[period-1]);
      TotChgAvg[period]=TotChgAvg[period-1]+SF*(math.abs(Change)-TotChgAvg[period-1]);

      if TotChgAvg[period]~=0 then
        ChgRatio=NetChgAvg[period]/TotChgAvg[period];
      else
        ChgRatio=0;
      end

      SRSI[period]=50*(ChgRatio+1);
    end 
 
end

