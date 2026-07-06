-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59572


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
    indicator:name("Heikin-Ashi MA T3 indicator");
    indicator:description("Heikin-Ashi MA T3 indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("replaceSource", "t");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("MA_Period", "Ma period", "", 10);
    indicator.parameters:addString("MA_Method", "MA method", "", "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "KAMA", "", "KAMA");
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
    indicator.parameters:addInteger("Step", "Step", "", 1);
    indicator.parameters:addBoolean("UseT3", "Use T3", "", true);
    indicator.parameters:addDouble("b", "b", "", 0.88);
    indicator.parameters:addBoolean("Alerts", "Alerts", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP", "Color UP", "Color UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "Color DN", "Color DN", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrUPA", "Color UP arrow", "Color UP arrow", core.rgb(0, 128, 0));
    indicator.parameters:addColor("clrDNA", "Color DN arrow", "Color DN arrow", core.rgb(128, 0, 0));
    indicator.parameters:addInteger("ArrowSize", "Arrow size", "", 15);
end

local first;
local source = nil;
local MA_Period;
local MA_Method;
local Step;
local UseT3;
local b;
local Alerts;
local StepPip;

local open=nil;
local high=nil;
local low=nil;
local close=nil;
local MA_O, MA_H, MA_L, MA_C;
local ArrowUP=nil;
local ArrowDN=nil;

 function Prepare(nameOnly) 
    source = instance.source;
    MA_Period=instance.parameters.MA_Period;
    MA_Method=instance.parameters.MA_Method;
    Step=instance.parameters.Step;
    UseT3=instance.parameters.UseT3;
    b=instance.parameters.b;
    Alerts=instance.parameters.Alerts;
    StepPip=Step*source:pipSize();
    
	
	 
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.MA_Period .. ", " .. instance.parameters.MA_Method .. ", " .. instance.parameters.Step .. ", " .. instance.parameters.b .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    if not(UseT3) then
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");  
     MA_O = core.indicators:create("AVERAGES", source.open, MA_Method, MA_Period, false);
     MA_H = core.indicators:create("AVERAGES", source.high, MA_Method, MA_Period, false);
     MA_L = core.indicators:create("AVERAGES", source.low, MA_Method, MA_Period, false);
     MA_C = core.indicators:create("AVERAGES", source.close, MA_Method, MA_Period, false);
    else 
	assert(core.indicators:findIndicator("T3_MA") ~= nil, "Please, download and install T3_MA.LUA indicator");  
     MA_O = core.indicators:create("T3_MA", source.open, MA_Period, b);
     MA_H = core.indicators:create("T3_MA", source.high, MA_Period, b);
     MA_L = core.indicators:create("T3_MA", source.low, MA_Period, b);
     MA_C = core.indicators:create("T3_MA", source.close, MA_Period, b);
    end
	
	first = MA_O.DATA:first();
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first);
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first);
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first);
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("HA_MA", "HA_MA", open, high, low, close);
    ArrowUP = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Top, instance.parameters.clrUPA, 0);
    ArrowDN = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Bottom, instance.parameters.clrDNA, 0);
end

function Update(period, mode)
   if period>first then
    local MA_Open, MA_High, MA_Low, MA_Close;
    MA_O:update(mode);
    MA_H:update(mode);
    MA_L:update(mode);
    MA_C:update(mode);
    MA_Open=MA_O.DATA[period];
    MA_High=MA_H.DATA[period];
    MA_Low=MA_L.DATA[period];
    MA_Close=MA_C.DATA[period];

    close[period]=(MA_Open+MA_High+MA_Low+MA_Close)/4;
    open[period]=(open[period-1]+close[period-1])/2;
    high[period]=math.max(MA_High, open[period], close[period]);
    low[period]=math.min(MA_Low, open[period], close[period]);

    if Step>0 then
     if math.abs(open[period]-open[period-1])<StepPip then
      open[period]=open[period-1];
     end 
     if math.abs(high[period]-high[period-1])<StepPip then
      high[period]=high[period-1];
     end 
     if math.abs(low[period]-low[period-1])<StepPip then
      low[period]=low[period-1];
     end 
     if math.abs(close[period]-close[period-1])<StepPip then
      close[period]=close[period-1];
     end 
    end

    if open[period]<close[period] then
     open:setColor(period, instance.parameters.clrUP);
    else
     open:setColor(period, instance.parameters.clrDN);
    end
    
    if Alerts then
     if open[period]<close[period] and open[period-1]>close[period-1] then
      ArrowUP:set(period, high[period], "\226");
     else
      ArrowUP:setNoData(period);
     end
     if open[period]>close[period] and open[period-1]<close[period-1] then
      ArrowDN:set(period, low[period], "\225");
     else
      ArrowDN:setNoData(period);
     end
    end
   end 
end

