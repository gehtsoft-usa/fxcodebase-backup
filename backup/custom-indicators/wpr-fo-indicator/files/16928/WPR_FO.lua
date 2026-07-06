-- Id: 4859

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7633

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
    indicator:name("WPR_FO indicator");
    indicator:description("WPR_FO indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("WPR_Period", "WPR Period", "", 5);
    indicator.parameters:addInteger("MA_Period", "MA_Period", "", 9);
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

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("NEclr", "Neutral Color", "Neutral Color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local WPR_Period;
local MA_Period;
local Method;
local Value;
local MA;
local WPR_FO=nil;
local RLW;

function Prepare(nameOnly)  
    source = instance.source;
    WPR_Period=instance.parameters.WPR_Period;
    MA_Period=instance.parameters.MA_Period;
    Method=instance.parameters.Method;
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.WPR_Period .. ", " .. instance.parameters.MA_Period .. ", " .. instance.parameters.Method .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
   
    Value = instance:addInternalStream(0, 0);
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	
    RLW = core.indicators:create("RLW", source, WPR_Period);
    MA = core.indicators:create("AVERAGES", Value, Method, MA_Period, false);
	first = MA.DATA:first();
    
	
    WPR_FO = instance:addStream("WPR_FO", core.Line, name .. ".WPR_FO", "WPR_FO", instance.parameters.NEclr, first);
    WPR_FO:setWidth(instance.parameters.widthLinReg);
    WPR_FO:setStyle(instance.parameters.styleLinReg);
	
	
	WPR_FO:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period<RLW.DATA:first()) then
   return;
   end
   
    RLW:update(mode);
    Value[period]=0.1*(RLW.DATA[period]+50);
    MA:update(mode);
	if period < first then
	return;
	end
	
    WPR_FO[period]=(math.exp(2*MA.DATA[period])-1)/(math.exp(2*MA.DATA[period])+1);
    if WPR_FO[period]>0.5 then
     WPR_FO:setColor(period,instance.parameters.UPclr);
     WPR_FO:setColor(period-1,instance.parameters.UPclr);
    end
    if WPR_FO[period]<-0.5 then
     WPR_FO:setColor(period,instance.parameters.DNclr);
     WPR_FO:setColor(period-1,instance.parameters.DNclr);
    end
 
end

