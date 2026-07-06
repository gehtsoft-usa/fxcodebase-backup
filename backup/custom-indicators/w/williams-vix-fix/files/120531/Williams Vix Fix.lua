-- Id: 21967
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66498

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

-- Indicator profile initialization routine

function Init()
    indicator:name("Williams Vix Fix");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("pd", "LookBack Period Standard Deviation High", "", 22, 2, 2000);
	indicator.parameters:addInteger("bbl", "Bolinger Band Length", "", 20, 2, 2000);
	indicator.parameters:addDouble("mult", "Bollinger Band Standard Devaition Up", "", 20, 1, 5);
	indicator.parameters:addInteger("lb", "Look Back Period Percentile High", "", 50, 2, 2000);
	
	indicator.parameters:addDouble("ph", "Highest Percentile - 0.90=90%, 0.95=95%, 0.99=99%", "", 0.85);
	indicator.parameters:addDouble("pl", "Lowest Percentile - 1.10=90%, 1.05=95%, 1.01=99%", "", 1.01);
	
	
	indicator.parameters:addBoolean("hp", "Show High Range - Based on Percentile and LookBack Period", "", false);
	indicator.parameters:addBoolean("sd", "Show Standard Deviation Line", "",  false);
	
 
	indicator.parameters:addGroup("Style"); 	
	
	color = core.colors(); 
	
    indicator.parameters:addColor("color1", "Bar Color", "", color.Lime);
	 indicator.parameters:addColor("color2", "Bar Color", "", color.Gray);
	 
	 indicator.parameters:addColor("color3", "Line Color", "", color.Orange);
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addColor("color4", "Line Color", "", color.Aqua);
	indicator.parameters:addInteger("style4", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width4", "Line Width", "", 3, 1, 5);

	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local first;
local source = nil;
 
local Oscillator;  


local pd,bbl,mult,lb,ph, pl, hp, sd;
local wvf;	
local lowerBand, upperBand
local rangeHigh, rangeLow;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	pd= instance.parameters.pd;
	bbl= instance.parameters.bbl;
	mult= instance.parameters.mult;
	lb= instance.parameters.lb;
	ph= instance.parameters.ph;
	pl= instance.parameters.pl;
	hp= instance.parameters.hp;
	sd= instance.parameters.sd;
 
			
    source = instance.source;
    first=source:first()+pd;
  
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    --Indicator[1] = core.indicators:create(Method1, source[Price1], Period1);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
    --Indicator[2] = core.indicators:create(Method2, source[Price2], Period2);
    
 
	lowerBand = instance:addInternalStream(first +bbl, 0);
	
	
	
	if sd then
	upperBand = instance:addStream("upperBand" , core.Line, " Upper Band"," Upper Band",instance.parameters.color4, first +bbl);
    upperBand:setPrecision(math.max(2, instance.source:getPrecision()));
	upperBand:setWidth(instance.parameters.width4);
    upperBand:setStyle(instance.parameters.style4);
	else
	upperBand = instance:addInternalStream(first +bbl, 0);
	end

	
	if hp then
	rangeLow = instance:addStream("rangeLow" , core.Line, " rangeLow"," rangeLow",instance.parameters.color3, first +lb);
    rangeLow:setPrecision(math.max(2, instance.source:getPrecision()));
	rangeLow:setWidth(instance.parameters.width3);
    rangeLow:setStyle(instance.parameters.style3);
	
	rangeHigh = instance:addStream("rangeHigh" , core.Line, " rangeHigh"," rangeHigh",instance.parameters.color3, first +lb);
    rangeHigh:setPrecision(math.max(2, instance.source:getPrecision()));
	rangeHigh:setWidth(instance.parameters.width3);
    rangeHigh:setStyle(instance.parameters.style3);
	else
	rangeHigh = instance:addInternalStream(first +lb, 0);
	rangeLow = instance:addInternalStream(first +lb, 0);
	end
	 
   
 
	wvf = instance:addStream("Oscillator" , core.Bar, " Williams Vix Fix"," Williams Vix Fix",instance.parameters.color1, first );
    wvf:setPrecision(math.max(2, instance.source:getPrecision()));
	 
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
  --  Indicator[1]:update(mode);
  --  Indicator[2]:update(mode);
	
	
    if period < first then
	return;
	end
	
	local min, max;
	
	max=mathex.max(source.close, period-pd+1, period);
	
	wvf[period] =  ((max-source.low[period])/max)*100;
	
	
	if period < first +bbl  then
	return;
	end

	local sDev= mult * mathex.stdev(wvf, period-bbl+1, period);
	local midLine= mathex.stdev(wvf, period-bbl+1, period);
	
	
	lowerBand[period] = midLine - sDev;
    upperBand[period] = midLine + sDev;
	
	
	if period < first +lb  then
	return;
	end
	
	
	min,max=mathex.minmax(wvf, period-lb+1, period);
	
	rangeHigh[period] = max * ph;
    rangeLow[period] = min * pl;

	
	 if wvf[period] >= upperBand[period] or wvf[period] >= rangeHigh[period] then
	 wvf:setColor(period, instance.parameters.color1);
	 else
	 wvf:setColor(period,instance.parameters.color2);
	 end
	
				  
end
