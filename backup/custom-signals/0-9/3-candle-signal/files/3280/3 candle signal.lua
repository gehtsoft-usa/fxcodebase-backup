-- Id: 1138
function Init()
    strategy:name("3 candle signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("3 candle signal");

    strategy.parameters:addGroup("Parameters");

	
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
local BUY, SELL;
local BarSource = nil;         -- the source stream

function Prepare()
    
    ShowAlert = instance.parameters.ShowAlert;

    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

    SELL = " Short";
    BUY = " Long";

    ExtSetupSignal(" 3 candle", ShowAlert);

    BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");

    local name = profile:id() .. "(" .. instance.bid:instrument()  .. "(" .. instance.parameters.Period  .. ")" ..")";
    instance:name(name);
end



-- when tick source is updated
function ExtUpdate(id, source, period)
					
				
				if period > 3 then			
				             
							local Body= math.abs(BarSource.close[period]-BarSource.open[period]);	 
						   
							if  math.abs(BarSource.close[period-2]-BarSource.open[period-2]) < Body  and  math.abs(BarSource.close[period-1]-BarSource.open[period-1]) < Body then
							
									if BarSource.close[period-1] < BarSource.open[period-1]  and BarSource.close[period] > BarSource.open[period] then
									ExtSignal(BarSource.close, period, BUY, SoundFile);
									end
									
									if BarSource.close[period-1] > BarSource.open[period-1]  and BarSource.close[period] < BarSource.open[period] then
									ExtSignal(BarSource.close, period, SELL, SoundFile);							
									end
							end	
		end					
					   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
