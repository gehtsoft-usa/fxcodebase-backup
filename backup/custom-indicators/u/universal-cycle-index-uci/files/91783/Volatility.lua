-- Id: 10779
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60163

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Volatility");
    indicator:description("Volatility");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
     indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("AveragePeriod", "Average Period", "Average Period", 25);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
		
    indicator.parameters:addInteger("ShiftPeriod", "Shift Period", "Shift Period", 12);
    indicator.parameters:addInteger("SummarizingPeriod", "Summarizing Period", "Summarizing Period", 50);
	
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Volatility_color", "Color of Volatility", "Color of Volatility", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local AveragePeriod;
local ShiftPeriod;
local SummarizingPeriod;
local Method;
local first;
local source = nil;

-- Streams block
local Volatility = nil;
local MA,yom,yomyom,som, Avg,varyom;
-- Routine
function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    AveragePeriod = instance.parameters.AveragePeriod;
    ShiftPeriod = instance.parameters.ShiftPeriod;
	Method = instance.parameters.Method;
    SummarizingPeriod = instance.parameters.SummarizingPeriod;
    source = instance.source;
	
	yom= instance:addInternalStream(0, 0);
	yomyom= instance:addInternalStream(0, 0);
	som= instance:addInternalStream(0, 0);
	varyom = instance:addInternalStream(0, 0);
	
    MA = core.indicators:create( Method, source, AveragePeriod);
	Avg = core.indicators:create( Method, som, AveragePeriod);
    first = MA.DATA:first()+ShiftPeriod;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(AveragePeriod) .. ", " .. tostring(Method) .. ", " .. tostring(ShiftPeriod) .. ", " .. tostring(SummarizingPeriod) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Volatility = instance:addStream("Volatility", core.Line, name, "Volatility", instance.parameters.Volatility_color,Avg.DATA:first());
    Volatility:setPrecision(math.max(2, instance.source:getPrecision()));
		Volatility:setWidth(instance.parameters.width);
        Volatility:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    MA:update(mode);
	
    if period < first then
	return;
	end
	
	yom[period]= 100*(source[period]-MA.DATA[period-ShiftPeriod+1])/MA.DATA[period-ShiftPeriod+1];
	yomyom[period]=yom[period]*yom[period];
	
	 if period < first  +  SummarizingPeriod then
	return;
	end
	
	local avyom= mathex.sum(yom, period-SummarizingPeriod+1, period)/SummarizingPeriod;
	 varyom[period] = mathex.sum(yomyom,period-SummarizingPeriod+1, period)/50-avyom*avyom;
	som[period]= math.sqrt(varyom[period-ShiftPeriod+1]) ;
	
	Avg:update(mode);
	
	if period < Avg.DATA:first() then
	return;
	end
	
        Volatility[period] = Avg.DATA[period];
    
end
--[[
yom:=100*(C-Ref(Mov(C,25,S),12))/Ref(Mov(C,25,S),12);
avyom:=Sum(yom,50)/50;
varyom:=Sum(yom*yom,50)/50-avyom*avyom;
som:=Ref(Sqrt(varyom),-12);
sigom:=Mov(som,25,S); sigom;
]]