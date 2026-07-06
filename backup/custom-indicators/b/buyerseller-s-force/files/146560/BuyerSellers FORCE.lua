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
    indicator:name("BuyerSeller’s FORCE");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Periods", "Periods", "", 20, 1, 2000);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addBoolean("AbsFlag", "Use ABS", "", false);
	
 
	
	 indicator.parameters:addGroup("BuyerForce Line Style");	
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);	
	 indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0)); 


	indicator.parameters:addGroup("SellerForce Line Style");	
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);	
	indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0)); 
	 
	 
	indicator.parameters:addGroup("Difference Line Style");	
    indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);	
	indicator.parameters:addColor("color3", "Line Color", "", core.rgb(0, 0, 255));  
	
	 indicator.parameters:addGroup("Average BuyerForce Line Style");	
    indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "",  core.LINE_DASH );
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);	
	 indicator.parameters:addColor("color4", "Line Color", "", core.rgb(0, 255, 0)); 


	indicator.parameters:addGroup("Average SellerForce Line Style");	
    indicator.parameters:addInteger("width5", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style5", "Line style", "",  core.LINE_DASH );
    indicator.parameters:setFlag("style5", core.FLAG_LINE_STYLE);	
	indicator.parameters:addColor("color5", "Line Color", "", core.rgb(255, 0, 0)); 
	 
	 
	indicator.parameters:addGroup("Average Difference Line Style");	
    indicator.parameters:addInteger("width6", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style6", "Line style", "",  core.LINE_DASH );
    indicator.parameters:setFlag("style6", core.FLAG_LINE_STYLE);	
	indicator.parameters:addColor("color6", "Line Color", "", core.rgb(0, 0, 255));  	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Periods, AbsFlag, Method; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Periods=instance.parameters.Periods;
	AbsFlag=instance.parameters.AbsFlag;
	Method=instance.parameters.Method;	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Periods.. "," ..  Method  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	

	first=source:first() ;  
	
    BuyerForce = instance:addStream("BuyerForce", core.Line, name, "BuyerForce", instance.parameters.color1, first );
    BuyerForce:setPrecision(math.max(2, instance.source:getPrecision()));
    BuyerForce:setWidth(instance.parameters.width1);
    BuyerForce:setStyle(instance.parameters.style1);
    BuyerForce:addLevel(0);	

    SellerForce = instance:addStream("SellerForce", core.Line, name, "SellerForce", instance.parameters.color2, first );
    SellerForce:setPrecision(math.max(2, instance.source:getPrecision()));
    SellerForce:setWidth(instance.parameters.width2);
    SellerForce:setStyle(instance.parameters.style2);
    SellerForce:addLevel(0);	


    Difference = instance:addStream("Difference", core.Line, name, "Difference", instance.parameters.color3, first );
    Difference:setPrecision(math.max(2, instance.source:getPrecision()));
    Difference:setWidth(instance.parameters.width2);
    Difference:setStyle(instance.parameters.style2);
    Difference:addLevel(0);		 
	
	Indicator1= core.indicators:create(Method, BuyerForce, Periods );
	Indicator2= core.indicators:create(Method, SellerForce, Periods );	
	Indicator3= core.indicators:create(Method, Difference, Periods );		
	

    AverageBuyerForce = instance:addStream("AverageBuyerForce", core.Line, name, "AverageBuyerForce", instance.parameters.color4, first + Periods );
    AverageBuyerForce:setPrecision(math.max(2, instance.source:getPrecision()));
    AverageBuyerForce:setWidth(instance.parameters.width4);
    AverageBuyerForce:setStyle(instance.parameters.style4);
    AverageBuyerForce:addLevel(0);	

    AverageSellerForce = instance:addStream("AverageSellerForce", core.Line, name, "AverageSellerForce", instance.parameters.color5, first + Periods );
    AverageSellerForce:setPrecision(math.max(2, instance.source:getPrecision()));
    AverageSellerForce:setWidth(instance.parameters.width5);
    AverageSellerForce:setStyle(instance.parameters.style5);
    AverageSellerForce:addLevel(0);	


    AverageDifference = instance:addStream("AverageDifference", core.Line, name, "AverageDifference", instance.parameters.color6, first + Periods );
    AverageDifference:setPrecision(math.max(2, instance.source:getPrecision()));
    AverageDifference:setWidth(instance.parameters.width6);
    AverageDifference:setStyle(instance.parameters.style6);
    AverageDifference:addLevel(0);		  
end


function Update(period, mode)


	
	BuyerForce[period]    = source.low[period] - source.close[period]
	SellerForce[period]   = source.high[period] - source.close[period]
	Difference[period]=BuyerForce[period]-SellerForce[period]; 
	
	if AbsFlag then
	   BuyerForce[period] = math.abs(BuyerForce[period])
	end	
	
	
 	Indicator1:update(mode); 
	Indicator2:update(mode); 	
	Indicator3:update(mode); 	

	 if period <= first + Periods then
	 return;
	 end
	  
	AverageBuyerForce[period] = Indicator1.DATA[period]
	AverageSellerForce[period] = Indicator2.DATA[period]
	AverageDifference[period] = Indicator3.DATA[period]
end

 