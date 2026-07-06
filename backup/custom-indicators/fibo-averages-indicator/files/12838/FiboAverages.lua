-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=5277

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
    indicator:name("Fibo averages indicator");
    indicator:description("Fibo averages indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FiboCount", "Count of fibo prices", "", 11);
    indicator.parameters:addString("MAMethod", "MAMethod", "", "MVA");
    indicator.parameters:addStringAlternative("MAMethod", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MAMethod", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MAMethod", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("MAMethod", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MAMethod", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("MAMethod", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("MAMethod", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("MAMethod", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MAMethod", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("MAMethod", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("MAMethod", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("MAMethod", "T3", "", "T3");
    indicator.parameters:addStringAlternative("MAMethod", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("MAMethod", "Median", "", "Median");
    indicator.parameters:addStringAlternative("MAMethod", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("MAMethod", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("MAMethod", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("MAMethod", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("MAMethod", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("MAMethod", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("MAPeriod", "MAPeriod", "", 55);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Fibo_clr", "Fibo Color", "Fibo Color", core.rgb(255, 255, 0));
    indicator.parameters:addColor("MA_clr", "MA Color", "MA Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local FiboCount;
local MAMethod;
local MAPeriod;
local MA;
local BuffFibo=nil;
local BuffMA=nil;
local FiboNumbers={};

function Prepare(nameOnly)
    source = instance.source;
    FiboCount=instance.parameters.FiboCount;
    MAMethod=instance.parameters.MAMethod;
    MAPeriod=instance.parameters.MAPeriod;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.FiboCount .. ", " .. instance.parameters.MAMethod .. ", " .. instance.parameters.MAPeriod .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
		 
	local i;
    FiboNumbers[1]=0;
    FiboNumbers[2]=1;
    for i=3,FiboCount,1 do
     FiboNumbers[i]=FiboNumbers[i-1]+FiboNumbers[i-2];
    end
	 
	BuffFibo = instance:addStream("BuffFibo", core.Line, name .. ".Fibo", "Fibo", instance.parameters.Fibo_clr, source:first()+FiboNumbers[FiboCount]);
	BuffFibo:setWidth(instance.parameters.widthLinReg);
    BuffFibo:setStyle(instance.parameters.styleLinReg);
	
	MA = core.indicators:create("AVERAGES", BuffFibo, MAMethod, MAPeriod, false);
	first = MA.DATA:first();
	
    BuffMA = instance:addStream("BuffMA", core.Line, name .. ".MA", "MA", instance.parameters.MA_clr, first);    
    BuffMA:setWidth(instance.parameters.widthLinReg);
    BuffMA:setStyle(instance.parameters.styleLinReg);
 
end

function Update(period, mode)
   if (period<source:first()+FiboNumbers[FiboCount]) then
   return;
   end
   
    local Sum=0;
    local i;
    for i=1,FiboCount,1 do
     Sum=Sum+source[period-FiboNumbers[i]];
    end
    BuffFibo[period]=Sum/FiboCount;
    if period < first  then
	return;
	end
     MA:update(mode);
     BuffMA[period]=MA.DATA[period];
    
end

