-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27886
-- Id: 8207

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
    indicator:name("UltraFatl indicator");
    indicator:description("UltraFatl indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method1", "Method 1", "", "EMA");
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
    indicator.parameters:addInteger("Period1", "Period 1", "", 3);
    indicator.parameters:addInteger("Step", "Step", "", 5);
    indicator.parameters:addInteger("StepsTotal", "Steps total", "", 10);
    indicator.parameters:addString("Method2", "Method 2", "", "EMA");
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
    indicator.parameters:addInteger("Period2", "Period 2", "", 3);
    indicator.parameters:addInteger("OverboughtLevel", "Overbought level", "", 30);
    indicator.parameters:addInteger("OversoldLevel", "Oversold level", "", -30);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color 1", "Color 1", core.rgb(255, 0, 255));
    indicator.parameters:addColor("clr2", "Color 2", "Color 2", core.rgb(255, 128, 192));
    indicator.parameters:addColor("clr3", "Color 3", "Color 3", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clr4", "Color 4", "Color 4", core.rgb(128, 0, 0));
    indicator.parameters:addColor("clr5", "Color 5", "Color 5", core.rgb(128, 255, 128));
    indicator.parameters:addColor("clr6", "Color 6", "Color 6", core.rgb(0, 128, 0));
    indicator.parameters:addColor("clr7", "Color 7", "Color 7", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr8", "Color 8", "Color 8", core.rgb(192, 255, 192));
    indicator.parameters:addColor("OBclr", "Overbought Color", "Overbought Color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("OSclr", "Oversold Color", "Oversold Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Level width", "Level width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Level style", "Level style", core.LINE_DASH);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Method1;
local Period1;
local Step;
local StepsTotal;
local Method2;
local Period2;
local OverboughtLevel;
local OversoldLevel;
local UpBuff=nil;
local DnBuff=nil;
local Fatl;
local MAs={};
local UpCount;
local MA2;
local dUpLevel, dDnLevel;

function Prepare(nameOnly)
    source = instance.source;
    Method1=instance.parameters.Method1;
    Period1=instance.parameters.Period1;
    Step=instance.parameters.Step;
    StepsTotal=instance.parameters.StepsTotal;
    Method2=instance.parameters.Method2;
    Period2=instance.parameters.Period2;
    OverboughtLevel=instance.parameters.OverboughtLevel;
    OversoldLevel=instance.parameters.OversoldLevel;
    dUpLevel=OverboughtLevel*StepsTotal/100;
    dDnLevel=OversoldLevel*StepsTotal/100;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Method1 .. ", " .. instance.parameters.Period1 .. ", " .. instance.parameters.Step .. ", " .. instance.parameters.StepsTotal .. ", " .. instance.parameters.Method2 .. ", " .. instance.parameters.Period2 .. ", " .. instance.parameters.OverboughtLevel .. ", " .. instance.parameters.OversoldLevel .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	assert(core.indicators:findIndicator("FATL") ~= nil, "Please, download and install FATL.LUA indicator");    
    
	
    Fatl = core.indicators:create("FATL", source);
    local i;
    local Ind;
	
	first = source:first();
    for i=0,StepsTotal,1 do
     MAs[i]=core.indicators:create("AVERAGES", Fatl.DATA, Method1, Period1+Step*i, false);
	 
	 first=math.max(first, MAs[i].DATA:first());
    end
	
    UpCount=instance:addInternalStream(first, 0);
    MA2=core.indicators:create("AVERAGES", UpCount, Method2, Period2, false);
    UpBuff = instance:addStream("Up", core.Bar, name .. ".Up", "Up", instance.parameters.clr1, MA2.DATA:first() );
    UpBuff:setPrecision(math.max(2, instance.source:getPrecision()));
    DnBuff = instance:addStream("Dn", core.Bar, name .. ".Dn", "Dn", instance.parameters.clr1, MA2.DATA:first() );
    DnBuff:setPrecision(math.max(2, instance.source:getPrecision()));
    UpBuff:addLevel(dUpLevel, instance.parameters.styleLinReg, instance.parameters.widthLinReg, instance.parameters.OBclr);
    DnBuff:addLevel(dDnLevel, instance.parameters.styleLinReg, instance.parameters.widthLinReg, instance.parameters.OSclr);
end

function Update(period, mode)
   if (period<Fatl.DATA:first()) then
   return;
   end
   
    Fatl:update(mode);
	
	if period < first then
	return;
	end
	
    local i;
    local _UpCount=0;
    for i=0,StepsTotal,1 do
     MAs[i]:update(mode);
     if MAs[i].DATA[period]>MAs[i].DATA[period-1] then
      _UpCount=_UpCount+1;
     end
    end
	
    UpCount[period]=_UpCount;
	
	if period < MA2.DATA:first() then
	return;
	end
	
    MA2:update(mode);
    UpBuff[period]=math.max(MA2.DATA[period],StepsTotal+1-MA2.DATA[period])-StepsTotal/2;
    DnBuff[period]=-UpBuff[period];
    if MA2.DATA[period]>StepsTotal/2 then
     if MA2.DATA[period]>dUpLevel or StepsTotal+1-MA2.DATA[period]<dDnLevel then
      if MA2.DATA[period-1]<=MA2.DATA[period] then
       UpBuff:setColor(period, instance.parameters.clr7);
       DnBuff:setColor(period, instance.parameters.clr7);
      else
       UpBuff:setColor(period, instance.parameters.clr8);
       DnBuff:setColor(period, instance.parameters.clr8);
      end
     else
      if MA2.DATA[period-1]<=MA2.DATA[period] then
       UpBuff:setColor(period, instance.parameters.clr5);
       DnBuff:setColor(period, instance.parameters.clr5);
      else
       UpBuff:setColor(period, instance.parameters.clr6);
       DnBuff:setColor(period, instance.parameters.clr6);
      end
     end
    else
     if MA2.DATA[period]<dDnLevel or StepsTotal+1-MA2.DATA[period]>dUpLevel then
      if MA2.DATA[period-1]>=MA2.DATA[period] then
       UpBuff:setColor(period, instance.parameters.clr1);
       DnBuff:setColor(period, instance.parameters.clr1);
      else
       UpBuff:setColor(period, instance.parameters.clr2);
       DnBuff:setColor(period, instance.parameters.clr2);
      end
     else
      if MA2.DATA[period-1]>=MA2.DATA[period] then
       UpBuff:setColor(period, instance.parameters.clr3);
       DnBuff:setColor(period, instance.parameters.clr3);
      else
       UpBuff:setColor(period, instance.parameters.clr4);
       DnBuff:setColor(period, instance.parameters.clr4);
      end
     end
    end
   
end

