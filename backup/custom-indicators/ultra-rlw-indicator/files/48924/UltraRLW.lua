-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27882
-- Id: 8199

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
    indicator:name("Ultra RLW");
    indicator:description("Ultra RLW");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RLW_Period", "RLW period", "", 13);
    indicator.parameters:addString("Method1", "Average method", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method1", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method1", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method1", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method1", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method1", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method1", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method1", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method1", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method1", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method1", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method1", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method1", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method1", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method1", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method1", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method1", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("Start", "Start length", "", 3);
    indicator.parameters:addInteger("Step", "Step length", "", 5);
    indicator.parameters:addInteger("StepsTotal", "Total steps", "", 10);
    indicator.parameters:addString("Method2", "Smoothing method", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method2", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method2", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method2", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method2", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method2", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method2", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method2", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method2", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method2", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method2", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method2", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method2", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method2", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method2", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method2", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method2", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("SmoothPeriod", "Smoothing period", "", 3);
    indicator.parameters:addInteger("OverboughtLevel", "Overbought level", "", 30);
    indicator.parameters:addInteger("OversoldLevel", "Oversold level", "", -30);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("OBclr", "Overbought Color", "Overbought Color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("OSclr", "Oversold Color", "Oversold Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Level width", "Level width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Level style", "Level style", core.LINE_DASH);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local RLW_Period;
local Method1;
local Start;
local Step;
local StepsTotal;
local Method2;
local SmoothPeriod;
local RLW;
local MA_Array={};
local Up;
local UpBuff=nil;
local DnBuff=nil;
local SmoothMA;

function Prepare(nameOnly)
    source = instance.source;
    RLW_Period=instance.parameters.RLW_Period;
    Method1=instance.parameters.Method1;
    Start=instance.parameters.Start;
    Step=instance.parameters.Step;
    StepsTotal=instance.parameters.StepsTotal;
    Method2=instance.parameters.Method2;
    SmoothPeriod=instance.parameters.SmoothPeriod;
    local dUpLevel=instance.parameters.OverboughtLevel*StepsTotal/100;
    local dDnLevel=instance.parameters.OversoldLevel*StepsTotal/100;
    
    local i;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.RLW_Period .. ", " .. instance.parameters.Method1 .. ", " .. instance.parameters.Start .. ", " .. instance.parameters.Step .. ", " .. instance.parameters.StepsTotal .. ", " .. instance.parameters.Method2 .. ", " .. instance.parameters.SmoothPeriod .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	
    RLW = core.indicators:create("RLW", source, RLW_Period);
	
	first = source:first();
	
    for i=0,StepsTotal,1 do
     MA_Array[i] = core.indicators:create("AVERAGES", RLW.DATA, Method1, Start+Step*i, false);
	 first = math.max( MA_Array[i].DATA:first(), first);
    end
    Up = instance:addInternalStream(first, 0);
    SmoothMA = core.indicators:create("AVERAGES", Up, Method2, SmoothPeriod, false);

    UpBuff = instance:addStream("Up", core.Bar, name .. ".Up", "Up", instance.parameters.UPclr, SmoothMA.DATA:first());
    UpBuff:setPrecision(math.max(2, instance.source:getPrecision()));
    DnBuff = instance:addStream("Dn", core.Bar, name .. ".Dn", "Dn", instance.parameters.UPclr, SmoothMA.DATA:first());
    DnBuff:setPrecision(math.max(2, instance.source:getPrecision()));
    UpBuff:addLevel(dUpLevel, instance.parameters.styleLinReg, instance.parameters.widthLinReg, instance.parameters.OBclr);
    DnBuff:addLevel(dDnLevel, instance.parameters.styleLinReg, instance.parameters.widthLinReg, instance.parameters.OSclr);
end

function Update(period, mode)

   RLW:update(mode);
   
   if (period<first) then
   return;
   end
   
    
    local i;
    local Count=0;
    for i=0,StepsTotal,1 do
     MA_Array[i]:update(mode);
     if MA_Array[i].DATA[period]>MA_Array[i].DATA[period-1] then
      Count=Count+1;
     end
    end
	
    Up[period] = Count;
    SmoothMA:update(mode);
	
   if (period<SmoothMA.DATA:first()) then
   return;
   end
   
    UpBuff[period]=math.max(SmoothMA.DATA[period], StepsTotal+1-SmoothMA.DATA[period])-StepsTotal/2;
    DnBuff[period]=-UpBuff[period];
    
    if SmoothMA.DATA[period]>StepsTotal/2 then
     UpBuff:setColor(period, instance.parameters.UPclr);
     DnBuff:setColor(period, instance.parameters.UPclr);
    else
     UpBuff:setColor(period, instance.parameters.DNclr);
     DnBuff:setColor(period, instance.parameters.DNclr);
    end
  
end

