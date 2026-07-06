-- More information about this indicator can be found at:
-- http://fxcodebase.com

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
    indicator:name("Pivots JF. Carter");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Pivot Line Color", "", core.rgb(0, 0, 255)); 

	indicator.parameters:addColor("color11", "1. Top Pivot Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color12", "2. Top Pivot Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color13", "3. Top Pivot Line Color", "", core.rgb(0, 255, 0)); 	 


	indicator.parameters:addColor("color21", "1. Bottom Pivot Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color22", "2. Bottom Pivot Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color23", "3. Bottom Pivot Line Color", "", core.rgb(255, 0, 0));	 
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
  
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end 
	
	first=source:first() ; 
	
 
	
	
    Pv = instance:addStream("Pv", core.Line, name, "Pv", instance.parameters.color, first );
    Pv:setPrecision(math.max(2, instance.source:getPrecision()));
    Pv:setWidth(instance.parameters.width);
    Pv:setStyle(instance.parameters.style);
    Pv:addLevel(0);	
	
    Rs1 = instance:addStream("Rs1", core.Line, name, "T1", instance.parameters.color11, first );
    Rs1:setPrecision(math.max(2, instance.source:getPrecision()));
    Rs1:setWidth(instance.parameters.width);
    Rs1:setStyle(instance.parameters.style);
    Rs1:addLevel(0);	

    Rs2 = instance:addStream("Rs2", core.Line, name, "T2", instance.parameters.color12, first );
    Rs2:setPrecision(math.max(2, instance.source:getPrecision()));
    Rs2:setWidth(instance.parameters.width);
    Rs2:setStyle(instance.parameters.style);
    Rs2:addLevel(0);	

    Rs3 = instance:addStream("Rs3", core.Line, name, "T3", instance.parameters.color13, first );
    Rs3:setPrecision(math.max(2, instance.source:getPrecision()));
    Rs3:setWidth(instance.parameters.width);
    Rs3:setStyle(instance.parameters.style);
    Rs3:addLevel(0);	


    Ss1= instance:addStream("Ss1", core.Line, name, "B1", instance.parameters.color21, first );
    Ss1:setPrecision(math.max(2, instance.source:getPrecision()));
    Ss1:setWidth(instance.parameters.width);
    Ss1:setStyle(instance.parameters.style);
    Ss1:addLevel(0);	


    Ss2 = instance:addStream("Ss2", core.Line, name, "B2", instance.parameters.color22, first );
    Ss2:setPrecision(math.max(2, instance.source:getPrecision()));
    Ss2:setWidth(instance.parameters.width);
    Ss2:setStyle(instance.parameters.style);
    Ss2:addLevel(0);	

    Ss3 = instance:addStream("Ss3", core.Line, name, "B3", instance.parameters.color23, first );
    Ss3:setPrecision(math.max(2, instance.source:getPrecision()));
    Ss3:setWidth(instance.parameters.width);
    Ss3:setStyle(instance.parameters.style);
    Ss3:addLevel(0);		
 
end


function Update(period, mode)
 

	 if period < first then
	 return;
	 end
	 
 
 
 
Pv[period]=(source.high[period]+source.low[period] + source.close[period])/3;
Rs1[period]=2*Pv[period]-source.low[period]
Rs2[period]=Pv[period]+(source.high[period]-source.low[period])
Rs3[period]=Rs1[period] + (source.high[period]-source.low[period])
Ss1[period]=2*Pv[period]-source.high[period]
Ss2[period]=Pv[period]-(source.high[period]-source.low[period])
Ss3[period]=Ss1[period]-(source.high[period]-source.low[period])
	
	
 
	
end