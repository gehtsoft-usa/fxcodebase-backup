-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73360

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("ATLAS Mini");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("BB Calculation");	
    indicator.parameters:addInteger("Period1", "Period", "", 20, 1, 2000);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 2, 1, 2000);

 	indicator.parameters:addGroup("Smoothing Calculation");		
    indicator.parameters:addInteger("Period2", "Period", "", 120, 1, 2000);	
 	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");	
	
 	indicator.parameters:addGroup("Signal Calculation");
    indicator.parameters:addDouble("CutOff", "CutOff Percentage", "", 0.2, 0, 1);
	
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "Widening of Wide Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "Narrowing of Wide Color", "", core.rgb(0, 200, 0)); 	
	
	indicator.parameters:addColor("color3", "Widening Narrow Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color4", "Narrowing of Narrow Color", "", core.rgb(200, 0, 0)); 	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil; 
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Deviation=instance.parameters.Deviation;
	Period2=instance.parameters.Period2;	
	Method=instance.parameters.Method;
	CutOff=instance.parameters.CutOff;
	source = instance.source
	
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1 .. "," ..  Deviation .. "," ..  Period2 .. "," ..  Method .. "," ..  CutOff .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	BB= core.indicators:create("BB", source, Period1, Deviation);  
	first= BB.DATA:first()   
	
	
	Width = instance:addInternalStream(0, 0);
 
	MA= core.indicators:create(Method,Width, Period2 );  	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color1, first+ Period2 );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)

	BB:update(mode); 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
    Width[period] = math.sqrt((BB.TL[period] - BB.BL[period])/ BB.TL[period]) * 20
	
	MA:update(mode); 
	
	if period <= first + Period2
	then
	return;
	end 
 
 
	  	
	Line[period]= Width[period] - (MA.DATA[period])*(1-CutOff);
	
	if Line[period] > 0 then
	    if Line[period]> Line[period-1] then
		Line:setColor(period, instance.parameters.color1);
		else
		Line:setColor(period, instance.parameters.color2);	
		end
    else
	    if Line[period]> Line[period-1] then	
		Line:setColor(period, instance.parameters.color3);	
		else
		Line:setColor(period, instance.parameters.color4);	 
        end		
    end	
end

 

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+


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