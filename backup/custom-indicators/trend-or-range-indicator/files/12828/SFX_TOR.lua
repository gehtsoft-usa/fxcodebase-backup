-- Id: 4328

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=5270

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+
 

function Init()
    indicator:name("SFX Trend Or Range Indicator");
    indicator:description("SFX Trend Or Range Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ATRPeriod", "ATRPeriod", "", 12);
    indicator.parameters:addInteger("StdDevPeriod", "StdDevPeriod", "", 12);
    indicator.parameters:addString("StdDevPrice", "StdDevPrice", "", "close");
    indicator.parameters:addStringAlternative("StdDevPrice", "close", "", "close");
    indicator.parameters:addStringAlternative("StdDevPrice", "open", "", "open");
    indicator.parameters:addStringAlternative("StdDevPrice", "high", "", "high");
    indicator.parameters:addStringAlternative("StdDevPrice", "low", "", "low");
    indicator.parameters:addStringAlternative("StdDevPrice", "median", "", "median");
    indicator.parameters:addStringAlternative("StdDevPrice", "typical", "", "typical");
    indicator.parameters:addStringAlternative("StdDevPrice", "weighted", "", "weighted");
    indicator.parameters:addInteger("MAPeriod", "MAPeriod", "", 3);
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

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("ATR_clr", "ATR Color", "ATR Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("StdDev_clr", "StdDev Color", "StdDev Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("MA_clr", "MA Color", "MA Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local ATRPeriod;
local StdDevPeriod;
local StdDevPrice;
local MAPeriod;
local MAMethod;
local ATR;
local StdDev;
local MA;
local BuffATR=nil;
local BuffStdDev=nil;
local BuffMA=nil;

function Prepare(nameOnly)
    source = instance.source;
    ATRPeriod=instance.parameters.ATRPeriod;
    StdDevPeriod=instance.parameters.StdDevPeriod;
    StdDevPrice=instance.parameters.StdDevPrice;
    MAPeriod=instance.parameters.MAPeriod;
    MAMethod=instance.parameters.MAMethod;
	
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.ATRPeriod .. ", " .. instance.parameters.StdDevPeriod .. ", " .. instance.parameters.StdDevPrice .. ", " .. instance.parameters.MAMethod .. ", " .. instance.parameters.MAPeriod .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("STDDEV") ~= nil, "Please, download and install STDDEV.LUA indicator");
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");
	
	
    first = source:first();
    ATR = core.indicators:create("ATR", source, ATRPeriod);
    if StdDevPrice=="close" then
     StdDev = core.indicators:create("STDDEV", source.close, StdDevPeriod);
    elseif StdDevPrice=="open" then
     StdDev = core.indicators:create("STDDEV", source.open, StdDevPeriod);
    elseif StdDevPrice=="high" then
     StdDev = core.indicators:create("STDDEV", source.high, StdDevPeriod);
    elseif StdDevPrice=="low" then
     StdDev = core.indicators:create("STDDEV", source.low, StdDevPeriod);
    elseif StdDevPrice=="median" then
     StdDev = core.indicators:create("STDDEV", source.median, StdDevPeriod);
    elseif StdDevPrice=="typical" then
     StdDev = core.indicators:create("STDDEV", source.typical, StdDevPeriod);
    else
     StdDev = core.indicators:create("STDDEV", source.weighted, StdDevPeriod);
    end 
     
    MA = core.indicators:create("AVERAGES", StdDev.DATA, MAMethod, MAPeriod, false);
    
	
    BuffATR = instance:addStream("BuffATR", core.Line, name .. ".ATR", "ATR", instance.parameters.ATR_clr, first+ATRPeriod);
    BuffStdDev = instance:addStream("BuffStdDev", core.Line, name .. ".StdDev", "StdDev", instance.parameters.StdDev_clr, first+StdDevPeriod);
    BuffMA = instance:addStream("BuffMA", core.Line, name .. ".MA", "MA", instance.parameters.MA_clr,  MA.DATA:first());
    BuffATR:setWidth(instance.parameters.widthLinReg);
    BuffATR:setStyle(instance.parameters.styleLinReg);
    BuffStdDev:setWidth(instance.parameters.widthLinReg);
    BuffStdDev:setStyle(instance.parameters.styleLinReg);
    BuffMA:setWidth(instance.parameters.widthLinReg);
    BuffMA:setStyle(instance.parameters.styleLinReg);
	
	
	BuffATR:setPrecision(math.max(2, instance.source:getPrecision()));
	BuffStdDev:setPrecision(math.max(2, instance.source:getPrecision()));
	BuffMA:setPrecision(math.max(2, instance.source:getPrecision()));

end

function Update(period, mode)

   if (period>first+ATRPeriod) then
    ATR:update(mode);
    BuffATR[period]=ATR.DATA[period];
   end 
   
   StdDev:update(mode);
   
   if (period<first+StdDevPeriod) then    
   return;
   end
   
   BuffStdDev[period]=StdDev.DATA[period];
  --  if StdDev.DATA[period]>0 then
     
     MA:update(mode);
	 
	 if period < MA.DATA:first() then
	 return;
	 end
	 
     BuffMA[period]=MA.DATA[period]; 
  
end

