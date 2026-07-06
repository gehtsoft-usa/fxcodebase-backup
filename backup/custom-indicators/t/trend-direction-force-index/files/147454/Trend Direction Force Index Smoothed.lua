-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=70732

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

function Init()
    indicator:name("Trend Direction Force Index Smoothed");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("trendPeriod", "Trend Period", "", 20, 1, 2000); 
    indicator.parameters:addInteger("SmoothLength", "Smooth Period", "", 5, 1, 2000); 	
 
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method", "HPF", "", "HPF");
    indicator.parameters:addStringAlternative("Method", "VAMA", "", "VAMA");
	
	
	
	
	indicator.parameters:addDouble("TriggerUp", "Trigger up level", "", 0.05);	
	indicator.parameters:addDouble("TriggerDown", "Trigger down level", "", -0.05);		
 
	
     indicator.parameters:addBoolean("Line", "Signal Line", "", false); 
     indicator.parameters:addBoolean("ColorChangeOnZeroCross", "Color Change On Zero Cross", "", true); 	 
 
	
	indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 0));	
    indicator.parameters:addColor("color2", "Down Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("color3", "Neutral Line Color", "", core.rgb(0, 0, 255));	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
 
local first;
local source = nil;
 
local Oscillator;  

local alpha

-- Routine
 function Prepare(nameOnly)   
 
 
    trendPeriod= instance.parameters.trendPeriod; 
	Method= instance.parameters.Method;
	Line= instance.parameters.Line;
	ColorChangeOnZeroCross= instance.parameters.ColorChangeOnZeroCross;
	TriggerUp= instance.parameters.TriggerUp;
	TriggerDown= instance.parameters.TriggerDown;
	SmoothLength= instance.parameters.SmoothLength;
	
	alpha = 2.0 /(trendPeriod+1.0); 
		  
	local Parameters=""
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");	
	Averages1 = core.indicators:create("AVERAGES", source, Method,  trendPeriod);
    first=Averages1.DATA:first()+1;
	
	SMMA= instance:addInternalStream(0, 0);
	TDF= instance:addInternalStream(0, 0);
	Raw= instance:addInternalStream(0, 0);	 
	ABSTDF= instance:addInternalStream(0, 0);	

	Averages2 = core.indicators:create("AVERAGES", Raw, Method,  SmoothLength);
	
	
	if not Line then
	TDFI= instance:addStream("TDFI" , core.Line, " TDFI"," Oscillator",instance.parameters.color1, first+trendPeriod*3 +  SmoothLength);
	TDFI:setWidth(instance.parameters.width);
    TDFI:setStyle(instance.parameters.style);
    TDFI:setPrecision(math.max(2, source:getPrecision()));
	Oscillator= instance:addInternalStream(0, 0);
    else
 
 	TDFI= instance:addInternalStream(0, 0);
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color1, first+trendPeriod*3 +  SmoothLength);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	end
	
	
end

-- Indicator calculation routine
function Update(period, mode)
  
  
    Averages1:update(mode); 
	
 
	if period <= first
	then
	return;
	end
	
	
	SMMA[period]= SMMA[period-1]+alpha*(Averages1.DATA[period]-SMMA[period-1] );
 
 
    local  impetmma  = Averages1.DATA[period]  - Averages1.DATA[period-1];
    local impetsmma = SMMA[period] - SMMA[period-1];
	local  divma     = math.abs(Averages1.DATA[period]-SMMA[period])/source:pipSize();
    local  averimpet = (impetmma+impetsmma)/(2)*source:pipSize();
    TDF[period]  = divma*math.pow(averimpet,3);	
	ABSTDF[period]=math.abs(TDF[period]);
 
 
	if period <= first+trendPeriod*3
	then
	return;
	end	
	
	local MaxValue =mathex.max(ABSTDF,period-trendPeriod*3+1,period)
	
	
	if MaxValue>0 then 
    Raw[period]=TDF[period] / MaxValue
	else
	Raw[period]=0;
	end
	

    TDFI[period] = Raw[period];
 
    Averages2:update(mode)
	
	if period <= first+trendPeriod*3 +  SmoothLength
	then
	return;
	end		
	 
	if ColorChangeOnZeroCross then
	
		if TDFI[period] > 0 then
		TDFI:setColor(period, instance.parameters.color1);	
		else
		TDFI:setColor(period, instance.parameters.color2);	
		end	
		
    else
	
		if TDFI[period] > TriggerUp then
		TDFI:setColor(period, instance.parameters.color1);	
		elseif TDFI[period] < TriggerDown then
		TDFI:setColor(period, instance.parameters.color2);	
        else
		TDFI:setColor(period, instance.parameters.color3);			
		end	
    
    end	
	 
	if TDFI[period] > 0 then	
    Oscillator[period ]= 1; 
	Oscillator:setColor(period, instance.parameters.color1);	
	else
	Oscillator[period ]= -1;
	Oscillator:setColor(period, instance.parameters.color2);	
    end	
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

 