-- Id: 10439
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1290

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
    indicator:name("KDJ indicator");
    indicator:description("KDJ indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
	
	indicator.parameters:addGroup("Calculation");
    	
	indicator.parameters:addInteger("nPeriod", "nPeriod", "nPeriod", 9);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method1", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
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
	indicator.parameters:addStringAlternative("Method1", "KAMA", "", "KAMA");

    indicator.parameters:addInteger("Period1", "Period", "", 3);
 
    indicator.parameters:addString("Method2", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
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
	indicator.parameters:addStringAlternative("Method2", "KAMA", "", "KAMA");

    indicator.parameters:addInteger("Period2", "Period", "", 3);
	
	
 
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr_K", "Color K", "Color K", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clr_D", "Color D", "Color D", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clr_J", "Color J", "Color J", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

 
local source = nil;
local nPeriod;
local first;
local buff_K=nil;
local buff_D=nil;
local buff_J=nil;
local RSV;
local K, D;
local Method1, Period1, Method2, Period2;
function Prepare(nameOnly)
    source = instance.source;
    nPeriod=instance.parameters.nPeriod;
    Method1=instance.parameters.Method1;
    Method2=instance.parameters.Method2;
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
    first= source:first()+nPeriod;
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.nPeriod .. ", " .. Method1 .. ", " .. Period1.. ", " .. Method2.. ", " .. Period2 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	RSV = instance:addInternalStream(0, 0);
	K = core.indicators:create("AVERAGES", RSV, Method1 ,Period1);
	D = core.indicators:create("AVERAGES", K.DATA, Method2 ,Period2);
		 
	
    buff_K = instance:addStream("buff_K", core.Line, name .. ".K", "K", instance.parameters.clr_K, K.DATA:first());
    buff_K:setPrecision(math.max(2, instance.source:getPrecision()));
	buff_K:setWidth(instance.parameters.width1);
    buff_K:setStyle(instance.parameters.style1);
    buff_D = instance:addStream("buff_D", core.Line, name .. ".D", "D", instance.parameters.clr_D,  D.DATA:first());
    buff_D:setPrecision(math.max(2, instance.source:getPrecision()));
	buff_D:setWidth(instance.parameters.width2);
    buff_D:setStyle(instance.parameters.style2);
    buff_J = instance:addStream("buff_J", core.Line, name .. ".J", "J", instance.parameters.clr_J,  D.DATA:first());
    buff_J:setPrecision(math.max(2, instance.source:getPrecision()));
	buff_J:setWidth(instance.parameters.width3);
    buff_J:setStyle(instance.parameters.style3);
end

function Update(period, mode)
    if (period<first ) then
	return;
	end
	
     local Cn=source.close[period];
     local Ln=Cn;
     local Hn=Cn;
     for i=0,nPeriod-1,1 do
      Ln=math.min(Ln,source.low[period-i]);
      Hn=math.max(Hn,source.high[period-i]);
     end
     if Hn-Ln~=0. then
      RSV[period]=(Cn-Ln)/(Hn-Ln)*100.;
     else
      RSV[period]=50.;
     end
	 
	 K:update(mode);
	 
     if period <  K.DATA:first() then
     return;
     end		 
     buff_K[period]=K.DATA[period];
	 
	  D:update(mode);
	 
	  if period <  D.DATA:first() then
     return;
     end	
	 
     buff_D[period]=D.DATA[period];
     buff_J[period]=3.*buff_D[period]-2.*buff_K[period];

end

