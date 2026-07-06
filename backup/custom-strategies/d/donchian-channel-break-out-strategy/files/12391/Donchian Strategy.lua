-- Id: 4247
--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
 
function Init()
    strategy:name("Donchian Channel Break Out strategy");
    strategy:description("Donchian Channel Break Out strategy");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");

    strategy.parameters:addGroup("Price Parameters");
    strategy.parameters:addString("TF", "TF", "Time frame ('t1', 'm1', 'm5', etc.)", "m1");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
	
	strategy.parameters:addBoolean("AllowTicks", "Allow Ticks", "", false);
	
	strategy.parameters:addString("Type", "Bid/Ask", "Bid", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
    
    strategy.parameters:addGroup("Parameters");
	strategy.parameters:addInteger("Frame", "Donchian Channel Period", "", 55, 2, 10000);
	strategy.parameters:addInteger("STOPFrame", "Stop Donchian Channel Period", "", 20, 2, 10000);
	strategy.parameters:addBoolean("EXIT", "Exit on Central Line Crossover", "", true);
	strategy.parameters:addBoolean("BREAK", "Enter on Break Out", "", true);
	strategy.parameters:addBoolean("CROSS", "Enter on Central Line Crossover", "", true);
	strategy.parameters:addBoolean("STOPEXIT", "Use Stop Exit", "", true);
	

	Trading_Parameters();
end

-- ===============================================================
-- Function initializes trading parameters 
-- ===============================================================
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


-- Parameters block
local STOPEXIT;
local STOPFrame;
local CROSS;
local EXIT;
local BREAK;
local gSource = nil; -- the source stream



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


--TODO: Add variable(s) for your strategy if needed
local Frame;


-- strategy instance initialization routine
-- Processes strategy parameters and subscribe to price streams
-- TODO: Calculate all constants, create instances all necessary indicators and load all required libraries
function Prepare(nameOnly)
    STOPEXIT= instance.parameters.STOPEXIT
    STOPFrame= instance.parameters.STOPFrame;
    CROSS= instance.parameters.CROSS;
    BREAK= instance.parameters.BREAK;
    EXIT= instance.parameters.EXIT;
    Frame= instance.parameters.Frame;
    
    local name = profile:id() .. "(" .. instance.bid:instrument() .. ")";
    instance:name(name);

    if nameOnly then
        return ;
    end

	local AllowTicks;
    AllowTicks = instance.parameters.AllowTicks;
    if (not(AllowTicks)) then
        assert(instance.parameters.TF ~= "t1", "The strategy cannot be applied on ticks.");
    end

    
	Initialization();
	 --TODO: Find indicator's profile, intialize parameters, and create indicator's instance (if needed)
	

	
    gSource = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar"); 

    
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

function ALLOWEDBUY()  return ALLOWEDSIDE == "Buy" or ALLOWEDSIDE == "Both" end
function ALLOWEDSELL() return ALLOWEDSIDE == "Sell" or ALLOWEDSIDE == "Both" end

-- strategy calculation routine
-- TODO: Add your code for decision making
-- TODO: Update the instance of your indicator(s) if needed
function ExtUpdate(id, source, period)
   
    if  period < Frame+1 or id ~= 1 then 
	return;
	end 
	
	if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
            return ;
        end
    end
	

    local min, max, mid;
    min, max = core.minmax(gSource, core.range(period-Frame, period-1));  
    mid = min+(max -min)/2;
		
    --==========--
    -- STOPEXIT	--
    --==========--
    if STOPEXIT then
		local min2, max2, mid2;
		min2, max2 = core.minmax(gSource, core.range(period-STOPFrame, period-1));  
		mid2 = min2+(max2 -min2)/2;
		
        if core.crossesUnder( gSource.close, min2, period) and  haveTrades('B')  then  

            Signal('Exit Long');
            exit('B');                          
			 
		end
			 
		if core.crossesOver( gSource.close, max2, period) and  haveTrades('S') then 
            Signal('Exit Short');
            exit('S');                          
        end 
	end
 		
    --=======--
    -- CROSS --
    --=======--
        if CROSS then
            if core.crossesOver( gSource.close, mid , period) then 
                 
                if AllowTrade and ALLOWEDBUY() then
                        
                        -- Condition below should just 'return'
                        if haveTrades('B')  and not  AllowMultiple then
                            exit('S');
                            Signal ("Close Short");
                            return;
                        end
            
                        _ = [==[
                        if ALLOWEDSIDE == "Sell"  then
                            if haveTrades('S') then
                                exit('S');
                                Signal ("Close Short");
                            end
                            
                            return;
                        end 
                        ]==]
            
                    if haveTrades('S') then
                        exit('S');
                        Signal ("Close Short");
                    end
                    enter('B');
                    Signal ("Open Long");
                        
                elseif ShowAlert then
                         Signal ("Up Trend");         
                end
         
           elseif core.crossesUnder( gSource.close, mid , period) then 
            
                      if AllowTrade and ALLOWEDSELL() then
                        
                                -- Condition below should just 'return'
                               if haveTrades('S')  and not  AllowMultiple then
                                    
                                        exit('B');
                                        Signal ("Close Long");
                                    
                                 return;
                                end
                        
                                _ = [==[
                                if ALLOWEDSIDE == "Buy" then
                                    if  haveTrades('B') then
                                        exit('B');
                                        Signal ("Close Long");
                                        end
                                    return;
                                end
                                ]==]
                            
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
        
        end
        
        --================--
        -- EXIT and CROSS --
        --================--
        if EXIT and not CROSS  then
            
             if core.crossesUnder( gSource.close, mid, period) and  haveTrades('B')  then  
                       if ShowAlert then
                            terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Exit Long", instance.bid:date(NOW));
                        end
                        if SoundFile ~= nil then
							terminal:alertSound(SoundFile, RecurrentSound);
						end
						
						if Email ~= nil then
						 terminal:alertEmail(Email, "Exit Long", profile:id() .. "(" .. instance.bid:instrument() .. ")" ..", " ..instance.bid:instrument()..", " .. instance.bid[NOW]..", " .. "Exit Long"..", " .. instance.bid:date(NOW));
						end

						if AllowTrade then
                            exit('B');                          
	    		       end     
			 
			 end
			 
			  if core.crossesOver( gSource.close, mid, period) and  haveTrades('S') then 
			
			 
			              if ShowAlert then
							terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Exit Short", instance.bid:date(NOW));
						end
						if SoundFile ~= nil then
							terminal:alertSound(SoundFile, RecurrentSound);
						end
						
						if Email ~= nil then
						 terminal:alertEmail(Email, "Exit Short", profile:id() .. "(" .. instance.bid:instrument() .. ")" ..", " ..instance.bid:instrument()..", " .. instance.bid[NOW]..", " .. "Exit Short"..", " .. instance.bid:date(NOW));
						end

						if AllowTrade then
                            exit('S');                           
	    		       end      
			 end 
		end 
	
		if BREAK then
			
			if core.crossesOver( gSource.close, max , period) then 
	                   
					   
					   if AllowTrade and ALLOWEDBUY() then
						
						       		if haveTrades('B')  and not  AllowMultiple then
											
											exit('S');
											Signal ("Close Short");
											
						               return;
					              	end
						
					             	_ = [==[
                                    if ALLOWEDSIDE == "Sell"  then
											 if   haveTrades('S') then
											exit('S');
											Signal ("Close Short");
											end
										
						            return;
						              end 
                                    ]==]
						
								if haveTrades('S') then
								exit('S');
								Signal ("Close Short");
								end
								enter('B');
								Signal ("Open Long");
								
						elseif ShowAlert then
						         Signal ("Up Trend");		  
						end
						
         
		   elseif core.crossesUnder( gSource.close, min , period) then 
			
			            if AllowTrade and ALLOWEDSELL() then
						
						       if haveTrades('S')  and not  AllowMultiple then
									
										exit('B');
										Signal ("Close Long");
									
						         return;
						        end
						
                                _ = [==[
						        if ALLOWEDSIDE == "Buy"  then
										if  haveTrades('B') then										
										exit('B');
										Signal ("Close Long");
										end
										
						        return;
						        end
                                ]==]

							
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
        end 
end



--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--

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
		
		
		