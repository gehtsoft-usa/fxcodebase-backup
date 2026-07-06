-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72698

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
    indicator:name("Remove Waiting Orders");
    indicator:description("Remove Waiting Orders");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addString("Account", "Account2Trade", "", "");
    indicator.parameters:setFlag("Account", core.FLAG_ACCOUNT);
	
	
    indicator.parameters:addBoolean("Stop", "Remove Stop Orders", "", true);
    indicator.parameters:addBoolean("Limit", "Remove Limit Orders", "", true);
	indicator.parameters:addBoolean("EntryStop", "Remove Entry Stop Orders", "", true);
	indicator.parameters:addBoolean("EntryLimit", "Remove Entry Limit Orders", "", true);		
	indicator.parameters:addBoolean("Close", "Remove Close Orders", "", true);
	indicator.parameters:addBoolean("Open", "Remove Open Limit Orders", "", true);	
end

local source, period, Account, Offer, CanClose

function Prepare()
   source = instance.source
   Account = instance.parameters.Account;
   Stop = instance.parameters.Stop;
   Limit = instance.parameters.Limit;
   EntryStop = instance.parameters.EntryStop;
   EntryLimit = instance.parameters.EntryLimit;
   Open = instance.parameters.Open;
   Close = instance.parameters.Close;
   Offer = core.host:findTable("offers"):find("Instrument", instance.source:instrument()).OfferID;
   CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.source:instrument(), Account);

   core.host:execute("addCommand", 1001,  "Remove", "");
   
   instance:name(profile:id());
end



function Update(period)
end


function AsyncOperationFinished(cookie, success, message)

   if cookie == 1001 then
      local enum, row;
      enum = core.host:findTable("orders"):enumerator();
      row = enum:next();
      while (row ~= nil) do
         if row.FixStatus == "W"
		 and (
		 
		   ( Stop and row.Type == "S")
		   or (Limit and row.Type == "L")
		   or (EntryStop and row.Type == "SE")
		   or (EntryLimit and row.Type == "LE")
		   or (Open and row.Type == "C")
		   or (Close and row.Type == "O")
		 
		 )
		 then
            local valuemap = core.valuemap();
            valuemap.Command = "DeleteOrder";
            valuemap.OrderID = row.OrderID;
            success, msg = terminal:execute(200, valuemap);
            if not(success) then
				terminal:alertMessage(source:name(), core.now(), "RemoveWaitingOrdersFailed"..msg, core.now())
            end
			
         end
         row = enum:next();
      end
   end

end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

