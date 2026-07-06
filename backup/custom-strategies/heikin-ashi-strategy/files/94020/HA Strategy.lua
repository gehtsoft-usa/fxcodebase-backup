-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=4148
-- Id: 11746
-- More information about this indicator can be found at:
-- http://fxcodebase.com

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
-- Strategy profile initialization routine
-- Defines Strategy profile properties and Strategy parameters
function Init()
    strategy:name("Heikin-Ashi Strategy");
    strategy:description("");
   strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");

    strategy.parameters:addGroup("Price Parameters");
    strategy.parameters:addString("TF", "TF", "Time frame ('t1', 'm1', 'm5', etc.)", "m1");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
		
	strategy.parameters:addString("Type", "Bid/Ask", "Bid", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
    
    strategy.parameters:addGroup("Heikin-Ashi Trigger Level");	
    strategy.parameters:addBoolean("Trigger", "Trigger", "", false);
	
    strategy.parameters:addDouble("Level", "Trigger Level", "", 0.0, 0.0, 10000.0);
	
	 strategy.parameters:addString("Mode", "Price / HA", "", "HA");
    strategy.parameters:addStringAlternative("Mode", "HA", "", "HA");
    strategy.parameters:addStringAlternative("Mode", "Price", "", "PRICE");
 
    strategy.parameters:addString("Relativ", "Percentage / PIP", "", "PIP");
    strategy.parameters:addStringAlternative("Relativ", "PIP", "", "PIP");
    strategy.parameters:addStringAlternative("Relativ", "Percentage", "", "Percentage");
 

    strategy.parameters:addGroup("Trading Parameters");
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
	 strategy.parameters:addBoolean("AllowMultiple", "Allow Multiple Positions in the same direction", "", true);
	 
 
	 
	 strategy.parameters:addString("SIDE", "Allow Short/Long/Both Positions", "", "BOTH");
    strategy.parameters:addStringAlternative("SIDE", "Both", "", "BOTH");
    strategy.parameters:addStringAlternative("SIDE", "Short", "", "SHORT");
	strategy.parameters:addStringAlternative("SIDE", "Long", "", "LONG");
	
	 strategy.parameters:addBoolean("Reverse", "Reverse Direction", "", false);
	 
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000);
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false);
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false);
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false);

    strategy.parameters:addGroup("Notification");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", false);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addBoolean("RecurSound", "Recurrent Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", false);
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

-- Parameters block
local SIDE;
local gSource = nil; -- the source stream
local PlaySound;
local RecurrentSound;
local SoundFile;
local Email;
local SendEmail;
local AllowTrade;
local Account;
local Amount;
local BaseSize;
local SetLimit;
local Limit;
local SetStop;
local Stop;
local TrailingStop;
local Offer;
local CanClose;
local AllowMultiple;
local ShowAlert;
local first;
--TODO: Add variable(s) for your strategy if needed
local indicator;
local Trigger;
local Level;
local Mode;
local Relativ;
local LAST={};
local Reverse;
-- strategy instance initialization routine
-- Processes strategy parameters and subscribe to price streams
-- TODO: Calculate all constants, create instances all necessary indicators and load all required libraries
function Prepare(nameOnly)
    SIDE= instance.parameters.SIDE;    
    AllowMultiple= instance.parameters.AllowMultiple;
	Reverse= instance.parameters.Reverse;
    Level= instance.parameters.Level;
	Mode= instance.parameters.Mode;
	Relativ= instance.parameters.Relativ;

    local name;	
    name = profile:id() .. "(" .. instance.bid:instrument();

    local i;
   
	
	    -- collect parameters
		
		Trigger = instance.parameters.Trigger;
	
        name = name .. ", " .. instance.parameters.TF 

        assert(instance.parameters.TF ~= "t1", "timeframe must not be tick");
    
    name = name .. ")";
           

    ShowAlert = instance.parameters.ShowAlert;
    if ShowAlert then
        PlaySound = instance.parameters.PlaySound;
        if PlaySound then
            RecurrentSound = instance.parameters.RecurSound;
            SoundFile = instance.parameters.SoundFile;
        else
            SoundFile = nil;
        end
        assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");

        SendEmail = instance.parameters.SendEmail;
        if SendEmail then
            Email = instance.parameters.Email;
        else
            Email = nil;
        end
        assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
    end

    AllowTrade = instance.parameters.AllowTrade;
    if AllowTrade then
        Account = instance.parameters.Account;
        Amount = instance.parameters.Amount;
        BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);
        Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
        CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account);
        SetLimit = instance.parameters.SetLimit;
        Limit = instance.parameters.Limit;
        SetStop = instance.parameters.SetStop;
        Stop = instance.parameters.Stop ;
        TrailingStop = instance.parameters.TrailingStop;
    end
	
	 --TODO: Find indicator's profile, intialize parameters, and create indicator's instance (if needed)
	

	
		gSource= ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar");

		indicator = core.indicators:create("HA", gSource);

   first = indicator.DATA:first() ;
   
   if nameOnly then
        return ;
    end
	
	LAST["PRICE"]= nil;
	LAST["SIDE"]= nil;
	
    
end



-- strategy calculation routine
-- TODO: Add your code for decision making
-- TODO: Update the instance of your indicator(s) if needed
function ExtUpdate(id, source, period)

    if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
            return ;
        end
    end
   
     
		indicator:update(core.UpdateLast);
		
		if id ~= 1 or period < first +1 then
		return;
		end

		if not(indicator.DATA:hasData(period )) or not(indicator.DATA:hasData(period -1)) then
			return;
		end
	
	
	   		
		if indicator.open[period] <   indicator.close [period] and indicator.open[period-1] >  indicator.close [period-1] then
		LAST["PRICE"]= indicator.open [period];
		LAST["SIDE"]= "LONG";
		LAST["ON"]= "OFF";
		elseif indicator.open[period] >   indicator.close [period] and indicator.open[period-1] <  indicator.close [period-1] then
		LAST["PRICE"]= indicator.open [period];
		LAST["SIDE"]= "SHORT";
		LAST["ON"]= "OFF";
		end
		
		if  LAST["PRICE"] == nil then
		return;
		end
	
        local BUY= false;
		local SELL= false;
		
		if Trigger and Level ~= 0.0 and LAST["ON"] ==  "OFF" then
		
					 if Mode == "HA" then
								   
											   if Relativ == "PIP" then
														if LAST["SIDE"]== "LONG" and (indicator.close[period] - LAST["PRICE"]) / gSource:pipSize()> Level  then 
														BUY = true;
														LAST["ON"] =  "ON";
														end
														if LAST["SIDE"]== "SHORT" and ((indicator.close[period] - LAST["PRICE"]) / gSource:pipSize() < -Level ) then 
														SELL = true;
														LAST["ON"] =  "ON";
														end
												elseif   Relativ ==  "Percentage" then
														if LAST["SIDE"]== "LONG" and  (indicator.close[period] - LAST["PRICE"]) / (LAST["PRICE"] /100) > Level  then 
														BUY = true;
														LAST["ON"] =  "ON";
														end
														if LAST["SIDE"]== "SHORT" and (indicator.close[period] - LAST["PRICE"]) / (LAST["PRICE"] /100) < -Level  then 
														SELL = true;
														LAST["ON"] =  "ON";
														end
												end  
								   
					 elseif Mode == "PRICE" then
								   
											
												if Relativ == "PIP" then
														if LAST["SIDE"]== "LONG" and  (gSource.close[period] - LAST["PRICE"]) / gSource:pipSize() > Level  then 
														BUY = true;
														LAST["ON"] =  "ON";
														end
														if LAST["SIDE"]== "SHORT" and  (gSource.close[period] - LAST["PRICE"]) / gSource:pipSize() < - Level  then 
														SELL = true;
														LAST["ON"] =  "ON";
														end
												elseif   Relativ ==  "Percentage" then
														 if  LAST["SIDE"]== "LONG" and  (gSource.close[period] -  LAST["PRICE"]) / ( LAST["PRICE"] /100) > Level  then 
														BUY = true;
														LAST["ON"] =  "ON";
														end
														 if  LAST["SIDE"]== "SHORT" and  (gSource.close[period] -  LAST["PRICE"]) / ( LAST["PRICE"] /100) <- Level  then 
														SELL = true;
														LAST["ON"] =  "ON";
														end
												end  
									   
					 end	
						  
               		   
				
		
		else
			if  indicator.open[period] <   indicator.close [period] and indicator.open[period-1] >  indicator.close [period-1]  then 
			BUY= true;
			elseif  indicator.open[period] >   indicator.close [period] and indicator.open[period-1] <  indicator.close [period-1]  then 
			SELL= true;
			end
		end
		
		if BUY or (SELL and Reverse) then
			
			if haveTrades('B')  and not  AllowMultiple then
			               if haveTrades('S') then
                            exit('S');
							Signal ("Close Short");
							end
			return;
			end
			
			if SIDE == "SHORT" then
			
			      	if AllowTrade then
						    if haveTrades('S') then
                            exit('S');
							Signal ("Close Short");
							end
                            
						 elseif ShowAlert then	
						    if haveTrades('S') then                           
							Signal ("Close Short");
							end                            
							
	    		       end     
			
			return;
			end
			
			   
	              

						if AllowTrade then
						    if haveTrades('S') then
                            exit('S');
							Signal ("Close Short");
							end
                            enter('B');
							Signal ("Open Long");
						 elseif ShowAlert then	
						    if haveTrades('S') then                           
							Signal ("Close Short");
							end                            
							Signal ("Open Long");
	    		       end     
         
		   elseif  SELL   or (BUY and Reverse) then 
		   
		    if haveTrades('S')  and not  AllowMultiple then
			              if haveTrades('B') then
                            exit('B');
							Signal ("Close Long");
							end
			return;
			end
			
			if SIDE == "LONG" then
			
			         if AllowTrade then
						    if haveTrades('B') then
                            exit('B');
							Signal ("Close Long");
							end
                            
						 elseif ShowAlert then	
						    if haveTrades('B') then                           
							Signal ("Close Long");
							end                            
							
	    		       end     
			return;
			end
			
			           

						if AllowTrade then
						    if haveTrades('B') then
                            exit('B');
							Signal ("Close Long");
							end
                            enter('S');
							Signal ("Open Short");
						elseif ShowAlert then
                             if haveTrades('B') then                           
							Signal ("Close Long");
							end                            
							Signal ("Open Short");						
	    		       end      
        
		
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
								

--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--

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
    while count == 0 and row ~= nil do
        if row.AccountID == Account and
           row.OfferID == Offer and
           (row.BS == BuySell or BuySell == nil) then
           count = count + 1;
        end
        row = enum:next();
    end

    return count
end


function haveTrades(BuySell) 
    local enum, row;
    local found = false;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while (not found) and (row ~= nil) do
        if row.AccountID == Account and
           row.OfferID == Offer and
           (row.BS == BuySell or BuySell == nil) then
           found = true;
        end
        row = enum:next();
    end

    return found
end

-- enter into the specified direction
function enter(BuySell)
    if not(AllowTrade) then
        return true;
    end

    -- do not enter if position in the
    -- specified direction already exists
    if tradesCount(BuySell) > 0 and not  AllowMultiple  then
        return true;
    end

    local valuemap, success, msg;
    valuemap = core.valuemap();

    valuemap.OrderType = "OM";
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    valuemap.Quantity = Amount * BaseSize;
    valuemap.BuySell = BuySell;

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


    success, msg = terminal:execute(100, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        return false;
    end

    return true;
end

-- exit from the specified direction
function exit(BuySell, use_net)
    if not (AllowTrade) then
        return true
    end

    if use_net == true then
        local valuemap, success, msg
        if tradesCount(BuySell) > 0 then
            valuemap = core.valuemap()

            -- switch the direction since the order must be in oppsite direction
            if BuySell == "B" then
                BuySell = "S"
            else
                BuySell = "B"
            end
            valuemap.OrderType = "CM"
            valuemap.OfferID = Offer
            valuemap.AcctID = Account
            valuemap.NetQtyFlag = "Y"
            valuemap.BuySell = BuySell
            success, msg = terminal:execute(101, valuemap)

            if not(success) then
               terminal:alertMessage(
                   instance.bid:instrument(),
                   instance.bid[instance.bid:size() - 1],
                   "Open order failed"..msg,
                   instance.bid:date(instance.bid:size() - 1)
               )
                return false
            end
            return true
        end
    else
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while row ~= nil do
            if row.BS == BuySell and row.OfferID == Offer then
                local valuemap = core.valuemap();
                valuemap.BuySell = row.BS == "B" and "S" or "B";
                valuemap.OrderType = "CM";
                valuemap.OfferID = row.OfferID;
                valuemap.AcctID = row.AccountID;
                valuemap.TradeID = row.TradeID;
                valuemap.Quantity = row.Lot;
                local success, msg = terminal:execute(101, valuemap);
            end
        row = enum: next();
        end
    end
    return false
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");								