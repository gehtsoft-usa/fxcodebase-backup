-- Id: 13885
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62056

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 14 "Behavioral techniques" (page 358-361)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Elliot Wave Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Waves");

    indicator.parameters:addGroup("EWO Calculation");
    indicator.parameters:addInteger("FastN", "Fast Moving Average","", 5, 2, 1000);
    indicator.parameters:addInteger("SlowN", "Slow Moving Average","", 35, 2, 1000);

    indicator.parameters:addString("Source","Price source","", "M2");
    indicator.parameters:addStringAlternative("Source", "Typical (H+L+C)/3", "", "M3");
    indicator.parameters:addStringAlternative("Source", "Median (H+L)/2", "", "M2");
    indicator.parameters:addStringAlternative("Source", "Close", "", "C");

    indicator.parameters:addString("Method", "Smoothing method","", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "Vidya (1995)", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("Method", "Wilders", "", "WMA");
	
	indicator.parameters:addGroup(" MA Filter Calculation");
	
	indicator.parameters:addString("Price1", "1. MA Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");	

	indicator.parameters:addString("Method1", "1. MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Period1", "1. MA Period","", 10, 2, 1000);
	

    indicator.parameters:addString("Price2", "2. MA Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");	

	indicator.parameters:addString("Method2", "2. MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	 indicator.parameters:addInteger("Period2", "2. MA Period","", 100, 2, 1000);


    indicator.parameters:addString("Price3", "3. MA Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price3", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price3", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price3", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price3","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price3", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price3", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price3", "WEIGHTED", "", "weighted");	

	indicator.parameters:addString("Method3", "3. MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
	
	 indicator.parameters:addInteger("Period3", "3. MA Period","", 200, 2, 1000);	 
	 

	indicator.parameters:addGroup("Color Selector"); 
	indicator.parameters:addString("Type", "Coloring method","", "MA Filter");
    indicator.parameters:addStringAlternative("Type", "EWO Slope", "", "Slope");
    indicator.parameters:addStringAlternative("Type", "MA Filter", "", "MA Filter");
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUpGrow", "Up growing Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrUpFall","Up falling Color","", core.rgb(0, 127, 0));
    indicator.parameters:addColor("clrDnGrow","Down growing Color","", core.rgb(127, 0, 0));
    indicator.parameters:addColor("clrDnFall", "Down falling Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("clrNeGrow","Neutral growing Color","", core.rgb(128, 128, 128));
    indicator.parameters:addColor("clrNeFall", "Neutral falling Color", "", core.rgb(64, 64, 64));
end

-- Indicator instance initialization routine
local first;
local first1;
local source = nil;
local Type;
-- Streams block
local FMA = nil;
local SMA = nil;
local EWO = nil;
local UPGROW = nil;
local UPFALL = nil;
local DNGROW = nil;
local DNFALL = nil;
local NEGROW = nil;
local NEFALL = nil; 
local srcmode;
local prior;
local Price1, Price2,Price3, Method1,Method2,Method2,Period1,Period2,Period3;
local ma1, ma2,ma3;
-- Routine
function Prepare(nameOnly)
    Type = instance.parameters.Type;
    assert(instance.parameters.FastN < instance.parameters.SlowN, "Fast MA must be faster than Slow MA");
    srcmode = instance.parameters.Source;
    source = instance.source;
    first1 = source:first();
	
	Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
	Period3 = instance.parameters.Period3;
	Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
	Method3 = instance.parameters.Method3;
	Price1 = instance.parameters.Price1;
    Price2 = instance.parameters.Price2;
   	Price3 = instance.parameters.Price3;
	assert(core.indicators:findIndicator(Method1) ~= nil, "Please, download and install ".. Method1 ..".LUA indicator"); 
	assert(core.indicators:findIndicator(Method2) ~= nil, "Please, download and install ".. Method2..".LUA indicator");  
	assert(core.indicators:findIndicator(Method3) ~= nil, "Please, download and install ".. Method3 ..".LUA indicator");  	

    local SRC;
    
    if srcmode == "M3" then
        SRC = source.typical;
    elseif srcmode == "M2" then
        SRC = source.median;
    else
        SRC = source.close;
    end
    local name = profile:id() .. "(" .. source:name() .. "," .. instance.parameters.FastN .. "," ..  instance.parameters.SlowN .. "," ..  instance.parameters.Method  .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    
    assert(core.indicators:findIndicator(instance.parameters.Method) ~= nil, instance.parameters.Method .. " indicator must be installed");
    FMA = core.indicators:create(instance.parameters.Method, SRC, instance.parameters.FastN);
    SMA = core.indicators:create(instance.parameters.Method, SRC, instance.parameters.SlowN);
	
	ma1 = core.indicators:create(Method1, source[Price1], Period1);
    ma2 = core.indicators:create(Method2, source[Price2], Period2);
	ma3 = core.indicators:create(Method3, source[Price3], Period3);

    first = math.max(SMA.DATA:first(), FMA.DATA:first());
    first1 = first + 1;

    local precision = math.max(2, source:getPrecision());
    EWO = instance:addStream("EWO", core.Bar, name .. ".EWO", "EWO", instance.parameters.clrNeGrow, first);
    EWO:setPrecision(precision);

    UPGROW = instance.parameters.clrUpGrow;
    UPFALL = instance.parameters.clrUpFall;
    DNGROW = instance.parameters.clrDnGrow;
    DNFALL = instance.parameters.clrDnFall;
	NEGROW = instance.parameters.clrNeGrow;
    NEFALL = instance.parameters.clrNeFall;
    EWO:addLevel(0);
end

-- Indicator calculation routine
function Update(period, mode)
    local curr, prev;
    SMA:update(mode);
    FMA:update(mode);

    if period < first then
	EWO:setColor(period, NEUTRAL);
	return;
	end
        EWO[period] = FMA.DATA[period] - SMA.DATA[period];
    

    if period <first1 then
	EWO:setColor(period, NEUTRAL);
	return;
	end
	
	
        curr = EWO[period];
        prior = EWO[period - 1];
		
		
	if Type == "Slope" then	
		
        if curr >= 0 then
            if curr > prior then
                EWO:setColor(period, UPGROW);
            elseif curr < prior then
                EWO:setColor(period, UPFALL);
            else
                EWO:setColor(period, EWO:colorI(period - 1));
            end
        elseif curr < 0 then
            if curr > prior then
                EWO:setColor(period, DNGROW);
            elseif curr < prior then
                EWO:setColor(period, DNFALL);
            else
                EWO:setColor(period, EWO:colorI(period - 1));
            end
        end
    else
	 
	       ma1:update(mode);
		   ma2:update(mode);
	       ma3:update(mode);
	 
	       if period < math.max(ma1.DATA:first(), ma2.DATA:first(), ma3.DATA:first()) then
		   return;
		   end
 
		   
		     if (ma2.DATA[period] > ma3.DATA[period]  and  ma1.DATA[period] >ma2.DATA[period]) then
					if curr > prior then
						EWO:setColor(period, UPGROW);
					elseif curr < prior then
						EWO:setColor(period, UPFALL);
					else
						EWO:setColor(period, EWO:colorI(period - 1));
					end
			 elseif   (ma2.DATA[period] < ma3.DATA[period]  and  ma1.DATA[period] < ma2.DATA[period]) then
			 
					if curr > prior then
						EWO:setColor(period, DNGROW);
					elseif curr < prior then
						EWO:setColor(period, DNFALL);
					else
						EWO:setColor(period, EWO:colorI(period - 1));
             
					end	
			  
             else
			        if curr > prior then
						EWO:setColor(period, NEGROW);
					elseif curr < prior then
						EWO:setColor(period, NEFALL);
					else
						EWO:setColor(period, EWO:colorI(period - 1));
             
					end	
			 end
		   
	end
	
	
end


