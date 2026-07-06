-- Id: 10786
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60163

--+------------------------------------------------------------------+
--|                               Copyright � 2018, Gehtsoft USA LLC | 
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
    indicator:name("Centered  Minor cycle index");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
     indicator.parameters:addGroup("Volatility Calculation");	
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
	
	 indicator.parameters:addGroup(" Index Calculation");
	 
	 indicator.parameters:addInteger("Short", "Short MA Period", "Short MA Period", 12); 
	 indicator.parameters:addInteger("Long", "Long MA Period", "Long MA Period", 25);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MCI_color", "Color of MCI", "Color of MCI", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 50);
    indicator.parameters:addDouble("oversold","Oversold Level","", -50);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
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
local MCI;
local Short, Long, Method1;
-- Streams block
local sigom,MCI;
local MA,yom,yomyom,som, Avg,varyom;
local MA1,MA2;
local yme;
 
-- Routine
function Prepare(nameOnly)   
 
    
	
    AveragePeriod = instance.parameters.AveragePeriod;
    ShiftPeriod = instance.parameters.ShiftPeriod;
	Method = instance.parameters.Method;
    SummarizingPeriod = instance.parameters.SummarizingPeriod;
	Short = instance.parameters.Short;
	Long = instance.parameters.Long;
	Method1 = instance.parameters.Method1;
    source = instance.source;
	
	
	  local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(AveragePeriod) .. ", " .. tostring(Method) .. ", " .. tostring(ShiftPeriod) .. ", " .. tostring(SummarizingPeriod) 
	 .. ", " ..Short .. ", " .. Long .. ", " .. Method1
	
	.. ")";
	
	
    instance:name(name);
	
	    if   (nameOnly) then
        return;
    end
	
	yom= instance:addInternalStream(0, 0);
	yomyom= instance:addInternalStream(0, 0);
	som= instance:addInternalStream(0, 0);
	varyom = instance:addInternalStream(0, 0);
	sigom = instance:addInternalStream(0, 0);
	yme= instance:addInternalStream(0, 0);
	 
	
	
    MA = core.indicators:create( Method, source, AveragePeriod);
	Avg = core.indicators:create( Method, som, AveragePeriod);
    first = MA.DATA:first()+ShiftPeriod;
	 MA1 = core.indicators:create ( Method1, source, Short);
	 MA2 = core.indicators:create( Method1, source, Long);
	 
        MCI = instance:addStream("ICI", core.Line, name, "ICI", instance.parameters.MCI_color, math.max(MA1.DATA:first(),MA2.DATA:first())+ math.max(MA1.DATA:first(),MA2.DATA:first())/2 );
		MCI:setWidth(instance.parameters.width);
        MCI:setStyle(instance.parameters.style);
		MCI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		MCI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		MCI:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		
		MCI:setPrecision(math.max(2, instance.source:getPrecision()));
		
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    MA:update(mode);
	
    if period < first then
	return;
	end
	
	yom[period]= 100*(source[period]-MA.DATA[period-ShiftPeriod])/MA.DATA[period-ShiftPeriod];
	yomyom[period]=yom[period]*yom[period];
	
	 if period < first  +  SummarizingPeriod then
	return;
	end
	
	local avyom= mathex.sum(yom, period-SummarizingPeriod+1, period)/SummarizingPeriod;
	 varyom[period] = mathex.sum(yomyom,period-SummarizingPeriod+1, period)/50-avyom*avyom;
	som[period]= math.sqrt(varyom[period-ShiftPeriod]) ;
	
	Avg:update(mode);
	
	if period < Avg.DATA:first() then
	return;
	end
	
        sigom[period] = Avg.DATA[period];
		
		MA1:update(mode);
		MA2:update(mode);
		
	if period < math.max(MA1.DATA:first(),MA2.DATA:first())+ math.max(MA1.DATA:first(),MA2.DATA:first())/2 then
	return;
	end	
	yme[period]=100*(MA1.DATA[period-Short/2+1]-MA2.DATA[period-Long/2+1])/MA2.DATA[period-Long/2+1]
	
	 
	
 
	
    MCI[period]= 100*yme[period]/sigom[period]
	
end

--[[
sigom:=FmlVar(�_sac-sigom�,�sigom�);
ym:=100*(Ref(Mov(C,12,S),6)-Ref(Mov(C,25,S),12))/
Ref(Mov(C,25,S),12);
ymn:=100*ym/sigom; ymn

 ]]
 
 