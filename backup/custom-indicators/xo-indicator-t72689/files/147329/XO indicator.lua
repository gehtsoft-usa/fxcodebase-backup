-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72689

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
    indicator:name("XO indicator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addDouble("Size1", "Bar Box Size (in Pips)", "", 10, 1, 200000);
    indicator.parameters:addDouble("Size2", "Line Box Size (in Pips)", "", 30, 1, 200000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Up Bar Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down Bar Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Size1, Size2; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    

	source = instance.source
	
	Size1=instance.parameters.Size1*source:pipSize();
	Size2=instance.parameters.Size2*source:pipSize();
	
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Size1.. "," ..  Size2  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 
	first=source:first() ; 
	
	
	High1 = instance:addInternalStream(0, 0);
 	Low1 = instance:addInternalStream(0, 0);
	High2 = instance:addInternalStream(0, 0);
 	Low2 = instance:addInternalStream(0, 0);	
 
	
    UP1 = instance:addStream("UP1", core.Bar, name, "1. UP", instance.parameters.color1, first );
    UP1:setPrecision(math.max(2, instance.source:getPrecision())); 
    UP1:addLevel(0);	
	
    DN1 = instance:addStream("DN1", core.Bar, name, "1. DN", instance.parameters.color2, first );
    DN1:setPrecision(math.max(2, instance.source:getPrecision())); 
    DN1:addLevel(0);	


    UP2 = instance:addStream("UP2", core.Line, name, "2. UP", instance.parameters.color2, first );
    UP2:setPrecision(math.max(2, instance.source:getPrecision()));
    UP2:setWidth(instance.parameters.width);
    UP2:setStyle(instance.parameters.style);
    UP2:addLevel(0);	
	
    DN2 = instance:addStream("DN2", core.Line, name, "2. DN", instance.parameters.color1, first );
    DN2:setPrecision(math.max(2, instance.source:getPrecision()));
    DN2:setWidth(instance.parameters.width);
    DN2:setStyle(instance.parameters.style);
    DN2:addLevel(0);		
 
end


function Update(period, mode)



	 
	 if period <= first then	 
			UP1[period]= 0
			DN1[period]= 0
			High1[period]=source[period];
			Low1[period]=source[period];
			UP2[period]= 0
			DN2[period]= 0
			High2[period]=source[period];
			Low2[period]=source[period];			
	 return;
	 end
	 
	High1[period]=High1[period-1];
	Low1[period]=Low1[period-1];	 
	High2[period]=High2[period-1];
	Low2[period]=Low2[period-1];	
	UP1[period]= UP1[period-1]
	DN1[period]= DN1[period-1]
	UP2[period]= UP2[period-1]
	DN2[period]= DN2[period-1]	
	
	if source[period] > High1[period-1] + Size1 then
	UP1[period]=UP1[period-1]+1;
	DN1[period]=0;
	High1[period]=source[period];
	Low1[period]=High1[period] - Size1;	
	end
	
	if source[period]< Low1[period-1] - Size1 then
	DN1[period]=DN1[period-1]-1;	
	UP1[period]=0;
	Low1[period]=source[period];	
	High1[period]=Low1[period] + Size1;	
	end	
	
	 
	if source[period] > High2[period-1] + Size2 then
	UP2[period]=UP2[period-1]+1;
	DN2[period]=0;
	High2[period]=source[period];
	Low2[period]=High2[period] - Size2;	
	end
	
	if source[period]< Low2[period-1] - Size2 then
	DN2[period]=DN2[period-1]-1;	
	UP2[period]=0;
	Low2[period]=source[period];	
	High2[period]=Low2[period] + Size2;	
	end		
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

