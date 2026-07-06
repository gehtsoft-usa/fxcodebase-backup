-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75489

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 

function Init()
    indicator:name("Price Action Above/Below MVA")
    indicator:description("Measures the percentage of price action above or below the MVA.")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("MAPeriod", "MVA Period", "Period for the moving average.", 5, 1, 100)
	indicator.parameters:addString("TF", "Time Frame", "", "D1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);	
	
    
    indicator.parameters:addGroup("Levels")
    indicator.parameters:addDouble("BuyLevel", "Buy Threshold (%)", "Percentage threshold for a buy trend.", 65, 50, 100)
    indicator.parameters:addDouble("SellLevel", "Sell Threshold (%)", "Percentage threshold for a sell trend.", 35, 0, 50)
    
    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("AboveColor", "Above MVA Color", "Color for price action above MVA.", core.rgb(0, 255, 0))
    indicator.parameters:addColor("BelowColor", "Below MVA Color", "Color for price action below MVA.", core.rgb(255, 0, 0))
    indicator.parameters:addColor("NeutralColor", "Neutral Color", "Color for neutral price action.", core.rgb(128, 128, 128))
	
 
    indicator.parameters:addDouble("Level1", "1. Level","", 65);
	indicator.parameters:addDouble("Level2", "2. Level","", 50);
	indicator.parameters:addDouble("Level3", "3. Level","", 35); 
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);		
	
	

end

local MAPeriod, BuyLevel, SellLevel
local AboveColor, BelowColor, NeutralColor
local MVA, Output

function Prepare(nameOnly)
    MAPeriod = instance.parameters.MAPeriod
    BuyLevel = instance.parameters.BuyLevel
    SellLevel = instance.parameters.SellLevel
    AboveColor = instance.parameters.AboveColor
    BelowColor = instance.parameters.BelowColor
    NeutralColor = instance.parameters.NeutralColor
	TF= instance.parameters.TF;

    local name = string.format("Price Action Above/Below MVA (%d)", MAPeriod)
    instance:name(name)
	
    if nameOnly then
        return
    end
    source = instance.source;
    first = source:first();		
	
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");	
	
	
	local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	
	
	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), MAPeriod, 100, 101);
	loading=true;	
	

    MVA = core.indicators:create("MVA", Source.close, MAPeriod)
    Output = instance:addStream("Output", core.Line, "Above/Below MVA", "Output", core.rgb(255, 255, 255), 0) 
	Output:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.AboveColor);
	Output:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.NeutralColor);
	Output:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.BelowColor);	
end

function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);

  
    if loading or Source:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

 
function Update(period, mode)


    MVA:update(mode)

    local p =  Initialization(period) 
 

    if loading or MVA.DATA:size()-1 < MAPeriod or  p == false then
        return
    end


 
	local date = core.host:execute ("convertTime",  core.TZ_UTC, core.TZ_TS, source:date(period));  
    local dayStart, dayEnd = core.getcandle(TF, date, dayoffset, weekoffset);	
	
    local Start = core.findDate(source, dayStart, false);
    local End = core.findDate(source, dayEnd, false);	
 
    if  Start< 0 or End < 0 then
	return;
	end
	
    local aboveCount, belowCount = 0, 0	

    for i = Start, End,1 do
        if source.close[i] > MVA.DATA[p] then
            aboveCount = aboveCount + 1
        else
            belowCount = belowCount + 1
        end
    end

    local total = aboveCount + belowCount
    if total > 0 then
        local abovePercent = (aboveCount / total) * 100
        Output[period] = abovePercent
	else
        Output[period] = 0	
    end
end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
	
	return core.ASYNC_REDRAW	
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75489

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 