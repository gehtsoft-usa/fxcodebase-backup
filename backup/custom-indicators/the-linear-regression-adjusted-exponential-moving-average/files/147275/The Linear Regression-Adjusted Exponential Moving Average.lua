-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72677

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
--|                                                                       https://mario-jemic.com/ |
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
    indicator:name("The Linear Regression-Adjusted Exponential Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Periods", "EMA Length", "", 50, 1, 2000);
    indicator.parameters:addInteger("Pds", "LR Lookback Period", "", 50, 1, 2000);
    indicator.parameters:addInteger("Mltp", "Multiplier", "", 5, 1, 2000);	
	
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Periods, Pds, Mltp; 
local Indicator;
local Mltp1;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Periods=instance.parameters.Periods;
	Pds=instance.parameters.Pds;
	Mltp=instance.parameters.Mltp;	
	source = instance.source
	
   Mltp1 = 2.0 / ( Periods + 1.0)	;
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Periods.. "," ..  Pds .. "," ..  Mltp  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	---Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=source:first()+ Pds   ; 
	
	
	Dist = instance:addInternalStream(0, 0);
 
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first + Pds );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)

	 -- Indicator:update(mode); 

	 if period <= first then
	 return;
	 end
	 
    local  LR = mathex.lreg (source, period-Pds+1, period); 
    Dist[period] = math.abs(LR - source[period])
	
	
	 if period <= first +Pds then
	 return;
	 end
	 
	local  LLV,HHV= mathex.minmax(Dist, period-Pds+1, period);
	
 
    local  LRAdj = (Dist[period] - LLV) /(HHV - LLV)
    local  Mltp2 = LRAdj * Mltp
    local   Rate = Mltp1 * (1.0 + Mltp2)
    
  
	Line[period]=   Line[period-1] + Rate * (source[period] - Line[period-1])
	
end


 