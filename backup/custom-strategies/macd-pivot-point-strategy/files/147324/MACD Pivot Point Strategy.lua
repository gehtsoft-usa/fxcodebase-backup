-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=31&t=72685

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

function Init() --The strategy profile initialization
    strategy:name("MACD Pivot Point Strategy");
    strategy:description("");
	
	
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");
	
	strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
	
	strategy.parameters:addString("TF", "Time frame", "", "m1");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
    
    strategy.parameters:addGroup("Limit $ Stop Selection");
    strategy.parameters:addInteger("LimitLevel", "Limit Method", "Method" , 0);
    strategy.parameters:addIntegerAlternative("LimitLevel", "Regular Limit", "Regular Limit" , 0);
    strategy.parameters:addIntegerAlternative("LimitLevel", "1. Level", "Regular Stop" , 1);
    strategy.parameters:addIntegerAlternative("LimitLevel", "2. Level", "Regular Stop" , 2);
    strategy.parameters:addIntegerAlternative("LimitLevel", "3. Level", "Regular Stop" , 3);    
	strategy.parameters:addIntegerAlternative("LimitLevel", "4. Level", "Regular Stop" , 4);  
	
    strategy.parameters:addInteger("StopLevel", "Stop Method", "Method" , 0);
    strategy.parameters:addIntegerAlternative("StopLevel", "Regular Stop", "Regular Stop" , 0);
    strategy.parameters:addIntegerAlternative("StopLevel", "1. Level", "Regular Stop" , 1);
    strategy.parameters:addIntegerAlternative("StopLevel", "2. Level", "Regular Stop" , 2);
    strategy.parameters:addIntegerAlternative("StopLevel", "3. Level", "Regular Stop" , 3);    
	strategy.parameters:addIntegerAlternative("StopLevel", "4. Level", "Regular Stop" , 4);  	
	
    strategy.parameters:addGroup("MACD Calculation");
	
	strategy.parameters:addString("Method", "Indicator Method", "Method" , "MACD / Zero & MACD Slope");
    strategy.parameters:addStringAlternative("Method", "MACD / Zero & MACD Slope", "MACD / Zero & MACD Slope" , "MACD / Zero & MACD Slope");
    strategy.parameters:addStringAlternative("Method", "MACD / Signal", "MACD / Signal" , "MACD / Signal");
    strategy.parameters:addStringAlternative("Method", "Histogram/Zero & Histogram Slope", "Histogram/Zero & Histogram Slope" , "Histogram/Zero & Histogram Slope");
    strategy.parameters:addStringAlternative("Method", "MACD/Signal & MACD/Zero", "MACD/Signal & MACD/Zero" , "MACD/Signal & MACD/Zero");

	
    strategy.parameters:addInteger("Period1", "Fast Period", "", 12);  
    strategy.parameters:addInteger("Period2", "Slow Period", "", 26);  
    strategy.parameters:addInteger("Period3", "Signal Period", "", 9);  


    strategy.parameters:addGroup("Pivot Calculation")
    strategy.parameters:addString("PivotTF", "Pivot Time frame", "", "D1")
    strategy.parameters:setFlag("PivotTF", core.FLAG_PERIODS)
    strategy.parameters:addString("CalcMode", "Calculation mode", "The mode of pivot calculation.", "Pivot")
    strategy.parameters:addStringAlternative("CalcMode", "Classic Pivot", "", "Pivot")
    strategy.parameters:addStringAlternative("CalcMode", "Camarilla", "", "Camarilla")
    strategy.parameters:addStringAlternative("CalcMode", "Woodie", "", "Woodie")
    strategy.parameters:addStringAlternative("CalcMode", "Fibonacci", "", "Fibonacci")
    strategy.parameters:addStringAlternative("CalcMode", "Floor", "", "Floor")
    strategy.parameters:addStringAlternative("CalcMode", "Fibonacci Retracement", "", "FibonacciR")
	
 
    CreateTradingParameters();
end

function CreateTradingParameters()
    strategy.parameters:addGroup("Execution Parameters");

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);   
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
	
	 strategy.parameters:addString("AccountType", "Account Type", "", "Automatic");
    strategy.parameters:addStringAlternative("AccountType", "FIFO", "", "FIFO");
	strategy.parameters:addStringAlternative("AccountType", "non FIFO", "", "NON");
    strategy.parameters:addStringAlternative("AccountType", "Automatic", "", "Automatic");
	
  
	strategy.parameters:addString("EntryExecutionType", "Entry Execution Type", "", "EndOfTurn");
    strategy.parameters:addStringAlternative("EntryExecutionType", "End of Turn", "", "EndOfTurn");
	strategy.parameters:addStringAlternative("EntryExecutionType", "Live", "", "Live");	
	--*********************************************************************************************************
	strategy.parameters:addString("ExitExecutionType", "Exit Execution Type", "", "EndOfTurn");
    strategy.parameters:addStringAlternative("ExitExecutionType", "End of Turn", "", "EndOfTurn");
	strategy.parameters:addStringAlternative("ExitExecutionType", "Live", "", "Live");
	--*********************************************************************************************************
		
	 strategy.parameters:addGroup("Trade Parameters");
	
	strategy.parameters:addBoolean("CloseOnOpposite", "Close On Opposite", "", true);
    strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "MPS");
    strategy.parameters:addBoolean("use_own_positions", "Use Own Positions Only", "", true);
	
	strategy.parameters:addBoolean("opposite_after_stop", "Only opposite positions after stop", "", false);
	
	strategy.parameters:addBoolean("PositionCap", "Use Position Cap", "", false);
	
   
	
	strategy.parameters:addInteger("MaxNumberOfPositionInAnyDirection", "Max Number Of Open Position In Any Direction", "", 2);
	strategy.parameters:addInteger("MaxNumberOfPosition", "Max Number Of Position In One Direction", "", 1);
    	
    strategy.parameters:addString("ALLOWEDSIDE", "Allowed side", "Allowed side for trading or signaling, can be Sell, Buy or Both", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell");
 

    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1);
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false);
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30);
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false);
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30);
    strategy.parameters:addString("TRAILING_STOP_TYPE", "Trailing stop type", "", "Dynamic");
    strategy.parameters:addStringAlternative("TRAILING_STOP_TYPE", "Do not use", "", "No");
    strategy.parameters:addStringAlternative("TRAILING_STOP_TYPE", "Dynamic", "", "Dynamic");
    strategy.parameters:addStringAlternative("TRAILING_STOP_TYPE", "Fixed", "", "Fixed");
    strategy.parameters:addDouble("FIXED_TRAILING_STOP", "% of profit or trailing step", "", 10, 10, 300);
	
	--*********************************************************************************************************
    strategy.parameters:addBoolean("Exit", "Use Optional Exit", "", true);
	--*********************************************************************************************************
	
	
    strategy.parameters:addGroup("Alerts");
    strategy.parameters:addBoolean("ShowAlert", "ShowAlert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", true);
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", false);
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
	
	 strategy.parameters:addGroup("Time Parameters");
	 
	strategy.parameters:addInteger("ToTime", "Convert the date to", "", 6);
    strategy.parameters:addIntegerAlternative("ToTime", "EST", "", 1);
    strategy.parameters:addIntegerAlternative("ToTime", "UTC", "", 2);
    strategy.parameters:addIntegerAlternative("ToTime", "Local", "", 3);
    strategy.parameters:addIntegerAlternative("ToTime", "Server", "", 4);
    strategy.parameters:addIntegerAlternative("ToTime", "Financial", "", 5);
	strategy.parameters:addIntegerAlternative("ToTime", "Display", "", 6);
	
    strategy.parameters:addString("StartTime", "Start Time for Trading", "", "00:00:00");
    strategy.parameters:addString("StopTime", "Stop Time for Trading", "", "24:00:00");
	--*********************************************************************************************************
    strategy.parameters:addBoolean("ManageExit", "Use Exit  after Stop Time", "", true);
	--*********************************************************************************************************
    strategy.parameters:addBoolean("UseMandatoryClosing", "Use Mandatory Closing", "", false);
    strategy.parameters:addString("ExitTime", "Mandatory Closing  Time", "", "23:59:00");
    strategy.parameters:addInteger("ValidInterval", "Valid interval for operation in second", "", 60);
	
	
end

local AccountType;
local Source,TickSource;
local MaxNumberOfPositionInAnyDirection, MaxNumberOfPosition;
local SoundFile = nil;
local RecurrentSound = false;
local ALLOWEDSIDE;
local AllowTrade;
local Offer;
local CanClose;
local Account;
local Amount;
local SetLimit;
local Limit;
local SetStop;
local Stop;
local TRAILING_STOP_TYPE;
local FIXED_TRAILING_STOP;
local ShowAlert;
local Email;
local SendEmail;
local BaseSize;
local EntyExecutionType, ExitExecutionType;
local CloseOnOpposite
local first;
local Direction;
local CustomID;
local use_own_positions;
local PositionCap;
local TF;
local OpenTime, CloseTime, ExitTime;
local LastEntry, LastExit;
local ToTime;
local ValidInterval,UseMandatoryClosing;
--*********************************************************************************************************
local ManageExit,Exit;
--*********************************************************************************************************
local opposite_after_stop;
local TRADES_UPDATE = 3;
local ORDERS_UPDATE = 4;
local closing_order_types = {};
local last_closed_trade_info = {};
 
 
--Indicator parameters
 
 
function Prepare( nameOnly)

    CustomID = instance.parameters.CustomID;
    use_own_positions = instance.parameters.use_own_positions;
    name = profile:id() .. ", " .. instance.bid:name() .. ", " .. CustomID;
    instance:name(name);
	

    if nameOnly then
        return ;
    end
	

 
	AccountType = instance.parameters.AccountType;
	EntryExecutionType = instance.parameters.EntryExecutionType;
	ExitExecutionType= instance.parameters.ExitExecutionType;
    CloseOnOpposite = instance.parameters.CloseOnOpposite;
	MaxNumberOfPositionInAnyDirection = instance.parameters.MaxNumberOfPositionInAnyDirection;
	MaxNumberOfPosition = instance.parameters.MaxNumberOfPosition; 
	TF= instance.parameters.TF;
	ToTime= instance.parameters.ToTime;
	
	if ToTime == 1 then
	ToTime=core.TZ_EST;
	elseif ToTime == 2 then
	ToTime=core.TZ_UTC;
	elseif ToTime == 3 then
	ToTime=core.TZ_LOCAL;
	elseif ToTime == 4 then
	ToTime=core.TZ_SERVER;
	elseif ToTime == 5 then
	ToTime=core.TZ_FINANCIAL;
	elseif ToTime == 6 then
	ToTime=core.TZ_TS;
	end
		
	 
	PositionCap = instance.parameters.PositionCap;	
	ValidInterval = instance.parameters.ValidInterval;
	UseMandatoryClosing = instance.parameters.UseMandatoryClosing;
	opposite_after_stop = instance.parameters.opposite_after_stop;
	
	LastEntry=nil;
	LastExit=nil;
	--*********************************************************************************************************
	 ManageExit = instance.parameters.ManageExit;
	  Exit= instance.parameters.Exit;
	--*********************************************************************************************************
	
	--Indicator parameters
	Method = instance.parameters.Method;   
	LimitLevel = instance.parameters.LimitLevel;
	StopLevel = instance.parameters.StopLevel;

    assert(TF ~= "t1", "The time frame must not be tick");
    assert(instance.parameters.PivotTF ~= "t1", "The pivot time frame must not be tick")
	
  	s1, e1 = core.getcandle(TF, 0, 0, 0);
	s2, e2 = core.getcandle(instance.parameters.PivotTF, 0, 0, 0);	

    assert((e2-s2)>(e1-s1), "The pivot time frame should be equal or greater than the chart time frame")
	
    PrepareTrading();

        
	
 	if EntryExecutionType== "Live" 
	--****************************************************************************************************
	or ExitExecutionType== "Live"
	--******************************************************************************************************
	  then
	 TickSource = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close");
 	end
	
    Source = ExtSubscribe(2, nil, TF, instance.parameters.Type == "Bid", "bar"); 
    MACD = core.indicators:create("MACD", Source.close, instance.parameters.Period1, instance.parameters.Period2, instance.parameters.Period3 );
    PIVOT  = core.indicators:create("PIVOT", Source, instance.parameters.PivotTF, instance.parameters.CalcMode, "HIST")	
	first=math.max(MACD.DATA:first(),PIVOT.DATA:first()); 
	
	
	ValidInterval = instance.parameters.ValidInterval;
	UseMandatoryClosing = instance.parameters.UseMandatoryClosing;
	
	 local valid;
    OpenTime, valid = ParseTime(instance.parameters.StartTime);
    assert(valid, "Time " .. instance.parameters.StartTime .. " is invalid");
    CloseTime, valid = ParseTime(instance.parameters.StopTime);
    assert(valid, "Time " .. instance.parameters.StopTime .. " is invalid");
    ExitTime, valid = ParseTime(instance.parameters.ExitTime);
    assert(valid, "Time " .. instance.parameters.ExitTime .. " is invalid");
	
	if UseMandatoryClosing then
        core.host:execute("setTimer", 100, math.max(ValidInterval / 2, 1));
    end
    core.host:execute("subscribeTradeEvents", TRADES_UPDATE, "trades");
    core.host:execute("subscribeTradeEvents", ORDERS_UPDATE, "orders");
end


function ReleaseInstance()
core.host:execute ("killTimer", 100);

end


 -- NG: create a function to parse time
function ParseTime(time)
    local Pos = string.find(time, ":");
    if Pos == nil then
        return nil, false;
    end
    local h = tonumber(string.sub(time, 1, Pos - 1));
    time = string.sub(time, Pos + 1);
    Pos = string.find(time, ":");
    if Pos == nil then
        return nil, false;
    end
    local m = tonumber(string.sub(time, 1, Pos - 1));
    local s = tonumber(string.sub(time, Pos + 1));
    return (h / 24.0 +  m / 1440.0 + s / 86400.0),                          -- time in ole format
           ((h >= 0 and h < 24 and m >= 0 and m < 60 and s >= 0 and s < 60) or (h == 24 and m == 0 and s == 0)); -- validity flag
end



function PrepareTrading()
    ALLOWEDSIDE = instance.parameters.ALLOWEDSIDE;

    local PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be chosen");

    ShowAlert = instance.parameters.ShowAlert;
    RecurrentSound = instance.parameters.RecurrentSound;

    SendEmail = instance.parameters.SendEmail;

    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");

    AllowTrade = instance.parameters.AllowTrade;
    Account = instance.parameters.Account;
    Amount = instance.parameters.Amount;
    BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);
    Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
    --CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account);
	
	if AccountType== "FIFO" then
	CanClose=false;
    elseif AccountType== "NON" then
	CanClose=true;
	else
	CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account);
	end
	
    SetLimit = instance.parameters.SetLimit;
    Limit = instance.parameters.Limit;
    SetStop = instance.parameters.SetStop;
    Stop = instance.parameters.Stop;
    TRAILING_STOP_TYPE = instance.parameters.TRAILING_STOP_TYPE;
    FIXED_TRAILING_STOP = instance.parameters.FIXED_TRAILING_STOP;
end
 

function InRange(now, openTime, closeTime)
    if openTime < closeTime then
        return now >= openTime and now <= closeTime;
    end
    if openTime > closeTime then
        return now > openTime or now < closeTime;
    end

    return now == openTime;
end


function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.
   
   
    if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
         return ;
        end
		
    end 
  
    now = core.host:execute("getServerTime");
	now= core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
   -- get only time
    now = now - math.floor(now);
	
 
	 
	
	    -- update indicators.
   MACD:update(core.UpdateLast);
   PIVOT:update(core.UpdateLast);
   
	if period <=first
	or PIVOT==nil
    or not PIVOT.P:hasData(period)	
	or PIVOT.P[period]==nil	
	then
        return;
    end	

    EntryFunction(id,now,period);	
    ExitFunction(id, now,period);
	
end


function ExitFunction(id, now,period)

    
	if not Exit
	or (StopLevel ==0 and LimitLevel==0)
	then
	return;
	end
	
	if not InRange(now, OpenTime, CloseTime)
	and not ManageExit
	then            
    return;
    end

    if  (ExitExecutionType== "EndOfTurn" and id==2)	
	then   
    elseif (ExitExecutionType== "Live" and id==1) 
	then
	period= core.findDate (Source, TickSource:date(period), false); 
	else
	return;
    end
	 
	--/////////////////////////////////////////////////////////////////  
	if  LastExit == Source:serial(period)
	--or not MA.DATA:hasData(period)
	then
	return;
	end	  
	--/////////////////////////////////////////////////////////////////////
	  
 
 

		            if   haveTrades("B") 
					then
 
						    Stop=PIVOT:getStream (StopLevel)[period]; 
                            Limit=PIVOT:getStream (4+LimitLevel)[period];							
							if Source.close[period]< Stop 
							or Source.close[period] >  Limit							
							then 					   
							    exitSpecific("B");
							    Signal ("Close Long");
							end						   
										   
							 
								LastExit= Source:serial(period);
					  end
					  if haveTrades("S")
					  then
					  
		   
						    Stop=PIVOT:getStream (4+LimitLevel)[period]; 
                            Limit=PIVOT:getStream (StopLevel)[period]; 					 
							if   Source.close[period] > Stop 
					        or   Source.close[period] <  Limit							
					        then
										   exitSpecific("S");
										   Signal ("Close Short");
							end		 
								  
							 
							 
						
							 
							 LastExit= Source:serial(period);
				
					end
					
					
					
					
	 
                
end

function EntryFunction( id, now,period)


     if not InRange(now, OpenTime, CloseTime)
	 then            
     return ;
     end
	


    if(EntryExecutionType== "EndOfTurn" and id==2) 
	--/////////////////////////////////////////////////////////////////     
	then
	
	period = period; 
		
	elseif (EntryExecutionType== "Live" and id==1) 
	then
	period = core.findDate (Source , TickSource:date(period), false); 
	else
	return;	
    end

	
	--/////////////////////////////////////////////////////////////////    
     if LastEntry == Source:serial(period)  
     --or not MA.DATA:hasData(period)
	 then
	 return;
	 end	
	 --/////////////////////////////////////////////////////////////////  

    local Return=false;

 
	
 

	
	if Method== "MACD / Zero & MACD Slope" then
			if MACD.MACD[period] > 0 
			and  MACD.MACD[period-1] < 0 
			and Source.close[period]< PIVOT.P[period]
			then
			          
							BUY();
						 
					LastEntry= Source:serial(period);
					Return=true;			  
			elseif MACD.MACD[period] < 0 
			and  MACD.MACD[period-1] > 0 
			and Source.close[period]> PIVOT.P[period]			
			then
			
					 
						SELL();
					 
					LastEntry= Source:serial(period);
					Return=true;			
				 
			end
	end
	
	
	if Method== "MACD / Signal" then
			if MACD.MACD[period] > MACD.SIGNAL[period] 
			and MACD.MACD[period-1] < MACD.SIGNAL[period-1] 
			and Source.close[price]< PIVOT.P[period]			
			then
			          
							BUY();
						 
					LastEntry= Source:serial(period);
					Return=true;			 
			elseif MACD.MACD[period] < MACD.SIGNAL[period] 
			and MACD.MACD[period-1] > MACD.SIGNAL[period-1]
			and Source.close[price]> PIVOT.P[period]			
			then
					 
						SELL();
				 
					LastEntry= Source:serial(period);
					Return=true;			 
			end
	end
	
	
	
	if Method== "Histogram/Zero & Histogram Slope" then
			if MACD.HISTOGRAM[period] > 0
			and MACD.HISTOGRAM[period-1] < 0
			and Source.close[price]< PIVOT.P[period]			
			then
			        
							BUY();
					 
					LastEntry= Source:serial(period);
					Return=true;				 
			elseif MACD.HISTOGRAM[period] < 0
			and MACD.HISTOGRAM[period-1] > 0
			and Source.close[price]> PIVOT.P[period]			
			then
					 
						SELL();
					 
					LastEntry= Source:serial(period);
					Return=true;				 
			end
	end
	
	if Method== "MACD/Signal & MACD/Zero" then
		if MACD.MACD[period] > MACD.SIGNAL[period] 
		and  MACD.MACD[period-1] < MACD.SIGNAL[period-1]
		and Source.close[price]< PIVOT.P[period]		
		then
			          
							BUY();
						 
					LastEntry= Source:serial(period);
					Return=true;	
				 
		elseif MACD.MACD[period] < MACD.SIGNAL[period] 
		and  MACD.MACD[period-1] > MACD.SIGNAL[period-1]
			and Source.close[price]> PIVOT.P[period]		
		then    
					 
						SELL();
					 
					LastEntry= Source:serial(period);
					Return=true;		
				 
		end
	end 


	
	 
	 return Return;
	  
end
-- NG: Introduce async function for timer/monitoring for the order results
function ExtAsyncOperationFinished(cookie, success, message)

    if cookie == 100 then
        -- timer
        if UseMandatoryClosing and AllowTrade then
            now = core.host:execute("getServerTime");
            now= core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
            -- get only time
            now = now - math.floor(now);
			
            -- check whether the time is in the exit time period
            if now >= ExitTime and now < ExitTime +(ValidInterval / 86400.0) then
                if not checkReady("trades")  then
                    return ;
                end  
				
				     if haveTrades("B")  then
                     exitSpecific("B");
                     Signal ("Close Long");
					 end
					 
					 if haveTrades("S")  then
                     exitSpecific("S");
                     Signal ("Close Short");
					 end
            end
        end
    elseif cookie == 200 and not success then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. message, instance.bid:date(instance.bid:size() - 1));
    elseif cookie == 201 and not success then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Close order failed" .. message, instance.bid:date(instance.bid:size() - 1));
    elseif cookie == TRADES_UPDATE then
        local trade_id = message;
        local close_trade = success;
        if close_trade then
            local closed_trade = core.host:findTable("closed trades"):find("TradeID", trade_id);
            if closed_trade ~= nil then
                last_closed_trade_info.side = closed_trade.BS;
                last_closed_trade_info.close_order_type = closing_order_types[closed_trade.CloseOrderID];
            end
        end
    elseif cookie == ORDERS_UPDATE then
        local order_id = message;
        local order = core.host:findTable("orders"):find("OrderID", order_id);
        if order ~= nil then
            if order.Stage == "C" then
                closing_order_types[order.OrderID] = order.Type;
            end
        end
    end
end

--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--
function BUY()
    if AllowTrade then
        --if CanClose and CloseOnOpposite and  haveTrades("S") then
		if  CloseOnOpposite   and  haveTrades("S")then
            -- close on opposite signal
            exitSpecific("S");
            Signal ("Close Short");
        end

        if ALLOWEDSIDE == "Sell"  then
            -- we are not allowed buys.
            return;
        end 

        enter("B",0);
    else
        Signal ("Buy Signal");	
    end
end   

-- We have 4 Long possitions
-- We call HEDGELONG
-- Option 1 -  We have 4 Long possitions + 4 Short possitions  (Line 697 commented)
-- Option 2 -  We have  4 Short possitions   (Line 697 uncommented)
-- to work your ALLOWEDSIDE should be set to Both 
function HEDGELONG ()
			
	  if ALLOWEDSIDE == "Buy" and haveTrades("B")  then
				-- we are not allowed sells.
				return;
	  end 
			
	 if not haveTrades("B")  then
     return;
     end		

     if AllowTrade then
	       
	 
	        local bCount= tradesCount("B"); 	
			
			if  bCount > 0  then				 
				exitSpecific("B");
				Signal ("Hedge Long");  --< Option 1 and Option 2
				enter("S", bCount);
			end

		 
			 
    else
        Signal ("Hedge Long");	
    end

end
function HEDGESHORT ()

       if ALLOWEDSIDE == "Sell" and haveTrades("S")  then
				-- we are not allowed buys.
				return;
			end 
			
	 if not haveTrades("S")  then
     return;
     end	 

     if AllowTrade then
	       
		    local sCount= tradesCount("S"); 	  
			  
        
			if  sCount > 0  then				 
				exitSpecific("S");
				Signal ("Hedge Short");
				 enter("B", sCount);
			end
				 
			 
    else
        Signal ("Hedge Short");	
    end

end



    
function SELL ()		
    if AllowTrade then
        --if CanClose and CloseOnOpposite and  haveTrades("B") then
		if  CloseOnOpposite  and  haveTrades("B") then
            -- close on opposite signal
            exitSpecific("B");
            Signal ("Close Long");
        end

        if ALLOWEDSIDE == "Buy"  then
            -- we are not allowed sells.
            return;
        end

        enter("S",0);
    else
        Signal ("Sell Signal");	
    end
end

function Signal (Label)
    if ShowAlert then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW],  Label, instance.bid:date(NOW));
    end

    if SoundFile ~= nil then
        terminal:alertSound(SoundFile, RecurrentSound);
    end

    if Email ~= nil then
        terminal:alertEmail(Email, profile:id().. " : " .. Label , FormatEmail(Source, NOW, Label));
		 
    end
end								

function checkReady(table)
    local rc;
    if Account == "TESTACC_ID" then
        -- run under debugger/simulator
        rc = true;
    else
        rc = core.host:execute("isTableFilled", table);
    end

    return rc;
end

 

function tradesCount(BuySell) 
    local enum, row;
    local count = 0;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while row ~= nil do
        if row.AccountID == Account 
		and row.OfferID == Offer 
		and (row.QTXT == CustomID or not use_own_positions)
		and (row.BS == BuySell or BuySell == nil) then
            count = count + 1;
        end

        row = enum:next();
    end

    return count;
end

function haveTrades(BuySell) 
    local enum, row;
    local found = false;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while (row ~= nil) do
        if row.AccountID == Account
		and row.OfferID == Offer
		and (row.QTXT == CustomID or not use_own_positions)
		and (row.BS == BuySell or BuySell == nil) then
            found = true;
            break;
        end
 
        row = enum:next();
    end

    return found;
end

function AllowThisSize(side)
    if not opposite_after_stop then
        return true;
    end
    if last_closed_trade_info.side == nil then
        return true;
    end
    return last_closed_trade_info.side ~= side or last_closed_trade_info.close_order_type ~= "S";
end

-- enter into the specified direction
function enter(BuySell, hCount)
    -- do not enter if position in the specified direction already exists
    if (tradesCount(BuySell) >= MaxNumberOfPosition
	or (tradesCount(nil) >= MaxNumberOfPositionInAnyDirection))	
    and PositionCap	
    or not AllowThisSize(BuySell)
	then
        return true;
    end

    -- send the alert after the checks to see if we can trade.
    if (BuySell == "S") then
        Signal ("Sell Signal");	
    else
        Signal ("Buy Signal");	
    end

    return MarketOrder(BuySell,hCount);
end


-- enter into the specified direction
function MarketOrder(BuySell,hCount)

  --  if trade_in_progress then
	--return;
	--end

   -- trade_in_progress=true;
	
    local valuemap, success, msg;
    valuemap = core.valuemap();

    valuemap.Command = "CreateOrder";
    valuemap.OrderType = "OM";
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
	if hCount > 0 then
	valuemap.Quantity = hCount * BaseSize;
	else
    valuemap.Quantity = Amount * BaseSize;
	end
    valuemap.BuySell = BuySell;
     valuemap.CustomID = CustomID;

    -- add stop/limit
    valuemap.PegTypeStop = "O";
    if SetStop then 
        if BuySell == "B" then
            valuemap.PegPriceOffsetPipsStop = -Stop;
        else
            valuemap.PegPriceOffsetPipsStop = Stop;
        end
    end
    if TRAILING_STOP_TYPE == "Dynamic" then
        valuemap.TrailStepStop = 1;
    elseif TRAILING_STOP_TYPE ~= "No" then
        valuemap.TrailStepStop = FIXED_TRAILING_STOP;
    end

    valuemap.PegTypeLimit = "O";
    if SetLimit then
        if BuySell == "B" then
            valuemap.PegPriceOffsetPipsLimit = Limit;
        else
            valuemap.PegPriceOffsetPipsLimit = -Limit;
        end
    end

    if (not CanClose) then
        valuemap.EntryLimitStop = 'Y'
    end

    success, msg = terminal:execute(200, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        return false;
    end

    return true;
end




function exitSpecific(BuySell)

 if not AllowTrade then
 return;
 end
 
--side
-- closes all positions of the specified direction (B for buy, S for sell)
 
    local enum, row, valuemap;

    enum = core.host:findTable("trades"):enumerator();
    while true do
        row = enum:next();
        if row == nil then
            break;
        end
        if row.AccountID == Account and
           row.OfferID == Offer and
           row.BS == BuySell and
           (row.QTXT == CustomID or not use_own_positions) then
            -- if trade has to be closed

						if CanClose then
										-- non-FIFO account, create a close market order
										valuemap = core.valuemap();
										valuemap.OrderType = "CM";
										valuemap.OfferID = Offer;
										valuemap.AcctID = Account;
										valuemap.Quantity = row.Lot;
										valuemap.TradeID = row.TradeID;
										valuemap.CustomID = CustomID;
										if row.BS == "B" then
											valuemap.BuySell = "S";
										else
											valuemap.BuySell = "B";
										end
										success, msg = terminal:execute(201, valuemap);
										 if not(success) then
											terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Close order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
											return false;
										end
						  else
											-- FIFO account, create an opposite market order
											valuemap = core.valuemap();
											valuemap.OrderType = "OM";
											valuemap.OfferID = Offer;
											valuemap.AcctID = Account;
											--valuemap.Quantity = Amount*BaseSize;
							                valuemap.Quantity = row.Lot;
											valuemap.CustomID = CustomID;
											if row.BS == "B" then
												valuemap.BuySell = "S";
											else
												valuemap.BuySell = "B";
											end
											success, msg = terminal:execute(201, valuemap);
											 if not(success) then
												terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Close order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
												return false;
											end
						end
        end
    end
end 

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+