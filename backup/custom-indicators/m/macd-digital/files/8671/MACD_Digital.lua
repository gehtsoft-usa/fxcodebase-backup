-- Id: 3283
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3607

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
    indicator:name("MACD Digital");
    indicator:description("MACD Digital");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Signal_Method", "Signal Method", "", "EMA");
    indicator.parameters:addStringAlternative("Signal_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Signal_Method", "EMA", "", "EMA");
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
    indicator.parameters:addInteger("Signal_Period", "Signal_Period", "", 5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP", "Color UP", "Color UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "Color DN", "Color DN", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrSignal", "Color Signal", "Color Signal", core.rgb(0, 0, 255));
end

local first;
local source = nil;
local Signal_Method;
local Signal_Period;
local Buff=nil;
local MA;
local BuffUP=nil;
local BuffDN=nil;
local BuffSig=nil;

function Prepare(nameOnly)
    source = instance.source;
    Signal_Method=instance.parameters.Signal_Method;
    Signal_Period=instance.parameters.Signal_Period;
    Buff = instance:addInternalStream(0, 0);
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator"); 
	
    first = source:first()+65;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Signal_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    MA=core.indicators:create("AVERAGES", Buff, Signal_Method, Signal_Period, false);
    BuffUP = instance:addStream("BuffUP", core.Bar, name .. ".UP", "UP", instance.parameters.clrUP, first);
    BuffUP:setPrecision(math.max(2, instance.source:getPrecision()));
    BuffDN = instance:addStream("BuffDN", core.Bar, name .. ".DN", "DN", instance.parameters.clrDN, first);
    BuffDN:setPrecision(math.max(2, instance.source:getPrecision()));
    BuffSig = instance:addStream("BuffSig", core.Line, name .. ".Signal", "Signal", instance.parameters.clrSignal, first+Signal_Period);
    BuffSig:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period<first+65) then
   return;
   end
   
   local Val1=
 0.2149840610*source[period]
+0.2065763732*source[period-1]
+0.1903728890*source[period-2]
+0.1675422436*source[period-3]
+0.1397053150*source[period-4]
+0.1087951881*source[period-5]
+0.0768869405*source[period-6]
+0.0460244906*source[period-7]
+0.0180517395*source[period-8]
-0.0055294579*source[period-9]
-0.0236660212*source[period-10]
-0.0358140055*source[period-11]
-0.0419497760*source[period-12]
-0.0425331450*source[period-13]
-0.0384279507*source[period-14]
-0.0307917433*source[period-15]
-0.0209443384*source[period-16]
-0.0102335925*source[period-17]
+0.0000932767*source[period-18]
+0.0089950015*source[period-19]
+0.0157131144*source[period-20]
+0.0198149331*source[period-21]
+0.0211989019*source[period-22]
+0.0200639819*source[period-23]
+0.0168532934*source[period-24]
+0.0121825067*source[period-25]
+0.0067474241*source[period-26]
+0.0012444305*source[period-27]
-0.0037087682*source[period-28]
-0.0076300416*source[period-29]
-0.0102110543*source[period-30]
-0.0113306266*source[period-31]
-0.0110462105*source[period-32]
-0.0095662166*source[period-33]
-0.0072080453*source[period-34]
-0.0043494435*source[period-35]
-0.0013771970*source[period-36]
+0.0013575268*source[period-37]
+0.0035760416*source[period-38]
+0.0050946166*source[period-39]
+0.0058339574*source[period-40]
+0.0058160431*source[period-41]
+0.0051486631*source[period-42]
+0.0039984014*source[period-43]
+0.0025619380*source[period-44]
+0.0010531475*source[period-45]
-0.0003481453*source[period-46]
-0.0014937154*source[period-47]
-0.0022905986*source[period-48]
-0.0027000514*source[period-49]
-0.0027359080*source[period-50]
-0.0024543322*source[period-51]
-0.0019409837*source[period-52]
-0.0012957482*source[period-53]
-0.0006179734*source[period-54]
+0.0000057542*source[period-55]
+0.0005111297*source[period-56]
+0.0008605279*source[period-57]
+0.0010441921*source[period-58]
+0.0010775684*source[period-59]
+0.0009966494*source[period-60]
+0.0008537300*source[period-61]
+0.0007142855*source[period-62]
+0.0006599146*source[period-63]
-0.0008151017*source[period-64];

   local Val2 = 
 0.0825641231*source[period]
+0.0822783080*source[period-1]
+0.0814249974*source[period-2]
+0.0800166909*source[period-3]
+0.0780735197*source[period-4]
+0.0756232268*source[period-5]
+0.0727009740*source[period-6]
+0.0693478349*source[period-7]
+0.0656105823*source[period-8]
+0.0615409157*source[period-9]
+0.0571939540*source[period-10]
+0.0526285643*source[period-11]
+0.0479025123*source[period-12]
+0.0430785482*source[period-13]
+0.0382152880*source[period-14]
+0.0333706133*source[period-15]
+0.0286021160*source[period-16]
+0.0239614376*source[period-17]
+0.0194972056*source[period-18]
+0.0152532583*source[period-19]
+0.0112682658*source[period-20]
+0.0075745482*source[period-21]
+0.0041980052*source[period-22]
+0.0011588603*source[period-23]
-0.0015292889*source[period-24]
-0.0038593393*source[period-25]
-0.0058303888*source[period-26]
-0.0074473108*source[period-27]
-0.0087203043*source[period-28]
-0.0096645874*source[period-29]
-0.0102995666*source[period-30]
-0.0106483424*source[period-31]
-0.0107374524*source[period-32]
-0.0105952115*source[period-33]
-0.0102516944*source[period-34]
-0.0097377645*source[period-35]
-0.0090838346*source[period-36]
-0.0083237046*source[period-37]
-0.0074804382*source[period-38]
-0.0065902734*source[period-39]
-0.0056742995*source[period-40]
-0.0047554314*source[period-41]
-0.0038574209*source[period-42]
-0.0029983549*source[period-43]
-0.0021924972*source[period-44]
-0.0014513858*source[period-45]
-0.0007848072*source[period-46]
-0.0001995891*source[period-47]
+0.0003009728*source[period-48]
+0.0007162164*source[period-49]
+0.0010478905*source[period-50]
+0.0012994016*source[period-51]
+0.0014755433*source[period-52]
+0.0015824007*source[period-53]
+0.0016272598*source[period-54]
+0.0016185271*source[period-55]
+0.0015648336*source[period-56]
+0.0014747659*source[period-57]
+0.0013569946*source[period-58]
+0.0012193896*source[period-59]
+0.0010695971*source[period-60]
+0.0009140878*source[period-61]
+0.0007591540*source[period-62]
+0.0016019033*source[period-63];
    
    Buff[period]=Val1-Val2; 
    if Buff[period]>0 then
     BuffUP[period]=Buff[period];
     BuffDN[period]=nil;
    else
     BuffDN[period]=Buff[period];
     BuffUP[period]=nil;
    end
    
    if period>first+Signal_Period then
     MA:update(mode);
     BuffSig[period]=MA.DATA[period];
    end
 
end

