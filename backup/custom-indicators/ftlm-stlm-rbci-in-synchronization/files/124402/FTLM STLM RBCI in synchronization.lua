-- Id: 24160
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67442

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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


-- Indicator profile initialization routine

function Init()
    indicator:name("FTLM STLM RBCI in synchronization");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Selector"); 
	
	
	
	indicator.parameters:addBoolean("S1", "Use 1. Filter", "", true);
	indicator.parameters:addBoolean("S2", "Use 2. Filter", "", true);
	indicator.parameters:addBoolean("S3", "Use 3. Filter", "", true);
	
	indicator.parameters:addGroup("MA Calculation"); 
	indicator.parameters:addInteger("Period", "MA Period", "Period" , 14);
	indicator.parameters:addString("Method", "MA Method", "Method" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("1. Filter Calculation"); 
	
 
	indicator.parameters:addString("Method1", "Selector", "Selector" , "FATL");
    indicator.parameters:addStringAlternative("Method1", "FTLM", "FTLM" , "FTLM");
    indicator.parameters:addStringAlternative("Method1", "STLM", "STLM" , "STLM");
    indicator.parameters:addStringAlternative("Method1", "FATL", "FATL" , "FATL");
	indicator.parameters:addStringAlternative("Method1", "SATL", "SATL" , "SATL");
	indicator.parameters:addStringAlternative("Method1", "RFTL", "RFTL" , "RFTL");
	indicator.parameters:addStringAlternative("Method1", "RSTL", "RSTL" , "RSTL");
	indicator.parameters:addStringAlternative("Method1", "RBCI", "RBCI" , "RBCI");
	indicator.parameters:addStringAlternative("Method1", "PCCI", "PCCI" , "PCCI");
	
	indicator.parameters:addGroup("2. Filter Calculation"); 
	
 
	indicator.parameters:addString("Method2", "Selector", "Selector" , "FTLM");
    indicator.parameters:addStringAlternative("Method2", "FTLM", "FTLM" , "FTLM");
    indicator.parameters:addStringAlternative("Method2", "STLM", "STLM" , "STLM");
    indicator.parameters:addStringAlternative("Method2", "FATL", "FATL" , "FATL");
	indicator.parameters:addStringAlternative("Method2", "SATL", "SATL" , "SATL");
	indicator.parameters:addStringAlternative("Method2", "RFTL", "RFTL" , "RFTL");
	indicator.parameters:addStringAlternative("Method2", "RSTL", "RSTL" , "RSTL");
	indicator.parameters:addStringAlternative("Method2", "RBCI", "RBCI" , "RBCI");
	indicator.parameters:addStringAlternative("Method2", "PCCI", "PCCI" , "PCCI");
	
	
	
	indicator.parameters:addGroup("3. Filter Calculation"); 
	
 
	indicator.parameters:addString("Method3", "Selector", "Selector" , "RBCI");
    indicator.parameters:addStringAlternative("Method3", "FTLM", "FTLM" , "FTLM");
    indicator.parameters:addStringAlternative("Method3", "STLM", "STLM" , "STLM");
    indicator.parameters:addStringAlternative("Method3", "FATL", "FATL" , "FATL");
	indicator.parameters:addStringAlternative("Method3", "SATL", "SATL" , "SATL");
	indicator.parameters:addStringAlternative("Method3", "RFTL", "RFTL" , "RFTL");
	indicator.parameters:addStringAlternative("Method3", "RSTL", "RSTL" , "RSTL");
	indicator.parameters:addStringAlternative("Method3", "RBCI", "RBCI" , "RBCI");
	indicator.parameters:addStringAlternative("Method3", "PCCI", "PCCI" , "PCCI");
	
	 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Bar Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Bar Color", "", core.rgb(255,0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Bar Color", "", core.rgb(0,0, 255));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Period, Method;
local Method1;
local Method2; 
local Method3; 
local first;
local source = nil;
 
local MA={};  
local Indicator={};
local S1, S2, S3;
-- Routine
 function Prepare(nameOnly)    
 
 
    Period= instance.parameters.Period;
	Method= instance.parameters.Method
 
    Method1= instance.parameters.Method1; 
    Method2= instance.parameters.Method2; 
	Method3= instance.parameters.Method3; 
	
	S1= instance.parameters.S1;
	S2= instance.parameters.S2;
	S3= instance.parameters.S3;
	
	local Parameters= Period ..  ", "   .. Method ..  ", "   ..  Method1 ..  ", "   .. Method2 ..  ", " .. Method3;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

 
	
	assert(core.indicators:findIndicator("FTLM-STLM COMPONENTS") ~= nil, "Please, download and install FTLM-STLM COMPONENTS.LUA indicator");
			
    source = instance.source;
    
  
    Indicator[1] = core.indicators:create("FTLM-STLM COMPONENTS", source, Method1);
    Indicator[2] = core.indicators:create("FTLM-STLM COMPONENTS", source, Method2);
	Indicator[3] = core.indicators:create("FTLM-STLM COMPONENTS", source, Method3);
	
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA[1] = core.indicators:create(Method,  Indicator[1].DATA, Period);
    MA[2] = core.indicators:create(Method,  Indicator[2].DATA, Period);
	MA[3] = core.indicators:create(Method,  Indicator[3].DATA, Period);
    
    first=math.max(MA[1].DATA:first(), MA[2].DATA:first(),  MA[3].DATA:first());
	
	 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",instance.parameters.Neutral, first);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
    Oscillator[period]=0;
	
    if not S1 and not S2 and not S3 then
	return;
	end
	
	
    Indicator[1]:update(mode);
    Indicator[2]:update(mode);
	Indicator[3]:update(mode);
	
	MA[1]:update(mode);
    MA[2]:update(mode);
	MA[3]:update(mode);
	
	
    if period < first then
	return;
	end
	
	if ((Indicator[1].DATA[period]> MA[1].DATA[period] and S1) or not S1)
	and ((Indicator[2].DATA[period]> MA[2].DATA[period]and S2 ) or not S2)
	and ((Indicator[3].DATA[period]> MA[3].DATA[period] and S3) or not S3)
	then
	Oscillator[period]=1;
	elseif ((Indicator[1].DATA[period]< MA[1].DATA[period] and S1) or not S1)
	and ((Indicator[2].DATA[period]< MA[2].DATA[period] and S2) or not S2)
	and ((Indicator[3].DATA[period]< MA[3].DATA[period] and S3) or not S3)
	then
	Oscillator[period]=-1;
	else
	Oscillator[period]=0;
	end
	
		
    if  Oscillator[period] > 0 then  
	Oscillator:setColor(period, instance.parameters.Up);
	elseif  Oscillator[period] < 0 then  
	Oscillator:setColor(period, instance.parameters.Down);
	else
    Oscillator:setColor(period, instance.parameters.Neutral);	
	end
end

