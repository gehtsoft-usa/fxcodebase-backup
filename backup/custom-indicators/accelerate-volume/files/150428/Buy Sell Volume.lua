-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73604

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
    indicator:name("Buy Sell Volume");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("PeriodFast", "Fast Period", "", 4, 1, 2000);
    indicator.parameters:addInteger("PeriodSlow", "Slow Period", "", 10, 1, 2000);
	
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
	 indicator.parameters:addColor("color1", "Buy Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Sell Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color3", "Control Color", "", core.rgb(0, 0, 255));

    indicator.parameters:addInteger("width", "Line width", "", 3, 1, 5);
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
local PeriodFast,PeriodSlow,Method; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	PeriodFast=instance.parameters.PeriodFast;
	PeriodSlow=instance.parameters.PeriodSlow;
	Method=instance.parameters.Method;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  PeriodFast.. "," ..  PeriodSlow .. "," ..  Method .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	

	first=source:first() ; 
	
	
 
	VolBuyRed = instance:addInternalStream(0, 0);
	VolSellGreen = instance:addInternalStream(0, 0); 
	
 
	
    VolBuyGreen = instance:addStream("VolBuyGreen", core.Bar, name, "VolBuyGreen", instance.parameters.color1, first );
    VolBuyGreen:setPrecision(math.max(2, instance.source:getPrecision())); 
    VolBuyGreen:addLevel(0);	

    VolSellRed = instance:addStream("VolSellRed", core.Bar, name, "VolSellRed", instance.parameters.color2, first );
    VolSellRed:setPrecision(math.max(2, instance.source:getPrecision())); 


    Control = instance:addStream("Control", core.Line, name, "Control", instance.parameters.color3, first );
    Control:setPrecision(math.max(2, instance.source:getPrecision()));
    Control:setWidth(instance.parameters.width);
    Control:setStyle(instance.parameters.style);
end


function Update(period, mode)



	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
 
	local a = source.high[period]-source.low[period] 
	local b = source.open[period]-source.low[period]
	local c = source.high[period]-source.close[period]
	local d = source.high[period]-source.open[period]
	local e = source.close[period]-source.low[period]
	   
    local volUniBuy = source.volume[period]/(a+b+c)   --Green Candle    
    local volUniSell = source.volume[period]/(a+d+e)  --Red Candle
	
         
	VolBuyGreen[period]=a*volUniBuy                   --Buy volume on green candle        
	VolBuyRed[period]=(d+e)*volUniSell                --Buy volume on red candle
	VolSellGreen[period]=-(b+c)*volUniBuy              --Sell Volume on green candle
	VolSellRed[period]=-a*volUniSell                   --Sell Volume on red candle

	if source.close[period]>=source.open[period] then
	VolBuyGreen[period] = VolBuyRed[period]
	VolSellGreen[period] = 0
	else
	VolSellRed[period] = VolSellGreen[period]
	VolBuyRed[period] = 0
	end 
	
 
 	Control[period]=VolBuyRed[period]+VolSellRed[period];
	
	
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