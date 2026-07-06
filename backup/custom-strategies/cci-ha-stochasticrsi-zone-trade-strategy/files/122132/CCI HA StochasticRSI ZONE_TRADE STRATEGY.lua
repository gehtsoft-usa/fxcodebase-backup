-- Id: 22740
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=66931

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+



function Init() --The strategy profile initialization
    strategy:name("CCI HA StochasticRSI ZONE_TRADE STRATEGY");
    strategy:description(" ");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");
 
	strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
	
	strategy.parameters:addString("TF", "Time frame", "", "H1");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);

    strategy.parameters:addGroup("HA Parameters");
	strategy.parameters:addBoolean("UseHA", "Use HA", "", true); 
	
	
	strategy.parameters:addGroup("Stochastic RSI Parameters");
	strategy.parameters:addBoolean("UseStochasticRSI", "Use Stochastic RSI", "", true); 
    strategy.parameters:addInteger("N", "Number of periods for RSI", "", 14, 1, 200);
    strategy.parameters:addInteger("K", "%K Stochastic Periods", "", 14, 1, 200);
    strategy.parameters:addInteger("KS", "%K Slowing Periods", "", 5, 1, 200);
    strategy.parameters:addInteger("D", "%D Slowing Stochastic Periods", "", 3, 1, 200);
	
	 strategy.parameters:addDouble("OB", "OB Level", "", 80);
	 strategy.parameters:addDouble("OS", "OS Level", "", 20);
	 
	 strategy.parameters:addGroup("CCI Parameters");
	strategy.parameters:addBoolean("UseCCI", "Use CCI", "", true); 
	strategy.parameters:addInteger("CCI_Period", "CCI Period", "", 14);
	
	
    strategy.parameters:addGroup("Bill Williams Zone Parameters");
   
	
	strategy.parameters:addString("TYPE", "Type", "", "ZONE");
    strategy.parameters:addStringAlternative("TYPE", "ZONE", "", "ZONE");
    strategy.parameters:addStringAlternative("TYPE", "AO", "", "AO");
	strategy.parameters:addStringAlternative("TYPE", "AC", "", "AC");
	strategy.parameters:addStringAlternative("TYPE", "Do not use it", "", "NOT");
	
	strategy.parameters:addBoolean("EXIT", "If Neutral Close Position", "", false);
	
	
	strategy.parameters:addGroup("AC Parameters");
	strategy.parameters:addInteger("ACFM", "Fast Moving Average for Awesome oscillator", "", 5, 2, 10000);
    strategy.parameters:addInteger("ACSM", "Slow Moving Average for Awesome oscillator", "", 35, 2, 10000);
    strategy.parameters:addInteger("ACM", "Moving Average for Acceleration/Deceleration", "", 5, 2, 10000);
   
    strategy.parameters:addGroup("AO Parameters");
    strategy.parameters:addInteger("AOFM", "Fast Moving Average", "", 5, 2, 10000);
    strategy.parameters:addInteger("AOSM", "Slow Moving Average", "", 35, 2, 10000);
	
	 
    

    CreateTradingParameters();
end

function CreateTradingParameters()
    strategy.parameters:addGroup("Trading Parameters");

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false);   
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
	
 
	strategy.parameters:addString("ExecutionType", "End of Turn / Live", "", "End of Turn");
    strategy.parameters:addStringAlternative("ExecutionType", "End of Turn", "", "End of Turn");
	strategy.parameters:addStringAlternative("ExecutionType", "Live", "", "Live");
	
	strategy.parameters:addBoolean("CloseOnOpposite", "Close On Opposite", "", true);
    strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "CHSZS");
	
	strategy.parameters:addInteger("MaxNumberOfPositionInAnyDirection", "Max Number Of Open Position In Any Direction", "", 2, 1, 100);
	strategy.parameters:addInteger("MaxNumberOfPosition", "Max Number Of Position In One Direction", "", 1, 1, 100);
    	
    strategy.parameters:addString("ALLOWEDSIDE", "Allowed side", "Allowed side for trading or signaling, can be Sell, Buy or Both", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell");
	
	strategy.parameters:addString("Direction", "Type of Signal / Trade", "", "direct");
    strategy.parameters:addStringAlternative("Direction", "Direct", "", "direct");
    strategy.parameters:addStringAlternative("Direction", "Reverse", "", "reverse");

    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 100);
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false);
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false);
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false);
	
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

    strategy.parameters:addBoolean("UseMandatoryClosing", "Use Mandatory Closing", "", false);
    strategy.parameters:addString("ExitTime", "Mandatory Closing  Time", "", "23:59:00");
    strategy.parameters:addInteger("ValidInterval", "Valid interval for operation in second", "", 60);
	
	
end
 
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
local TrailingStop;
local ShowAlert;
local Email;
local SendEmail;
local BaseSize;
local ExecutionType;
local CloseOnOpposite
local first;
local Short={};
local Direction;
local CustomID;
local EXIT, TYPE;
 

local indicator = {};
local iprofile = {};
local iparams = {};


local OpenTime, CloseTime, ExitTime;
local ValidInterval,UseMandatoryClosing;
local ToTime;

local UseCCI, CCI_Period;

local UseHA;
 local N,K,KS,D,OB,OS,UseStochasticRSI;
--
function Prepare( nameOnly)
    CustomID = instance.parameters.CustomID;
	ExecutionType = instance.parameters.ExecutionType;
    CloseOnOpposite = instance.parameters.CloseOnOpposite;
	MaxNumberOfPositionInAnyDirection = instance.parameters.MaxNumberOfPositionInAnyDirection;
	MaxNumberOfPosition = instance.parameters.MaxNumberOfPosition;
	Direction = instance.parameters.Direction == "direct";
	 
	
	EXIT = instance.parameters.EXIT;
	TYPE = instance.parameters.TYPE;
	 
	UseHA= instance.parameters.UseHA;
	
	N= instance.parameters.N;
	K= instance.parameters.K;
	KS= instance.parameters.KS;
	D= instance.parameters.D;
	OB= instance.parameters.OB;
	OS= instance.parameters.OS;
	UseStochasticRSI= instance.parameters.UseStochasticRSI;
	
	 UseCCI= instance.parameters.UseCCI;
	 CCI_Period= instance.parameters.CCI_Period;
		 
			
			 name = profile:id();  
    
	
    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");

    local name;
    name = profile:id() .. "( " .. instance.bid:name() .. "," .. CustomID ..  " )";
    instance:name(name);
   
    PrepareTrading();

    if nameOnly then
        return ;
    end
	
	 
	
	if ExecutionType== "Live" then
	TickSource = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close");
	end
	
    Source = ExtSubscribe(2, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar");
    first=Source:first();
   
   
    if  TYPE == "AO" or TYPE == "ZONE"  then
    indicator[1] = core.indicators:create("AO",Source, instance.parameters:getInteger("AOFM"), instance.parameters:getInteger("AOSM")  );	
	first=math.max(first, indicator[1].DATA:first());
    end
	
	if  TYPE == "AC" or TYPE == "ZONE"  then
	 indicator[2] = core.indicators:create("AC",Source,  instance.parameters:getInteger("ACFM"),  instance.parameters:getInteger("ACSM"),instance.parameters:getInteger("ACM")  );	
	 first=math.max(first, indicator[2].DATA:first());
	end    
	
	
	if  UseHA then
	 indicator[3] = core.indicators:create("HA",Source);	
	 first=math.max(first, indicator[3].DATA:first());
	end
	
	
	if UseStochasticRSI then
    assert(core.indicators:findIndicator("STOCHRSI") ~= nil, "STOCHRSI" .. " indicator must be installed");
	indicator[4] = core.indicators:create("STOCHRSI",Source.close,N,K,KS,D);	
	 first=math.max(first, indicator[4].DATA:first());
	end
	
	
	if UseCCI then
	indicator[5] = core.indicators:create("CCI",Source ,CCI_Period);	
	 first=math.max(first, indicator[5].DATA:first());
	end
	
	   ToTime= instance.parameters.ToTime;
    ValidInterval = instance.parameters.ValidInterval;
    UseMandatoryClosing = instance.parameters.UseMandatoryClosing;	
	
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
	
	
end


-- NG: create a function to parse time
function InRange(now, openTime, closeTime)
    if openTime < closeTime then
        return now >= openTime and now <= closeTime;
    end
    if openTime > closeTime then
        return now > openTime or now < closeTime;
    end

    return now == openTime;
end

function ParseTime(time)
    local pos = string.find(time, ":");
    if pos == nil then
        return nil, false;
    end
    local h = tonumber(string.sub(time, 1, pos - 1));
    time = string.sub(time, pos + 1);
    pos = string.find(time, ":");
    if pos == nil then
        return nil, false;
    end
    local m = tonumber(string.sub(time, 1, pos - 1));
    local s = tonumber(string.sub(time, pos + 1));
    return (h / 24.0 + m / 1440.0 + s / 86400.0),                          --time in ole format
            ((h >= 0 and h< 24 and m >= 0 and m< 60 and s >= 0 and s< 60) or(h == 24 and m == 0 and s == 0)); --validity flag
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
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account);
    SetLimit = instance.parameters.SetLimit;
    Limit = instance.parameters.Limit;
    SetStop = instance.parameters.SetStop;
    Stop = instance.parameters.Stop;
    TrailingStop = instance.parameters.TrailingStop;
end
 
local Last;
local LAST;
local ONE;


local FLAGAO=nil;
local FLAGAC=nil;
local FLAG=nil;

function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.

        now = core.host:execute("getServerTime");
	now= core.host:execute ("convertTime", core.TZ_EST, ToTime, now);
   -- get only time
    now = now - math.floor(now);		
	if not InRange(now, OpenTime, CloseTime) 
	  then  
      return ;
      end
 
 
 
    if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
            return ;
        end
    end
	
	
	if  ExecutionType ==  "Live" and  id == 1 then
			
			period= core.findDate (Source.close, TickSource:date(period), false );		
					
	end

	if  ExecutionType ==  "Live"  then
	
	        if ONE == Source:serial(period) then
			return;
			end
	
			if id == 2 then
			return;
			end		
			
			
		
	else	
			if id ~= 2 then       
			return;
			end
	end

 

    -- update indicators.
 

	if period < first  then
        return;
    end
	
    
 
          if  TYPE == "AO"  or TYPE == "ZONE"  then 
          indicator[1]:update(core.UpdateLast);
		  
		       if  not indicator[1].DATA:hasData(period) or not indicator[1].DATA:hasData(period-1) then
			   return;
			   end
			   
		  end
		  
		  if  TYPE == "AC"  or TYPE == "ZONE"  then 
		   indicator[2]:update(core.UpdateLast);
		   
		       if  not indicator[2].DATA:hasData(period) or not indicator[2].DATA:hasData(period-1) then
			   return;
			   end
	      end

		  
		  if UseHA then
		  
		  indicator[3]:update(core.UpdateLast);
		   
		       if  not indicator[3].DATA:hasData(period) or not indicator[3].DATA:hasData(period-1) then
			   return;
			   end
		  
		  end
		  
		  
		  if UseStochasticRSI then
		  
		     indicator[4]:update(core.UpdateLast);
		   
		       if  not indicator[4].D:hasData(period) or not indicator[4].D:hasData(period-1) then
			   return;
			   end
		  
		  end
		  
		  if UseCCI then
		  
		     indicator[5]:update(core.UpdateLast);
		   
		       if  not indicator[5].DATA:hasData(period) or not indicator[5].DATA:hasData(period-1) then
			   return;
			   end
		  
		  end
		  
		  
		  
	 
		   
		 local Signal1=0;
         local Signal2=0;	
         local Signal3=0;
	     local Signal4=0;	 
	     local Signal5=0;	  
		 
		 
			   if  TYPE == "AO"  or TYPE == "ZONE"  then 
			   if   indicator[1].DATA[period] >  indicator[1].DATA[period-1]  then
			   Signal1 = 1;
					 
			   elseif   indicator[1].DATA[period] <  indicator[1].DATA[period-1]   then
			    Signal1 = -1;
			   end
			   end
			   
			   
			    
		       if  TYPE == "AC"  or TYPE == "ZONE"  then 
			   if   indicator[2].DATA[period] >  indicator[2].DATA[period-1]  and FLAGAC ~= "Buy" then
			   Signal2 = 1;  
			   elseif  indicator[2].DATA[period] <  indicator[2].DATA[period-1]  and FLAGAC ~= "Sell" then
			    Signal2 = -1;
			   end
			   end
			   
			   if UseHA then 
			   if   indicator[3].close[period] >  indicator[3].open[period]  then
			   Signal3 = 1;
					 
			   elseif   indicator[3].close[period] <  indicator[3].open[period]   then
			   Signal3 = -1;
			   end
			   end
			   
			   
			   if UseStochasticRSI then
			   if   FindRSI(period)==1
			   then
			   Signal4 = 1;
					 
			   elseif  FindRSI(period)==-1
			   then
			   Signal4 = -1;
			   end
			   end
			   
			   if UseCCI then
			   
			      if   indicator[5].DATA[period] > 0   then
				   Signal5 = 1;
						 
				   elseif   indicator[5].DATA[period] < 0  then
				   Signal5 = -1;
				   end
				   
			   
			   end
			   

 
			   
			 if   ((Signal1==1 and (TYPE == "AO"  or TYPE == "ZONE") ) or (TYPE ~= "AO"  and TYPE ~= "ZONE" ))
			 and  ((Signal2==1 and (TYPE == "AC"  or TYPE == "ZONE") ) or (TYPE ~= "AC"  and TYPE ~= "ZONE" ))
			 and  ((Signal3==1 and UseHA ) or not UseHA)
			 and  ((Signal4==1 and UseStochasticRSI ) or not UseStochasticRSI)
			  and  ((Signal5==1 and UseCCI ) or not UseCCI)
			 then			   
			   
				  if Direction then
						BUY();
					else
						SELL();
					end
				ONE= Source:serial(period);
			  elseif  ((Signal1==-1 and (TYPE == "AO"  or TYPE == "ZONE") ) or (TYPE ~= "AO"  and TYPE ~= "ZONE" ))
			  and ((Signal2==-1 and (TYPE == "AC"  or TYPE == "ZONE") ) or (TYPE ~= "AC"  and TYPE ~= "ZONE" ))
			  and  ((Signal3==-1 and UseHA ) or not UseHA)
			  and  ((Signal4==-1 and UseStochasticRSI ) or not UseStochasticRSI)
			  and  ((Signal5==-1 and UseCCI ) or not UseCCI)
			  then
		 
			      if Direction then
						SELL();
					else
						BUY();
					end
				ONE= Source:serial(period)
			   elseif EXIT and haveTrades(nil)  then 
			   TRADE("Neutral"); 
               end
			   

end

function FindRSI(period)

local Return=0;


		for i= period-1, Source:first(), -1 do



			  if indicator[4].K[i] > OS 
			  and indicator[4].D[i] > OS   and indicator[4].D[i-1] < OS
			  then 
			  Return=1;
			  break;
			  end
			  
			  if indicator[4].K[i] < OB 
			  and indicator[4].D[i] < OB  and indicator[4].D[i-1] > OB 
			  then 
			  Return=-1;
			  break;
			  end
		  end
 

return Return;

			    
end

function TRADE (SIDE)

           
			NOTE =" Exit Position";
		 
			
            if ShowAlert then
                terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], NOTE, instance.bid:date(NOW));
            end

            if SoundFile ~= nil then
                terminal:alertSound(SoundFile, RecurrentSound);
            end

            if Email ~= nil then
                terminal:alertEmail(Email, NOTE , name .." " .. NOTE)
            end
			
           	
			exitSpecific("B");
			exitSpecific("S");
			 
   
end


-- NG: Introduce async function for timer/monitoring for the order results
function ExtAsyncOperationFinished(cookie, success, message)

    if cookie == 100 then
        -- timer
        if UseMandatoryClosing and AllowTrade then
            now = core.host:execute("getServerTime");
            now= core.host:execute ("convertTime", core.TZ_EST, ToTime, now);
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
		
	 end
	 
end

--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--
function BUY()
    if AllowTrade then
        if CloseOnOpposite and haveTrades("S") then
            -- close on opposite signal
            exitSpecific("S");
            Signal ("Close Short");
        end

        if ALLOWEDSIDE == "Sell"  then
            -- we are not allowed buys.
            return;
        end 

        enter("B");
    else
        Signal ("Buy Signal");	
    end
end   
    
function SELL ()		
    if AllowTrade then
        if CloseOnOpposite and haveTrades("B") then
            -- close on opposite signal
            exitSpecific("B");
            Signal ("Close Long");
        end

        if ALLOWEDSIDE == "Buy"  then
            -- we are not allowed sells.
            return;
        end

        enter("S");
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
        terminal:alertEmail(Email, Label, profile:id() .. "(" .. instance.bid:instrument() .. ")" .. instance.bid[NOW]..", " .. Label..", " .. instance.bid:date(NOW));
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
        if row.AccountID == Account and row.OfferID == Offer and row.QTXT == CustomID and (row.BS == BuySell or BuySell == nil) then
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
        if row.AccountID == Account and row.OfferID == Offer and row.QTXT == CustomID and (row.BS == BuySell or BuySell == nil) then
            found = true;
            break;
        end

        row = enum:next();
    end

    return found;
end

-- enter into the specified direction
function enter(BuySell)
    -- do not enter if position in the specified direction already exists
    if tradesCount(BuySell) >= MaxNumberOfPosition
	or ((tradesCount(nil)) >= MaxNumberOfPositionInAnyDirection)	
	then
        return true;
    end

    -- send the alert after the checks to see if we can trade.
    if (BuySell == "S") then
        Signal ("Sell Signal");	
    else
        Signal ("Buy Signal");	
    end

    return MarketOrder(BuySell);
end


-- enter into the specified direction
function MarketOrder(BuySell)
    local valuemap, success, msg;
    valuemap = core.valuemap();

    valuemap.Command = "CreateOrder";
    valuemap.OrderType = "OM";
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    valuemap.Quantity = Amount * BaseSize;
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
    if TrailingStop then
        valuemap.TrailStepStop = 1;
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

-- exit from the specified trade using the direction as a key
function exitSpecific(BuySell)
    -- we have to loop through to exit all trades in each direction instead
    -- of using the net qty flag because we may be running multiple strategies on the same account.
    local enum, row;
    local found = false;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while (not found) and (row ~= nil) do
        -- for every trade for this instance.
        if row.AccountID == Account and row.OfferID == Offer and row.QTXT == CustomID and (row.BS == BuySell or BuySell == nil) then
           exitTrade(row);
        end

        row = enum:next();
    end
end

-- exit from the specified direction
function exitTrade(tradeRow)
    if not(AllowTrade) then
        return true;
    end

    local valuemap, success, msg;
    valuemap = core.valuemap();

    -- switch the direction since the order must be in oppsite direction
    if tradeRow.BS == "B" then
        BuySell = "S";
    else
        BuySell = "B";
    end
    valuemap.OrderType = "CM";
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    if (CanClose) then
        -- Non-FIFO can close each trade independantly.
        valuemap.TradeID = tradeRow.TradeID;
        valuemap.Quantity = tradeRow.Lot;
    else
        -- FIFO.
        valuemap.NetQtyFlag = "Y"; -- this forces all trades to close in the opposite direction.
    end
    valuemap.BuySell = BuySell;
    valuemap.CustomID = CustomID;
    success, msg = terminal:execute(201, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Close order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        return false;
    end

    return true;
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");

