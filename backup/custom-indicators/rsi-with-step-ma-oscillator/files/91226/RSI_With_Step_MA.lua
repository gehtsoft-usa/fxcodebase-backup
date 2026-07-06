-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60018
-- Id: 10580

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
    indicator:name("RSI with step MA oscillator");
    indicator:description("RSI with step MA oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RSI_Period", "RSI period", "", 14);
    indicator.parameters:addInteger("Step", "Step", "", 5);
    indicator.parameters:addInteger("MA_Period", "MA period", "", 6);
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("RSIclr", "RSI color", "RSI color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("RSIwidth", "RSI width", "RSI width", 1, 1, 5);
    indicator.parameters:addInteger("RSIstyle", "RSI style", "RSI style", core.LINE_SOLID);
    indicator.parameters:setFlag("RSIstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("Level1", "Level 1", "", 30);
    indicator.parameters:addInteger("Level2", "Level 2", "", 70);
    indicator.parameters:addColor("Lclr", "Levels color", "Levels color", core.rgb(128, 128, 0));
    indicator.parameters:addInteger("Lwidth", "Levels width", "Levels width", 1, 1, 5);
    indicator.parameters:addInteger("Lstyle", "Levels style", "Levels style", core.LINE_DASH);
    indicator.parameters:setFlag("Lstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local RSI_Period;
local Step;
local MA_Period;
local Method;
local RSI=nil;
local MA;
local P, N;

function Prepare(nameOnly)
    source = instance.source;
    RSI_Period=instance.parameters.RSI_Period;
    Step=instance.parameters.Step;
    MA_Period=instance.parameters.MA_Period;
    Method=instance.parameters.Method;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.RSI_Period .. ", " .. instance.parameters.Step .. ", " .. instance.parameters.MA_Period .. ", " .. instance.parameters.Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
    MA = core.indicators:create("AVERAGES", source, Method, MA_Period, false);
	
	first = source:first()+RSI_Period+Step-1;
    P=instance:addInternalStream(0, 0);
    N=instance:addInternalStream(0, 0);
    RSI = instance:addStream("RSI", core.Line, name .. ".RSI", "RSI", instance.parameters.RSIclr, first);
    RSI:setPrecision(math.max(2, instance.source:getPrecision()));
    RSI:setWidth(instance.parameters.RSIwidth);
    RSI:setStyle(instance.parameters.RSIstyle);
    RSI:addLevel(30, instance.parameters.Lstyle, instance.parameters.Lwidth, instance.parameters.Lclr);
    RSI:addLevel(70, instance.parameters.Lstyle, instance.parameters.Lwidth, instance.parameters.Lclr);
end

function Update(period, mode)
  
    MA:update(mode);
	if period>=first then
    local i=0;
    local sump=0;
    local sumn=0;
    local positive=0;
    local negative=0;
    local diff=0;
    if period==first then
     for i=period-RSI_Period+1, period do
      diff=MA.DATA[i]-MA.DATA[i-Step];
      if diff>=0 then
       sump=sump+diff;
      else
       sumn=sumn-diff;
      end
     end
     positive=sump/RSI_Period;
     negative=sumn/RSI_Period;
    else
     diff=MA.DATA[period]-MA.DATA[period-Step];
     if diff>=0 then
      sump=diff;
     else
      sumn=-diff;
     end
     positive=(P[period-1]*(RSI_Period-1)+sump)/RSI_Period;
     negative=(N[period-1]*(RSI_Period-1)+sumn)/RSI_Period;
    end
    P[period]=positive;
    N[period]=negative;
    if negative==0 then
     RSI[period]=0;
    else
     RSI[period]=100-(100/(1+positive/negative));
    end
    
   end 
end

