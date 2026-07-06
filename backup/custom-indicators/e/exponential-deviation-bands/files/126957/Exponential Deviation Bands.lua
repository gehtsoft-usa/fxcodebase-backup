-- Id: 25327
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68581

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
    indicator:name("Exponential Deviation Bands");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "Central Line Smoothing Period", "", 20, 2, 2000);
	indicator.parameters:addInteger("Period2", "Deviation Period", "", 20, 2, 2000);
	indicator.parameters:addInteger("Period3", "Deviation Smoothing Period", "", 20, 2, 2000);
    indicator.parameters:addDouble("Multiplier", "Multiplier", "", 2, 0, 2000);
	
	indicator.parameters:addString("Method1", "Central Line MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
	
	indicator.parameters:addString("Method2", "Deviation MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA")
 
	
	indicator.parameters:addGroup("Top Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("Bottom Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255,0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	
	
	indicator.parameters:addGroup("Central Line Style"); 	
    indicator.parameters:addColor("color3", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period1,Period2,Period3,Multiplier,Method1, Method2; 
local first;
local source = nil;
local Top, Bottom, Central;
local MA1,MA2,Data,Dev;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period1= instance.parameters.Period1;
	Period2= instance.parameters.Period2;
	Period3= instance.parameters.Period3;
	Multiplier= instance.parameters.Multiplier;
	Method1= instance.parameters.Method1;
	Method2= instance.parameters.Method2;
	
	local Parameters= Period1..", "..Period2..", "..Period3..", "..Multiplier..", "..Method1..", "..Method2;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

   
			
    source = instance.source; 
    first=source:first()+Period1;
	
	 
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    MA1 = core.indicators:create(Method1, source, Period1);
	Data= instance:addInternalStream(0, 0);
	Dev= instance:addInternalStream(0, 0);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
	MA2 = core.indicators:create(Method2, Dev, Period3);
 
	Top = instance:addStream("Top" , core.Line, "Top","Top",instance.parameters.color1, first );
	Top:setWidth(instance.parameters.width1);
    Top:setStyle(instance.parameters.style1);
    Top:setPrecision(math.max(2, source:getPrecision()));
	
	Bottom = instance:addStream("Bottom" , core.Line, "Bottom","Bottom",instance.parameters.color2, first );
	Bottom:setWidth(instance.parameters.width2);
    Bottom:setStyle(instance.parameters.style2);
    Bottom:setPrecision(math.max(2, source:getPrecision()));
	
	
	Central = instance:addStream("Central" , core.Line, "Central","Central",instance.parameters.color3, first );
	Central:setWidth(instance.parameters.width3);
    Central:setStyle(instance.parameters.style3);
    Central:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

    MA1:update(mode);
	if period < source:first()  
	then
	return;
	end
	 
     Central[period]=MA1.DATA[period];
	 
	 Data[period] = math.abs( Central[period] -source[period] ) ;
	
	if period < source:first() +Period2  
	then
	return;
	end
	
    Dev[period] = mathex.sum(Data, period-Period2+1, period)/Period2 ;
	 
	 MA2:update(mode);
	if period < source:first() +Period2  +Period3
	then
	return;
	end
	 

	 Top[period]=Central[period]+MA2.DATA[period]*Multiplier;
	 Bottom[period]=Central[period]-MA2.DATA[period]*Multiplier; 
	 
	 
				  
end

 

 
