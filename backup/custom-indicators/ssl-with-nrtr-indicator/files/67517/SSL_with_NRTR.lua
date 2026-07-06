-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41294

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
    indicator:name("SSL with NRTR indicator");
    indicator:description("SSL with NRTR indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 13);
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
    indicator.parameters:addBoolean("NRTR", "Enable NRTR", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP line color", "UP line color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN line color", "DN line color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("UPDclr", "UP dot color", "UP dot color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNDclr", "DN dot color", "DN dot color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);
end

local first;
local source = nil;
local Period;
local Method;
local NRTR;
local HMA, LMA;
local trend;
local UP=nil;
local DN=nil;
local UPdot=nil;
local DNdot=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Method=instance.parameters.Method;
    NRTR=instance.parameters.NRTR;
    first = source:first()+2;
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Method .. ")";
    instance:name(name);
    if (nameOnly) then
        return;
    end

    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");
	
    trend=instance:addInternalStream(first, 0);
    HMA = core.indicators:create("AVERAGES", source.high, Method, Period, false);
    LMA = core.indicators:create("AVERAGES", source.low, Method, Period, false);
    UP = instance:addStream("UP", core.Line, name .. ".UP", "UP", instance.parameters.UPclr, first);
    DN = instance:addStream("DN", core.Line, name .. ".DN", "DN", instance.parameters.DNclr, first);
    UP:setWidth(instance.parameters.widthLinReg);
    UP:setStyle(instance.parameters.styleLinReg);
    DN:setWidth(instance.parameters.widthLinReg);
    DN:setStyle(instance.parameters.styleLinReg);
    UPdot = instance:addStream("UPdot", core.Dot, name .. ".UPdot", "UPdot", instance.parameters.UPDclr, first);
    DNdot = instance:addStream("DNdot", core.Dot, name .. ".DNdot", "DNdot", instance.parameters.DNDclr, first);
    UPdot:setWidth(instance.parameters.DotSize);
    DNdot:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)
   if period>first+Period then
    HMA:update(mode);
    LMA:update(mode);
    if source.close[period]>HMA.DATA[period-1] then
     trend[period]=1;
    elseif source.close[period]<LMA.DATA[period-1] then
     trend[period]=-1;
    else
     trend[period]=trend[period-1];
    end
    if trend[period]==-1 then
     UP[period]=nil;
     if not(NRTR) or DN[period-1]==nil or DN[period-1]==0 then
      DN[period]=HMA.DATA[period-1];
     else
      DN[period]=math.min(HMA.DATA[period-1], DN[period-1]);
     end
    else
     DN[period]=nil;
     if not(NRTR) or UP[period-1]==nil or UP[period-1]==0 then
      UP[period]=LMA.DATA[period-1];
     else
      UP[period]=math.max(LMA.DATA[period-1], UP[period-1]);
     end
    end
    if UP[period-1]==0 and UP[period]~=0 then
     UPdot[period]=UP[period];
    end
    if DN[period-1]==0 and DN[period]~=0 then
     DNdot[period]=DN[period];
    end
   end 
end

