-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72583

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
    indicator:name("Fishnet Moving Averages with step");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("minperiod", "Min MA Period", "", 20, 1, 2000);
    indicator.parameters:addInteger("maxperiod", "Max MA Period", "", 200, 1, 2000);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");	

     indicator.parameters:addInteger("stepperiod", "Step Period", "", 5, 1, 2000);
     indicator.parameters:addInteger("alpha", "Slpha", "", 50, 1, 2000);  
	 
 
 
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local minperiod, maxperiod,Method,stepperiod  ; 
local Indicator={};
local Line={};
local segment;	
-- Routine
 function Prepare(nameOnly)   
 
    
	minperiod=instance.parameters.minperiod;
	maxperiod=instance.parameters.maxperiod;
	Method=instance.parameters.Method;
	stepperiod=instance.parameters.stepperiod; 
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  minperiod.. "," ..  maxperiod .. "," ..   Method   .. "," ..  stepperiod  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
	first=source:first() ; 	
	for i= minperiod, maxperiod, stepperiod do
	Indicator[i]= core.indicators:create(Method, source, i);
	first=math.max(first, Indicator[i].DATA:first()) ; 	
	end

	
	
   segment = (maxperiod-minperiod)/3
 
    local Number=0;	
	for i= minperiod, maxperiod, stepperiod do
	Number=Number+1;
    Line[i] = instance:addStream("Line"..Number, core.Line, name, Number, core.COLOR_LABEL , first );
    Line[i]:setPrecision(math.max(2, instance.source:getPrecision()));
    Line[i]:setWidth(instance.parameters.width);
    Line[i]:setStyle(instance.parameters.style);
    Line[i]:addLevel(0);	
	end
 
end


function Update(period, mode)
	for i= minperiod, maxperiod, stepperiod do
	  Indicator[i]:update(mode); 
	

    local r=255
    local g=81
    local b=38 
	
	 if(i>segment) then 
	  r=38
	  g=167
	  b=255
	 end 
	 if(i>segment*2) then 
	  r=178
	  g=58
	  b=238
	 end 
 
	
	Line[i][period]= Indicator[i].DATA[period];	 	
	Line[i]:setColor(period,  core.rgb(r, g, b));		
	end  
	
	
 
 
	
end
 