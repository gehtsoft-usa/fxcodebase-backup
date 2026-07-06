-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72371

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

function Init()
    indicator:name("Sigma_Bands");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator); 

	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 1, 1, 2000);
    indicator.parameters:addInteger("BarsCount", "Bars Count", "", 200, 1, 2000);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "SigmaBands Line Color", "", core.rgb(128, 128, 128));
    indicator.parameters:addColor("color2", "Average Line Color", "", core.rgb(0, 0, 255));	
	
    indicator.parameters:addColor("color3", "1. MeanDeviation Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color4", "2. MeanDeviation e Line Color", "", core.rgb(255, 0, 0));	
    indicator.parameters:addColor("color5", "3. MeanDeviation  Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color6", "4. MeanDeviation  Line Color", "", core.rgb(255, 0, 0));		
	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method, Period,BarsCount; 
local first;
local source = nil;
 

-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    Method= instance.parameters.Method;
    Period= instance.parameters.Period; 
	BarsCount= instance.parameters.BarsCount;
	
	local Parameters= Method ..  ", " .. Period..  ", " .. BarsCount;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
 
  
    Indicator1 = core.indicators:create(Method, source, Period); 
    Indicator2 = core.indicators:create("MVA", Indicator1.DATA, BarsCount);   
    first=Indicator2.DATA:first() ;
 
 
	SigmaBands = instance:addStream("SigmaBands" , core.Line, " Sigma Bands"," Sigma Bands",instance.parameters.color1, first);
	SigmaBands:setWidth(instance.parameters.width);
    SigmaBands:setStyle(instance.parameters.style);
    SigmaBands:setPrecision(math.max(2, source:getPrecision()));
	
	AverageMA = instance:addStream("Average" , core.Line, " Average"," Average",instance.parameters.color2, first);
	AverageMA:setWidth(instance.parameters.width);
    AverageMA:setStyle(instance.parameters.style);
    AverageMA:setPrecision(math.max(2, source:getPrecision()));	
	
	
	MeanDeviation1 = instance:addStream("MeanDeviation1" , core.Line, " Mean deviation +68%"," Mean deviation +68%",instance.parameters.color3, first);
	MeanDeviation1:setWidth(instance.parameters.width);
    MeanDeviation1:setStyle(instance.parameters.style);
    MeanDeviation1:setPrecision(math.max(2, source:getPrecision()));	 
	
	MeanDeviation2 = instance:addStream("MeanDeviation2" , core.Line, " Mean deviation -68%"," Mean deviation -68%",instance.parameters.color4, first);
	MeanDeviation2:setWidth(instance.parameters.width);
    MeanDeviation2:setStyle(instance.parameters.style);
    MeanDeviation2:setPrecision(math.max(2, source:getPrecision()));	
	
	
	MeanDeviation3 = instance:addStream("MeanDeviation3" , core.Line, " Mean deviation +95.4%"," Mean deviation +95.4%",instance.parameters.color5, first);
	MeanDeviation3:setWidth(instance.parameters.width);
    MeanDeviation3:setStyle(instance.parameters.style);
    MeanDeviation3:setPrecision(math.max(2, source:getPrecision()));	
	
	
	MeanDeviation4 = instance:addStream("MeanDeviation4" , core.Line, " Mean deviation -95.4%"," Mean deviation -95.4%",instance.parameters.color6, first);
	MeanDeviation4:setWidth(instance.parameters.width);
    MeanDeviation4:setStyle(instance.parameters.style);
    MeanDeviation4:setPrecision(math.max(2, source:getPrecision()));	
	
 
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    Indicator1:update(mode);
    Indicator2:update(mode);


     if period <= first   then
	return;
	end
	
     SigmaBands[period]=Indicator1.DATA[period];
	 AverageMA[period]=Indicator2.DATA[period];	
	 
	 
    if period <= first +BarsCount then
	return;
	end
	
	local SumPow=0;	
	for i= 0, BarsCount, 1 do
	SumPow  = SumPow + math.pow(SigmaBands[period-i]-AverageMA[period],2)
	end
		
 
	local  Dispersion=SumPow/ BarsCount ;	

    MeanDeviation1[period]=AverageMA[period]+math.sqrt(Dispersion);
    MeanDeviation2[period]= AverageMA[period]-math.sqrt(Dispersion);
    MeanDeviation3[period] = AverageMA[period]+2*math.sqrt(Dispersion);
    MeanDeviation4[period]= AverageMA[period]-2*math.sqrt(Dispersion);	
end

