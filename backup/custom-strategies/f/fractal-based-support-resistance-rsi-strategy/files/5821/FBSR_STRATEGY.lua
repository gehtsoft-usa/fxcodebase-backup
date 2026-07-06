-- Id: 2219
--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

function Init()
    strategy:name("FBSR Strategy");
    strategy:description("FBSR Strategy");	
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");
	 
   strategy.parameters:addGroup("RSI Parameters");
   strategy.parameters:addInteger("Frame", "RSI Period", "", 8, 2, 1000);
   strategy.parameters:addInteger("OVRB", "Overbought level", "", 60, 2, 100);
   strategy.parameters:addInteger("OVRS", "Oversold level", "", 40, 2, 100);
   
   
    strategy.parameters:addInteger("PIN" , "RSI Price Type", "", 4);
    strategy.parameters:addIntegerAlternative("PIN" , "Open", "", 1);
    strategy.parameters:addIntegerAlternative("PIN", "High", "", 2);
    strategy.parameters:addIntegerAlternative("PIN" , "Low", "", 3);
   strategy.parameters:addIntegerAlternative("PIN" , "Close", "", 4);
   strategy.parameters:addIntegerAlternative("PIN", "Median", "", 5);
    strategy.parameters:addIntegerAlternative("PIN" , "Typical", "", 6);
   strategy.parameters:addIntegerAlternative("PIN" , "Weighted ", "", 7);      
   
   strategy.parameters:addString("Type", "RSU Filter Type", "", "Central");
	 strategy.parameters:addStringAlternative("Type", "Central Line", "", "Central");
     strategy.parameters:addStringAlternative("Type", "Overbought/Oversold", "", "Over");
  
   strategy.parameters:addGroup("Strategy Time Frame");
   strategy.parameters:addString("TF", "Time Frame", "", "m15");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);

 Trading_Parameters();
end

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

local barsource = nil;
local name;

local PRICE;
local PIN;
local Frame;
local RSI;
local OVRB;
local OVRS;
local FBSR;
local Type;
local Test;

local first;

function Prepare(onlyName)

    assert(core.indicators:findIndicator("FBSR") ~= nil, "Please download and install  FBSR Indicator!");
   Type = instance.parameters.Type; 
   Test = instance.parameters.Test; 
    OVRB = instance.parameters.OVRB;
    OVRS = instance.parameters.OVRS;
    Frame = instance.parameters.Frame;
    PIN = instance.parameters.PIN;
   
     
Initialization();

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");
    
    name = profile:id() .. "(" .. "FBSR(" .. instance.bid:name() .. "." .. instance.parameters.TF .. ", "..instance.parameters.Frame .."," ..Type.. ")";
 

    instance:name(name);

    if onlyName then
        return ;
    end

	first=1;
	
    barsource = ExtSubscribe(1, nil, instance.parameters.TF, true, "bar");
   
       if PIN == 1 then
      PRICE = barsource.open;      
      elseif PIN==2 then
      PRICE = barsource.high;   
      elseif PIN==3 then
      PRICE = barsource.low;   
      elseif PIN==4 then
      PRICE = barsource.close;   
      elseif PIN==5 then
      PRICE = barsource.median;   
      elseif PIN==6 then
      PRICE = barsource.typical;   
      elseif PIN==7 then
      PRICE = barsource.weighted;   
      end
      
       RSI=core.indicators:create("RSI", PRICE, Frame);   
        FBSR=core.indicators:create("FBSR", barsource); 
		
		 first=math.max(first, RSI.DATA:first(),FBSR.DATA:first());
		
	if Type== "Central" then
	OVRB=50;
	OVRS=50;
	end

end

function ExtUpdate(id, source, period)

  if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
            return ;
        end
    end
   
   if id == 1 and period > 1 then
   
       RSI:update(core.UpdateLast); 
      if  not RSI.DATA:hasData(period) or not RSI.DATA:hasData(period-1) then
        return;
        end    
         
      FBSR:update(core.UpdateLast);
      if  not FBSR.R:hasData(period) and  not FBSR.S:hasData(period) then
        return;
        end 
      if  not FBSR.R:hasData(period-1) and  not FBSR.S:hasData(period-1) then
        return;
        end       
      
      if   FBSR.R[period] ~= FBSR.R[period-1] then
        return;
        end 
      if  FBSR.S[period] ~= FBSR.S[period-1] then
        return;
        end 
      
      if Test then
              if  core.crossesOver(barsource.close, FBSR.R,   period) and RSI.DATA[period] > OVRB then
            BUY();
            elseif  core.crossesUnder(barsource.close, FBSR.S,   period) and RSI.DATA[period] < OVRS then
            SELL();       
            end
            
            if EXIT then
            end
      else
            if  core.crossesOver(barsource.close, FBSR.R,   period) then
            BUY();
            elseif  core.crossesUnder(barsource.close, FBSR.S,   period) then
            SELL();
            end
      end
           
   end       
end

local NOTE;




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
		
		
		