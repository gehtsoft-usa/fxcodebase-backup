-- Id: 7968
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=26991

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("Ultra RSI");
    indicator:description("Ultra RSI");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RSI_Period", "RSI period", "", 13);
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
    indicator.parameters:addInteger("Level", "Level", "", 2);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local RSI_Period;
local Method1;
local Start;
local Step;
local StepsTotal;
local Method2;
local SmoothPeriod;
local RSI;
local MA_Array={};
local Up;
local UpBuff=nil;
local DnBuff=nil;
local SmoothMA;

function Prepare(nameOnly)
    source = instance.source;
    RSI_Period=instance.parameters.RSI_Period;
    Method1=instance.parameters.Method1;
    Start=instance.parameters.Start;
    Step=instance.parameters.Step;
    StepsTotal=instance.parameters.StepsTotal;
    Method2=instance.parameters.Method2;
    SmoothPeriod=instance.parameters.SmoothPeriod;
    first = source:first() ;
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    

    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.RSI_Period .. ", " .. instance.parameters.Method1 .. ", " .. instance.parameters.Start .. ", " .. instance.parameters.Step .. ", " .. instance.parameters.StepsTotal .. ", " .. instance.parameters.Method2 .. ", " .. instance.parameters.SmoothPeriod .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    local i;
    local Period=Start;
    RSI = core.indicators:create("RSI", source, RSI_Period);
    for i=1,StepsTotal,1 do
     MA_Array[i] = core.indicators:create("AVERAGES", RSI.DATA, Method1, Period, false);
     Period=Period+Step; 
	 first=math.max(first,MA_Array[i].DATA:first() );
    end
    Up = instance:addInternalStream(0, 0);
    SmoothMA = core.indicators:create("AVERAGES", Up, Method2, SmoothPeriod, false);
    UpBuff = instance:addStream("Up", core.Bar, name .. ".Up", "Up", instance.parameters.UPclr, first);
    UpBuff:setPrecision(math.max(2, instance.source:getPrecision()));
    DnBuff = instance:addStream("Dn", core.Bar, name .. ".Dn", "Dn", instance.parameters.DNclr, first);
    DnBuff:setPrecision(math.max(2, instance.source:getPrecision()));
    UpBuff:addLevel(instance.parameters.Level);
    UpBuff:addLevel(-instance.parameters.Level);
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    RSI:update(mode);
    local i;
    local Count=0;
    for i=1,StepsTotal,1 do
     MA_Array[i]:update(mode);
     if MA_Array[i].DATA[period]>MA_Array[i].DATA[period-1] then
      Count=Count+1 
     end
    end
    Up[period] = Count;
    SmoothMA:update(mode);
    if SmoothMA.DATA[period]>=StepsTotal/2 then
     UpBuff[period]=SmoothMA.DATA[period];
     DnBuff[period]=-UpBuff[period];
     UpBuff:setColor(period, instance.parameters.UPclr)
     DnBuff:setColor(period, instance.parameters.UPclr)
    else
     UpBuff[period]=StepsTotal/2-SmoothMA.DATA[period];
     DnBuff[period]=-UpBuff[period];
     UpBuff:setColor(period, instance.parameters.DNclr)
     DnBuff:setColor(period, instance.parameters.DNclr)
    end
   
end

