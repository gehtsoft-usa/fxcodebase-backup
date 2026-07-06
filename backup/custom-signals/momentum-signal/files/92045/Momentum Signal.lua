-- Id: 10939
-- More information about this indicator can be found at:
-- http://fxcodebase.com/

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
local BAR = true;

function Init() --The strategy profile initialization
    strategy:name("Momentum Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("");


    strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

 


    strategy.parameters:addString("TF", "Time frame", "", "m5");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
	


    strategy.parameters:addGroup("MA Parameters");
 
    strategy.parameters:addInteger("Period", "MA Period", "", 20);
	strategy.parameters:addString("Method", "MA Method", "Method" , "EMA");
    strategy.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    strategy.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    strategy.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    strategy.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    strategy.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    strategy.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    strategy.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    strategy.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA"); 
 
 
    strategy.parameters:addGroup("MACD Parameters");
	strategy.parameters:addInteger("LookBack", "LookBack Period", "", 5);
	strategy.parameters:addInteger("Short", "Short MA Period", "", 12);
	strategy.parameters:addInteger("Long", "Long MA Period", "", 26);
	strategy.parameters:addInteger("Signal", "Signal MA Period", "", 26);
	
	
	strategy.parameters:addString("Cross", "Cross Method", "Cros Method" , "Zero");
    strategy.parameters:addStringAlternative("Cross", "Zero", "Zero" , "Zero");
    strategy.parameters:addStringAlternative("Cross", "Signal", "Signal" , "Signal");
	
	 strategy.parameters:addGroup("Source");
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");



    CreateTradingParameters();
end

function CreateTradingParameters()
    strategy.parameters:addGroup("Trading Parameters");

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false);
    -- NG: optimizer/backtester hint
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


local Source;

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


 local Method, Period;
local MA,MACD=nil;
local LookBack;
local Short, Long, Signal;
local Cross;

local Source;

local Direction;
local UseMandatoryClosing;
local ValidInterval;

local first;
 


-- Don't need to store hour + minute + second for each time
local OpenTime, CloseTime, ExitTime;

--
function Prepare(nameOnly)

   Method = instance.parameters.Method;
	Period = instance.parameters.Period;
	LookBack = instance.parameters.LookBack;
	Cross = instance.parameters.Cross;
   Short = instance.parameters.Short;
   Long = instance.parameters.Long;
   Signal = instance.parameters.Signal;
	
 
    -- NG: replace string comparison everytime in future.
   
    -- NG: check TF1/TF2 instead of TF
    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");
 

    local name;
    name = profile:id() .. "( " .. instance.bid:name();
 
    name = name  ..  " )";
    instance:name(name);


	PrepareTrading();
    
    if nameOnly then
        return ;
    end

    Source = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar");
	
	
	MACD  = core.indicators:create("MACD", Source.close, Short, Long, Signal);
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA  = core.indicators:create(Method, Source.close, Period);
	first= math.max(MA.DATA:first(), MACD.MACD:first());
	


	 
end

function PrepareTrading()
  
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


 end



function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.
  

 
    if id ~= 1 then
        return;
    end


	 MACD:update(core.UpdateLast);
	 MA:update(core.UpdateLast);
		   
		if  period  <  first + 2  then
		return;
		end
		
			
					if core.crossesOver(Source.close, MA.DATA, period) and Over (period) ~= nil     then 					
					Alert("Momentum Signal", " Cross Over ", period);
					end 	
					
				
				    if core.crossesUnder(Source.close, MA.DATA, period) and Under (period) ~= nil  then 						
					Alert("Momentum  Signal", " Cross Under ", period);
					end 	
     
   
end



-- NG: Introduce async function for timer/monitoring for the order results
function ExtAsyncOperationFinished(cookie, success, message)
    
end


function Over(period)
local Value=nil;
 

	if (Cross== "Zero" and MACD.MACD[period]> 0)
    or (Cross== "Signal" and MACD.MACD[period] > MACD.SIGNAL[period]) then
	return Value;
    end	
		

for  i= period , period-LookBack+1,-1 do

		

	if (Cross== "Zero" and MACD.MACD[i] < 0) 
    or (Cross== "Signal" and   MACD.MACD[i] < MACD.SIGNAL[i]) 
	then     
	Value=i;
	break;
	end 

end


return Value;

end

function Under(period)

local Value=nil;
local Second;

    if (Cross== "Zero" and MACD.MACD[period] < 0) 
    or (Cross== "Signal" and   MACD.MACD[period] < MACD.SIGNAL[period]) then
	return Value;
    end	

for  i= period , period-LookBack+1,-1 do

	

	if (Cross== "Zero" and MACD.MACD[i] > 0) 
    or (Cross== "Signal" and   MACD.MACD[i] > MACD.SIGNAL[i]) 
	then
    Value=i;
	break;
	end 

end


return Value;

end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");

function Alert(Label,Subject, period)
    if ShowAlert then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW],  Label .. " : " .. Subject , instance.bid:date(NOW));
    end


    if SoundFile ~= nil then
        terminal:alertSound(SoundFile, RecurrentSound);
    end

    if Email ~= nil then
       
		
		    local date = instance.bid:date(NOW)
	local DATA = core.dateToTable (date);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..Label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. instance.bid:instrument()
   local TF= "Time Frame : " .. Source:barSize();    
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
     local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
	 terminal:alertEmail(Email, Label, text);
	
    end
end



dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");



