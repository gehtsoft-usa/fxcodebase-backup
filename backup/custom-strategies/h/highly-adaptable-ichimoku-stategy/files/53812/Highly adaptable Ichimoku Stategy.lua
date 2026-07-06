-- Id: 8436
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/posting.php?mode=reply&f=31&t=31550

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

function Init() --The strategy profile initialization
    strategy:name("Highly adaptable Ichimoku Stategy");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("");
	
	    strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
	
	  strategy.parameters:addString("TF", "Time frame", "", "m5");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
	
	strategy.parameters:addGroup("Calculation");
    strategy.parameters:addInteger("T", "Tenkan Period", "Tenkan Period", 9);
    strategy.parameters:addInteger("K", "Kijun Period", "Kijun Period", 26);
    strategy.parameters:addInteger("S", "Senkou Period", "Senkou Period", 52);
 

	strategy.parameters:addGroup("Selector");
	
	strategy.parameters:addString("Action".. 1, "TS/KS Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 1, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 1, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 1, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 1, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 1, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 2, "TS/KS Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 2, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 2, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 2, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 2, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 2, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 3, "CS / Price Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 3, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 3, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 3, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 3, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 3, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 4, "CS / Price Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 4, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 4, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 4, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 4, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 4, "Alert", "", "Alert");
	
	
	strategy.parameters:addString("Action".. 5, "Top Cloud / Price  Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 5, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 5, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 5, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 5, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 5, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 6, "Top Cloud / Price Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 6, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 6, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 6, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 6, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 6, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 7, "Bottom Cloud / Price  Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 7, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 7, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 7, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 7, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 7, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 8, "Bottom Cloud / Price Cross  Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 8, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 8, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 8, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 8, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 8, "Alert", "", "Alert");
	
	

	
	strategy.parameters:addString("Action".. 9, "Chinkou / Top Cloud  Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 9, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 9, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 9, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 9, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 9, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 10, "Chinkou / Top Cloud  Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 10, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 10, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 10, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 10, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 10, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 11, "Chinkou /  Bottom Cloud  Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 11, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 11, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 11, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 11, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 11, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 12, "Chinkou /  Bottom Cloud  Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 12, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 12, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 12, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 12, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 12, "Alert", "", "Alert");
	
	
	strategy.parameters:addString("Action".. 13, "SA /  SB  Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 13, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 13, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 13, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 13, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 13, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 14, "SA /  SB  Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 14, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 14, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 14, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 14, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 14, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 15, "Price / TL  Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 15, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 15, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 15, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 15, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 15, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 16, "Price / TL   Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 16, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 16, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 16, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 16, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 16, "Alert", "", "Alert");
	
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
    strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "HAIS");
	
	strategy.parameters:addInteger("MaxNumberOfPositionInAnyDirection", "Max Number Of Open Position In Any Direction", "", 2, 1, 100);
	strategy.parameters:addInteger("MaxNumberOfPosition", "Max Number Of Position In One Direction", "", 1, 1, 100);
    	
    strategy.parameters:addString("ALLOWEDSIDE", "Allowed side", "Allowed side for trading or signaling, can be Sell, Buy or Both", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell");
	
	

    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 100);
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false);
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false);
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false);
    strategy.parameters:addBoolean("Exit", "Use Optional Exit", "", false);
	
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
    strategy.parameters:addString("StartTime", "Start Time for Trading", "", "00:00:00");
    strategy.parameters:addString("StopTime", "Stop Time for Trading", "", "24:00:00");

    strategy.parameters:addBoolean("UseMandatoryClosing", "Use Mandatory Closing", "", false);
    strategy.parameters:addString("ExitTime", "Mandatory Closing  Time", "", "23:59:00");
    strategy.parameters:addInteger("ValidInterval", "Valid interval for operation in second", "", 60);
end

local OpenTime, CloseTime, ExitTime,ValidInterval,UseMandatoryClosing;
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
local Exit;
--local Direction;
local CustomID;

local Tenkan;
local Kijun;
local Senkou;
local ICH;

local Action={};
local first={};
  
local Number = 16;

-- Don't need to store hour + minute + second for each time
local OpenTime, CloseTime, ExitTime;
--
function Prepare( nameOnly)
    CustomID = instance.parameters.CustomID;
	ExecutionType = instance.parameters.ExecutionType;
    CloseOnOpposite = instance.parameters.CloseOnOpposite;
	MaxNumberOfPositionInAnyDirection = instance.parameters.MaxNumberOfPositionInAnyDirection;
	MaxNumberOfPosition = instance.parameters.MaxNumberOfPosition;
	--Direction = instance.parameters.Direction == "direct";
	
	ValidInterval = instance.parameters.ValidInterval;
	UseMandatoryClosing = instance.parameters.UseMandatoryClosing;
	
    Exit= instance.parameters.Exit;
	
	
	Tenkan = instance.parameters.T;
    Kijun = instance.parameters.K;
    Senkou = instance.parameters.S;


    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");

    local name;
    name = profile:id() .. "( " .. instance.bid:name() 
	local i;
	
	
	for i = 1, Number, 1 do 
	Action[i]= instance.parameters:getString ("Action" .. i);
	end

	
	name = name  ..  " )";
    instance:name(name);
		
 

    PrepareTrading();

    if nameOnly then
        return ;
    end
	
	
	if ExecutionType== "Live" then
	TickSource = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close");
	end
	
	
    Source = ExtSubscribe(2, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar");
	
	ICH  = core.indicators:create("ICH", Source, Tenkan, Kijun, Senkou);
   
    
    first["SL"]=ICH.SL:first();
	 first["TL"]=ICH.TL:first();
	  first["SA"]=ICH.SA:first();
	   first["CS"]=ICH.CS:first();
	   first["SB"]=ICH.SB:first();
	    first["PRICE"]=Source:first();
	
 
	

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
 
 
local ONE;

function ACTION (Flag, Line, Label)

                                if Action[Flag] ==  "NO" then
								return;								
								elseif Action[Flag] ==  "BUY" then		

															BUY();
								
								elseif Action[Flag] ==  "SELL" then				
                                                           
														   SELL();
														   
								elseif Action[Flag] ==  "CLOSE" then
								
								        if AllowTrade then
																			
												if haveTrades('B') then
														exitSpecific('B');
														Signal ("Close Long");
												end							
												
                                                if haveTrades('S') then
														exitSpecific('S');
														Signal ("Close Short");
												end	
                                         else
										 
										Signal ("Close All");									
										end	
                                elseif Action[Flag] ==  "Alert" then 										
									Signal (Line .. " Line Cross" .. Label );				 		
								end

end


 
function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.

    if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
            return ;
        end
    end
	
		   
    if  ExecutionType ==  "Live" and  id == 1 then
			
			period= core.findDate (Source.close, TickSource:date(period), false );		
					
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

 
	 
   
			ICH:update(core.UpdateLast);
					
										
						if period-1 > math.max( first["SL"],  first["TL"])  then   
								if core.crossesOver(ICH.SL, ICH.TL, period)then									
									ACTION(1,"TS/KS" ,"Over");								
								end
								if core.crossesUnder(ICH.SL, ICH.TL, period) then		
                                    ACTION(2,"TS/KS" ,"Under");	  
                                end				

						end 

						if period-1 > math.max( first["CS"] +Kijun ,  first["PRICE"] +Kijun) then
					            if core.crossesOver(ICH.CS, Source.close, period-Kijun, period-Kijun-1 ) then	
								     ACTION(3,"CS / Price" ,"Over");	
								end	  
								if core.crossesUnder(ICH.CS, Source.close, period-Kijun, period-Kijun-1 )  then	
								     ACTION(4,"CS / Price" ,"Under");	
								end	  
								
						end		
						
						
						if period-1 > math.max( first["SA"],  first["SB"]) then	
								if math.max(ICH.SA[period], ICH.SB[period])< Source.close[period] and  math.max(ICH.SA[period-1], ICH.SB[period-1]) > Source.close[period-1]   then	
								     ACTION(5,"Top Cloud / Price" , "Over");
                                end									 
								if  math.max(ICH.SA[period], ICH.SB[period]) >  Source.close[period] and  math.max(ICH.SA[period-1], ICH.SB[period-1]) < Source.close[period-1]  then	
								    ACTION(6,"Top Cloud / Price" ,"Under");
					            end				
								if math.min(ICH.SA[period], ICH.SB[period]) < Source.close[period] and  math.min(ICH.SA[period-1], ICH.SB[period-1]) > Source.close[period-1] then									
									ACTION(7,"Bottom Cloud / Price" ,"Over");	
                                end									
								if   math.min(ICH.SA[period], ICH.SB[period])> Source.close[period] and  math.min(ICH.SA[period-1], ICH.SB[period-1]) < Source.close[period-1] then		
                                    ACTION(8,"Bottom Cloud / Price" ,"Under");	
                                end  			
                        end
						
						
						if period-1 > math.max( first["CS"] +Kijun+1 ,  first["SA"]) then
					            if ICH.CS[period-Kijun-1] < math.max(ICH.SA[period-1-Kijun], ICH.SB[period-1-Kijun]) and ICH.CS[period-Kijun] > math.max(ICH.SA[period-Kijun], ICH.SB[period-Kijun]) then	
								     ACTION(9,"CS / Top Cloud" ,"Over");	
								end	  
								if ICH.CS[period-Kijun-1] > math.max(ICH.SA[period-1-Kijun], ICH.SB[period-1-Kijun]) and ICH.CS[period-Kijun] < math.max(ICH.SA[period-Kijun], ICH.SB[period-Kijun]) then	
								     ACTION(10,"CS / Top Cloud" ,"Under");	
								end	  
								
								
								 if ICH.CS[period-Kijun-1] < math.min(ICH.SA[period-1-Kijun], ICH.SB[period-1-Kijun]) and ICH.CS[period-Kijun] > math.min(ICH.SA[period-Kijun], ICH.SB[period-Kijun])  then	
								     ACTION(11,"SA / SB" ,"Over");	
								end	  
								if  ICH.CS[period-Kijun-1] > math.min(ICH.SA[period-1-Kijun], ICH.SB[period-1-Kijun]) and ICH.CS[period-Kijun] < math.min(ICH.SA[period-Kijun], ICH.SB[period-Kijun])   then	
								     ACTION(12,"SA / SB" ,"Under");	
								end	  
								
						end		
						
						
						--Price / TL
         
		 
		               if period >  first["TL"] then
						  
						  
						  if  core.crossesOver(Source.close,ICH.TL, period ) then
						   ACTION(15,"Price / TL" ,"Over");
						  end
						  
						  if  core.crossesUnder(Source.close,ICH.TL, period ) then
						   ACTION(16,"Price / TL" ,"Over");
						  end
						
						
						end
						
						
						if period >  first["SA"] then
						  
						  
						  if  ICH.SA[period+Kijun-1]<ICH.SB[period+Kijun-1] and ICH.SA[period+Kijun]>ICH.SB[period+Kijun] then
						   ACTION(13,"SA /SB" ,"Over");
						  end
						  
						  if  ICH.SA[period+Kijun-1]>ICH.SB[period+Kijun-1] and ICH.SA[period+Kijun]<ICH.SB[period+Kijun] then
						   ACTION(14,"SA /SB" ,"Over");
						  end
						
						
						end
							
		 
end





-- NG: Introduce async function for timer/monitoring for the order results
function ExtAsyncOperationFinished(cookie, success, message)

    if cookie == 100 then
        -- timer
        if UseMandatoryClosing and AllowTrade then
            now = core.host:execute("getServerTime");
            -- get only time
            now = now - math.floor(now);
            -- check whether the time is in the exit time period
            if now >= ExitTime and now < ExitTime + ValidInterval then
                if not(checkReady("trades")) or not(checkReady("orders")) then
                    return ;
                end
                if haveTrades("S") then
                     exitSpecific("S");
                     Signal ("Close Short");
                end
                if haveTrades("B") then
                     exitSpecific("B");
                     Signal ("Close Long");
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

