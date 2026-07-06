-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34069
-- Id: 8890

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("QQE oscillator");
    indicator:description("QQE oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RSI_Period", "RSI period", "", 14);
    indicator.parameters:addInteger("SF", "SF", "", 5);
    indicator.parameters:addDouble("DarFactor", "DarFactor", "", 4.236);
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
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Transparency", "Transparency", "", 50,0,100);
end

local first;
local source = nil;
local RSI_Period;
local SF;
local DarFactor;
local Method;
local Wilders_Period;
local RSI;
local MA_RSI;
local Abs_MA_RSI;
local MA1;
local MA2;
local Pbuff=nil;
local Mbuff=nil;

function Prepare(nameOnly)
    source = instance.source;
    RSI_Period=instance.parameters.RSI_Period;
    SF=instance.parameters.SF;
    DarFactor=instance.parameters.DarFactor;
    Method=instance.parameters.Method;
    Wilders_Period=2*RSI_Period-1;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.RSI_Period .. ", " .. instance.parameters.SF .. ", " .. instance.parameters.DarFactor .. ", " .. instance.parameters.Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	
    RSI = core.indicators:create("RSI", source.close, RSI_Period);
    MA_RSI = core.indicators:create("AVERAGES", RSI.DATA, Method, SF, false);
    Abs_MA_RSI=instance:addInternalStream(0, 0);
    MA1 = core.indicators:create("AVERAGES", Abs_MA_RSI, Method, Wilders_Period, false);
    MA2 = core.indicators:create("AVERAGES", MA1.DATA, Method, Wilders_Period, false);
	
	first = MA2.DATA:first();
    Pbuff = instance:addStream("Pbuff", core.Line, name .. ".Pbuff", "Pbuff", instance.parameters.UPclr, first);
    Pbuff:setPrecision(math.max(2, instance.source:getPrecision()));
    Mbuff = instance:addStream("Mbuff", core.Line, name .. ".Mbuff", "Mbuff", instance.parameters.UPclr, first);
    Mbuff:setPrecision(math.max(2, instance.source:getPrecision()));
    instance:createChannelGroup("TC","TC" , Pbuff, Mbuff, instance.parameters.UPclr, 100-instance.parameters.Transparency);
end

function Update(period, mode)
 
   
    RSI:update(mode);
    MA_RSI:update(mode);
	
	if period<MA_RSI.DATA:first() then
   return;
   end
   
    Abs_MA_RSI[period]=math.abs(MA_RSI.DATA[period-1]-MA_RSI.DATA[period]);
    MA1:update(mode);
    MA2:update(mode);
	
   if period< first  then
   return;
   end
   
   
    local dar=MA2.DATA[period]*DarFactor;
    local tr=Mbuff[period-1];
    local dv=tr;
    if MA_RSI.DATA[period]<tr then
     tr=MA_RSI.DATA[period]+dar;
     if MA_RSI.DATA[period-1]<dv and tr>dv then
      tr=dv;
     end
    elseif MA_RSI.DATA[period]>=tr then
     tr=MA_RSI.DATA[period]-dar;
     if MA_RSI.DATA[period-1]>dv and tr<dv then
      tr=dv;
     end
    end
    Mbuff[period]=tr;
    Pbuff[period]=MA_RSI.DATA[period];
    if Pbuff[period]>Mbuff[period] then
     Pbuff:setColor(period, instance.parameters.UPclr);
     Mbuff:setColor(period, instance.parameters.UPclr);
    else
     Pbuff:setColor(period, instance.parameters.DNclr);
     Mbuff:setColor(period, instance.parameters.DNclr);
    end

end

