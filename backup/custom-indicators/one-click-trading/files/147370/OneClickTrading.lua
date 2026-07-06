-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72701

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("One Click Trading");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addString("Account", "Account2Trade", "", "");
    indicator.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    indicator.parameters:addString("CustomID", "Custom Identifier", "", "TEST");	
	

    Temp={"EUR/USD","EUR/CHF", "EUR/GBP", "EUR/JPY", "EUR/CAD" }	
	
	for i= 1, 5, 1 do
    indicator.parameters:addGroup(i .. ". Slot");	
    indicator.parameters:addBoolean("Trade".. i, "Use This Slot", "", true);		
	
	indicator.parameters:addString("BuySell".. i, "Trade Direction", "Trade Direction" , "B");
    indicator.parameters:addStringAlternative("BuySell".. i, "Buy", "Buy" , "B");
    indicator.parameters:addStringAlternative("BuySell".. i, "Sell", "Sell" , "S");
	
	indicator.parameters:addString("Instrument".. i  , "1. Instrument (Trade on) ", "", Temp[i]);
    indicator.parameters:setFlag("Instrument".. i  , core.FLAG_INSTRUMENTS);	
	indicator.parameters:addInteger("Amount".. i, "Trade Amount (in Lots)", "", 1, 1, 20000);	
    indicator.parameters:addBoolean("SetLimit".. i, "Set Limit Orders", "", false);	
	indicator.parameters:addDouble("Limit".. i, "Limit (in Pips)", "", 30, 1, 20000);	
    indicator.parameters:addBoolean("SetStop".. i, "Set Stop", "", false); 	
	indicator.parameters:addDouble("Stop".. i, "Stop (in Pips)", "", 30, 1, 20000);	
    indicator.parameters:addBoolean("TrailingStop".. i, "Use Trailing Stop", "", false); 
	end
	
end

local source, period, Account 
local CustomID;
local Offer={};
local CanClose={}; 
local BaseSize={};
local BuySell={};
local Amount={};
local Limit={};
local SetStop={};
local Stop={};
local TrailingStop={};
local SetLimit={};
local Instrument={};
local Count=0;
 
function Prepare(nameOnly)

   
   
    instance:name(profile:id() .. "One Click Trading" );   
    if   (nameOnly) then
        return;
    end
	
   source = instance.source
   CustomID = instance.parameters.CustomID;
   Account = instance.parameters.Account;
   Count=0;
 
   for i= 1, 5, 1 do 
	   if instance.parameters:getString("Trade" .. i) then  
		   Count=Count+1;
		   Instrument[Count]=instance.parameters:getString("Instrument" .. i);
		   Offer[Count] = core.host:findTable("offers"):find("Instrument", Instrument[i]).OfferID;
		   CanClose[Count] = core.host:execute("getTradingProperty", "canCreateMarketClose", Instrument[i], Account);
		   BaseSize[Count] = core.host:execute("getTradingProperty", "baseUnitSize", Instrument[i], Account);
		   Amount[Count] =instance.parameters:getInteger("Amount" .. i);
		   BuySell[Count] =instance.parameters:getString("BuySell" .. i);
		   Limit[Count] =instance.parameters:getDouble("Limit" .. i);
		   SetStop[Count] =instance.parameters:getBoolean("SetStop" .. i);
		   Stop[Count] =instance.parameters:getDouble("Stop" .. i);
		   TrailingStop[Count] =instance.parameters:getBoolean("TrailingStop" .. i);
		   SetLimit[Count] =instance.parameters:getBoolean("SetLimit" .. i);
	   end	   
   end
  

   core.host:execute("addCommand", 1001,  "One Click Open", "");
   core.host:execute("addCommand", 1002,  "One Click Close", "");  

end


function Update(period)
end

function AsyncOperationFinished(cookie, success, message)


   if cookie == 1001 then
   OpenAll();   
   end  
   if cookie == 1002 then
   CloseAll();   
   end   
end



function OpenAll()
 
	
    for i = 1, Count , 1 do 
					local valuemap, success, msg;
					valuemap = core.valuemap();
					valuemap.Command = "CreateOrder";
					valuemap.OrderType = "OM";
					valuemap.OfferID = Offer[i];
					valuemap.AcctID = Account;
					valuemap.Quantity = Amount[i] * BaseSize[i];
					valuemap.BuySell = BuySell[i];
					valuemap.CustomID = CustomID;

					-- add stop/limit
					valuemap.PegTypeStop = "O";
					if SetStop[i] then 
						if BuySell[i] == "B" then
							valuemap.PegPriceOffsetPipsStop = -Stop[i];
						else
							valuemap.PegPriceOffsetPipsStop = Stop[i];
						end
					end
					if TrailingStop[i] then
						valuemap.TrailStepStop = 1;
					end

					valuemap.PegTypeLimit = "O";
					if SetLimit[i] then
						if BuySell[i] == "B" then
							valuemap.PegPriceOffsetPipsLimit = Limit[i];
						else
							valuemap.PegPriceOffsetPipsLimit = -Limit[i];
						end
					end

					if (not CanClose[i]) then
						valuemap.EntryLimitStop = 'Y'
					end

					success, msg = terminal:execute(200, valuemap);
                    assert(success, msg);
    end
 
 
end   

function CloseAll()

 
 
--side
-- closes all positions of the specified direction (B for buy, S for sell)
 
    local enum, row, valuemap;

    enum = core.host:findTable("trades"):enumerator();
    while true do
        row = enum:next();
        if row == nil then
            break;
        end
		
		------------------------------------------------------------------------------------------------------------
		for i= 1, Count, 1 do
			if row.AccountID == Account
			and row.OfferID == Offer[i]
			and row.QTXT == CustomID 
			then
				-- if trade has to be closed
               if CanClose[i] then
											-- non-FIFO account, create a close market order
											valuemap = core.valuemap();
											valuemap.OrderType = "CM";
											valuemap.OfferID = Offer[i];
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
											 
							  else
												-- FIFO account, create an opposite market order
												valuemap = core.valuemap();
												valuemap.OrderType = "OM";
												valuemap.OfferID = Offer[i];
												valuemap.AcctID = Account; 
												valuemap.Quantity = row.Lot;
												valuemap.CustomID = CustomID;
												if row.BS == "B" then
													valuemap.BuySell = "S";
												else
													valuemap.BuySell = "B";
												end
												success, msg = terminal:execute(201, valuemap);
                                                assert(success, msg);
												 
							end
							
			end
		end
		------------------------------------------------------------------------------------------------------------
	
    end
end 
 

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

