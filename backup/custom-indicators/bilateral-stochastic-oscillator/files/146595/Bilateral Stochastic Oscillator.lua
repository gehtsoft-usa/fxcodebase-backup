-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72456

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
    indicator:name("Bilateral Stochastic Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("length", "Length", "", 100, 1, 2000);
	
	indicator.parameters:addString("Method", "Pre-Filtering Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addInteger("slen", "Signal Length", "", 20, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Bull Line Color", "", core.rgb(0, 255, 0)); 
 	 indicator.parameters:addColor("color2", "Bear Line Color", "", core.rgb(255, 0, 0)); 
 	 indicator.parameters:addColor("color3", "Signal Line Color", "", core.rgb(0, 0, 255)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local length, Method,slen; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	length=instance.parameters.length;
	Method=instance.parameters.Method;
	slen=instance.parameters.slen;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  length.. "," ..  Method.. "," ..  slen  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator= core.indicators:create(Method, source, length);
	first=Indicator.DATA:first() ; 
	
	
	Src = instance:addInternalStream(0, 0);
 	Range = instance:addInternalStream(0, 0);
	Max = instance:addInternalStream(0, 0);
	
	
    bull = instance:addStream("bull", core.Line, name, "bull", instance.parameters.color1, first+length*2 );
    bull:setPrecision(math.max(2, instance.source:getPrecision()));
    bull:setWidth(instance.parameters.width);
    bull:setStyle(instance.parameters.style);
    bull:addLevel(0);	
 
 
    bear = instance:addStream("bear", core.Line, name, "bear", instance.parameters.color2, first+length*2 );
    bear:setPrecision(math.max(2, instance.source:getPrecision()));
    bear:setWidth(instance.parameters.width);
    bear:setStyle(instance.parameters.style);
    bear:addLevel(0);	
	
    signal = instance:addStream("signal", core.Line, name, "signal", instance.parameters.color3, first+length*2+slen );
    signal:setPrecision(math.max(2, instance.source:getPrecision()));
    signal:setWidth(instance.parameters.width);
    signal:setStyle(instance.parameters.style);
    signal:addLevel(0);		
end


function Update(period, mode)

	  Indicator:update(mode); 

	 if period <= first then
	 return;
	 end
	 
    Src[period]= Indicator.DATA[period];
	
	 if period <= first +length then
	 return;
	 end	
	 
	 
	local b, a = mathex.minmax(Src, period-length+1, period) 
	Range[period]= a-b;

	 if period <= first +length*2 then
	 return;
	 end	

    local Average=mathex.minmax(Range, period-length+1, period);	 
	
	
	bull[period] = Src[period]/Average - b/Average
	bear[period] = math.abs(Src[period]/Average - a/Average)
	
	Max[period]= math.max(bull[period],bear[period]);
	
	 if period <= first +length*2 +slen then
	 return;
	 end	

	signal[period]=mathex.avg(Max, period-slen+1, period);	 
	
end

 