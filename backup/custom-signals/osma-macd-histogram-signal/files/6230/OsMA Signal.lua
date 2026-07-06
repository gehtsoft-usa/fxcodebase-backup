-- Id: 2382
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
function Init()
    strategy:name("OsMA Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Difference between the Moving Average Convergence/Divergence and the signal line");

	strategy.parameters:addString("SignalType", "Signal Type", "", "CROSS");
    strategy.parameters:addStringAlternative("SignalType", "Zero Line Cross", "", "CROSS");
    strategy.parameters:addStringAlternative("SignalType", "Top/Bottom", "", "TREND");  
	 strategy.parameters:addStringAlternative("SignalType", "Both", "", "BOTH");  
   
    strategy.parameters:addGroup("Calculation");
    strategy.parameters:addInteger("SN", "Short EMA", "The period of the short EMA", 12, 2, 1000);
    strategy.parameters:addInteger("LN", "Long EMA", "The period of the Long EMA", 26, 2, 1000);
    strategy.parameters:addInteger("IN", "Signal line", "The number of periods for the signal line.", 9, 2, 1000);
	
	strategy.parameters:addString("PriceType", "CLOSE", "", "C");
    strategy.parameters:addStringAlternative("PriceType", "OPEN", "", "O");
    strategy.parameters:addStringAlternative("PriceType", "HIGH", "", "H");
    strategy.parameters:addStringAlternative("PriceType", "LOW", "", "L");
    strategy.parameters:addStringAlternative("PriceType","CLOSE", "", "C");
    strategy.parameters:addStringAlternative("PriceType", "MEDIAN", "", "M");
    strategy.parameters:addStringAlternative("PriceType", "TYPICAL", "", "T");
    strategy.parameters:addStringAlternative("PriceType", "WEIGHTED", "", "W");
  
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");	
   
    strategy.parameters:addString("Period", "Timeframe", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
   strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
	strategy.parameters:addBoolean("Recurrent", "RecurrentSound", "", false);
	
	strategy.parameters:addGroup("Email Parameters");
	strategy.parameters:addBoolean("SendEmail", "Send email", "", false);
    strategy.parameters:addString("Email", "Email address", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local name;

local Email;
local RecurrentSound;
local SoundFile;

local LongFrame,ShortFrame,SignalFrame;
local OSMA
local SignalType, PriceType;


local BarSource = nil; 
local TickSource=nil;
local Period;


function Prepare()
    Period= instance.parameters.Period;
    LongFrame= instance.parameters.LN;
	ShortFrame= instance.parameters.SN;
	SignalFrame= instance.parameters.IN;
	SignalType= instance.parameters.SignalType;
	PriceType= instance.parameters.PriceType;	
	  
    RecurrentSound= instance.parameters.Recurrent;
	
	local SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "Email address must be specified");
	
	
    
    ShowAlert = instance.parameters.ShowAlert;
	
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end   

    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");
    assert(instance.parameters.Period ~= "t1", "Signal cannot be applied on ticks");

   
    BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
	
	
	if PriceType == "O" then
        TickSource = BarSource.open;
    elseif PriceType == "H" then
        TickSource = BarSource.high;
    elseif PriceType == "L" then
        TickSource = BarSource.low;
    elseif PriceType == "M" then
        TickSource = BarSource.median;
    elseif PriceType == "T" then
        TickSource = BarSource.typical;
    elseif PriceType == "W" then
        TickSource = BarSource.weighted;
    else
        TickSource = BarSource.close;
    end
		
	
	OSMA  = core.indicators:create("MACD", TickSource, ShortFrame, LongFrame, SignalFrame );	
	
	
    name = profile:id() .. "OsMA Signal";
    instance:name(name);
end



-- when tick source is updated
function ExtUpdate(id, source, period)
    -- update moving average
	
	if  id ==1 and period > 1  then
		
    OSMA:update(core.UpdateLast);
	
	    if OSMA.HISTOGRAM:hasData(period-1) and  OSMA.HISTOGRAM:hasData(period) then			  
			if SignalType == "CROSS"  or  SignalType == "BOTH" then
							
					  
								if core.crossesOver(OSMA.HISTOGRAM, 0 , period) then
									 ALERT ("Zelo Line CrossOver", name.. ", ".. Period  ..  ", " ..  instance.bid:instrument() ..  ", " .. instance.bid[NOW] ..  ", " .. "Cross Over" ..  ", " .. instance.bid:date(NOW));
								end  
								
								  if core.crossesUnder(OSMA.HISTOGRAM, 0 , period) then
								 ALERT ("Zelo Line CrossUnder", name.. ", ".. Period  ..  ", " ..  instance.bid:instrument() ..  ", " .. instance.bid[NOW] ..  ", " .. "Cross Under" ..  ", " .. instance.bid:date(NOW));
								end  
								
			elseif  OSMA.HISTOGRAM:hasData(period-2) and (  SignalType == "TREND" or  SignalType == "BOTH") then
			
			                     if OSMA.HISTOGRAM[period] > OSMA.HISTOGRAM[period-1] and  OSMA.HISTOGRAM[period-1] < 0 and OSMA.HISTOGRAM[period-2] > OSMA.HISTOGRAM[period-1] then
								 ALERT ("Bottom", name.. ", ".. Period  ..  ", " ..  instance.bid:instrument() ..  ", " .. instance.bid[NOW] ..  ", " .. "Bottom" ..  ", " .. instance.bid:date(NOW));
					             end
								 
								 if OSMA.HISTOGRAM[period] < OSMA.HISTOGRAM[period-1] and  OSMA.HISTOGRAM[period-1] > 0 and OSMA.HISTOGRAM[period-2] < OSMA.HISTOGRAM[period-1] then
								 ALERT ("Top", name.. ", ".. Period  ..  ", " ..  instance.bid:instrument() ..  ", " .. instance.bid[NOW] ..  ", " .. "Top" ..  ", " .. instance.bid:date(NOW));
					             end
			
			end							
		end				
	end
end


function ALERT  (Label, Note)
                if ShowAlert then
                    terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], Label, instance.bid:date(NOW));
                end

                if SoundFile ~= nil then
                    terminal:alertSound(SoundFile, RecurrentSound);
                end
				
				if Email ~= nil then
				terminal:alertEmail (Email, Label, Note)
				end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
