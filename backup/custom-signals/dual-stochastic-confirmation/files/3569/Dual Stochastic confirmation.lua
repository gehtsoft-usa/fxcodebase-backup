-- Id: 1237
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
    strategy:name("Dual Stochastic confirmation Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Dual Stochastic confirmation Signal");

    strategy.parameters:addGroup("Parameters");
	
	
	strategy.parameters:addInteger("K1", "Number of periods for %K", "The number of periods for %K.", 10, 2, 1000);
    strategy.parameters:addInteger("SD1", "%D slowing periods", "The number of periods for slow %D.", 5, 2, 1000);
    strategy.parameters:addInteger("D1", "Number of periods for %D", "The number of periods for %D.", 5, 2, 1000);
	
    strategy.parameters:addInteger("K2", "Number of periods for %K", "The number of periods for %K.", 60, 2, 1000);
    strategy.parameters:addInteger("SD2", "%D slowing periods", "The number of periods for slow %D.", 30, 2, 1000);
    strategy.parameters:addInteger("D2", "Number of periods for %D", "The number of periods for %D.", 30, 2, 1000);
      	
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addString("Period", "Timeframe", "", "m5");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
end

local ShowAlert;
local SoundFile;

local  K1 , SD1, D1, K2, SD2, D2; 



local SSD1=nil;
local SSD2=nil;

local SSD1Flag=nil;
local SSD2Flaf=nil;
local Flag=nil;

local BUY, SELL;

local BarSource = nil;         -- the source stream



function Prepare()

    -- collect parameters	

	K1 = instance.parameters.K1;
	SD1 = instance.parameters.SD1;
	D1 = instance.parameters.D1;
	K2 = instance.parameters.K2;
	SD2 = instance.parameters.SD2;
	D2  = instance.parameters.D2;
    
    ShowAlert = instance.parameters.ShowAlert;

    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

    SELL = " Down Trend";
    BUY = " Up Trend";

    ExtSetupSignal("  Dual Stochastic confirmation", ShowAlert);

    BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");

    SSD1 = core.indicators:create("SSD", BarSource, K1, SD1, D1);
	SSD2 = core.indicators:create("SSD", BarSource, K2, SD2, D2);

	
    local name = profile:id() .. "(" .. instance.bid:instrument()  .. "(" .. instance.parameters.Period  .. ")" .. "," .. K1 .. "," ..SD1..",".. D1 .."," .. K2.."," ..SD2..","..D2.. ")";
    instance:name(name);
	
	Flag=nil;
	
end



-- when tick source is updated
function ExtUpdate(id, source, period)

    
		if period > math.max((K1+SD1+D1), (K2+SD2+D2)) then
		            SSD1:update(core.UpdateLast);
					SSD2:update(core.UpdateLast);
						   
						if  core.crossesOver(SSD1.K, SSD1.D, period) then 						
							SSD1Flag = true;
							Flag=nil;
						end
						
						if  core.crossesUnder(SSD1.K, SSD1.D, period)  then							
							SSD1Flag = false;
							Flag=nil;
						end
						
						if  core.crossesOver(SSD2.K, SSD2.D, period) then  						
							SSD2Flag = true;
							Flag=nil;
						end
						
						if  core.crossesUnder(SSD2.K, SSD2.D, period)  then							
							SSD2Flag = false;
							Flag=nil;
						end
						
						
					if 	 SSD1Flag and SSD2Flag and Flag~= "Buy" then
					   ExtSignal(BarSource.close, period, BUY, SoundFile);
					   Flag="Buy";
					end
					
					if 	 not SSD1Flag and  not SSD2Flag and Flag ~= "Sell" then
					   ExtSignal(BarSource.close, period, SELL, SoundFile);
					   Flag="Sell";
					end 
		end				   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
