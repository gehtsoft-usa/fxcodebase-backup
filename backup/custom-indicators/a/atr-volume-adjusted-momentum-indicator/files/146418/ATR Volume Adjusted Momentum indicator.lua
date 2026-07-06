-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72401

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("ATR & Volume Adjusted Momentum indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("avgP", "Period", "", 10, 1, 2000);
 
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA"); 
	
    indicator.parameters:addInteger("p1", "1. Period", "", 5, 1, 2000);
    indicator.parameters:addInteger("p2", "2. Period", "", 30, 1, 2000);
    indicator.parameters:addInteger("p3", "3. Period", "", 14, 1, 2000);	 
    indicator.parameters:addInteger("momp", "Momentum Period", "", 5, 1, 2000);  
 
 
 	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 
	indicator.parameters:addColor("color1", "Up Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "Down Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local avgP, Method; 
local p1, p2, p3, momp; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	avgP=instance.parameters.avgP;
	Method=instance.parameters.Method;
	p1=instance.parameters.p1;
	p2=instance.parameters.p2;
	p3=instance.parameters.p3;	
	momp=instance.parameters.momp;

	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  avgP.. "," ..  Method.. "," ..  p1.. "," ..  p2 .. "," ..  p3 .. "," ..  momp  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	--Indicator= core.indicators:create(Method, source, Period1, Period2);
	ATR= core.indicators:create("ATR", source, momp);	
	first=ATR.DATA:first() ; 
	
	
	Mtm = instance:addInternalStream(0, 0);
    AbsMtm= instance:addInternalStream(0, 0)
	Bensu= instance:addInternalStream(0, 0)
	
	
	EMA1= core.indicators:create("EMA", Mtm, p1);	
	EMA3= core.indicators:create("EMA", AbsMtm, p1);	
	
	EMA2= core.indicators:create("EMA", EMA1.DATA, p2);	
	EMA4= core.indicators:create("EMA", EMA3.DATA, p2);	

	LWMA= core.indicators:create("LWMA", Bensu, p3);	
	


    Bar = instance:addStream("Bar", core.Bar, name, "Signal line", instance.parameters.color1, first + p1 + p2 + p3  );
    Bar:setPrecision(math.max(2, instance.source:getPrecision())); 
    Bar:addLevel(0);	 
	
	MA= core.indicators:create("LWMA", Bar, avgP);	
	
    Line = instance:addStream("Line", core.Line, name, "VOLUME ADJUSTED MOMENTUM", instance.parameters.color, first + p1 + p2 + p3 +avgP );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);		
	
end


function Update(period, mode)

	--  Indicator:update(mode); 
	ATR:update(mode);  
	 if period <= first then
	 return;
	 end
	 
    Mtm[period] = (source.close[period] - source.close[period-momp+1] )/ATR.DATA[period]
    AbsMtm[period] = (math.abs ( Mtm[period])+ math.abs(source.volume[period]-source.volume[period-momp+1]))	
	
	
	EMA1:update(mode); 
	EMA2:update(mode); 
	EMA3:update(mode); 
	EMA4:update(mode);
	
	 if period <= first + p1 + p2 then
	 return;
	 end
	 
    local NumE = EMA2.DATA[period];
    local DenE = EMA4.DATA[period];
	
	
    Bensu[period] = 100*(NumE/DenE)	
	
	LWMA:update(mode)	
	
	 if period <= first + p1 + p2 + p3 then
	 return;
	 end
	
	Bar[period]= LWMA.DATA[period];
	
	
	MA:update(mode)			
	 if period <= first + p1 + p2 + p3 +avgP then
	 return;
	 end	
	Line[period]= MA.DATA[period];	
	
	if Bar[period] > 0 then
	Bar:setColor(period,  instance.parameters.color1);
    else	
	Bar:setColor(period,  instance.parameters.color2);	
	end
	
end
