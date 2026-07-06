-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72030

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
    indicator:name("The Classic Turtle Trader");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
 
 

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("TradePeriod", "Donchian channel period for trading signals", "", 20, 1, 2000);
    indicator.parameters:addInteger("StopPeriod", "Donchian channel period for exit signals", "", 10, 1, 2000);

    indicator.parameters:addInteger("ATRPeriod", "ATRPeriod to set the stop-loss", "", 20, 1, 2000);
    indicator.parameters:addDouble("ATRStopNumber", "N.Factor to calculate the stop-loss	", "", 2, 0, 2000);
	
	
	indicator.parameters:addBoolean("StrictEntry", "Apply strict entry parameters like the Turtles did", "", false);
	indicator.parameters:addBoolean("StrictExit", "Apply strict exit parameters like the Turtles did", "", false);
	indicator.parameters:addBoolean("StrictStop", "Apply strict stop-loss like the turtled did", "", false);
	indicator.parameters:addBoolean("Greedy", " Do not exit a trade unless it is in profit or the SL is hit", "", false);
	indicator.parameters:addBoolean("EvaluateStoploss", "Check if we have been stopped out and show future signals", "", true);	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
    indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);	

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local  IN_THE_MARKET = 0;
local  OUT_OF_MARKET = 1;
	
local first;
local source = nil;
local Period1, StopPeriod,ATRPeriod,ATRStopNumber; 
local Indicator;
local StrictEntry, StrictExit, StrictStop, Greedy, EvaluateStoploss;  	
-- Routine
 function Prepare(nameOnly)   
 
    
	TradePeriod=instance.parameters.TradePeriod;
	StopPeriod=instance.parameters.StopPeriod;
	ATRPeriod=instance.parameters.ATRPeriod;
	ATRStopNumber=instance.parameters.ATRStopNumber;
	
	StrictEntry=instance.parameters.StrictEntry;
	StrictExit=instance.parameters.StrictExit;
	StrictStop=instance.parameters.StrictStop;
	Greedy=instance.parameters.Greedy;
	EvaluateStoploss=instance.parameters.EvaluateStoploss;
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  TradePeriod.. "," ..  StopPeriod.. "," ..  ATRPeriod.. "," ..  ATRStopNumber  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	ATR= core.indicators:create("ATR", source, ATRPeriod);
	first=ATR.DATA:first() ; 
	
	
	LongInfo = instance:addInternalStream(0, 0);
	ShortInfo = instance:addInternalStream(0, 0);
	TrendDirection = instance:addInternalStream(0, 0);	
	long_stop= instance:addInternalStream(0, 0);	
	long_price= instance:addInternalStream(0, 0);	
	short_stop= instance:addInternalStream(0, 0);	
	short_price= instance:addInternalStream(0, 0);	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top , instance.parameters.clrDN, 0);
 
 
 	closeup = instance:createTextOutput ("CloseUp", "CloseUp", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top, instance.parameters.clrDN, 0);
    closedown = instance:createTextOutput ("CloseDown", "CloseDown", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom , instance.parameters.clrUP, 0);
end


function Update(period, mode)


    up:setNoData(period);
    down:setNoData(period);	
	
	ATR:update(mode); 

	 if period <= first then
	 return;
	 end
	 
 
    LongInfo[period] = LongInfo[period-1];
    ShortInfo[period] = ShortInfo[period-1];
    TrendDirection[period] = TrendDirection[period-1];	 

    long_stop[period] = long_stop[period-1];
    long_price[period] = long_price[period-1];
    short_stop[period] = short_stop[period-1];
    short_price[period] = short_price[period-1];	
	
	local rlow, rhigh = mathex.minmax(source, period-TradePeriod+1-1, period-1 );
	local slow, shigh = mathex.minmax(source, period-StopPeriod+1-1, period-1 );
	
	
	local CLOSE = source.close[period];
	local HIGH = source.high[period];
	local LOW  = source.low[period];
	
	
	
      
    local  ATRv= ATR.DATA[period] * ATRStopNumber;
    local  ATRup = CLOSE + ATRv;
    local  ATRlow = CLOSE - ATRv;	
		 
	 

 
         if(((CLOSE < slow ) and (CLOSE > long_price[period] or not Greedy )) or 
            (LOW < slow and StrictExit and (LOW > long_price[period] or not Greedy )) and 
            LongInfo[i] == IN_THE_MARKET) then
      
            LongInfo[period] = OUT_OF_MARKET;
            closedown:set(period, source.low[period], "\253", source.low[period]);	 
      
		 
		 end
         
        
         if(((CLOSE > shigh  ) and (CLOSE < short_price[period] or not Greedy )) or 
            (HIGH > shigh and StrictExit  and (HIGH < short_price[period] or not Greedy )) and  
            ShortInfo[period] == IN_THE_MARKET) then
        
            ShortInfo[period] = OUT_OF_MARKET;
			closeup:set(period, source.high[period], "\253", source.high[period]);	
         end
 

         if(((CLOSE < long_stop[period]  ) or (LOW < long_stop[period] and StrictStop  )) and LongInfo[period] == IN_THE_MARKET and EvaluateStoploss) then
   
            LongInfo[period] = OUT_OF_MARKET;
			closeup:set(period, source.high[period], "\253", source.high[period]);	 
        end
		
         if(((CLOSE > short_stop[period] ) or (HIGH > short_stop[period] and StrictStop )) and  ShortInfo[period] == IN_THE_MARKET and EvaluateStoploss) then
 
            ShortInfo[period] = OUT_OF_MARKET;
               closedown:set(period, source.low[period], "\253", source.low[period]);	 
        
         end	 
	 
 
         if(((CLOSE > rhigh   ) or (HIGH > rhigh and StrictEntry  )) and  LongInfo[period] == OUT_OF_MARKET) then
 
            TrendDirection[period] = OP_BUY;
            LongInfo[period] = IN_THE_MARKET;
			up:set(period, source.low[period], "\254", source.low[period]);	 
            long_stop[period] = ATRlow;
            long_price[period] = CLOSE;
         end
         
 
         if(((CLOSE < rlow   ) or (LOW < rlow and StrictEntry )) and ShortInfo[period] == OUT_OF_MARKET) then
    
            TrendDirection[period] = OP_SELL;
            ShortInfo[period] = IN_THE_MARKET;
            down:set(period, source.high[period], "\254", source.high[period]);	 
            short_stop[period] = ATRup;
            short_price[period] = CLOSE;
         end
    
   
   

	    
 
	
end 