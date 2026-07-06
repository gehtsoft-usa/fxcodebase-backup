-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76231

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
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
    indicator:name("Arrow MA Cross")
    indicator:description("Crta strelice Wingdings kada se Fast MA prekriži sa Slow MA.")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addString("Price", "Price Source", "", "close")
    indicator.parameters:addStringAlternative("Price","OPEN","", "open")
    indicator.parameters:addStringAlternative("Price","HIGH","", "high")
    indicator.parameters:addStringAlternative("Price","LOW","", "low")
    indicator.parameters:addStringAlternative("Price","CLOSE","", "close")
    indicator.parameters:addStringAlternative("Price","MEDIAN","", "median")
    indicator.parameters:addStringAlternative("Price","TYPICAL","", "typical")
    indicator.parameters:addStringAlternative("Price","WEIGHTED","", "weighted")

    indicator.parameters:addString("Method", "MA Method", "", "EMA")
    indicator.parameters:addStringAlternative("Method","MVA","","MVA")
    indicator.parameters:addStringAlternative("Method","EMA","","EMA")
    indicator.parameters:addStringAlternative("Method","LWMA","","LWMA")
    indicator.parameters:addStringAlternative("Method","SMMA","","SMMA")
    indicator.parameters:addStringAlternative("Method","TMA","","TMA")
    indicator.parameters:addStringAlternative("Method","KAMA","","KAMA")
    indicator.parameters:addStringAlternative("Method","VIDYA","","VIDYA")
    indicator.parameters:addStringAlternative("Method","WMA","","WMA")

    indicator.parameters:addInteger("Period", "Period", "", 18, 1, 10000)

    indicator.parameters:addGroup("Style (Arrows)")
    indicator.parameters:addColor("UpColor", "Up Arrow Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("DownColor", "Down Arrow Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("FontSize", "Wingdings Size (pt)", "", 20, 6, 36)
 
end

-- var
local source, srcP
local fastMA, slowMA
local firstCalc
local upTxt, dnTxt
local UpColor, DownColor
local UpChar, DownChar="\217","\218";

function Prepare(nameOnly)
    source = instance.source
    srcP   = source[instance.parameters.Price]
	Period=instance.parameters.Period;

    -- MA instanci (koriste se SDK ugrađeni indikatori):contentReference[oaicite:3]{index=3}:contentReference[oaicite:4]{index=4}
    --fastMA = core.indicators:create(instance.parameters.Method, srcP, instance.parameters.Fast)
    --slowMA = core.indicators:create(instance.parameters.Method, srcP, instance.parameters.Slow)

    -- prvi valjani bar za usporedbe (treba mjesta i za prethodni bar)
    firstCalc = source:first() + Period

    local name = string.format("Arrow MA Cross (%s,%d,%s)",
        instance.parameters.Price, instance.parameters.Period, instance.parameters.Method)
    instance:name(name)
    if nameOnly then return end

    UpColor   = instance.parameters.UpColor
    DownColor = instance.parameters.DownColor

 

    -- Tekstualni izlazi za strelice (oscilator panel):contentReference[oaicite:5]{index=5}
    upTxt = instance:createTextOutput("Up", "Up", "Wingdings", instance.parameters.FontSize,
        core.H_Center, core.V_Bottom , UpColor, firstCalc)
    dnTxt = instance:createTextOutput("Down", "Down", "Wingdings", instance.parameters.FontSize,
        core.H_Center,core.V_Top, DownColor, firstCalc)
		
    core.host:execute ("attachTextToChart", "Up")
    core.host:execute ("attachTextToChart", "Down")		
		
		

    -- Dodamo i “prazan” numeric stream da panel postoji (oscilator zona)
    -- vrijednosti nisu bitne; držimo ih na 0
    OUT = instance:addStream("OUT", core.Line, name, "OUT", UpColor, firstCalc)
    OUT:setWidth(1)
    OUT:setStyle(core.LINE_DOT)
	
    Value = instance:addInternalStream(0, 0);	
end

function Update(period, mode)
    -- ažuriraj MA izračun (bitno: update(mode) kad god naš Update radi):contentReference[oaicite:6]{index=6}
   -- fastMA:update(mode)
   -- slowMA:update(mode)

    -- Osiguraj dovoljno podataka
    if period <= firstCalc then
        return
    end
 
    local MinL, MaxH= mathex.minmax(source, period-Period+1, period)
 
		if (MaxH - MinL == 0) then
			Value[period] = 0.33 * 2 * (0 - 0.5) + 0.67 * Value[period-1]
		else
			Value[period] = 0.33 * 2 * ((source.median[period] - MaxH) / (MinL - MaxH) - 0.5) + 0.67 * Value[period-1]
		end

		-- clamp to [-0.999, 0.999]
		Value[period] = math.min(math.max(Value[period], -0.999), 0.999)

 
		if (1 - Value[period] == 0) then
			OUT[period] = 0.5 + 0.5 * OUT[period-1]
		else
			OUT[period] = 0.5 * math.log((1 + Value[period]) / (1 - Value[period])) + 0.5 * OUT[period-1]
		end
 

 
         if OUT[period] < 0 and OUT[period-1]>= 0  then
            local y = source.low[period]		 		 
                upTxt:set(period, y, UpChar)
                dnTxt:setNoData(period)  
       
        elseif OUT[period] > 0 and OUT[period-1]<= 0  then 
            local y = source.high[period]     
                dnTxt:set(period,y, DownChar)
                upTxt:setNoData(period)
   
        else
                dnTxt:setNoData(period)
                upTxt:setNoData(period)				
        end
     
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76231

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
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