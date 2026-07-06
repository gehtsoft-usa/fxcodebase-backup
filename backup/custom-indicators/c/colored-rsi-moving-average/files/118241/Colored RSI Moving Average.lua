-- Id: 20730
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65839

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+
function Init()
    indicator:name("Colored RSI Moving Average");
    indicator:description("Colored RSI Moving Average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RSI_Period", "RSI period", "", 14);
    indicator.parameters:addInteger("MA_Period", "MA period", "", 14);
    indicator.parameters:addString("MA_Method", "MA method", "", "EMA");
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

    indicator.parameters:addGroup("Style");
	
	indicator.parameters:addBoolean("Show", "Show RSI", "", false);
	
    indicator.parameters:addColor("RSIclr", "RSI Color", "RSI Color", core.rgb(0, 0, 288));
    indicator.parameters:addColor("MAclrUp", "MA Color Up", "MA Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("MAclrDown", "MA Color Down", "MA Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
 
end

local first;
local source = nil;
local RSI_Period;
local MA_Period;
local MA_Method;
local RSI_Buff = nil;
local MA_Buff = nil;
local RSI;
local MA;
local Show;
 function Prepare(nameOnly) 
    source = instance.source;
    RSI_Period=instance.parameters.RSI_Period;
    MA_Period=instance.parameters.MA_Period;
    MA_Method=instance.parameters.MA_Method;
	Show=instance.parameters.Show;
	 
	 
	 local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.RSI_Period .. ", " .. instance.parameters.MA_Period .. ", " .. instance.parameters.MA_Method .. ")";
    instance:name(name);
	
	
	 if   (nameOnly) then
        return;
    end
	
   
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	
    RSI = core.indicators:create("RSI", source, RSI_Period);
    MA = core.indicators:create("AVERAGES", RSI.DATA, MA_Method, MA_Period, false);
	
	first =MA.DATA:first();
   
    if Show  then
    RSI_Buff = instance:addStream("RSI", core.Line, name .. ".RSI", "RSI", instance.parameters.RSIclr, first);
	else
	  RSI_Buff= instance:addInternalStream(0, 0);
	end
	
    MA_Buff = instance:addStream("MA", core.Line, name .. ".MA", "MA", instance.parameters.MAclrUp, first);
    RSI_Buff:setWidth(instance.parameters.widthLinReg);
    RSI_Buff:setStyle(instance.parameters.styleLinReg);
    MA_Buff:setWidth(instance.parameters.widthLinReg);
    MA_Buff:setStyle(instance.parameters.styleLinReg);
	
	MA_Buff:setPrecision(math.max(2, instance.source:getPrecision()));
    RSI_Buff:setPrecision(math.max(2, instance.source:getPrecision()));
   
end

function Update(period, mode)
    
    RSI:update(mode);
    MA:update(mode);
	
	if (period<first) then
   return;
   end
	
	
    RSI_Buff[period] = RSI.DATA[period];
    MA_Buff[period] = MA.DATA[period];
	
	if MA_Buff[period]> 50 then
	MA_Buff:setColor(period, instance.parameters.MAclrUp);	
	else
	MA_Buff:setColor(period, 	instance.parameters.MAclrDown);
	end
	
 
end

