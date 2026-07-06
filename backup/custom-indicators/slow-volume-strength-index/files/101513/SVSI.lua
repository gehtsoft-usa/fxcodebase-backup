-- Id: 14482
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62451

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
    indicator:name("Slow Volume Strength Index oscillator");
    indicator:description("Slow Volume Strength Index oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("EMA_Period", "EMA period", "", 6);
    indicator.parameters:addInteger("Smooth_Period", "Smoothing period", "", 14);
    indicator.parameters:addDouble("OB", "Overbought level", "", 80);
    indicator.parameters:addDouble("OS", "Oversold level", "", 20);
    indicator.parameters:addDouble("ML", "Middle line", "", 50);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "SVSI Color", "SVSI Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("width", "SVSI Line width", "SVSI Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "SVSI Line style", "SVSI Line style", core.LINE_SOLID);
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
local EMA_Period;
local Smooth_Period;
local OB;
local OS;
local ML;
local SVSI;
local EMA;
local PosVolume, NegVolume;
local AvgPosVol, AvgNegVol;

function Prepare(nameOnly)
    source = instance.source;
    EMA_Period=instance.parameters.EMA_Period;
    Smooth_Period=instance.parameters.Smooth_Period;
    OB=instance.parameters.OB;
    OS=instance.parameters.OS;
    ML=instance.parameters.ML;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.EMA_Period .. ", " .. instance.parameters.Smooth_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    PosVolume = instance:addInternalStream(0, 0);
    NegVolume = instance:addInternalStream(0, 0);
    EMA = core.indicators:create("EMA", source.close, EMA_Period);
	
	first = EMA.DATA:first();
	 
    AvgPosVol = core.indicators:create("MVA", PosVolume, Smooth_Period);
    AvgNegVol = core.indicators:create("MVA", NegVolume, Smooth_Period);
    SVSI = instance:addStream("SVSI", core.Line, name .. ".SVSI", "SVSI", instance.parameters.clr, AvgPosVol.DATA:first());
    SVSI:setPrecision(math.max(2, instance.source:getPrecision()));
    SVSI:setWidth(instance.parameters.width);
    SVSI:setStyle(instance.parameters.style);
    SVSI:addLevel(OB, instance.parameters.Lstyle, instance.parameters.Lwidth, instance.parameters.Lclr);
    SVSI:addLevel(OS, instance.parameters.Lstyle, instance.parameters.Lwidth, instance.parameters.Lclr);
    SVSI:addLevel(ML, instance.parameters.Mstyle, instance.parameters.Mwidth, instance.parameters.Mclr);
end

function Update(period, mode)
   if period<first then
   return;
   end
   
    EMA:update(mode);
    if source.close[period]>EMA.DATA[period] then
      PosVolume[period]=source.volume[period];
      NegVolume[period]=0;
    elseif source.close[period]<EMA.DATA[period] then
      PosVolume[period]=0;
      NegVolume[period]=source.volume[period];
    else
      PosVolume[period]=0;
      NegVolume[period]=0;
    end

    AvgPosVol:update(mode);
    AvgNegVol:update(mode);
	
	if period<AvgPosVol.DATA:first() then
   return;
   end

    local SVS;
    if AvgNegVol.DATA[period]~=0 then
      SVS=AvgPosVol.DATA[period]/AvgNegVol.DATA[period];
    else
      SVS=100;
    end

    if SVS~=0 then
      SVSI[period]=100-100/(1+SVS);
	else
	  SVSI[period]=0;
    end
  
end

