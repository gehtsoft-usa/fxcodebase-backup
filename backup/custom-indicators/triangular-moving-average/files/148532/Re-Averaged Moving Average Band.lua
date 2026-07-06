-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72993

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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
    indicator:name("Re-Averaged Moving Average Re-Averaged Moving Average Band");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

 	indicator.parameters:addGroup("Selector");
    indicator.parameters:addBoolean("ShowMAs", "Show MAs", "", false);
    indicator.parameters:addBoolean("ShowLast", "Show Last MA", "", false); 
 	
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "", 14, 1, 2000);
    indicator.parameters:addInteger("N", "Number of Re-Averaging ", "", 10, 0, 2000);	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");	
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(128, 128, 128)); 
	indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color3", "Central Line Color", "", core.rgb(0, 0, 255)); 
	indicator.parameters:addColor("color4", "LAst MA Line Color", "", core.rgb(128, 0, 255)); 	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period,Method, N; 
local Indicator;
local MVA={};	
local Line={};
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	Method=instance.parameters.Method;
	N=instance.parameters.N+1;
	ShowMAs=instance.parameters.ShowMAs;
	ShowLast=instance.parameters.ShowLast;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period  .. "," .. Method .. "," ..  N .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	for i= 1, N , 1 do
	if i== 1 then
		MVA[i]= core.indicators:create(Method, source, Period);
		else
		MVA[i]= core.indicators:create(Method, MVA[i-1].DATA, Period);	
		end	
	end
	first=MVA[N].DATA:first() ; 
	
 
 
	
	for i= 1, N , 1 do	
	    if ShowMAs then
		Line[i] = instance:addStream("Line"..i, core.Line, name, i..". Line", instance.parameters.color, first );
		Line[i]:setPrecision(math.max(2, instance.source:getPrecision()));
		Line[i]:setWidth(instance.parameters.width);
		Line[i]:setStyle(instance.parameters.style);
		Line[i]:addLevel(0);	 
		else
		Line[i] = instance:addInternalStream(0, 0);
		end
	end
	
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color1, first );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style); 
 
 
    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color2, first );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style); 
	
	
    Central = instance:addStream("Central", core.Line, name, "Central", instance.parameters.color3, first );
    Central:setPrecision(math.max(2, instance.source:getPrecision()));
    Central:setWidth(instance.parameters.width);
    Central:setStyle(instance.parameters.style); 
	
	if ShowLast then
    Last = instance:addStream("Last", core.Line, name, "Last", instance.parameters.color4, first );
    Last:setPrecision(math.max(2, instance.source:getPrecision()));
    Last:setWidth(instance.parameters.width);
    Last:setStyle(instance.parameters.style); 	
	else
    Last = instance:addInternalStream(0, 0);	
	end
end


function Update(period, mode)
    for i= 1, N , 1 do 	
	MVA[i]:update(mode); 
    end
	
	 if period <= first then
	 return;
	 end
	
	local min=math.huge;
	local max=MVA[1].DATA[period];
	
    for i= 1, N , 1 do 		  	
	Line[i][period]= MVA[i].DATA[period];
		if  max < Line[i][period] then
		max = Line[i][period]
		end
		if  min > Line[i][period] then
		min = Line[i][period]
		end
	end
	
	
	Last[period]=MVA[N].DATA[period];
	
	
	Top[period]=max;
	Bottom[period]=min;	
	Central[period]=(Top[period]+Bottom[period])/2;	
	
	
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