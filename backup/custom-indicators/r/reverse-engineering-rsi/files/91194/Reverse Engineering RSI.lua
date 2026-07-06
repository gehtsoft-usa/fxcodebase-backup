-- Id: 10564
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60010

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Reverse Engineering RSI");
    indicator:description("Reverse Engineering RSI");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("WildPer", "RSI Period", "RSI Period", 14);
	indicator.parameters:addInteger("MA_Period", "MA Period", "MA Period", 45);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
	
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("RevEngSMARSI_color", "Color of Reverse Engineering RSI MA", "Color of Reverse Engineering RSI MA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local WildPer;
local rsi, ma;
local first;
local source = nil;
local ExpPer;
-- Streams block
local RevEngMA = nil;
local Method,MA_Period;
local auc, AUC;
local ADC, adc;
-- Routine
function Prepare(nameOnly)
    Method = instance.parameters.Method;
	MA_Period = instance.parameters.MA_Period;
    WildPer = instance.parameters.WildPer;
	ExpPer=2*WildPer-1;
	
	  source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(WildPer).. ", " .. tostring(MA_Period).. ", " .. tostring(Method) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        rsi = core.indicators:create("RSI", source,WildPer );
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
        ma = core.indicators:create(Method, rsi.DATA, MA_Period);
        auc = instance:addInternalStream(0, 0);
        adc = instance:addInternalStream(0, 0);
        AUC = core.indicators:create("EMA", auc, ExpPer);
        ADC = core.indicators:create("EMA", adc, ExpPer);
      
        first = ma.DATA:first();
        RevEngMA = instance:addStream("RevEngMA", core.Line, name, "RevEngMA", instance.parameters.RevEngSMARSI_color, first);
		RevEngMA:setWidth(instance.parameters.width);
        RevEngMA:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

  if source[period]>source[period-1] then
  auc[period]=source[period]-source[period-1];
  adc[period]=0;
  else
  auc[period]=0;
  adc[period]=source[period-1]-source[period];
  end
  
 

    rsi:update(mode);
	ma:update(mode);
	AUC:update(mode);
	ADC:update(mode);

    if period < first   then
	return;
	end

	
	local x=(WildPer-1)*(ADC.DATA[period]*ma.DATA[period]/(100-ma.DATA[period])-AUC.DATA[period]);
	
     if x>=0  then	 
	RevEngMA[period] =  source[period]+x;
	else
	 RevEngMA[period] =  source[period]+x*(100-ma.DATA[period])/ma.DATA[period];
    end 

	 
   
end

