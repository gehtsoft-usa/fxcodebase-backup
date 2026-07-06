-- Id: 1272
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
    strategy:name("T3 signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("T3 signal");

    strategy.parameters:addGroup("Parameters");


    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addDouble("VF", "Volume Factor", "Volume Factor", 0.7, 0, 1);
    strategy.parameters:addInteger("F", "Period", "Period",20,2,2000);
	
	strategy.parameters:addBoolean("Turning", "Show Turning point", "", true);
	strategy.parameters:addBoolean("Cross", "Show Cross Over", "", true);
	

    strategy.parameters:addString("Period", "Timeframe", "", "m5");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
end

local b=nil;
local Frame=nil;
local Turning=nil;
local Cross=nil;

local GD1=nil;
local GD2=nil;
local GD3=nil;


local ShowAlert;
local SoundFile;
local BUY, SELL;
local TickSource = nil;         -- the source stream
local first;

function Prepare()

    ShowAlert = instance.parameters.ShowAlert;

     b = instance.parameters.VF;
    Frame = instance.parameters.F;
	Cross = instance.parameters.Cross;
    Turning = instance.parameters.Turning;
	

    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

    BUY = " Up Trend";
    SELL = " Down Trend";

    ExtSetupSignal(" T3", ShowAlert);

    TickSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "close");

    assert(core.indicators:findIndicator("GD") ~= nil, "GD" .. " indicator must be installed");
	 GD1 = core.indicators:create("GD", TickSource, b, Frame);
	 GD2 = core.indicators:create("GD", GD1.DATA, b, Frame);
     GD3 = core.indicators:create("GD", GD2.DATA, b, Frame);

    local name = profile:id() .. " ( " .. instance.bid:instrument()  .. " ( " .. instance.parameters.Period  .. " ) ".. b .. ", ".. Frame .." )";
    instance:name(name);
end



-- when tick source is updated
function ExtUpdate(id, source, period)

		if period > Frame*3 then

			GD1:update(core.UpdateLast);
			GD2:update(core.UpdateLast);
			GD3:update(core.UpdateLast);
			
			if Turning then
			 
						if GD3.DATA[period-1] < GD3.DATA[period] and  GD3.DATA[period-1] < GD3.DATA[period-2]then
						ExtSignal(GD3.DATA, period-1, BUY, SoundFile);
						end
						if GD3.DATA[period-1] > GD3.DATA[period] and  GD3.DATA[period-1] > GD3.DATA[period-2] then		
						ExtSignal(GD3.DATA, period-1, SELL, SoundFile);
						end
			end		

			if Cross then 
					  
						  if core.crossesOver(TickSource, GD3.DATA, period)   then
								ExtSignal(TickSource, period, BUY, SoundFile);
						   elseif core.crossesUnder(TickSource, GD3.DATA, period)  then
								 ExtSignal(TickSource, period, SELL, SoundFile);              
						  end

			end 	
				  
		end    
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
