-- Id: 4028
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=2419

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


function AddMvaParam(id, frame, n)
    strategy.parameters:addGroup("EHLERS CG Parameters" .. id);
    strategy.parameters:addString("B" .. id, "Time frame" .. id, "", frame);
    strategy.parameters:setFlag("B" .. id, core.FLAG_PERIODS);
    strategy.parameters:addInteger("N" .. id, "Periods", "", n);
    strategy.parameters:addString("PriceType" .. id, "Price type" ..id, "", "Bid");
    strategy.parameters:addStringAlternative("PriceType" .. id, "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("PriceType" .. id, "Ask", "", "Ask");
end

function Init()
    local i;

    strategy:name("MTF Ehlers_CG Strategy");
    strategy:description("MTF Ehlers_CG Strategy");
	
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert,Account,CanTrade,Email,SendEmail");

    AddMvaParam(1, "m1", 10);
    AddMvaParam(2, "m5", 10);
    AddMvaParam(3, "m15", 10);
    AddMvaParam(4, "m30", 10);

   
   Trading_Parameters();
   
end

--local price = nil;
local masource = {};
local mva = {};
local first = nil;
local WatchID;

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


local Direction;

local NONE = 0;
local SELL = 1;
local BUY = 2;
local LastSignal = NONE;


function Prepare(onlyName)
    local name;
	
    name = profile:id() .. "(" .. instance.bid:instrument();
	
	assert (core.indicators:findIndicator("EHLERS_CG") ~=  nil, "Download EHLERS CG from FXCODEBASE.COM");

    local i;
    for i = 1, 4 ,1 do
        name = name .. "," ..  instance.parameters:getInteger("N" .. i) .. ")";

        assert(instance.parameters:getString("B" .. i) ~= "t1", "timeframe must not be tick");
    end
    name = name .. ")";

   

    instance:name(name);
    if onlyName then
        return ;
    end

Initialization();

    local minsize = 10000000000000;
    local minindex = -1;
    first = 0;

    for i = 1, 4 ,1 do
        local isource, type, s, e;
        s, e = core.getcandle(instance.parameters:getString("B" .. i), core.now(), 0, 0);
        s = e - s;
        if s < minsize then
            minsize = s;
            minindex = i;
        end

        masource[i] = ExtSubscribe(i, nil, instance.parameters:getString("B" .. i), instance.parameters:getString("PriceType" .. i) == "Bid", "bar");

       
    assert(core.indicators:findIndicator( "EHLERS_CG") ~= nil,  "EHLERS_CG" .. " indicator must be installed");
        mva[i] = core.indicators:create( "EHLERS_CG", masource[i], instance.parameters:getInteger("N" .. i));

        if mva[i].DATA:first() > first then
            first = mva[i].DATA:first();
        end
    end
    first = first + 3;
    assert(minindex >= 1 and minindex <= 4, "error 0001: contact the developer, please");
    WatchID = minindex;
end

function ExtUpdate(id, source, period)

      if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
            return ;
        end
    end 

    local i, pos, neg, mvaperiod;
    if id == WatchID then
        pos = 0;
        neg = 0;
        for i = 1, 4, 1  do
            mva[i]:update(core.UpdateLast);

            -- use most recently closed candle for smallest timeframe
            -- and active candle for other timeframes
            if i == WatchID then
                mvaperiod = period;
            else
                mvaperiod = mva[i].DATA:size() - 1;
            end


            if mvaperiod >= first then
                if mva[i].DATA[mvaperiod] >= mva[i].DATA[mvaperiod - 1] then
                    pos = pos + 1;
                elseif mva[i].DATA[mvaperiod] < mva[i].DATA[mvaperiod - 1] then
                    neg = neg + 1;
                end
            end
        end
		
	        -- replace condition to
        if pos == 4 and LastSignal ~= BUY then
            LastSignal = BUY;
            BUY();
		   
        elseif neg == 4 and LastSignal ~= SELL then
            LastSignal = SELL;
            SELL();
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
		
		
		