-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71515

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Candle MA");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("replaceSource", "t");
	
	indicator.parameters:addGroup("MACD Calculation");

	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");	
	
	indicator.parameters:addInteger("Period1", "1. MA ", "", 3, 2, 1000);
	indicator.parameters:addInteger("Period2", "2. MA ", "", 5, 2, 1000);
	indicator.parameters:addInteger("Period3", "3. MA ", "", 8, 2, 1000);
	indicator.parameters:addInteger("Period4", "4. MA ", "", 13, 2, 1000); 
	
   
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

local MA={};

 


 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end


   
 

	source = instance.source;
	first=source:first();
	
	
		MA[1]=core.indicators:create(instance.parameters.Method,  source.close, instance.parameters.Period1 );
		MA[2]=core.indicators:create(instance.parameters.Method,  source.close, instance.parameters.Period2 );
		MA[3]=core.indicators:create(instance.parameters.Method,  source.close, instance.parameters.Period3 );
		MA[4]=core.indicators:create(instance.parameters.Method,  source.close, instance.parameters.Period4 );
     
	
	
	for i= 1, 4, 1 do 
    first= math.max(first, MA[i].DATA:first() )
	end
    	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)
	
    for i= 1, 4, 1 do
	MA[i]:update(mode);
    end
	
	if period < first then
	return
	end

	
    for i= 1, 4, 1 do
		if i== 1 then 
		high[period]=MA[i].DATA[period];
		low[period]=MA[i].DATA[period];
		end
		
		high[period]=math.max(MA[i].DATA[period],high[period]);
		low[period]=math.min(MA[i].DATA[period],low[period]);
    end

    for i= 4, 1, -1 do
		if MA[i].DATA[period]~= high[period] and  MA[i].DATA[period]~= low[period] then
		close[period]= MA[i].DATA[period];
		break;
		end
    end		
	
	for i= 1, 4, 1 do
		if MA[i].DATA[period]~= high[period] and  MA[i].DATA[period]~= low[period] then
		open[period]= MA[i].DATA[period];
		break;
		end	
    end	
	
 end


