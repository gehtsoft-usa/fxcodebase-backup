-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2430
-- Id: 18092

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Averages Arrows");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("Selector");
	indicator.parameters:addString("Type", "Overlay Type", "", "Slope");
    indicator.parameters:addStringAlternative("Type", "1. MA Slope", "", "Slope");
    indicator.parameters:addStringAlternative("Type", "1. MA / Price", "", "MAPrice");
	indicator.parameters:addStringAlternative("Type", "1. MA / 2. MA", "", "2MA");
	
    indicator.parameters:addGroup("1. MA Calculation");
	
	indicator.parameters:addString("Price1", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");	
	
	
    indicator.parameters:addString("Method1", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method1", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method1", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method1", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method1", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method1", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method1", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method1", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method1", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method1", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method1", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method1", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method1", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method1", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method1", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method1", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method1", "JSmooth", "", "JSmooth");
	indicator.parameters:addStringAlternative("Method1", "KAMA", "", "KAMA");

    indicator.parameters:addInteger("Period1", "Period", "", 20);
	
	
	indicator.parameters:addGroup("2. MA Calculation");
	
	indicator.parameters:addString("Price2", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");	
	
	
    indicator.parameters:addString("Method2", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method2", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method2", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method2", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method2", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method2", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method2", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method2", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method2", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method2", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method2", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method2", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method2", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method2", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method2", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method2", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method2", "JSmooth", "", "JSmooth");
	indicator.parameters:addStringAlternative("Method2", "KAMA", "", "KAMA");

    indicator.parameters:addInteger("Period2", "Period", "", 40);
 

    indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("Up", "UP color", "UP color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Down", "DN color", "DN color", core.rgb(0, 0, 255)); 
	indicator.parameters:addInteger("Size", "Arrow Size", "Size", 10);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
 
local first;
local source = nil;

-- Streams block
local Up, Down;
local Method1, Period1;
local Method2, Period2;
 
 
local Indicator1, Indicator2;
local Price1, Price2;
local Type;
local up,down,Size;
-- Routine
function Prepare(nameOnly)
    Method1= instance.parameters.Method1;
	Period1= instance.parameters.Period1;
	Method2= instance.parameters.Method2;
	Period2= instance.parameters.Period2;
	Size= instance.parameters.Size;
	Type= instance.parameters.Type;
	Price1= instance.parameters.Price1;
	Price2= instance.parameters.Price2;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;

	Price= instance.parameters.Price;
    source = instance.source;
    
    local name = profile:id() .. "(" .. source:name() .. ", " ..Method1 .. ", " .. Period1 .. ", " ..Method2 .. ", " .. Period2 .. ")";
    instance:name(name); 
    if nameOnly then
        return;
    end

    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");
	

	 if Method1 == "HPF" or Method1 == "VAMA" then
        Indicator1 = core.indicators:create("AVERAGES", source, Method1,Period1, false);
	else
	     Indicator1 = core.indicators:create("AVERAGES", source[Price1], Method1,Period1, false);
    end
	
	first = Indicator1.DATA:first() ;
	
    if Type == "2MA"	 then
		if Method2 == "HPF" or Method2 == "VAMA" then
			Indicator2 = core.indicators:create("AVERAGES", source, Method2,Period2, false);
		else
			 Indicator2 = core.indicators:create("AVERAGES", source[Price2], Method2,Period2, false);
		end
		first = math.max(first ,Indicator2.DATA:first());
	end	
	 	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, Up, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, Down, 0); 
 
 
	
end

-- Indicator calculation routine
function Update(period, mode)
	
	Indicator1:update(mode);
	
   down:setNoData(period);
   up:setNoData(period);
    
	if period < first then
	return;
	end 
	
	if Type == "Slope" then 
	
		if source.close[period]>Indicator1.DATA[period] 
		and source.close[period-1]<=Indicator1.DATA[period-1] 
		then
		up:set(period, source.high[period], "\217", source.high[period ]); 
		elseif source.close[period]<Indicator1.DATA[period] 
		and source.close[period-1]>=Indicator1.DATA[period-1] 
		then
		down:set(period, source.low[period], "\218", source.low[period ]); 	 
		end
	elseif Type == "2MA" then 
	    Indicator2:update(mode);
	    if Indicator1.DATA[period]>Indicator2.DATA[period] 
		and  Indicator1.DATA[period-1]<= Indicator2.DATA[period-1] 
		then
		up:set(period, source.high[period], "\217", source.high[period ]); 
		elseif Indicator1.DATA[period]<Indicator2.DATA[period] 
		and  Indicator1.DATA[period-1]>= Indicator2.DATA[period-1] 
		then
	    down:set(period, source.low[period], "\218", source.low[period ]); 	 
		end
		
    end	
		
 
end

 