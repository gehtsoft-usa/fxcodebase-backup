-- Id: 3405
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=3691

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
    strategy:name("4 Stripes Strategy Indicator");
    strategy:description("");
	
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert,Account,CanTrade,Email,SendEmail");

    strategy.parameters:addGroup("Price Parameters");
    strategy.parameters:addString("TF", "TF", "Time frame ('t1', 'm1', 'm5', etc.)", "m1");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
	

	
	strategy.parameters:addString("Type", "Bid/Ask", "Bid", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
    
   strategy.parameters:addGroup("Slow MA of Close Calculation"); 
    strategy.parameters:addInteger("SC", "Slow MA Period of Close", "", 36);
    strategy.parameters:addString("Method_SC", "Method", "", "MVA");
    strategy.parameters:addStringAlternative("Method_SC", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("Method_SC", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("Method_SC", "Wilder", "", "Wilder");
    strategy.parameters:addStringAlternative("Method_SC", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("Method_SC", "SineWMA", "", "SineWMA");
    strategy.parameters:addStringAlternative("Method_SC", "TriMA", "", "TriMA");
    strategy.parameters:addStringAlternative("Method_SC", "LSMA", "", "LSMA");
    strategy.parameters:addStringAlternative("Method_SC", "SMMA", "", "SMMA");
    strategy.parameters:addStringAlternative("Method_SC", "HMA", "", "HMA");
    strategy.parameters:addStringAlternative("Method_SC", "ZeroLagEMA", "", "ZeroLagEMA");
    strategy.parameters:addStringAlternative("Method_SC", "DEMA", "", "DEMA");
    strategy.parameters:addStringAlternative("Method_SC", "T3", "", "T3");
    strategy.parameters:addStringAlternative("Method_SC", "ITrend", "", "ITrend");
    strategy.parameters:addStringAlternative("Method_SC", "Median", "", "Median");
    strategy.parameters:addStringAlternative("Method_SC", "GeoMean", "", "GeoMean");
    strategy.parameters:addStringAlternative("Method_SC", "REMA", "", "REMA");
    strategy.parameters:addStringAlternative("Method_SC", "ILRS", "", "ILRS");
    strategy.parameters:addStringAlternative("Method_SC", "IE/2", "", "IE/2");
    strategy.parameters:addStringAlternative("Method_SC", "TriMAgen", "", "TriMAgen");
    strategy.parameters:addStringAlternative("Method_SC", "JSmooth", "", "JSmooth");	
	
	strategy.parameters:addGroup("Slow MA of High Calculation"); 
    strategy.parameters:addInteger("SH", "Slow MVA Period of High", "Slow MVA Period of High", 36);
	   strategy.parameters:addString("Method_SH", "Method", "", "MVA");
    strategy.parameters:addStringAlternative("Method_SH", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("Method_SH", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("Method_SH", "Wilder", "", "Wilder");
    strategy.parameters:addStringAlternative("Method_SH", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("Method_SH", "SineWMA", "", "SineWMA");
    strategy.parameters:addStringAlternative("Method_SH", "TriMA", "", "TriMA");
    strategy.parameters:addStringAlternative("Method_SH", "LSMA", "", "LSMA");
    strategy.parameters:addStringAlternative("Method_SH", "SMMA", "", "SMMA");
    strategy.parameters:addStringAlternative("Method_SH", "HMA", "", "HMA");
    strategy.parameters:addStringAlternative("Method_SH", "ZeroLagEMA", "", "ZeroLagEMA");
    strategy.parameters:addStringAlternative("Method_SH", "DEMA", "", "DEMA");
    strategy.parameters:addStringAlternative("Method_SH", "T3", "", "T3");
    strategy.parameters:addStringAlternative("Method_SH", "ITrend", "", "ITrend");
    strategy.parameters:addStringAlternative("Method_SH", "Median", "", "Median");
    strategy.parameters:addStringAlternative("Method_SH", "GeoMean", "", "GeoMean");
    strategy.parameters:addStringAlternative("Method_SH", "REMA", "", "REMA");
    strategy.parameters:addStringAlternative("Method_SH", "ILRS", "", "ILRS");
    strategy.parameters:addStringAlternative("Method_SH", "IE/2", "", "IE/2");
    strategy.parameters:addStringAlternative("Method_SH", "TriMAgen", "", "TriMAgen");
    strategy.parameters:addStringAlternative("Method_SH", "JSmooth", "", "JSmooth");	
	
	strategy.parameters:addGroup("Slow MA of Low Calculation"); 
    strategy.parameters:addInteger("SL", "Slow MVA Period of Close", "Slow MVA Period of Close", 36);
		   strategy.parameters:addString("Method_SL", "Method", "", "MVA");
    strategy.parameters:addStringAlternative("Method_SL", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("Method_SL", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("Method_SL", "Wilder", "", "Wilder");
    strategy.parameters:addStringAlternative("Method_SL", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("Method_SL", "SineWMA", "", "SineWMA");
    strategy.parameters:addStringAlternative("Method_SL", "TriMA", "", "TriMA");
    strategy.parameters:addStringAlternative("Method_SL", "LSMA", "", "LSMA");
    strategy.parameters:addStringAlternative("Method_SL", "SMMA", "", "SMMA");
    strategy.parameters:addStringAlternative("Method_SL", "HMA", "", "HMA");
    strategy.parameters:addStringAlternative("Method_SL", "ZeroLagEMA", "", "ZeroLagEMA");
    strategy.parameters:addStringAlternative("Method_SL", "DEMA", "", "DEMA");
    strategy.parameters:addStringAlternative("Method_SL", "T3", "", "T3");
    strategy.parameters:addStringAlternative("Method_SL", "ITrend", "", "ITrend");
    strategy.parameters:addStringAlternative("Method_SL", "Median", "", "Median");
    strategy.parameters:addStringAlternative("Method_SL", "GeoMean", "", "GeoMean");
    strategy.parameters:addStringAlternative("Method_SL", "REMA", "", "REMA");
    strategy.parameters:addStringAlternative("Method_SL", "ILRS", "", "ILRS");
    strategy.parameters:addStringAlternative("Method_SL", "IE/2", "", "IE/2");
    strategy.parameters:addStringAlternative("Method_SL", "TriMAgen", "", "TriMAgen");
    strategy.parameters:addStringAlternative("Method_SL", "JSmooth", "", "JSmooth");
	
	
	strategy.parameters:addGroup("Fast MA of Close Calculation"); 
    strategy.parameters:addInteger("FC", "Fast MVA Period of Close", "Fast MVA Period of Close", 12);
		   strategy.parameters:addString("Method_FC", "Method", "", "MVA");
    strategy.parameters:addStringAlternative("Method_FC", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("Method_FC", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("Method_FC", "Wilder", "", "Wilder");
    strategy.parameters:addStringAlternative("Method_FC", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("Method_FC", "SineWMA", "", "SineWMA");
    strategy.parameters:addStringAlternative("Method_FC", "TriMA", "", "TriMA");
    strategy.parameters:addStringAlternative("Method_FC", "LSMA", "", "LSMA");
    strategy.parameters:addStringAlternative("Method_FC", "SMMA", "", "SMMA");
    strategy.parameters:addStringAlternative("Method_FC", "HMA", "", "HMA");
    strategy.parameters:addStringAlternative("Method_FC", "ZeroLagEMA", "", "ZeroLagEMA");
    strategy.parameters:addStringAlternative("Method_FC", "DEMA", "", "DEMA");
    strategy.parameters:addStringAlternative("Method_FC", "T3", "", "T3");
    strategy.parameters:addStringAlternative("Method_FC", "ITrend", "", "ITrend");
    strategy.parameters:addStringAlternative("Method_FC", "Median", "", "Median");
    strategy.parameters:addStringAlternative("Method_FC", "GeoMean", "", "GeoMean");
    strategy.parameters:addStringAlternative("Method_FC", "REMA", "", "REMA");
    strategy.parameters:addStringAlternative("Method_FC", "ILRS", "", "ILRS");
    strategy.parameters:addStringAlternative("Method_FC", "IE/2", "", "IE/2");
    strategy.parameters:addStringAlternative("Method_FC", "TriMAgen", "", "TriMAgen");
    strategy.parameters:addStringAlternative("Method_FC", "JSmooth", "", "JSmooth");

    Trading_Parameters();
end

-- Parameters block

local gSource = nil; -- the source stream
--TODO: Add variable(s) for your strategy if needed
local SlowClose = nil;
local SlowLow = nil;
local SlowHigh = nil;
local FastClose = nil;

local SC;
local SH;
local SL;
local FC;

local   Method_SC;
local	Method_SH;
local	Method_SL;
local	Method_FC;

local indicator={};

local first=1;

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
   	
	SC = instance.parameters.SC;
    SH = instance.parameters.SH;
    SL = instance.parameters.SL;
    FC = instance.parameters.FC;
	
	 Method_SC= instance.parameters.Method_SC;
	Method_SH= instance.parameters.Method_SH;
	Method_SL= instance.parameters.Method_SL;
	Method_FC= instance.parameters.Method_FC;
	
	
	Method_SC= instance.parameters.Method_SC;
	Method_SH= instance.parameters.Method_SH;
	Method_SL= instance.parameters.Method_SL;
	Method_FC= instance.parameters.Method_FC;
	
	
	
    local name = profile:id() .. "(" .. instance.bid:instrument() .. ")";
    instance:name(name);

    if nameOnly then
        return ;
    end
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");

	
        assert(instance.parameters.TF ~= "t1", "The strategy cannot be applied on ticks.");
    

   Initialization();
	
	 --TODO: Find indicator's profile, intialize parameters, and create indicator's instance (if needed)
	

	
    gSource = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar"); 
	
	indicator["SC"]  = core.indicators:create("AVERAGES", gSource.close, Method_SC, SC, false);
	first = math.max(first,indicator["SC"].DATA:first());
	
	indicator["SL"]  = core.indicators:create("AVERAGES", gSource.close, Method_SL, SL, false);
    first = math.max(first,indicator["SL"].DATA:first());	
	
	indicator["SH"]  = core.indicators:create("AVERAGES", gSource.close, Method_SH, SH, false);
	first = math.max(first,indicator["SH"].DATA:first());
	
	indicator["FC"]  = core.indicators:create("AVERAGES", gSource.close, Method_FC, FC, false);
	first = math.max(first,indicator["FC"].DATA:first());	
 
     
   
    
end

-- strategy calculation routine
-- TODO: Add your code for decision making
-- TODO: Update the instance of your indicator(s) if needed
function ExtUpdate(id, source, period)
   
    if  period <  first +1  or id ~= 1 then 
	return;
	end 
	
	if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
            return ;
        end
    end
	
	    indicator["SC"]:update(core.UpdateLast);
	    indicator["SL"]:update(core.UpdateLast);
		indicator["SH"]:update(core.UpdateLast);
		indicator["FC"]:update(core.UpdateLast);
	        
	if not indicator["SC"].DATA:hasData(period-1) or not indicator["SL"].DATA:hasData(period-1)  then 
	return;
	end
	
	if   not indicator["SH"].DATA:hasData(period-1) or not indicator["FC"].DATA:hasData(period-1)  then 
	return;
	end
		

		    if core.crossesOver( indicator["FC"].DATA, indicator["SH"].DATA  , period) then 
			
			if haveTrades('B')  and not  AllowMultiple then
			return;
			end
			
			if SIDE == "SHORT" then
			return;
			end
			
			   
	                     if ShowAlert then
							terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Enter Long", instance.bid:date(NOW));
						end
						if SoundFile ~= nil then
							terminal:alertSound(SoundFile, RecurrentSound);
						end
						
						if Email ~= nil then
						 terminal:alertEmail(Email, "Enter Long", profile:id() .. "(" .. instance.bid:instrument() .. ")" .. instance.bid[NOW]..", " .. "Enter Long"..", " .. instance.bid:date(NOW));
						end

						if AllowTrade then
						    if haveTrades('S') then
                            exit('S');
							end
                            enter('B');
	    		       end     
         
		   elseif core.crossesUnder( indicator["FC"].DATA, indicator["SL"].DATA , period) then 
		   
		    if haveTrades('S')  and not  AllowMultiple then
			return;
			end
			
			if SIDE == "LONG" then
			return;
			end
			
			              if ShowAlert then
							terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Enter Short", instance.bid:date(NOW));
						end
						if SoundFile ~= nil then
							terminal:alertSound(SoundFile, RecurrentSound);
						end
						
						if Email ~= nil then
						 terminal:alertEmail(Email, "Enter Short", profile:id() .. "(" .. instance.bid:instrument() .. ")" ..", " .. instance.bid[NOW]..", " .. "Enter Short"..", " .. instance.bid:date(NOW));
						end

						if AllowTrade then
						    if haveTrades('B') then
                            exit('B');
							end
                            enter('S');
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
		
		
		