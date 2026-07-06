-- Id: 10794
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
    indicator:name("Centered channel lines");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
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
	 
	 indicator.parameters:addInteger("Short", "MA Period", "MA Period",  25);
	 indicator.parameters:addDouble("Deviations", "Deviations", "Deviations",  2);
    indicator.parameters:addInteger("Shift", "Shift Period", "Shift Period",  12)
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
    indicator.parameters:addColor("MCI_color1", "Central Line Color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("MCI_color2", "Top Line Color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("MCI_color3", "Bottom Line Color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local AveragePeriod;
local TsfPeriod;
local ShiftPeriod;
local SummarizingPeriod;
local Method;
local first;
local source = nil;
local MCI;
local Shift;
local Short, Long, Method1;
-- Streams block
local sigom,MCI;
local MA,yom,yomyom,som, Avg,varyom;
local MA1,MA2;
local yme;
local TSF,ymes;
local Top, Bottom, Central;
local Deviations;
-- Routine
function Prepare(nameOnly)   
  
	
    AveragePeriod = instance.parameters.AveragePeriod;
	Deviations = instance.parameters.Deviations;
	TsfPeriod = instance.parameters.TsfPeriod;
    ShiftPeriod = instance.parameters.ShiftPeriod;
	Method = instance.parameters.Method;
    SummarizingPeriod = instance.parameters.SummarizingPeriod;
	Short = instance.parameters.Short;
	Long = instance.parameters.Long;
	Method1 = instance.parameters.Method1;
	Shift = instance.parameters.Shift;
    source = instance.source;
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(AveragePeriod) .. ", " .. tostring(Method) .. ", " .. tostring(ShiftPeriod) .. ", " .. tostring(SummarizingPeriod) 
	 .. ", " ..Short .. ", " .. Method1
	
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
	ymes= instance:addInternalStream(0, 0);
	
	
    MA = core.indicators:create( Method, source, AveragePeriod);
	Avg = core.indicators:create( Method, som, AveragePeriod);
    first = MA.DATA:first()+ShiftPeriod;
	 MA1 = core.indicators:create ( Method1, source, Short);
	 
	 
    assert(core.indicators:findIndicator("TSF") ~= nil, "TSF" .. " indicator must be installed");
	 TSF= core.indicators:create("TSF", yme, TsfPeriod);

    
	 
        Central = instance:addStream("Central", core.Line, name, "Central", instance.parameters.MCI_color1,MA1.DATA:first());
		Central:setWidth(instance.parameters.width1);
        Central:setStyle(instance.parameters.style1);
	    
		Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.MCI_color2,MA1.DATA:first());
		Top:setWidth(instance.parameters.width2);
        Top:setStyle(instance.parameters.style2);
		
		Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.MCI_color3,MA1.DATA:first());
		Bottom:setWidth(instance.parameters.width3);
        Bottom:setStyle(instance.parameters.style3);
 
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
		
		
	if period <MA1.DATA:first() then
	return;
	end	
	
	Central[period]= MA1.DATA[period-Shift];
	Top[period]= (1+Deviations*sigom[period]/100)*Central[period];
    Bottom[period]= (1-Deviations*sigom[period]/100)*Central[period];
	
		
end

--[[
sigom:=FmlVar(�_sac-sigom�,�sigom�);
arm:=Mov(C,25,S); arm;
(1+2.0*sigom/100)*arm;
(1-2.0*sigom/100)*arm;

---


sigom:=FmlVar(�_sac-sigom�,�sigom�);
acm:=Ref(Mov(C,25,S),12);
 acm;
(1+2.0*sigom/100)*acm; 
(1-2.0*sigom/100)*acm

 ]]
 
 