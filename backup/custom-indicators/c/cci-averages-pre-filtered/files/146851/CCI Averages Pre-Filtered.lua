-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72545

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
    indicator:name("CCI Averages Pre-Filtered");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("CCI Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 14, 1, 2000);	
    indicator.parameters:addDouble("Coefficient", "Coefficient", "",  0.015, 0, 2000);	
	
	indicator.parameters:addGroup("Price Smoothing"); 
    indicator.parameters:addInteger("Period1", "Period", "", 14, 1, 2000);
 

    indicator.parameters:addString("Method1", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method1", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method1", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method1", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method1", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method1", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method1", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method1", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method1", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method1", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method1", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method1", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method1", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method1", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method1", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method1", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method1", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method1", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "", "VIDYA"); 
	
	indicator.parameters:addGroup("CCI Smoothing"); 
    indicator.parameters:addInteger("Period2", "Period", "", 1, 1, 2000);
 
 
	
    indicator.parameters:addString("Method2", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method2", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method2", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method2", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method2", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method2", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method2", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method2", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method2", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method2", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method2", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method2", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method2", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method2", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method2", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method2", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method2", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method2", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "", "VIDYA") 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method1 , Period1;
local Method2 , Period2; 
local first;
local source = nil;
 
local CCI;

-- Routine
 function Prepare(nameOnly)   
 
 
 
    Period= instance.parameters.Period; 
	Coefficient= instance.parameters.Coefficient;
 
    Period1= instance.parameters.Period1;
    Method1= instance.parameters.Method1; 
	
	Period2= instance.parameters.Period2;
    Method2= instance.parameters.Method2; 
	
	
	local Parameters= Period ..  ", " ..  Coefficient ..  ", " ..Period1 ..  ", " .. Method1 ..  ", " ..Period2 ..  ", " .. Method2 ;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    
  
    MA1 = core.indicators:create("AVERAGES", source , Method1, Period1);   
    first=MA1.DATA:first();
	
    cci = instance:addInternalStream(0, 0);	 
    MA2 = core.indicators:create("AVERAGES", cci , Method2, Period2);  
 
	CCI = instance:addStream("CCI" , core.Line, " CCI"," CCI",instance.parameters.color, MA2.DATA:first());
	CCI:setWidth(instance.parameters.width);
    CCI:setStyle(instance.parameters.style);
    CCI:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    MA1:update(mode);
	
	
    if period < first+Period then
	return;
	end
	
	
 
        local mean = mathex.avg(MA1.DATA, period-Period+1, period);
        local meandev = mathex.meandev(MA1.DATA, period-Period+1, period);
        		
        if (meandev == 0) then
            cci[period] = 0;
        else
            cci[period] = (MA1.DATA[period] - mean) / (meandev *  Coefficient);
        end

    MA2:update(mode);		
 
    if period < MA2.DATA:first() then
	return;
	end	

   CCI[period]=MA2.DATA[period];
end
 