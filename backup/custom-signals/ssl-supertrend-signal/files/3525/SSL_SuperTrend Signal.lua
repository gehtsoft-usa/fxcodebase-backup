-- Id: 1221
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
    strategy:name("SSL_SuperTrend");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("SSL_SuperTrend");

    strategy.parameters:addGroup("Parameters");


    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addInteger("SSLFrame", "SSL Number of periods", "SSL The number of periods.", 2, 2, 1000);
	
	strategy.parameters:addInteger("STFrame", "Super Trend Number of periods", "Super Trend Number of periods", 10);
    strategy.parameters:addDouble("Multiplier", "Super Trend Multiplier", "Super Trend Multiplier", 1.5);
	
	strategy.parameters:addBoolean("Broader", "Broader definition", "", false);

    strategy.parameters:addString("Period", "Timeframe", "", "m5");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
end

local SSLFrame=nil;
local STFrame=nil;
local Multiplier=nil;

local Broader=nil;

local ST=nil;
local SSL=nil;

local ShowAlert;
local SoundFile;
local BUY, SELL;
local BarSource = nil;         -- the source stream
local first;

function Prepare()

    ShowAlert = instance.parameters.ShowAlert;

    SSLFrame=instance.parameters.SSLFrame;
    STFrame=instance.parameters.STFrame;
    Multiplier=instance.parameters.Multiplier;
	
	Broader=instance.parameters.Broader;


    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");
	 assert(core.indicators:findIndicator("SUPERTREND") ~= nil, "Please, download and install SUPERTREND.LUA indicator");     
	 assert(core.indicators:findIndicator("SSL") ~= nil, "Please, download and install SSL.LUA indicator");     

    BUY = " Up Trend";
    SELL = " Down Trend";

    ExtSetupSignal(" SSL_SuperTrend", ShowAlert);

    BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");

    ST  = core.indicators:create("SUPERTREND", BarSource, STFrame, Multiplier);
	SSL  = core.indicators:create("SSL", BarSource, SSLFrame);
	
	first = math.max(ST.UP:first(),ST.DN:first(), SSL.DATA:first() );
	
    local name = profile:id() .. " ( " .. instance.bid:instrument()  .. " ( " .. instance.parameters.Period  .. " ) ".. STFrame.. ", ".. Multiplier..", " .. SSLFrame .." )";
    instance:name(name);
end



-- when tick source is updated
function ExtUpdate(id, source, period)

    if period < first +1 then
	return;
	end

			if Broader then
			
			      SSL:update(core.UpdateLast);
	              ST:update(core.UpdateLast);
			      
			
					if core.crossesOver(BarSource.close, SSL.DATA, period)   then
						SSLFlag= true;
				   elseif core.crossesUnder( BarSource.close , SSL.DATA, period)  then
						SSLFlag= false;               
					end
					
					if  ST.UP[period] > 0 then
						STFlag= true;
				   elseif ST.DN[period] > 0 then
						STFlag= false;               
					end
					
					if SSLFlag and STFlag and Flag~="Buy" then
					ExtSignal(BarSource.close, period, BUY, SoundFile);
					Flag="Buy"
					end
					
					if not SSLFlag and  not STFlag and Flag~= "Sell" then
					ExtSignal(BarSource.close, period, SELL, SoundFile);
					Flag="Sell";
					end
					
			
			else
			 
			SSL:update(core.UpdateLast);
			ST:update(core.UpdateLast);
			
			
				   if core.crossesOver(BarSource.close, SSL.DATA, period) and ST.UP[period] > 0  then
						ExtSignal(BarSource.close, period, BUY, SoundFile);
				   elseif core.crossesUnder( BarSource.close , SSL.DATA, period)  and ST.DN[period] > 0  then
						ExtSignal(BarSource.close, period, SELL, SoundFile);
					end
			end		
			
			
			
			
    
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
