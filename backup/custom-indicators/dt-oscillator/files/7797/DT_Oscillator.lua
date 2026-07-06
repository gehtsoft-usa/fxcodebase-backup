-- Id: 2989
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("DT Oscillator");
    indicator:description("DT Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RSI_Period", "Period of RSI", "", 13);
    indicator.parameters:addInteger("Stoch_Period", "Period of Stoch", "", 8);
    indicator.parameters:addInteger("SK_Period", "SK_Period", "", 5);
    indicator.parameters:addInteger("SD_Period", "SD_Period", "", 3);
	indicator.parameters:addInteger("OB_Level", "Overbought Level", "", 75);
	indicator.parameters:addInteger("OS_Level", "Oversold Level", "", 25);
    indicator.parameters:addString("MA_Method", "MA_Method", "", "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("MA_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("MA_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("MA_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("MA_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MA_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("MA_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("MA_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("MA_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("MA_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("MA_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("MA_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("MA_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("MA_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("MA_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("MA_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("MA_Method", "JSmooth", "", "JSmooth");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("SKclr", "SK Color", "SK Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("SDclr", "SD Color", "SD Color", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local RSI_Period;
local Stoch_Period;
local SK_Period;
local SD_Period;
local MA_Method;
local StoRSI_Array;
local SK_Array;
local SK_Buff=nil;
local SD_Buff=nil;
local RSI;
local MA1;
local MA2;
local OS_Level;
local OB_Level;

function Prepare(nameOnly)
    source = instance.source;
    RSI_Period=instance.parameters.RSI_Period;
    Stoch_Period=instance.parameters.Stoch_Period;
    SK_Period=instance.parameters.SK_Period;
    SD_Period=instance.parameters.SD_Period;
    MA_Method=instance.parameters.MA_Method;
	OS_Level =instance.parameters.OS_Level;
	OB_Level =instance.parameters.OB_Level;
    RSI = core.indicators:create("RSI", source.close, RSI_Period);
     first = source:first()+Stoch_Period+RSI_Period;
    StoRSI_Array = instance:addInternalStream(first, 0);
    SK_Array = instance:addInternalStream(first, 0);
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.RSI_Period .. ", " .. instance.parameters.Stoch_Period .. ", " .. instance.parameters.SK_Period .. ", " .. instance.parameters.SD_Period .. ", " .. instance.parameters.MA_Method .. ")";
    instance:name(name);
	if nameOnly then
        return;
    end
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
 
	
    MA1 = core.indicators:create("AVERAGES", StoRSI_Array, MA_Method, SK_Period, false);
    MA2 = core.indicators:create("AVERAGES", MA1.DATA, MA_Method, SD_Period, false);
    
	
    SK_Buff = instance:addStream("SK_Buff", core.Line, name .. ".SK", "SK", instance.parameters.SKclr, first+SK_Period);
    SD_Buff = instance:addStream("SD_Buff", core.Line, name .. ".SD", "SD", instance.parameters.SDclr, first+SD_Period);
    SK_Buff:addLevel(0);    
    SK_Buff:addLevel(OS_Level);    
    SK_Buff:addLevel(OB_Level);  
    SK_Buff:addLevel(100);    
	
	SK_Buff:setWidth(instance.parameters.width1);
	SK_Buff:setStyle(instance.parameters.style1);
	SD_Buff:setWidth(instance.parameters.width2);
	SD_Buff:setStyle(instance.parameters.style2);
	
	SK_Buff:setPrecision(math.max(2, instance.source:getPrecision()));
	SD_Buff:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
     if (period<first) then
   return;
   end
   
   
    RSI:update(mode);
    local LLV, HHV=mathex.min(RSI.DATA, period-Stoch_Period+1, period);
   
    if HHV-LLV~=0 then
     StoRSI_Array[period]=100.*(RSI.DATA[period]-LLV)/(HHV-LLV);
    else
     StoRSI_Array[period]=0; 
    end
    MA1:update(mode);
    MA2:update(mode);
	
   if (period>first+SK_Period) then
    SK_Buff[period]=MA1.DATA[period];
   end
   
   if (period>first+SD_Period) then
    SD_Buff[period]=MA2.DATA[period];
   end
    
  
end

