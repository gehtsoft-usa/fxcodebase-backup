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

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=61974




-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Bars identifier");
    indicator:description("Bars identifier");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("spb", "Show Pin Bars", "", true);
	indicator.parameters:addBoolean("ssb", "Show Shaved Bars", "", true);
	indicator.parameters:addBoolean("sib", "Show Inside Bars", "", true);
	indicator.parameters:addBoolean("sob", "Show Outside Bars", "", true);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("pctP", "Percentage Input For Pin Bars", " What % The Wick Of Candle Has To Be", 66, 1, 99);
	indicator.parameters:addInteger("pblb", "Pin Bars Look Back Period To Define The Trend of Highs and Lows", "", 6, 1, 100);
	indicator.parameters:addDouble("pctS", "Percentage Input For Shaved Bars", "Percent of Range it Has To Close On The Lows or Highs", 5, 1, 99);
 
    indicator.parameters:addGroup("Style");
	indicator.parameters:addBoolean("Neutral", "Turn Regular Bars Neutral", "", true);
    indicator.parameters:addColor("Up", "Color of Up Candle", "Color of Up Candle", core.COLOR_UPCANDLE);
	indicator.parameters:addColor("Down", "Color of Down Candle", "Color of Down Candle",  core.COLOR_DOWNCANDLE);
	indicator.parameters:addColor("Color", "Color of Neutral", "Color of Neutral",  core.rgb(128, 128, 128));
	
	local color = core.colors(); 
	
	indicator.parameters:addColor("pBarUpColor", "Pin Bar Up Color", "Pin Bar Up",  color.Lime);
	indicator.parameters:addColor("pBarDnColor", "Pin Bar Down Color", "Pin Bar Down",  color.Red);
	indicator.parameters:addColor("sBarUpColor", "Shaved Bar Up Color", "Shaved Bar Up",  color.Aqua);
	indicator.parameters:addColor("sBarDownColor", "Shaved Bar Down Color", "Shaved Bar Down",  color.Fuchsia);
	indicator.parameters:addColor("insideBarColor", "Inside Bar Color", "Inside Bar",  color.Yellow);
	indicator.parameters:addColor("outsideBarColor", "Outside Bar Color", "Outside Bar",  color.Orange);
end

 
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local spb, ssb, sib, sob;
local open=nil;
local close=nil;
local high=nil;
local low=nil;
local Neutral;
local Color;
local pctP, pblb, pctS;
-- Routine
function Prepare(nameOnly)
    source = instance.source; 
	Neutral=instance.parameters.Neutral;
	Color=instance.parameters.Color;
	spb=instance.parameters.spb;
	ssb=instance.parameters.ssb;
	sib=instance.parameters.sib;
	sob=instance.parameters.sob;
	pctP=instance.parameters.pctP;
	pblb=instance.parameters.pblb;
	pctS=instance.parameters.pctS;
	
	first= source:first()+pblb;
	--PBar Percentages
	pctCp = pctP * 0.01
	pctCPO = 1 - pctCp

	--Shaved Bars Percentages
	pctCs = pctS * 0.01
	pctSPO = pctCs

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), source:first())
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), source:first())
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), source:first())
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), source:first())
    instance:createCandleGroup("ZONE", "", open, high, low, close);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	
	
	
	if period < first then
	open:setColor(period,  Color);
	return;
	end
	
	


local range = source.high[period] - source.low[period];


local pBarUp= false;
local pBarDn= false;
local sBarUp=false;
local sBarDown=false;
local insideBar=false;
local outsideBar=false;

local min, max= mathex.minmax(source, period-pblb+1, period)


	 --PinBars
	if spb then
		if (source.open[period] > source.high[period] - (range * pctCPO)) and ( source.close[period] > source.high[period] - (range * pctCPO)) and (source.low[period] <= min)  then
		pBarUp=true;
		end

		if (source.open[period] < source.high[period] - (range *  pctCp)) and (source.close[period] < source.high[period]-(range * pctCp)) and (source.high[period] >= max)  then
		pBarDn=true;
		end
	end


	--Shaved Bars
	if ssb then
	  if (source.close[period] >= (source.high[period] - (range * pctCs))) then
	  sBarUp=true;
	  end
	  if source.close[period] <= (source.low[period] + (range * pctCs)) then
	  sBarDown=true;
	  end
	end

	--Inside Bars
	if sib then
	 if source.high[period] <= source.high[period-1] and source.low[period] >= source.low[period-1] then  
	 insideBar= true;
	 end
	end

  --Outside Bars
	if sob  then
	  if source.high[period] > source.high[period-1] and source.low[period] < source.low[period-1] then
	  outsideBar= true;
	  end
	  
	end 
	
    
    
	if pBarUp then
	open:setColor(period,  instance.parameters.pBarUpColor);
	elseif pBarDn then
	open:setColor(period,  instance.parameters.pBarDnColor);
	elseif sBarUp then
	open:setColor(period,  instance.parameters.sBarUpColor);
	elseif sBarDown then
	open:setColor(period,  instance.parameters.sBarDownColor);
	elseif insideBar then
	open:setColor(period,  instance.parameters.insideBarColor);
	elseif outsideBar then
	open:setColor(period,  instance.parameters.outsideBarColor);
	elseif Neutral then
	open:setColor(period,  Color);
	elseif source.close[period]> source.open[period] then
	open:setColor(period,  instance.parameters.Up);
	else
	open:setColor(period, instance.parameters.Down);
	end
	
		
end





