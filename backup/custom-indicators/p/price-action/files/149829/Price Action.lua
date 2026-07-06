-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73440

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
    indicator:name("Price Action");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period1", "Fast MA", "", 5, 1, 2000);
    indicator.parameters:addInteger("Period2", "Slow MA", "", 15, 1, 2000);
	
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
local Period1, Period2 ; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2; 
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=source:first() ;  
 
	VHCORPVHMECHVHBMECH= instance:addInternalStream(0, 0); 
	VBCORPVBMECHVBHMECH= instance:addInternalStream(0, 0); 	
	
 
	
    LDF = instance:addStream("Force", core.Line, name, "Force", core.COLOR_LABEL , first );
    LDF:setPrecision(math.max(2, instance.source:getPrecision()));
    LDF:setWidth(instance.parameters.width);
    LDF:setStyle(instance.parameters.style);
    LDF:addLevel(0);

    VHCORP = instance:addStream("HCorp", core.Bar, name, "HCorp", core.rgb(36,147,219) , first );
    VHCORP:setPrecision(math.max(2, instance.source:getPrecision())); 
    VHCORP:addLevel(0);

    VHMECH = instance:addStream("HMeche", core.Bar, name, "HMeche", core.rgb(36,147,219) , first );
    VHMECH:setPrecision(math.max(2, instance.source:getPrecision())); 
    VHMECH:addLevel(0);

    VHBMECH = instance:addStream("HBMeche", core.Bar, name, "HBMeche", core.rgb(101,101,101) , first );
    VHBMECH:setPrecision(math.max(2, instance.source:getPrecision())); 
    VHBMECH:addLevel(0);

    VBCORP = instance:addStream("BCorp", core.Bar, name, "BCorp",core.rgb(101,101,101) , first );
    VBCORP:setPrecision(math.max(2, instance.source:getPrecision())); 
    VBCORP:addLevel(0);

    VBMECH = instance:addStream("BMeche", core.Bar, name, "BMeche", core.rgb(101,101,101) , first );
    VBMECH:setPrecision(math.max(2, instance.source:getPrecision())); 
    VBMECH:addLevel(0);

    VBHMECH = instance:addStream("BHMeche", core.Bar, name, "BHMeche", core.rgb(36,147,219) , first );
    VBHMECH:setPrecision(math.max(2, instance.source:getPrecision())); 
    VBHMECH:addLevel(0);	
 	

    VNHMECH = instance:addStream("BMeche", core.Bar, name, "HMeche Doji", core.rgb(36,147,219) , first );
    VNHMECH:setPrecision(math.max(2, instance.source:getPrecision())); 
    VNHMECH:addLevel(0);

    VNBMECH = instance:addStream("BHMeche", core.Bar, name, "BMeche Doji", core.rgb(101,101,101) , first );
    VNBMECH:setPrecision(math.max(2, instance.source:getPrecision())); 
    VNBMECH:addLevel(0);
  
    Open = instance:addStream("Open", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
    Close = instance:addStream("Close", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
    High = instance:addStream("High", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
    Low = instance:addStream("Low", core.Line, name .. "", "", core.rgb(0, 0, 0), first);	
    instance:createCandleGroup("OVERLAY", "OVERLAY", Open, High, Low, Close); 
end


function Update(period, mode)

	--Indicator:update(mode); 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
    local UP, DW;
	if (source.close[period] > source.open[period]) then
	UP = 1 
	DW = 0	
	else
	UP = 0
	DW = 1
	end

	if (source.close[period] == source.open[period]) then
	NT = 1 
	else
	NT = 0 
	end 
	
	
	if (UP == 1)  then
	VHCORP[period] = 0 + (source.close[period] - source.open[period])
	VHMECH[period] = VHCORP[period] + (source.open[period] - source.low[period])
	VHBMECH[period] = 0 - (source.high[period] - source.close[period])

	elseif (UP == 0) then
	VHCORP[period] = 0
	VHMECH[period] = 0
	VHBMECH[period] = 0 
	end 
	
	
	
	VHCORPVHMECHVHBMECH[period] = VHCORP[period]+VHMECH[period]+VHBMECH[period];
	
	if (DW == 1) then
	VBCORP[period] = 0 - (source.open[period] - source.close[period])
	VBMECH[period] = VBCORP[period] - (source.high[period] - source.open[period])
	VBHMECH[period] = 0 + (source.close[period] - source.low[period])

	elseif (DW == 0) then
	VBCORP[period] = 0
	VBMECH[period] = 0
	VBHMECH[period] = 0
	end
	
    VBCORPVBMECHVBHMECH[period]=VBCORP[period]+VBMECH[period]+VBHMECH[period];
	

	
	
	if period <= first + math.max(Period1, Period2)
	or  not source:hasData(period) 
	then
	return;
	end
	
	local STD1=mathex.stdev(source.close, period-Period1+1, period)
	local STD2=mathex.stdev(source.close, period-Period2+1, period)
	
	
	VMHCORP1 = mathex.sum(VHCORP, period-Period1+1, period);
	VMHCORP2 = mathex.sum(VHCORP, period-Period2+1, period); 
	VMHCORP = (VMHCORP1 + VMHCORP2) / 2	
	
	VMHMECH1 =  mathex.sum(VHCORPVHMECHVHBMECH, period-Period1+1, period); 
	VMHMECH2 = mathex.sum(VHCORPVHMECHVHBMECH, period-Period2+1, period); 
	VMHMECH = (VMHMECH1 + VMHMECH2) / 2	
	
    VMH = (VMHCORP + VMHMECH) / 2 
	 
	VMBMECH1 =  mathex.sum(VBCORPVBMECHVBHMECH, period-Period1+1, period); 
	VMBMECH2 = mathex.sum(VBCORPVBMECHVBHMECH, period-Period2+1, period); 
    VMBMECH = (VMBMECH1 + VMBMECH2) / 2

	
	VMBCORP1 =  mathex.sum(VBCORP, period-Period1+1, period); 
	VMBCORP2 =  mathex.sum(VBCORP, period-Period2+1, period);  
	VMBCORP = (VMBCORP1 + VMBCORP2) / 2
	

	VMB1 = (VMBCORP + VMBMECH) / 2
    --VMB = (VMB1 - VMB1) - VMB1
  	VMB = (VMB1 - VMB1) - VMB1
	
 
	if (NT == 1) then
	VNHMECH[period] = 0 + (source.open[period] - source.low[period])
	VNBMECH[period] = 0 - (source.high[period] - source.open[period]) 
	elseif (NT == 0) then
	VNHMECH[period] = 0
	VNBMECH[period] = 0
	end 
 
	UP1 = VMH + STD1 * 1
	UP2 = VMH + STD2 * 1
	UP = (UP1 + UP2) / 2

	DW1 = VMB + STD1 * 1
	DW2 = VMB + STD2 * 1
	DW = (DW1 + DW2) / 2 
	
	LDF[period] = (UP + DW) / 2

 
	if (LDF[period] > LDF[period-1]) then
	R = 13
	G = 127
	B = 13

	elseif (LDF[period] < LDF[period-1]) then
	R = 127
	G = 13
	B = 13	
	end
	
    LDF:setColor(period, core.rgb (R,G,B))  	
	
    if VMH > VMB then
        Open[period] = VMB;
        Close[period] =VMH;
        High[period] = VMH ;
        Low[period] =  VMB;	
    else
        Open[period] = VMH;
        Close[period] =VMB;
        High[period] = VMB ;
        Low[period] =  VMH;		
	
	end
	
	
	if (VMH > VMB) and (LDF[period] < LDF[period-1]) then
	Open:setColor(period, core.rgb (36,147,219))  
	elseif (VMH < VMB) and (LDF[period] < LDF[period-1]) then
	Open:setColor(period, core.rgb (101,101,101))  
	elseif (VMH > VMB) and (LDF[period] > LDF[period-1]) and ((source.close[period]-source.open[period]) > (source.high[period]-source.close[period])) then
	Open:setColor(period, core.rgb (36,147,219))  
	elseif (VMH < VMB) and (LDF[period] > LDF[period-1]) and ((source.open[period]-source.close[period]) > (source.close[period]-source.low[period])) then
	Open:setColor(period, core.rgb (101,101,101))  
	elseif (VMH > VMB) and (LDF[period] > LDF[period-1]) and (source.close[period] < source.open[period]) then
	Open:setColor(period, core.rgb (36,147,219) )  
	elseif (VMH < VMB) and (LDF[period] > LDF[period-1]) and (source.close[period] > source.open[period]) then
	Open:setColor(period, core.rgb (101,101,101))  
	elseif (VMH > VMB) and (LDF[period] > LDF[period-1]) and ((source.high[period]-source.close[period] > source.close[period]-source.open[period])) then
	Open:setColor(period, core.rgb (36,147,219))  
	elseif (VMH < VMB) and (LDF[period] > LDF[period-1]) and ((source.close[period]-source.low[period] > source.open[period]-source.close[period])) then
	Open:setColor(period, core.rgb (101,101,101))  
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