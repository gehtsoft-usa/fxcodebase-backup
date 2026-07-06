-- Id: 4130
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=3833

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+
function Init()
    strategy:name("MTF Stochastic Strategy");
    strategy:description("Signal in generated when All Time Frames Have the same indication");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");

    Parameters (1 , "H1" );
	Parameters (2 , "H4" );
	Parameters (3 , "H8" );
    Parameters (4 , "D1" );
	Parameters (5 , "W1" );
	
	 strategy.parameters:addGroup("Price Parameters");	 
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addString("Period", "Timeframe", "", "m5");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Trading Parameters");
   strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false);   
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
	 strategy.parameters:addBoolean("AllowMultiple", "Allow Multiple Positions in the same direction", "", true);
	 
	 strategy.parameters:addString("SIDE", "Allow Short/Long/Both Positions", "", "BOTH");
    strategy.parameters:addStringAlternative("SIDE", "Both", "", "BOTH");
    strategy.parameters:addStringAlternative("SIDE", "Short", "", "SHORT");
	strategy.parameters:addStringAlternative("SIDE", "Long", "", "LONG");
	 
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

function Parameters (id , FRAME )


  	strategy.parameters:addGroup(id..". STOCHASTIC TIME FRAME");
    strategy.parameters:addInteger("K"..id, "Number of periods for %K", "", 5, 2, 1000);
    strategy.parameters:addInteger("SD"..id, "%D slowing periods", "", 3, 2, 1000);
    strategy.parameters:addInteger("D"..id, "The number of periods for %D.", "", 3, 2, 1000);

    strategy.parameters:addString("KS"..id, "Smoothing type for %K", "", "MVA");
    strategy.parameters:addStringAlternative("KS"..id, "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("KS"..id, "EMA","", "EMA");
    strategy.parameters:addStringAlternative("KS"..id, "MT4","", "MT");
    
    strategy.parameters:addString("DS"..id, "Smoothing type for %D", "", "MVA");
    strategy.parameters:addStringAlternative("DS"..id, "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("DS"..id, "EMA", "", "EMA"); 	
  
    strategy.parameters:addString("B"..id, "Stochastic Time frame", "", FRAME);
    strategy.parameters:setFlag("B"..id, core.FLAG_PERIODS);
end

local first=1;

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


local DS={};
local KS={};
local K={};
local SD={};
local D={};
local stream={};
local Indicator={};
local Flag;

function Prepare(nameOnly)
	
	 local name = profile:id() .. "(" ..  instance.bid:name()  .. ")";
    instance:name(name); 


     if   (nameOnly) then
        return;
    end

	
	SIDE= instance.parameters.SIDE;    
    AllowMultiple= instance.parameters.AllowMultiple;
	
	local i;
    for i= 1, 5, 1 do	
	DS[i]=instance.parameters:getString ("DS"..i);
    KS[i]=instance.parameters:getString ("KS"..i);
    K[i]=instance.parameters:getInteger ("K"..i);
    SD[i]=instance.parameters:getInteger ("SD"..i);
    D[i]=instance.parameters:getInteger ("D"..i);
	end
   
   
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
        Stop = instance.parameters.Stop;
        TrailingStop = instance.parameters.TrailingStop;
    end   
    
	
	
     
	  local i;
	
	for i = 1, 5 , 1 do	 
			stream[i] = ExtSubscribe(i, nil, instance.parameters:getString ("B"..i), instance.parameters.Type == "Bid", "bar");				
			Indicator[i] = core.indicators:create("STOCHASTIC", stream[i], K[i],SD[i],D[i],KS[i],DS[i]);
		first= math.max(first,Indicator[i].DATA:first() );	
	end
		
 
end


-- when tick source is updated
function ExtUpdate(id, source, period)	

     if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
            return ;
        end
    end 
       
	 local i;
	
	local Count=0;
	for i = 1, 5 , 1 do	    
    Indicator[i]:update(core.UpdateLast);
	
		if Indicator[i].DATA:hasData(Indicator[i].DATA:size()-1) and Indicator[i].DATA:hasData(Indicator[i].DATA:size()-2) then
		
			if  Indicator[i].DATA[Indicator[i].DATA:size()-1] >   Indicator[i].DATA[Indicator[i].DATA:size()-2] then
			Count= Count+1;
			elseif Indicator[i].DATA[Indicator[i].DATA:size()-1] <   Indicator[i].DATA[Indicator[i].DATA:size()-2] then
			Count= Count-1;
			end
		
		end
	
    end   
	
	if Count == 5 and Flag~= "Long" then
	Flag= "Long";
	
	        if haveTrades('B')  and not  AllowMultiple then
			                if haveTrades('S') then
                            exit('S');
							Signal ("Close Short");
							end
			return;
			end
			
			if SIDE == "SHORT" then
			                if haveTrades('S') then
                            exit('S');
							Signal ("Close Short");
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
	    		            end     
	
	                       if  ShowAlert and not AllowTrade then
									if haveTrades('S') then                           
									Signal ("Close Short");
									end
								  
									Signal ("Open Long");
						   end
	
	
	
	elseif  Count == -5  and Flag~= "Short" then
	Flag= "Short";
	         if haveTrades('S')  and not  AllowMultiple then
			              if haveTrades('B') then
                            exit('B');
							Signal ("Close Long");
							end
			return;
			end
			
			if SIDE == "LONG" then
			                if haveTrades('B') then
                            exit('B');
							Signal ("Close Long");
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
	    		            end     
							
							 if  ShowAlert and not AllowTrade then
									if haveTrades('B') then                           
									Signal ("Close Long");
									end
								  
									Signal ("Open Short");
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
		
		
		