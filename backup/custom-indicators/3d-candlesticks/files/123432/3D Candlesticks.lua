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

 

	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period", "", 14, 2, 1000);
	indicator.parameters:addString("Method" , "Selector", "", "CCI");
    indicator.parameters:addStringAlternative("Method" , "CCI", "", "CCI");
    indicator.parameters:addStringAlternative("Method", "RSI", "", "RSI");
    indicator.parameters:addStringAlternative("Method" , "Stochastic", "", "Stochastic");
	--indicator.parameters:addStringAlternative("Method" , "Cycle", "", "Cycle");
	indicator.parameters:addStringAlternative("Method", "DI", "", "DI");	


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

local Method;


local K,SD,D,KS,DS, Period;
	
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
	Period= instance.parameters.Period;
	

 
   
    Method = instance.parameters.Method;
	
 
	 

	source = instance.source;
	
	
	
    if Method== "Stochastic" then
	Indicator= core.indicators:create("STOCHASTIC", source,K,SD,D,KS,DS );
    first= Indicator.D:first();
	elseif Method== "CCI" then
	Indicator= core.indicators:create("CCI", source,  Period);
    first= Indicator.DATA:first();
	elseif Method== "RSI" then
	Indicator= core.indicators:create("RSI", source.close,  Period);
    first= Indicator.DATA:first();
	elseif Method== "DI" then
	Indicator= core.indicators:create("DMI", source ,  Period);
    first= Indicator.DATA:first(); 
	end
	
	
	
	

    	
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
	
			if period <= first then
			open:setColor(period, core.rgb(128, 128, 128));	
			return;
			end
	
 
	
	 Indicator:update(mode);
	

	local R=0;
	local G=0;
	local B=0;
	
	if Method== "CCI" then
	R = (200-Indicator.DATA[period])
    G =(200+Indicator.DATA[period])
	elseif Method== "RSI" then
	R = 50+(200-(Indicator.DATA[period]-50)*12)
    G =50+(200+(Indicator.DATA[period]-50)*12)
	elseif Method== "Stochastic" then
	
	 R =50+(200-(Indicator.DATA[period]-50)*6)
     G =50+(200+(Indicator.DATA[period]-50)*6)
	
    elseif Method== "DI" then	
	 R = 50+(200-(Indicator.DIP[period]-Indicator.DIM[period] ) *10)
     G =50+(200+(Indicator.DIP[period]-Indicator.DIM[period] )*10)
	end
 
		 
	open:setColor(period,core.rgb(R, G, B));	   
    
	
 
		
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