-- Id: 16591
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=63785

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




function AddLong(id, LevelFlag)

	strategy.parameters:addDouble("LevelLong"..id, "Level", "",LevelFlag);

end

function AddShort(id, LevelFlag)

	strategy.parameters:addDouble("LevelShort"..id, "Level", "",LevelFlag);

end

function Init() --The strategy profile initialization
    strategy:name("Highly adaptable Multiple CCI Strategy");
    strategy:description("");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");
	
	strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
	
	strategy.parameters:addString("TF", "Time frame", "", "H1");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);


    strategy.parameters:addGroup("Calculation");
    strategy.parameters:addInteger("Period1", "1. Period", "", 8);
    strategy.parameters:addInteger("Period2", "2. Period", "", 10);
	strategy.parameters:addInteger("Period3", "3. Period", "", 12);
	strategy.parameters:addInteger("Period4", "4. Period", "", 6);
	strategy.parameters:addInteger("Period5", "5. Period", "", 14);
	
	
	strategy.parameters:addGroup("Long Level Selector");
    AddLong(1, 0);
	AddLong(2, 0);
	AddLong(3, 0);
	AddLong(4, 0);
	AddLong(5, 0);
	
    strategy.parameters:addGroup("Short Level Selector");
	AddShort(1, 0);
	AddShort(2, 0);
	AddShort(3, 0);
	AddShort(4, 0);
	AddShort(5, 0);
	
	strategy.parameters:addGroup("Long Level Cross Selector");
	
	strategy.parameters:addString("Action".. 1, "1. Line / Long Level Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 1, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 1, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 1, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 1, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 1, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 2, "1. Line / Long Level Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 2, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 2, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 2, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 2, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 2, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 3, "1. Line / Long Level Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 3, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 3, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 3, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 3, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 3, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 4, "1. Line / Long Level Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 4, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 4, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 4, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 4, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 4, "Alert", "", "Alert");
	
	
	strategy.parameters:addString("Action".. 5, "2. Line / Long Level Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 5, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 5, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 5, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 5, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 5, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 6, "2. Line / Long Level Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 6, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 6, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 6, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 6, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 6, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 7, "2. Line / Long Level Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 7, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 7, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 7, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 7, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 7, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 8, "2. Line / Long Level Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 8, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 8, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 8, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 8, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 8, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 9, "3. Line / Long Level Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 9, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 9, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 9, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 9, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 9, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 10, "3. Line / Long Level Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 10, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 10, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 10, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 10, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 10, "Alert", "", "Alert");
	
    strategy.parameters:addString("Action".. 11, "3. Line / Long Level Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 11, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 11, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 11, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 11, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 11, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 12, "3. Line / Long Level Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 12, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 12, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 12, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 12, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 12, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 13, "4. Line / Long Level Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 13, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 13, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 13, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 13, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 13, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 14, "4. Line / Long Level Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 14, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 14, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 14, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 14, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 14, "Alert", "", "Alert");
	
	
	
		strategy.parameters:addString("Action".. 15, "4. Line / Long Level Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 15, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 15, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 15, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 15, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 15, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 16, "4. Line / Long Level Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 16, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 16, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 16, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 16, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 16, "Alert", "", "Alert");
	
    strategy.parameters:addString("Action".. 17, "5. Line / Long Level Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 17, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 17, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 17, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 17, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 17, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 18, "5. Line / Long Level  Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 18, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 18, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 18, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 18, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 18, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 19, "5. Line / Long Level Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 19, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 19, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 19, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 19, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 19, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 20, "5. Line / Long Level Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 20, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 20, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 20, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 20, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 20, "Alert", "", "Alert");
	
	strategy.parameters:addGroup("Short Level Cross Selector");
	
	strategy.parameters:addString("Action".. 21, "1. Line / Short Level Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 21, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 21, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 21, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 21, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 21, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 22, "1. Line / Short Level Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 22, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 22, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 22, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 22, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 22, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 23, "1. Line / Short Level Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 23, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 23, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 23, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 23, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 23, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 24, "1. Line / Short Level Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 24, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 24, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 24, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 24, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 24, "Alert", "", "Alert");
	
	
	strategy.parameters:addString("Action".. 25, "2. Line / Short Level Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 25, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 25, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 25, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 25, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 25, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 26, "2. Line / Short Level Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 26, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 26, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 26, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 26, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 26, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 27, "2. Line / Short Level Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 27, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 27, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 27, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 27, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 27, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 28, "2. Line / Short Level Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 28, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 28, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 28, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 28, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 28, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 29, "3. Line / Short Level Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 29, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 29, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 29, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 29, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 29, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 30, "3. Line / Short Level Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 30, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 30, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 30, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 30, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 30, "Alert", "", "Alert");
	
    strategy.parameters:addString("Action".. 31, "3. Line / Short Level Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 31, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 31, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 31, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 31, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 31, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 32, "3. Line / Short Level Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 32, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 32, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 32, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 32, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 32, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 33, "4. Line / Short Level Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 33, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 33, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 33, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 33, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 33, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 34, "4. Line / Short Level Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 34, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 34, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 34, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 34, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 34, "Alert", "", "Alert");
	
	
	
		strategy.parameters:addString("Action".. 35, "4. Line / Short Level Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 35, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 35, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 35, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 35, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 35, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 36, "4. Line / Short Level Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 36, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 36, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 36, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 36, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 36, "Alert", "", "Alert");
	
    strategy.parameters:addString("Action".. 37, "5. Line / Short Level Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 37, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 37, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 37, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 37, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 37, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 38, "5. Line / Short Level  Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 38, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 38, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 38, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 38, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 38, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 39, "5. Line / Short Level Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 39, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 39, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 39, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 39, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 39, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 40, "5. Line / Short Level Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 40, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 40, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 40, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 40, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 40, "Alert", "", "Alert");

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
    strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "HAMCS2");
	
	strategy.parameters:addInteger("MaxNumberOfPositionInAnyDirection", "Max Number Of Open Position In Any Direction", "", 2, 1, 100);
	strategy.parameters:addInteger("MaxNumberOfPosition", "Max Number Of Position In One Direction", "", 1, 1, 100);
    	
    strategy.parameters:addString("ALLOWEDSIDE", "Allowed side", "Allowed side for trading or signaling, can be Sell, Buy or Both", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell");
	
	--strategy.parameters:addString("Direction", "Type of Signal / Trade", "", "direct");
   -- strategy.parameters:addStringAlternative("Direction", "Direct", "", "direct");
    --strategy.parameters:addStringAlternative("Direction", "Reverse", "", "reverse");

    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000);
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false);
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false);
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false);
  --  strategy.parameters:addBoolean("Exit", "Use Optional Exit", "", true);
	
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
local Period={};
local Indicator={};
local Short={};
--local Direction;
local CustomID;
local SignalLong={};
local SignalShort={};
local LevelLong={};
local LevelShort={};

local Action={};

	
local OpenTime, CloseTime, ExitTime;
local ValidInterval,UseMandatoryClosing;
local ToTime;
--
function Prepare( nameOnly)
   	CustomID = instance.parameters.CustomID;
	
    local name = profile:id() .. "( " .. instance.bid:name() .. "," .. CustomID ..  " )";
    instance:name(name); 

    if nameOnly then
        return ;
    end
	
	
	ExecutionType = instance.parameters.ExecutionType;
    CloseOnOpposite = instance.parameters.CloseOnOpposite;
	MaxNumberOfPositionInAnyDirection = instance.parameters.MaxNumberOfPositionInAnyDirection;
	MaxNumberOfPosition = instance.parameters.MaxNumberOfPosition;
	--Direction = instance.parameters.Direction == "direct";
	 
	
	for i=1, 5 , 1 do
	Period[i]= instance.parameters:getInteger("Period" .. i);
    SignalLong[i]= instance.parameters:getString("SignalLong" .. i);
    SignalShort[i]= instance.parameters:getString("SignalShort" .. i)
	LevelLong[i]= instance.parameters:getDouble("LevelLong" .. i)
    LevelShort[i]= instance.parameters:getDouble("LevelShort" .. i)
	end
	
	for i = 1, 40 , 1 do 
	Action[i]= instance.parameters:getString ("Action" .. i);
	end

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");
 
   
    PrepareTrading();

   
 
	
	if ExecutionType== "Live" then
	TickSource = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close");
	end
	
    Source = ExtSubscribe(2, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar");
	first=Source.close:first(); 
	for i=1, 5 , 1 do
    Indicator[i] = core.indicators:create("CCI", Source, Period[i]  ); 
	first=Indicator[i].DATA:first(); 
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
function ParseTime(time)
    local Pos = string.find(time, ":");
    if Pos == nil then
        return nil, false;
    end
    local h = tonumber(string.sub(time, 1, Pos - 1));
    time = string.sub(time, Pos + 1);
    Pos = string.find(time, ":");
    if Pos == nil then
        return nil, false;
    end
    local m = tonumber(string.sub(time, 1, Pos - 1));
    local s = tonumber(string.sub(time, Pos + 1));
    return (h / 24.0 +  m / 1440.0 + s / 86400.0),                          -- time in ole format
           ((h >= 0 and h < 24 and m >= 0 and m < 60 and s >= 0 and s < 60) or (h == 24 and m == 0 and s == 0)); -- validity flag
end

function InRange(now, openTime, closeTime)
    if openTime < closeTime then
        return now >= openTime and now <= closeTime;
    end
    if openTime > closeTime then
        return now > openTime or now < closeTime;
    end

    return now == openTime;
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
	
	
	if  period < 0
	then
        return;
    end
	
	
	if  ExecutionType ==  "Live" and  id == 1 then
			
			period= core.findDate (Source.close, TickSource:date(period), false );		
					
	end
	 
	
	if period <0 
	then
        return;
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
	for i=1, 5 , 1 do
    Indicator[i]:update(core.UpdateLast);
	end

	if period < first  then
        return;
    end
	
    
 
    if   Indicator[1].DATA[period] > LevelLong[1]  then
	ACTION(1 ,SignalLong[1], period);
	end
	if    Indicator[1].DATA[period] < LevelLong[1] 	then	
	ACTION(2 ,SignalLong[1], period);
	end
	
	if   Indicator[1].DATA[period] > LevelLong[1] and   Indicator[1].DATA[period-1] <= LevelLong[1] then
	ACTION(3 ,SignalLong[1], period);
	end
	
	if   Indicator[1].DATA[period] < LevelLong[1] and   Indicator[1].DATA[period-1] >= LevelLong[1]  	then
	ACTION(4 ,SignalLong[1], period);
	end
	 
	
	if   Indicator[2].DATA[period] > LevelLong[2] then
	ACTION(5 ,SignalLong[2], period);
	end
	
	if   Indicator[2].DATA[period] < LevelLong[2] then
	ACTION(6 ,SignalLong[2], period);
	end
	
	if   Indicator[2].DATA[period] > LevelLong[2] and   Indicator[2].DATA[period-1] <= LevelLong[2] then
	ACTION(7 ,SignalLong[2], period);
	end
	
	if   Indicator[2].DATA[period] < LevelLong[2] and   Indicator[2].DATA[period-1] >= LevelLong[2]  then
	ACTION(8 ,SignalLong[2], period);
	end
	
	 
	
	if   Indicator[3].DATA[period] > LevelLong[3] then
	ACTION(9 ,SignalLong[3], period);
	end
	
	if   Indicator[3].DATA[period] < LevelLong[3] then
	ACTION(10 ,SignalLong[3], period);
	end
	
	
	if   Indicator[3].DATA[period] > LevelLong[3] and   Indicator[3].DATA[period-1] <= LevelLong[3] then
	ACTION(11 ,SignalLong[3], period);
	end
	
	if   Indicator[3].DATA[period] < LevelLong[3] and   Indicator[3].DATA[period-1] >= LevelLong[3]  then
	ACTION(12 ,SignalLong[3], period);
	end
	
	 
	
	if   Indicator[4].DATA[period] > LevelLong[4] then
	ACTION(13 ,SignalLong[4], period);
	end
	
	if   Indicator[4].DATA[period] < LevelLong[4] then
	ACTION(14 ,SignalLong[4], period);
	end
	
	if   Indicator[4].DATA[period] > LevelLong[4] and   Indicator[4].DATA[period-1] <= LevelLong[4] then
	ACTION(15 ,SignalLong[4], period);
	end
	
	
	if   Indicator[4].DATA[period] < LevelLong[4] and   Indicator[4].DATA[period-1] >= LevelLong[4] then
	ACTION(16 ,SignalLong[4], period);
	end
	
	
	if   Indicator[5].DATA[period] > LevelLong[5] then
	ACTION(17 ,SignalLong[5], period);
	end
	
	if   Indicator[5].DATA[period] < LevelLong[5] then
	ACTION(18 ,SignalLong[5], period);
	end
	
	
	if   Indicator[5].DATA[period] > LevelLong[5] and   Indicator[5].DATA[period-1] <= LevelLong[5] then
	ACTION(19 ,SignalLong[5], period);
	end
	
	if   Indicator[5].DATA[period] < LevelLong[5] and   Indicator[5].DATA[period-1] >= LevelLong[5]  then
	ACTION(20 ,SignalLong[5], period);
	end
	 
	 
	 
	 
    if   Indicator[1].DATA[period] > LevelShort[1] then
	ACTION(21 ,SignalShort[1], period);
	end
		
	if   Indicator[1].DATA[period] < LevelShort[1] then
	ACTION(22 ,SignalShort[1], period);
	end
	
	if   Indicator[1].DATA[period] > LevelShort[1] and   Indicator[1].DATA[period-1] <= LevelShort[1] then
	ACTION(23 ,SignalShort[1], period);
	end
	
	if   Indicator[1].DATA[period] < LevelShort[1] and   Indicator[1].DATA[period-1] >= LevelShort[1]  then
	ACTION(24 ,SignalShort[1], period);
	end
	
	
	if   Indicator[2].DATA[period] > LevelShort[2] then
	ACTION(25 ,SignalShort[2], period);
	end
	
	if   Indicator[2].DATA[period] < LevelShort[2]  then
	ACTION(26 ,SignalShort[2], period);
	end
	
	if   Indicator[2].DATA[period] > LevelShort[2] and   Indicator[2].DATA[period-1] <= LevelShort[2] then
	ACTION(27 ,SignalShort[2], period);
	end
	
	if   Indicator[2].DATA[period] < LevelShort[2] and   Indicator[2].DATA[period-1] >= LevelShort[2]  then
    ACTION(28 ,SignalShort[2], period);
	end
	
	
	if   Indicator[3].DATA[period] > LevelShort[3] then
	ACTION(29 ,SignalShort[3], period);
	end
	
	if   Indicator[3].DATA[period] < LevelShort[3] then
	ACTION(30 ,SignalShort[3], period);
	end
	
	if  Indicator[3].DATA[period] > LevelShort[3] and   Indicator[3].DATA[period-1] <= LevelShort[3] then
	ACTION(31 ,SignalShort[3], period);
	end
	
	if   Indicator[3].DATA[period] < LevelShort[3] and   Indicator[3].DATA[period-1] >= LevelShort[3]  then
	ACTION(32 ,SignalShort[3], period);
	end
	
	
	if  Indicator[4].DATA[period] > LevelShort[4] then
	ACTION(33 ,SignalShort[4], period);
	end
	
	if  Indicator[4].DATA[period] < LevelShort[4]  then
	ACTION(34 ,SignalShort[4], period);
	end
	
	if   Indicator[4].DATA[period] > LevelShort[4] and   Indicator[4].DATA[period-1] <= LevelShort[4] then
	ACTION(35 ,SignalShort[4], period);
	end
	
	if   Indicator[4].DATA[period] < LevelShort[4] and   Indicator[4].DATA[period-1] >= LevelShort[4]  then
    ACTION(36 ,SignalShort[4], period);
	end
	
	if   Indicator[5].DATA[period] > LevelShort[5] then
	ACTION(37 ,SignalShort[5], period);
	end
	
	if   Indicator[5].DATA[period] < LevelShort[5] then
	ACTION(38 ,SignalShort[5], period);
	end
	
	if   Indicator[5].DATA[period] > LevelShort[5] and   Indicator[5].DATA[period-1] <= LevelShort[5]then
	ACTION(39 ,SignalShort[5], period);
	end
	
	if   Indicator[5].DATA[period] < LevelShort[5] and   Indicator[5].DATA[period-1] >= LevelShort[5]  then
    ACTION(40 ,SignalShort[5], period);
	end
	 
end

function ACTION (Flag, Label, period)

                                if Action[Flag] ==  "NO" then
								return;								
								elseif Action[Flag] ==  "BUY" then		

															BUY();
								ONE= Source:serial(period);		
								elseif Action[Flag] ==  "SELL" then				
                                                           
														   SELL();
								ONE= Source:serial(period);								   
								elseif Action[Flag] ==  "CLOSE" then
								
								        if AllowTrade then
																			
												if haveTrades('B') then
														exitSpecific("B");
														Signal ("Close Long");
												end							
												
                                                if haveTrades('S') then
														exitSpecific("S");
														Signal ("Close Short");
												end	
                                         else
										 
										Signal ("Close All");									
										end	
                                elseif Action[Flag] ==  "Alert" then 										
									Signal (  Label );				 		
								end

								
						  
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

