-- Id: 4048
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=4938

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
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
    strategy:name("FlatTrend Strategy");
    strategy:description("");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert,Account,CanTrade,Email,SendEmail");

    strategy.parameters:addGroup("Price Parameters");
    strategy.parameters:addString("TF", "TF", "Time frame ('t1', 'm1', 'm5', etc.)", "m1");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
	

	
	strategy.parameters:addString("Type", "Bid/Ask", "Bid", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
    
   strategy.parameters:addGroup("MACD Parameters");
	
    strategy.parameters:addInteger("MACD_Fast", "MACD_Fast", "Period for fast MACD", 12);
    strategy.parameters:addInteger("MACD_Slow", "MACD_Slow", "Period for slow MACD", 26);
    strategy.parameters:addInteger("MACD_MA", "MACD_MA", "Period for signal MACD", 9);

Trading_Parameters();
end

-- Parameters block

local gSource = nil; -- the source stream
local first;
--TODO: Add variable(s) for your strategy if needed
local MACD_Fast;
local MACD_Slow;
local MACD_MA;
local MACD;


local SoundFile = nil;
local RecurrentSound = false;
local ALLOWEDSIDE;
local AllowMultiple;
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
-- strategy instance initialization routine
-- Processes strategy parameters and subscribe to price streams
-- TODO: Calculate all constants, create instances all necessary indicators and load all required libraries
function Prepare(nameOnly)
   	
	 MACD_Fast=instance.parameters.MACD_Fast;
    MACD_Slow=instance.parameters.MACD_Slow;
    MACD_MA=instance.parameters.MACD_MA;

    local name;	
    name = profile:id() .. "(" .. instance.bid:instrument();

    
        name = name .. ", " .. instance.parameters.TF .. "(" .. ", " .. MACD_Fast .. "," .. MACD_Slow .. "," .. MACD_MA.. ")";

        assert(instance.parameters.TF ~= "t1", "timeframe must not be tick");
    
    name = name .. ")";
	
	instance:name(name); 
	
	if nameOnly then
        return ;
    end
           

  Initialization();
	
	 --TODO: Find indicator's profile, intialize parameters, and create indicator's instance (if needed)
	
	

	
		gSource= ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "close");

		 MACD = core.indicators:create("MACD", gSource, MACD_Fast, MACD_Slow, MACD_MA);
	
	

   first =MACD.SIGNAL:first();
   
   
    
end


local SIGNAL={};
local FLAG;


-- strategy calculation routine
-- TODO: Add your code for decision making
-- TODO: Update the instance of your indicator(s) if needed
function ExtUpdate(id, source, period)

   
     if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
            return ;
        end
    end
	
	

    if id ~= 1 or period < first +1 then
		return;
	elseif period == first+1 then
	 SIGNAL["Signal"] = nil;
	  SIGNAL["Zero"] = nil;
	end
   
    MACD:update(core.UpdateLast);
	
	
	if   core.crossesOver(MACD.MACD, MACD.SIGNAL, period)   then	  
	  SIGNAL["Signal"] = true;
     elseif core.crossesUnder(MACD.MACD, MACD.SIGNAL, period)   then 
	  SIGNAL["Signal"] = false;
    end
	
	 
	 if   core.crossesOver(MACD.MACD,0, period)   then	  
	  SIGNAL["Zero"] = true;
     elseif core.crossesUnder(MACD.MACD, 0, period)   then 
	  SIGNAL["Zero"] = false;
     end 
		
	if 	SIGNAL["Signal"] == nil or SIGNAL["Zero"] == nil then
    return;
    end

	       if SIGNAL["Signal"] and   SIGNAL["Zero"]  and FLAG~= "B" then
		   
		    FLAG= "B";
				
          			 BUY();
		   
		   
		   elseif not SIGNAL["Signal"] and   not SIGNAL["Zero"] and FLAG~= "S"  then
		    FLAG= "S" ; 
         	  
		                SELL();
					   
			 elseif SIGNAL["Signal"] ~=  SIGNAL["Zero"]   and FLAG~= "N"  then	

			       FLAG = "N"
			 
                     if AllowTrade then  
			                if haveTrades('S') then
                            exit('S');
							Signal ("Close Short");
							end			 
							
							if haveTrades('B') then
                            exit('B');
							Signal ("Close Long");
							end
		            elseif ShowAlert then
					 Signal ("Close Short");
					 Signal ("Close Long");
                    end  					 
		   end
	

	
end





--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--

function BUY()
         
		 if AllowTrade then
						
						       		if haveTrades('B')  and not  AllowMultiple then
											
											exit('S');
											Signal ("Close Short");
											
						               return;
					              	end
						
					             	if ALLOWEDSIDE == "Sell"   then
										if     haveTrades('S')	 then
											exit('S');
											Signal ("Close Short");
										end	
										
						            return;
						              end 
						
								if haveTrades('S') then
								exit('S');
								Signal ("Close Short");
								end
								enter('B');
								Signal ("Open Long");
								
						elseif ShowAlert then
						         Signal ("Up Trend");		  
						end
						
		end   
    
	function SELL ()		
			           if AllowTrade then
						
						       if haveTrades('S')  and not  AllowMultiple then
									
										exit('B');
										Signal ("Close Long");
									
						         return;
						        end
						
						        if ALLOWEDSIDE == "Buy"  then
										if  haveTrades('B') then
										exit('B');
										Signal ("Close Long");
										end
										
						        return;
						        end



							
							if haveTrades('B') then
							exit('B');
							Signal ("Close Long");
							end
							enter('S');
							Signal ("Open Short");																				
						else  
							Signal ("Down Trend");	
						end				 
    
end


function Trading_Parameters()
    strategy.parameters:addGroup("Trading Parameters");
		
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false);
	strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);  
	
	 strategy.parameters:addString("ALLOWEDSIDE", "Allowed side", "Allowed side for trading or signaling, can be Sell, Buy or Both", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell");
	
	 strategy.parameters:addBoolean("AllowMultiple", "Allow Multiple", "", true);
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000);
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
end

function Initialization()

	
	  AllowMultiple =  instance.parameters.AllowMultiple; 
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
    if AllowTrade then
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
		
		
		