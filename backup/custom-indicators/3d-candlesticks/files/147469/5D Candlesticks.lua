-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67283

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("3D Candlesticks");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

 
	indicator.parameters:addGroup("Selector");
    indicator.parameters:addBoolean("CCI", "CCI", "", true);
    indicator.parameters:addBoolean("RSI", "RSI", "", true);
    indicator.parameters:addBoolean("Stochastic", "Stochastic", "", true);
	indicator.parameters:addBoolean("DI", "DI", "", true);
    indicator.parameters:addBoolean("CYCLE", "CYCLE", "", true);		 

 
 
	indicator.parameters:addGroup("CCI Calculation");
	indicator.parameters:addInteger("Period1", "Period", "", 14, 2, 1000);	
	
	indicator.parameters:addGroup("RSI Calculation");
	indicator.parameters:addInteger("Period2", "Period", "", 14, 2, 1000);		
	
	indicator.parameters:addGroup("DMI Calculation");
	indicator.parameters:addInteger("Period3", "Period", "", 14, 2, 1000);		

	indicator.parameters:addGroup("Stochastic Calculation");
    indicator.parameters:addInteger("K", "Number of periods for %K", "", 14, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "", 3, 2, 1000);
    indicator.parameters:addInteger("D", "The number of periods for %D.", "", 25, 2, 1000);

    indicator.parameters:addString("KS", "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("KS", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("KS", "EMA","", "EMA");
    indicator.parameters:addStringAlternative("KS", "FS","", "FS");
    
    indicator.parameters:addString("DS", "Smoothing type for %D", "", "MVA");
    indicator.parameters:addStringAlternative("DS", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("DS", "EMA", "", "EMA");
	
	
   	indicator.parameters:addGroup("Cycle Indicator Calculation");
   	indicator.parameters:addGroup("Smoothing Calculation");
    indicator.parameters:addInteger("Period", "MA Period", "", 9, 1, 2000);	
    indicator.parameters:addDouble("Weight1", "1. Stochastic Weight ", "", 4.1 );	
    indicator.parameters:addDouble("Weight2", "2. Stochastic Weight ", "", 2.5 );	
    indicator.parameters:addDouble("Weight3", "3. Stochastic Weight ", "", 1 );	
    indicator.parameters:addDouble("Weight4", "4. Stochastic Weight ", "", 4 );		
	
 	indicator.parameters:addGroup("1. Stochastic Calculation");	
    indicator.parameters:addInteger("Period11", "Fast MA", "", 5, 1, 2000);
    indicator.parameters:addInteger("Period12", "Slow MA", "", 3, 1, 2000);
	
	
    indicator.parameters:addString("MVAT_K1", "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K1", "FS", "", "FS");
 
	
	
 	indicator.parameters:addGroup("2. Stochastic Calculation");	
    indicator.parameters:addInteger("Period21", "Fast MA", "", 14, 1, 2000);
    indicator.parameters:addInteger("Period22", "Slow MA", "", 3, 1, 2000);	
	
    indicator.parameters:addString("MVAT_K2", "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K2", "FS", "", "FS");	
	
 	indicator.parameters:addGroup("3. Stochastic Calculation");	
    indicator.parameters:addInteger("Period31", "Fast MA", "", 45, 1, 2000);
    indicator.parameters:addInteger("Period32", "Slow MA", "", 14, 1, 2000);
    indicator.parameters:addString("MVAT_K3", "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K3", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K3", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K3", "FS", "", "FS");	
	

 	indicator.parameters:addGroup("4. Stochastic Calculation");	
    indicator.parameters:addInteger("Period41", "Fast MA", "", 75, 1, 2000);
    indicator.parameters:addInteger("Period42", "Slow MA", "", 20, 1, 2000);	
    indicator.parameters:addString("MVAT_K4", "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K4", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K4", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K4", "FS", "", "FS");	

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

 
local first;
local source = nil;

 

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil; 

 
	
local Indicator;


 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	K= instance.parameters.K;
	SD= instance.parameters.SD;
	D= instance.parameters.D;
	KS= instance.parameters.KS;
	DS= instance.parameters.DS;
	Period1= instance.parameters.Period1;
	Period2= instance.parameters.Period2;
	Period3= instance.parameters.Period3;	
	
   CCI= instance.parameters.CCI;
   RSI= instance.parameters.RSI;
   Stochastic= instance.parameters.Stochastic;
   DI= instance.parameters.DI;
   CYCLE= instance.parameters.CYCLE;
	 

	source = instance.source;
	
    assert(core.indicators:findIndicator("CYCLE INDICATOR") ~= nil, "Please, download and install CYCLE INDICATOR.LUA indicator");	
	
	
	Indicator1= core.indicators:create("CCI", source,  Period1); 
	Indicator2= core.indicators:create("RSI", source.close,  Period2);	
	Indicator3= core.indicators:create("STOCHASTIC", source,K,SD,D,KS,DS );
	Indicator4= core.indicators:create("DMI", source ,  Period3);
	Indicator5= core.indicators:create("CYCLE INDICATOR", source , 
	   instance.parameters.Period,instance.parameters.Weight1,instance.parameters.Weight2,instance.parameters.Weight3,instance.parameters.Weight4,
	   instance.parameters.Period11, instance.parameters.Period12, instance.parameters.MVAT_K1,
	   instance.parameters.Period21, instance.parameters.Period22, instance.parameters.MVAT_K2,
	   instance.parameters.Period31, instance.parameters.Period32, instance.parameters.MVAT_K3,
	   instance.parameters.Period41, instance.parameters.Period42, instance.parameters.MVAT_K4
	);	
    first= math.max(Indicator1.DATA:first(),Indicator2.DATA:first(),Indicator3.D:first(),Indicator4.DATA:first(),Indicator5.DATA:first());
	
	
	

    	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)
	
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
	 Indicator1:update(mode);
	 Indicator2:update(mode);
	 Indicator3:update(mode);
	 Indicator4:update(mode);	 
	 Indicator5:update(mode);		 
	
			if period <= first then
			open:setColor(period, core.rgb(128, 128, 128));	
			return;
			end
	
 
	R1=0; 
	R2=0; 
	R3=0; 
	R4=0; 
	R5=0; 
	G1=0; 
	G2=0; 
	G3=0; 
	G4=0; 
	G5=0; 	
    count = 0;

	local R=0;
	local G=0;
	

	if  CCI then
	R1 = (200-Indicator1.DATA[period])
    G1 =(200+Indicator1.DATA[period])  
    count=count+1;
	end
	
	if RSI then
	R2 = 50+(200-(Indicator2.DATA[period]-50)*12)
    G2 =50+(200+(Indicator2.DATA[period]-50)*12)
    count=count+1;	
	end
	if Stochastic then
	R3 =50+(200-(Indicator3.DATA[period]-50)*6)
    G3 =50+(200+(Indicator3.DATA[period]-50)*6)
    count=count+1;	
    end
	if DI then	
	 R4 = 50+(200-(Indicator4.DIP[period]-Indicator4.DIM[period] ) *10)
     G4 =50+(200+(Indicator4.DIP[period]-Indicator4.DIM[period] )*10)
    count=count+1;	 
	end
 
    if CYCLE then
	R5=0;
	G5=0;
	
	R5 = (200-Indicator5.DATA[period]*10)
	G5 = (200+Indicator5.DATA[period]*10)	
    count=count+1;	
	end
 
	 if count ~= 0 then 
	 R = (R1 + R2 + R3 + R4 + R5)/count
	 G = (G1 + G2 + G3  + G4 + G5)/count 
	end 
		 
	open:setColor(period,core.rgb(R, G, 0));	   
    
	
 
		
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