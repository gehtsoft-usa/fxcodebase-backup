-- Id: 15857
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=63362

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




function Init() --The strategy profile initialization
    strategy:name("PRICE_AVERAGES OBOS ADX_AVERAGES ");
    strategy:description("");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");
	
	strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
	
	strategy.parameters:addString("TF", "Time frame", "", "H1");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);

    
    strategy.parameters:addGroup("Price Averages Calculation"); 
    strategy.parameters:addBoolean("S1", "Use MA Filter", "", true);
    strategy.parameters:addString("Price_Average_Method", "Method", "", "MVA");
    strategy.parameters:addStringAlternative("Price_Average_Method", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("Price_Average_Method", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("Price_Average_Method", "Wilder", "", "Wilder");
    strategy.parameters:addStringAlternative("Price_Average_Method", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("Price_Average_Method", "SineWMA", "", "SineWMA");
    strategy.parameters:addStringAlternative("Price_Average_Method", "TriMA", "", "TriMA");
    strategy.parameters:addStringAlternative("Price_Average_Method", "LSMA", "", "LSMA");
    strategy.parameters:addStringAlternative("Price_Average_Method", "SMMA", "", "SMMA");
    strategy.parameters:addStringAlternative("Price_Average_Method", "HMA", "", "HMA");
    strategy.parameters:addStringAlternative("Price_Average_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    strategy.parameters:addStringAlternative("Price_Average_Method", "DEMA", "", "DEMA");
    strategy.parameters:addStringAlternative("Price_Average_Method", "T3", "", "T3");
    strategy.parameters:addStringAlternative("Price_Average_Method", "ITrend", "", "ITrend");
    strategy.parameters:addStringAlternative("Price_Average_Method", "Median", "", "Median");
    strategy.parameters:addStringAlternative("Price_Average_Method", "GeoMean", "", "GeoMean");
    strategy.parameters:addStringAlternative("Price_Average_Method", "REMA", "", "REMA");
    strategy.parameters:addStringAlternative("Price_Average_Method", "ILRS", "", "ILRS");
    strategy.parameters:addStringAlternative("Price_Average_Method", "IE/2", "", "IE/2");
    strategy.parameters:addStringAlternative("Price_Average_Method", "TriMAgen", "", "TriMAgen");
    strategy.parameters:addStringAlternative("Price_Average_Method", "JSmooth", "", "JSmooth");
    strategy.parameters:addStringAlternative("Price_Average_Method", "KAMA", "", "KAMA");
    strategy.parameters:addStringAlternative("Price_Average_Method", "ARSI", "", "ARSI");
    strategy.parameters:addStringAlternative("Price_Average_Method", "VIDYA", "", "VIDYA");
    strategy.parameters:addStringAlternative("Price_Average_Method", "HPF", "", "HPF");
    strategy.parameters:addStringAlternative("Price_Average_Method", "VAMA", "", "VAMA");
	
    strategy.parameters:addInteger("Price_Average_Period", "Period", "", 14);
 
	strategy.parameters:addGroup("OB / OS  Calculation");
    strategy.parameters:addBoolean("S2", "Use 1. OBOS Filter", "", true);	
	strategy.parameters:addInteger("Period1", "1. OB/OS Period", "", 14);
	 strategy.parameters:addBoolean("S3", "Use 2. OBOS Filter", "", true);	
    strategy.parameters:addInteger("Period2", "2. OB/OS Period", "", 28);
	
	
	strategy.parameters:addGroup("ADX  Calculation"); 
	strategy.parameters:addBoolean("S4", "Use ADX Slope Filter", "", false);		
    strategy.parameters:addBoolean("S5", "Use MA of ADX Slope Filter", "", false);		
	strategy.parameters:addBoolean("S6", "Use ADX / Level Filter", "", false);		
    strategy.parameters:addBoolean("S7", "Use MA of ADX / Level Filter", "", false);
	
    strategy.parameters:addInteger("ADX_Period", "ADX Period", "", 14);
   strategy.parameters:addDouble("ADX_Level", "ADX Level", "", 20);	
	
	strategy.parameters:addString("ADX_Average_Method", "Method", "", "MVA");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "Wilder", "", "Wilder");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "SineWMA", "", "SineWMA");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "TriMA", "", "TriMA");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "LSMA", "", "LSMA");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "SMMA", "", "SMMA");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "HMA", "", "HMA");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "DEMA", "", "DEMA");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "T3", "", "T3");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "ITrend", "", "ITrend");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "Median", "", "Median");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "GeoMean", "", "GeoMean");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "REMA", "", "REMA");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "ILRS", "", "ILRS");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "IE/2", "", "IE/2");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "TriMAgen", "", "TriMAgen");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "JSmooth", "", "JSmooth");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "KAMA", "", "KAMA");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "ARSI", "", "ARSI");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "VIDYA", "", "VIDYA");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "HPF", "", "HPF");
    strategy.parameters:addStringAlternative("ADX_Average_Method", "VAMA", "", "VAMA");
	
    strategy.parameters:addInteger("ADX_Average_Period", "Period", "", 14);

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
    strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "PAOBOSAA");
	
	strategy.parameters:addInteger("MaxNumberOfPositionInAnyDirection", "Max Number Of Open Position In Any Direction", "", 2, 1, 100);
	strategy.parameters:addInteger("MaxNumberOfPosition", "Max Number Of Position In One Direction", "", 1, 1, 100);
    	
    strategy.parameters:addString("ALLOWEDSIDE", "Allowed side", "Allowed side for trading or signaling, can be Sell, Buy or Both", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell");
	
	strategy.parameters:addString("Direction", "Type of Signal / Trade", "", "direct");
    strategy.parameters:addStringAlternative("Direction", "Direct", "", "direct");
    strategy.parameters:addStringAlternative("Direction", "Reverse", "", "reverse");

    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000);
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false);
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false);
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false);
    strategy.parameters:addBoolean("Exit", "Use Optional Exit", "", true);
	
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
local Exit;
local Price_Average_Method, Price_Average_Period, Price_Average;
local Direction;
local CustomID;
local Period1, Period2, OBOS1, OBOS2;
local ADX, ADX_Period;
local ADX_Average_Method, ADX_Average_Period, ADX_MA;
 
local S1, S2, S3, S4,S5, S6,S7;
local ADX_Level;

local OpenTime, CloseTime, ExitTime;
local ValidInterval,UseMandatoryClosing;
local ToTime;



function Prepare( nameOnly)

    
	CustomID = instance.parameters.CustomID;
	
    local name = profile:id() .. "( " .. instance.bid:name() .. "," .. CustomID ..  " )";
    instance:name(name);
   
    PrepareTrading();

    if nameOnly then
        return ;
    end
	
	
	ExecutionType = instance.parameters.ExecutionType;
    CloseOnOpposite = instance.parameters.CloseOnOpposite;
	MaxNumberOfPositionInAnyDirection = instance.parameters.MaxNumberOfPositionInAnyDirection;
	MaxNumberOfPosition = instance.parameters.MaxNumberOfPosition;
	Direction = instance.parameters.Direction == "direct";
	
	S1= instance.parameters.S1;
	S2= instance.parameters.S2;
	S3= instance.parameters.S3;
	S4= instance.parameters.S4;
	S5= instance.parameters.S5;
	S6= instance.parameters.S6;
	S7= instance.parameters.S7;
	ADX_Level= instance.parameters.ADX_Level;
 
	
	Price_Average_Method= instance.parameters.Price_Average_Method;
	Price_Average_Period= instance.parameters.Price_Average_Period;
	
	ADX_Average_Method= instance.parameters.ADX_Average_Method;
	ADX_Average_Period= instance.parameters.ADX_Average_Period;
	
	ADX_Period= instance.parameters. ADX_Period;
	
	Period1= instance.parameters.Period1;
	Period2= instance.parameters.Period2;
	
    Exit= instance.parameters.Exit;

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");

    
   
    PrepareTrading();
 
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");          
	
	if ExecutionType== "Live" then
	TickSource = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close");
	end
	
    Source = ExtSubscribe(2, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar");
    Price_Average = core.indicators:create("AVERAGES", Source.close, Price_Average_Method, Price_Average_Period, true,  core.rgb(128, 128, 128),  core.rgb(0, 255, 0),  core.rgb(255, 0, 0)  );
	OBOS1 = core.indicators:create("OBOS", Source, Period1 ,   core.rgb(0, 255, 0),  core.rgb(255, 0, 0),  core.rgb(0, 0, 255) ); 
	OBOS2 = core.indicators:create("OBOS", Source, Period2 ,   core.rgb(0, 255, 0),  core.rgb(255, 0, 0),  core.rgb(0, 0, 255) ); 
	ADX = core.indicators:create("ADX", Source, ADX_Period ); 
	ADX_MA = core.indicators:create("AVERAGES", ADX.DATA, ADX_Average_Method, ADX_Average_Period, true,  core.rgb(128, 128, 128),  core.rgb(0, 255, 0),  core.rgb(255, 0, 0) ); 
	
	first=math.max(Price_Average.DATA:first(), OBOS1.DATA:first(), OBOS2.DATA:first(), ADX.DATA:first(), ADX_MA.DATA:first()); 
	
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
	
	
	if  ExecutionType ==  "Live" and  id == 1 then
			
			period= core.findDate (Source.close, TickSource:date(period), false );		
					
	end
	
	if period <Source:first() then
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

 --[[
Initiate Short Trade:
Close of candle = Averages line indicates sell + OBOS1 indicates sell + OBOS2 indicates sell + ADX averages line is at a higher value then previous candle
Close Short Trade:
Price hits take profit, reverses and hits trailing stop, Averages line on close of candle gives long indication
Initiate long Trade:
Close of candle = Averages line indicates long + OBOS1 indicates long + OBOS2 indicates long + ADX averages line is at a higher value then previous candle
Close long Trade:
Price hits take profit, reverses and hits trailing stop, Averages line on close of candle gives short indication

 
 ]]

    -- update indicators.
    Price_Average:update(core.UpdateLast);
	OBOS1:update(core.UpdateLast);
	OBOS2:update(core.UpdateLast);
	ADX:update(core.UpdateLast);
    ADX_MA:update(core.UpdateLast);
	
	if period < first  then
        return;
    end
	
    if not S1 and not S2 and not S3 and not S4 and not S5  and not S6 and not S7 then
	return;
	end
	
    -- only buy if we have a fast cross over slow and the price is above the moving averages.
    if (not S1 or  (Price_Average.DATA:colorI(period) ==  core.rgb(0, 255, 0) 
	--and  Price_Average.DATA:colorI(period-1) ~=  core.rgb(0, 255, 0)
	) 
	)
    and (not S2	or OBOS1.DATA:colorI(period) ==  core.rgb(0, 255, 0) )	 
	and (not S3 or OBOS2.DATA:colorI(period) ==  core.rgb(0, 255, 0))
	and  (not S5 or  ADX_MA.DATA[period] > ADX_MA.DATA[period-1] )
	and ( not S4 or  ADX.DATA[period] > ADX.DATA[period-1] )
	and ( not S6 or  ADX.DATA[period] > ADX_Level )
    and ( not S7 or  ADX_MA.DATA[period] > ADX_Level )
	then	
          if Direction then
                BUY();
            else
                SELL();
            end
		ONE= Source:serial(period);
    elseif (not S1 or  ( Price_Average.DATA:colorI(period) == core.rgb(255, 0, 0) 
	--and   Price_Average.DATA:colorI(period-1) ~= core.rgb(255, 0, 0)
	) 
	)
	and ( not S2 or  OBOS1.DATA:colorI(period) ==  core.rgb(255, 0, 0)) 	 
	and  (not S3 or OBOS2.DATA:colorI(period) ==  core.rgb(255, 0, 0) )
	and ( not S5 or  ADX_MA.DATA[period] > ADX_MA.DATA[period-1] )
	and ( not S4 or  ADX.DATA[period] > ADX.DATA[period-1] )
	and ( not S6 or  ADX.DATA[period] > ADX_Level )
    and ( not S7 or  ADX_MA.DATA[period] > ADX_Level )
	then
            if Direction then
                SELL();
            else
                BUY();
            end
		ONE= Source:serial(period);
    end
	
	
	if Exit then
		            if      Price_Average.DATA:colorI(period) ==  core.rgb(255, 0, 0) 
					then 			
								if   Direction then
										   if haveTrades("B") then
											   exitSpecific("B");
											   Signal ("Close Long");
										   end
							   else 
										 if haveTrades("S") then
											   exitSpecific("S");
											   Signal ("Close Short");
										   end
								   
								end
					  end
					  if   Price_Average.DATA:colorI(period) ==  core.rgb(0, 255, 0) 
		               then
								   if   Direction then    
										if haveTrades("S") then
										   exitSpecific("S");
										   Signal ("Close Short");
									   end 
								  
								  
							   else 
							   
									  if haveTrades("B") then
										   exitSpecific("B");
										   Signal ("Close Long");
									   end
								
							 
							 end
				
					end
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

