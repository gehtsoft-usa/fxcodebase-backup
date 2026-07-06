-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3767

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
    indicator:name("Average of MA");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period_1", "First period", "No description", 5);
    indicator.parameters:addString("Method", "Method", "", "Add");
    indicator.parameters:addStringAlternative("Method", "Add", "", "Add");
    indicator.parameters:addStringAlternative("Method", "Mult", "", "Mult");
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

    indicator.parameters:addInteger("K", "K", "No description", 2);
    indicator.parameters:addInteger("N", "Count of MA", "No description", 5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Color", "Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local Period1;
local K;
local N;
local Method;
local MA_Method;

local first;
local source = nil;
local Buff;

local Inds={};

function Prepare(nameOnly)
    Period1 = instance.parameters.Period_1;
    K = instance.parameters.K;
    N = instance.parameters.N;
    Method = instance.parameters.Method;
    MA_Method = instance.parameters.MA_Method;
    source = instance.source;
    local Period=Period1;
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. Period1 .. ", " .. K .. ", " .. N .. ", " .. MA_Method .. ", " .. Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    for i=1,N,1 do
        Ind=core.indicators:create("AVERAGES", source, MA_Method, Period, false);
        Inds[i]=Ind;
        if Method=="Mult" then
            Period=Period*K;
        else
            Period=Period+K;
        end 
    end
    
    first = Inds[N].DATA:first()+2;
    
    Buff = instance:addStream("Buff", core.Line, name .. ".Buff", "Buff", instance.parameters.Color, first);
    Buff:setWidth(instance.parameters.widthLinReg);
    Buff:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
 if (period>first) then
  local Sum=0;
  for i=1,N,1 do
   Inds[i]:update(mode);
   Sum=Sum+Inds[i].DATA[period];
  end
  Buff[period]=Sum/N;
 end 
end

