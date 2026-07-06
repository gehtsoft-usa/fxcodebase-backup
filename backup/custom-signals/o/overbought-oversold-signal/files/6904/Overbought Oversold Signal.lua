-- Id: 2687
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
    strategy:name("Overbought/Oversold Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Overbought/Oversold Signal");

    strategy.parameters:addGroup("Parameters");
 
    strategy.parameters:addInteger("EMAFrame", "EMA Period", "", 14, 3, 2000);	 
    strategy.parameters:addInteger("RSIFrame", "RSI Period", "", 14, 2, 2000);	
	 strategy.parameters:addInteger("OverboughtLevel", "Overbought Level", "", 70, 0, 100);	 
    strategy.parameters:addInteger("OversoldLevel", "Oversold Level", "", 30, 0, 100);	
	strategy.parameters:addBoolean("Repetition", "Repetition", "", false);
	
	
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

    strategy.parameters:addString("Period", "Timeframe", "", "m5");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
	
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
	
	 strategy.parameters:addBoolean("SendEmail", "Send Email", "", true);
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local first;
local ShowAlert;
local SoundFile;
local BUY, SELL;
local BarSource = nil;         -- the source stream
local Email;
local SendEmail;

local EMAFrame, RSIFrame;
local Indicator={};
local PriceType;
local Price;

local Repetition;

local OverboughtLevel,OversoldLevel;

function Prepare()
    -- collect parameters	
	Repetition= instance.parameters.Repetition;
	OverboughtLevel= instance.parameters.OverboughtLevel;
	OversoldLevel= instance.parameters.OversoldLevel;
	
	EMAFrame = instance.parameters.EMAFrame;
	RSIFrame = instance.parameters.RSIFrame;
	 PriceType= instance.parameters.PriceType;
	 
	  SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
   
	   
   
	   
    ShowAlert = instance.parameters.ShowAlert;
	
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
	
	
     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

    
    BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
	
	
	if PriceType == "O" then
        Price = BarSource.open;
    elseif PriceType == "H" then
        Price = BarSource.high;
    elseif PriceType == "L" then
        Price = BarSource.low;
    elseif PriceType == "M" then
        Price = BarSource.median;
    elseif PriceType == "T" then
        Price = BarSource.typical;
    elseif PriceType == "W" then
        Price = BarSource.weighted;
    else
        Price = BarSource.close;
    end
	
	Indicator[1]  = core.indicators:create("EMA", Price, EMAFrame);
	Indicator[2]  = core.indicators:create("RSI", Price, RSIFrame);
	
	first= math.max(Indicator[1].DATA:first(), Indicator[2].DATA:first()); 
	
        local name = profile:id() .. "(" ..  instance.bid:instrument() .. ", " .. EMAFrame .. ", ".. RSIFrame .. ")";
         instance:name(name);
 
    ExtSetupSignal(profile:id() .. ":", ShowAlert);
    ExtSetupSignalMail(name);		
	
end

local EMABuy=false;
local  EMASell=false;
local RSIBuy=false;
local RSISell=false;
local Flag=nil;


-- when tick source is updated
function ExtUpdate(id, source, period)	
       
     Indicator[1]:update(core.UpdateLast);
	  Indicator[2]:update(core.UpdateLast);
		   
		if  period  <  first + 2 or not Indicator[1].DATA:hasData(period) or not Indicator[2].DATA:hasData(period) then
		return;
		end
			
		if  Repetition then
			
					if Indicator[2].DATA[period] > OverboughtLevel  and BarSource.low[period] > Indicator[1].DATA[period]  then 					
					 ExtSignal(BarSource.close, period, "Overbought", SoundFile, Email);
					end 	
					
				
				    if Indicator[2].DATA[period] < OversoldLevel  and BarSource.high[period] < Indicator[1].DATA[period] then 					
					 ExtSignal(BarSource.close, period, "Oversold", SoundFile, Email);
					end 	
		else        
		            if  core.crossesOver(  Indicator[2].DATA , OverboughtLevel, period)  then
					RSIBuy = true;
					end
					if  core.crossesUnder(  Indicator[2].DATA , OverboughtLevel, period)  then
					RSIBuy = false;
					end
					
					
					
					 if  core.crossesUnder(  Indicator[2].DATA , OversoldLevel, period)  then
					RSISell = true;
					end
					if  core.crossesOver(  Indicator[2].DATA , OversoldLevel, period)  then
					RSISell = false;
					end
                 
				 
				      if  BarSource.low[period] > Indicator[1].DATA[period]   then
					EMABuy = true;
					end
					if   BarSource.low[period] < Indicator[1].DATA[period]  then
					EMABuy = false;
					end		
					
					 if   BarSource.high[period] < Indicator[1].DATA[period]  then
					EMASell = true;
					end
					if  BarSource.high[period] > Indicator[1].DATA[period]  then
					EMASell = false;
					end
					

                    				
					
					if EMABuy and RSIBuy and Flag ~= "Buy" then
					Flag="Buy";
					 ExtSignal(BarSource.close, period, "Overbought", SoundFile, Email);
					end
				    
					if EMASell and RSISell and Flag ~= "Sell" then
					Flag="Sell";
					 ExtSignal(BarSource.close, period, "Oversold", SoundFile, Email);
					end
        end									  
							   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
