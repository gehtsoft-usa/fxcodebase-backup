-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73256

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
    indicator:name("Kijun-sen Envelope");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Kijun_Sen_Period", "Kijun Sen Period", "", 26, 1, 2000);
    indicator.parameters:addInteger("ShiftKijun", "Shift Kijun", "", 0);
    indicator.parameters:addDouble("Envelope_Deviation_Multiplier", "Envelope Deviation Multiplier", "", 1);	

	indicator.parameters:addString("Method", "Method", "Method" , "Median");
    indicator.parameters:addStringAlternative("Method", "Whole Range Maximum", "" , "Maximum");
    indicator.parameters:addStringAlternative("Method", "Whole Range Median" , "" , "Median");
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Kijun Line Color", "", core.rgb(0, 0, 255)); 
	 indicator.parameters:addColor("color2", "Top Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color3", "Bottom Line Color", "", core.rgb(0, 255, 0)); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Kijun_Sen_Period, ShiftKijun,Envelope_Deviation_Multiplier; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Kijun_Sen_Period=instance.parameters.Kijun_Sen_Period;
	ShiftKijun=instance.parameters.ShiftKijun;
	Envelope_Deviation_Multiplier=instance.parameters.Envelope_Deviation_Multiplier;
	Method=instance.parameters.Method;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	 
	first=math.max( source:first() ,source:first() + math.abs(ShiftKijun) )+ Kijun_Sen_Period ; 
	
	Delta = instance:addInternalStream(0, 0);
	Range = instance:addInternalStream(0, 0);
	
    Kijun = instance:addStream("Kijun", core.Line, name, "Kijun", instance.parameters.color1, first, ShiftKijun );
    Kijun:setPrecision(math.max(2, instance.source:getPrecision()));
    Kijun:setWidth(instance.parameters.width);
    Kijun:setStyle(instance.parameters.style);
 
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color2, first, ShiftKijun );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
	
    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color3, first, ShiftKijun );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);	
end


function Update(period, mode)

 

	if period <= first +ShiftKijun
	or  not source:hasData(period) 
	then
	return;
	end
	
	local min, max=mathex.minmax(source, period-Kijun_Sen_Period+1, period );
	Kijun[period+ShiftKijun]= (max+min)/2;	
	
	
    Delta[period]=math.abs(source.close[period] -(max+min)/2)  	
 	 
 
	if period <= first +math.abs(ShiftKijun)
	or  not source:hasData(period) 
	then
	return;
	end
	
	local Median=mathex.median_s(Delta, first, period) 	
	
	Range[period]=math.max(Range[period-1], Delta[period] );
	
	if Method == "Maximum" then
	Top[period+ShiftKijun]= Kijun[period+ShiftKijun]+ Envelope_Deviation_Multiplier*Range[period];	
	Bottom[period+ShiftKijun]= Kijun[period+ShiftKijun]-Envelope_Deviation_Multiplier*Range[period];		
	elseif Method == "Median" then
	Top[period+ShiftKijun]= Kijun[period+ShiftKijun]+ Envelope_Deviation_Multiplier*Median;	
	Bottom[period+ShiftKijun]= Kijun[period+ShiftKijun]-Envelope_Deviation_Multiplier*Median;		
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