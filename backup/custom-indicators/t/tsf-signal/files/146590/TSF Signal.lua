-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72454

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

----ADD DIFF MA
---added matype  in the name legend

function Init()
    indicator:name("TSF Signal");

    indicator:description("BOTH SLOW AND FAST MA IN ONE ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("1.MA Calculation");
	
	indicator.parameters:addString("Price_slow", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price_slow", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price_slow", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price_slow", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price_slow","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price_slow", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price_slow", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price_slow", "WEIGHTED", "", "weighted");
	
	
    indicator.parameters:addInteger("PERIOD_slow", "Period for slow ma", "Period", 81);
	indicator.parameters:addInteger("lookback_slow", "Lookback for slow ma", "", 5);
	
	indicator.parameters:addInteger("LWMA_slow", "LWMA Weight", "", 3);
	indicator.parameters:addInteger("MA_slow", "MA Weight", "", 2);
	
		
	indicator.parameters:addString("Method_slow", "MA Type", "Method" , "LWMA");
    indicator.parameters:addStringAlternative("Method_slow", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method_slow", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method_slow", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method_slow", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method_slow", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method_slow", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method_slow", "VIDYA", "VIDYA" , "VIDYA");
	
	
	
	indicator.parameters:addGroup("2.MA Calculation");
	
	indicator.parameters:addString("Price_fast", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price_fast", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price_fast", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price_fast", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price_fast","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price_fast", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price_fast", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price_fast", "WEIGHTED", "", "weighted");
	
    indicator.parameters:addInteger("PERIOD_fast", "Period for fast ma", "Period", 13);
	
	indicator.parameters:addInteger("lookback_fast", "Lookback for fast ma", "", 5);
	
	indicator.parameters:addInteger("LWMA_fast", "LWMA Weight", "", 3);
	
	indicator.parameters:addInteger("MA_fast", "MA Weight", "", 2);
	
	
	indicator.parameters:addString("Method_fast", "MA Type", "Method" , "LWMA");
    indicator.parameters:addStringAlternative("Method_fast", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method_fast", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method_fast", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method_fast", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method_fast", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method_fast", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method_fast", "VIDYA", "VIDYA" , "VIDYA");
	

	indicator.parameters:addGroup("FillStyle");
	indicator.parameters:addColor("Up", "Strong Color", "Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Weak Color", "Color", core.rgb(255, 0, 0));
 
	
 
	indicator.parameters:addBoolean("Flip", "Flip on Confirmation", "", false);
	
	
 


    
   
   
end
--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------


-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Price_slow, Price_fast;
local lookback_slow;
local lookbackfast;

local Method_slow,Method_fast,ma_slow, ma_fast;
local PERIOD_slow;
local PERIOD_fast;

local Flip;


local first_slow,first_fast;
local source = nil;
local LWMA_slow, MA_slow;
local LWMA_fast, MA_fast;
-- Streams block
 
local TSF_slow = nil;
local TSF_fast = nil;


local TSF_width;
local TSF_style;


local Transparency;
local Signal,Signal_fast,Signal_slow;
 

--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------

-- Routine
function Prepare(nameOnly)

    lookback_slow = instance.parameters.lookback_slow;
    Method_slow = instance.parameters.Method_slow;	
    PERIOD_slow = instance.parameters.PERIOD_slow;
	LWMA_slow= instance.parameters.LWMA_slow;
	MA_slow= instance.parameters.MA_slow; 


    lookback_fast = instance.parameters.lookback_fast;
    Method_fast = instance.parameters.Method_fast;	
	PERIOD_fast = instance.parameters.PERIOD_fast;
    LWMA_fast= instance.parameters.LWMA_fast;
	MA_fast= instance.parameters.MA_fast;
	
	Flip= instance.parameters.Flip;

	
	Price_slow= instance.parameters.Price_slow;
	Price_fast= instance.parameters.Price_fast; 
	
    source = instance.source;
    first_slow =  source:first() + PERIOD_slow - 1;
    first_fast =  source:first() + PERIOD_fast - 1;
	

	
    TSF_width=instance.parameters.TSF_width;
    TSF_style=instance.parameters.TSF_style;


    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
    
        TSF_slow= instance:addInternalStream(0, 0); 
        TSF_fast= instance:addInternalStream(0, 0);  
		 
    ma_slow = core.indicators:create(Method_slow, source[Price_slow], PERIOD_slow);
    ma_fast = core.indicators:create(Method_fast, source[Price_fast], PERIOD_fast);
	
	
	Signal= instance:addStream("Signal", core.Bar, name, "Signal", instance.parameters.Up, first_fast);
	Signal_fast = instance:addInternalStream(0, 0); 
	Signal_slow = instance:addInternalStream(0, 0); 
    	
	
 

end
--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

   
    if period < first_slow or not source:hasData(period) then
    return;
    end    
    if period < first_fast or not source:hasData(period) then
    return;
    end 

    local matype_slow ;
    ma_slow:update(mode);
    matype_slow= ma_slow.DATA[period];


    local matype_fast ;
    ma_fast:update(mode);
    matype_fast= ma_fast.DATA[period];

    
--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------

 


       TSF_slow[period] =  LWMA_slow *  matype_slow - MA_slow * matype_slow;
       TSF_fast[period] =  LWMA_fast *  matype_fast - MA_fast * matype_fast;

 
--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------



	if TSF_slow[period] > TSF_slow[period-lookback_slow]  then

	TSF_slow:setColor(period, instance.parameters.TSF_Up);
    Signal_slow[period]=1;

	elseif TSF_slow[period] < TSF_slow[period-lookback_slow]   then

  
     Signal_slow[period]=-1;
	TSF_slow:setColor(period, instance.parameters.TSF_Dn);
    
    end
--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------

	if TSF_fast[period] > TSF_fast[period-lookback_fast]  then

	TSF_fast:setColor(period, instance.parameters.TSF_Up);
    Signal_fast[period]=1;

	elseif TSF_fast[period] < TSF_fast[period-lookback_fast]   then

    Signal_fast[period]=-1;
	TSF_fast:setColor(period, instance.parameters.TSF_Dn); 
    end

 
 
    if Flip then
    Signal[period]=Signal[period-1];
	end
	
	
	if Signal_slow[period] ==1 and  Signal_fast[period] ==1 then 
	Signal[period]=1;
    Signal:setColor(period,  instance.parameters.Up);
	elseif Signal_slow[period] ==-1  and  Signal_fast[period] ==-1 then  
	Signal[period]=-1;
    Signal:setColor(period,  instance.parameters.Down);	
    end
	
end

--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------



 

function Next(period)

local Return=0;
local Max=0;
local Min=0;


   for i= period ,source:first(),-1 do
   
	   if Signal[period]~=Signal[i] then
	   Return=i;
	   break;
	   end
   
   end
   
   if Return ~=0 and  period> Return then
   Min,Max=mathex.minmax(source, Return,period);
   end
   
 return Return,Min,Max;
 

end







