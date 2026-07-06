-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=42268
-- Id: 9439

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
    indicator:name("Velocity oscillator");
    indicator:description("Velocity oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Momentum_Period", "Momentum period", "", 1);
    indicator.parameters:addString("Velocity_Method", "Velocity method", "", "EMA");
    indicator.parameters:addStringAlternative("Velocity_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Velocity_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Velocity_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Velocity_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Velocity_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Velocity_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Velocity_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Velocity_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Velocity_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Velocity_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Velocity_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Velocity_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Velocity_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Velocity_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Velocity_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Velocity_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Velocity_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Velocity_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Velocity_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Velocity_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Velocity_Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("Velocity_Period", "Velocity period", "", 8);
    indicator.parameters:addString("Signal_Method", "Signal method", "", "EMA");
    indicator.parameters:addStringAlternative("Signal_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Signal_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Signal_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Signal_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Signal_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Signal_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Signal_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Signal_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Signal_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Signal_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Signal_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Signal_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Signal_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Signal_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Signal_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Signal_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Signal_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Signal_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Signal_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Signal_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Signal_Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("Signal_Period", "Signal period", "", 5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("PUPclr", "Positive UP histogram color", "Positive UP histogram color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("PDNclr", "Positive DN histogram color", "Positive DN histogram color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("NUPclr", "Negative UP histogram color", "Negative UP histogram color", core.rgb(255, 0, 255));
    indicator.parameters:addColor("NDNclr", "Negative DN histogram color", "Negative DN histogram color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("UPclr", "Signal UP color", "Signal UP color", core.rgb(0, 255, 255));
    indicator.parameters:addColor("DNclr", "Signal DN color", "Signal DN color", core.rgb(255, 128, 0));
    indicator.parameters:addInteger("widthLinReg", "Signal width", "Signal width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Signal style", "Signal style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Momentum_Period;
local Velocity_Method;
local Velocity_Period;
local Signal_Method;
local Signal_Period;
local Momentum;
local MA1, MA2, MA3, MA4;
local Velocity=nil;
local Signal=nil;

function Prepare(nameOnly)
    source = instance.source;
    Momentum_Period=instance.parameters.Momentum_Period;
    Velocity_Method=instance.parameters.Velocity_Method;
    Velocity_Period=instance.parameters.Velocity_Period;
    Signal_Method=instance.parameters.Signal_Method;
    Signal_Period=instance.parameters.Signal_Period;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Momentum_Period .. ", " .. instance.parameters.Velocity_Method .. ", " .. instance.parameters.Velocity_Period .. ", " .. instance.parameters.Signal_Method .. ", " .. instance.parameters.Signal_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator"); 
	assert(core.indicators:findIndicator("MOMENTUM") ~= nil, "Please, download and install MOMENTUM.LUA indicator"); 
    Momentum = core.indicators:create("MOMENTUM", source, Momentum_Period);
    MA1 = core.indicators:create("AVERAGES", Momentum.DATA, Velocity_Method, Velocity_Period, false);
    MA2 = core.indicators:create("AVERAGES", MA1.DATA, Velocity_Method, Velocity_Period, false);
    MA3 = core.indicators:create("AVERAGES", MA2.DATA, Velocity_Method, Velocity_Period, false);
    MA4 = core.indicators:create("AVERAGES", MA3.DATA, Signal_Method, Signal_Period, false);
	
	first =  MA4.DATA:first();
    Velocity = instance:addStream("Velocity", core.Bar, name .. ".Velocity", "Velocity", instance.parameters.PUPclr, first);
    Velocity:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.UPclr, first);
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal:setWidth(instance.parameters.widthLinReg);
    Signal:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if period>first then
    Momentum:update(mode);
    MA1:update(mode);
    MA2:update(mode);
    MA3:update(mode);
    MA4:update(mode);
    Velocity[period]=MA3.DATA[period]-100;
    Signal[period]=MA4.DATA[period]-100;
    if Velocity[period]>0 then
     if Velocity[period]>=Velocity[period-1] then
      Velocity:setColor(period, instance.parameters.PUPclr);
     else
      Velocity:setColor(period, instance.parameters.PDNclr);
     end
    else
     if Velocity[period]>=Velocity[period-1] then
      Velocity:setColor(period, instance.parameters.NUPclr);
     else
      Velocity:setColor(period, instance.parameters.NDNclr);
     end
    end
    
    if Signal[period]>=Signal[period-1] then
     Signal:setColor(period, instance.parameters.UPclr);
    else
     Signal:setColor(period, instance.parameters.DNclr);
    end
   end 
end

