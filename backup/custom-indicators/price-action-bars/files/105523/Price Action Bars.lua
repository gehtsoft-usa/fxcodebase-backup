
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63317


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


function Init()
    indicator:name("Price Action Bars");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator); 
    indicator:setTag("replaceSource", "t");
    indicator.parameters:addGroup("Calculation");
 
    
	indicator.parameters:addInteger("pctP", "Percentage Input For PBars, What % The Wick Of Candle Has To Be", "", 66, 1, 99);
	indicator.parameters:addInteger("pblb", "Bars Look Back Period To Define The Trend of Highs and Lows", "", 6, 1,100);
	indicator.parameters:addInteger("pctS", "Percentage Input For Shaved Bars, Percent of Range it Has To Close On The Lows or Highs", "", 5, 1, 99);
 
    indicator.parameters:addBoolean("spb", "Show Pin Bars", "", true);
    indicator.parameters:addBoolean("ssb", "Show Shaved Bars", "", true);
	indicator.parameters:addBoolean("sib", "Show Inside Bars", "", true);
	indicator.parameters:addBoolean("sob", "Show Outside Bars", "", true);
	indicator.parameters:addBoolean("sgb", "Check Box To Turn Bars Gray", "", true);
	
	indicator.parameters:addGroup("Style");
	
	color = core.colors ()
	indicator.parameters:addColor("Color1", "Pin Bar Up Color", "", color.Lime);
	indicator.parameters:addColor("Color2", "Pin Bar Down Color", "", color.Red);
	indicator.parameters:addColor("Color3", "Shaved Bar Up Color", "", color.Fuchsia);
	indicator.parameters:addColor("Color4", "Shaved Bar Down Color", "", color.Aqua);
	indicator.parameters:addColor("Color5", "Inside Bar Color", "", color.Yellow);
	indicator.parameters:addColor("Color6", "Outside Bar Color", "", color.Orange);
	
	indicator.parameters:addColor("NEUTRAL", "Color of Neutral Candle", "", core.rgb(128,128,128));
	
 
end
 

local spb, ssb, sib, sob, sgb,pctP,pblb,pctS;
local open = nil;
local high = nil;
local low = nil;
local close = nil;

local first;
local NEUTRAL;
local Color1, Color2,Color3,Color4,Color5,Color6;

local pctCp, pctCPO, pctCs;
-- Routine
function Prepare(nameOnly) 
    source = instance.source;    
	NEUTRAL= instance.parameters.NEUTRAL;
    
	spb= instance.parameters.spb;
	ssb= instance.parameters.ssb;
	sib= instance.parameters.sib;
	sob= instance.parameters.sob;
	sgb= instance.parameters.sgb;
	pctP= instance.parameters.pctP;
	pblb= instance.parameters.pblb;
	pctS= instance.parameters.pctS;
	Color1= instance.parameters.Color1;
	Color2= instance.parameters.Color2;
	Color3= instance.parameters.Color3;
	Color4= instance.parameters.Color4;
	Color5= instance.parameters.Color5;
	Color6= instance.parameters.Color6;
	
	first=source:first()+pblb;
	
	 --PBar Percentages
	pctCp = pctP * 0.01
	pctCPO = 1 - pctCp

	--Shaved Bars Percentages
	pctCs = pctS * 0.01
	
	local name = "Price Action Bars" 
    instance:name(name); 
	
	if   (nameOnly) then
        return;
    end
	
   
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("HAS", "HAS", open, high, low, close);
end

-- Indicator calculation routine
function Update(period, mode)
 
 
        if period  < first then
		open:setColor(period, NEUTRAL);	
		return;
		end
		
		 
        open[period] = source.open[period];
        close[period] = source.close[period];
        high[period] = source.high[period];
        low[period] = source.low[period];
		
		
		local range = source.high[period] - source.low[period];
		local min, max=mathex.minmax(source, period-pblb+1, period);
		local pBarUp=false;
		local pBarDn=false;
		local sBarUp=false;
		local sBarDown=false;
		local insideBar=false;
		local outsideBar=false;
		
		
 
 

--PinBars
 if source.open[period] > source.high[period] - (range * pctCPO) and source.close[period] > source.high[period] - (range * pctCPO) and source.low[period] <= min then
 pBarUp=true;
 else 
 pBarUp=false;
 end
 

 if source.open[period] < source.high[period] - (range * pctCp) and source.close[period] < source.high[period]-(range * pctCp) and source.high[period] >= max then
 pBarDn=true;
 else 
 pBarDn=false;
 end

--Shaved Bars
if (source.close[period] >= (source.high[period] - (range * pctCs)))then
sBarUp=true;
else 
sBarUp=false;
end
 
 
if  source.close[period] <= (source.low[period] + (range * pctCs))then
sBarDown=true;
else 
sBarDown=false;
end
 
--Inside Bars
 if source.high[period] <= source.high[period-1] and source.low[period] >= source.low[period-1] then
 insideBar=true;
else 
insideBar=false;
end

--OutsideBar
 if (source.high[period] > source.high[period-1] and source.low[period] < source.low[period-1])  then
 outsideBar=true;
else 
outsideBar=false;
end
 
 
		
	    if  spb and pBarUp then
		open:setColor(period, Color1);	
		elseif spb and pBarDn then
		open:setColor(period, Color2);	
        elseif  ssb and  sBarUp then
		open:setColor(period, Color3);	
		elseif ssb and  sBarDown then
		open:setColor(period, Color4);
        elseif  sib and insideBar then
		open:setColor(period, Color5);	
		elseif sob and outsideBar then
		open:setColor(period, Color6);	
        elseif  sgb then
		open:setColor(period, NEUTRAL);	
		else
		   if source.close[period]>    source.open[period] then
		   open:setColor(period, core.COLOR_UPCANDLE );
		   else
		   open:setColor(period, core.COLOR_DOWNCANDLE );	
           end		   
		end		
    
end


