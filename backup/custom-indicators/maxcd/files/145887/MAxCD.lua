-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72146

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
    indicator:name("MAxCD");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("CDM1", "Fast Period", "", 10, 1, 2000);
    indicator.parameters:addInteger("CDM2", "Min Period", "", 23, 1, 2000);
    indicator.parameters:addInteger("CDM3", "Slow Period", "", 20, 1, 2000);
	
	indicator.parameters:addBoolean("Line", "Show Lines", "", true);	
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Main Bar Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color2", "Midle Bar Color", "", core.rgb(0, 0, 255)); 
	 indicator.parameters:addColor("color3", "Fast Bar Color", "", core.rgb(0, 255, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local CDM1, CDM2,CDM3,Line; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	CDM1=instance.parameters.CDM1;
	CDM2=instance.parameters.CDM2;
	CDM3=instance.parameters.CDM3;
	Line=instance.parameters.Line;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  CDM1.. "," ..  CDM2 .. "," ..  CDM3  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	 
	Indicator1= core.indicators:create("LWMA", source.close, CDM1);
	Indicator2= core.indicators:create("LWMA", source.open, CDM2);
	Indicator3= core.indicators:create("SMMA", source.median, CDM3);	
	first=math.max(Indicator1.DATA:first(),Indicator2.DATA:first(),Indicator3.DATA:first()) ; 
 
	
	if Line then
	Main = instance:addStream("Main", core.Line, name, "Main", instance.parameters.color1, first );
    Main:setPrecision(math.max(2, instance.source:getPrecision())); 
    Main:addLevel(0);	
	
    Midle = instance:addStream("Midle", core.Line, name, "Midle", instance.parameters.color2, first );
    Midle:setPrecision(math.max(2, instance.source:getPrecision())); 
    Midle:addLevel(0);	


    Fast = instance:addStream("Fast", core.Line, name, "Fast", instance.parameters.color3, first );
    Fast:setPrecision(math.max(2, instance.source:getPrecision())); 
    Fast:addLevel(0);		
	
	
	else
    Main = instance:addStream("Main", core.Bar, name, "Main", instance.parameters.color1, first );
    Main:setPrecision(math.max(2, instance.source:getPrecision())); 
    Main:addLevel(0);	
	
    Midle = instance:addStream("Midle", core.Bar, name, "Midle", instance.parameters.color2, first );
    Midle:setPrecision(math.max(2, instance.source:getPrecision())); 
    Midle:addLevel(0);	


    Fast = instance:addStream("Fast", core.Bar, name, "Fast", instance.parameters.color3, first );
    Fast:setPrecision(math.max(2, instance.source:getPrecision())); 
    Fast:addLevel(0);		
    end
end


function Update(period, mode)

	Indicator1:update(mode); 
	Indicator2:update(mode); 
	Indicator3:update(mode); 
		
	 if period <= first then
	 return;
	 end
	 
    
	Main[period]=Indicator1.DATA[period]-Indicator3.DATA[period];
    Midle[period]=Indicator2.DATA[period]-Indicator3.DATA[period];	
    Fast[period]=Indicator1.DATA[period]-Indicator2.DATA[period];
	    
end