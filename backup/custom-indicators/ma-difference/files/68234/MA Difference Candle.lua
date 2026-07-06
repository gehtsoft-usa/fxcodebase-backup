-- Id: 13799
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

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=41822

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("MA Difference Candle");
    indicator:description("MA Difference Candle");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Selector");	 
	 

	indicator.parameters:addString("Type", "Method", "Method" , "Price/MA");
    indicator.parameters:addStringAlternative("Type", "Price/MA", "Price/MA","Price/MA");
    indicator.parameters:addStringAlternative("Type", "MA/Price", "MA/Price" , "MA/Price");
	indicator.parameters:addStringAlternative("Type", "MA1/MA2", "MA1/MA2" , "MA1/MA2");
	indicator.parameters:addStringAlternative("Type", "MA2/MA1", "MA2/MA1" , "MA2/MA1");
	indicator.parameters:addBoolean("Absolute", "Absolute", "", false);
	indicator.parameters:addBoolean("Pips", "Pips", "", false);
	
    indicator.parameters:addGroup("First MA Calculation");	
    indicator.parameters:addInteger("Period1", "First MA Period", "", 14);
 
	indicator.parameters:addString("Method1", "First MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addGroup("Second MA Calculation");	
    indicator.parameters:addInteger("Period2", "Second MA Period", "", 14);	
	indicator.parameters:addString("Method2", "Second MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 0);
    indicator.parameters:addDouble("oversold","Oversold Level","", 0);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

    
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;
local Period1, Period2;
local Method1, Method2;
local One={};
local Two={};
local Type;
-- Streams block
local Open = nil;
local Close = nil;
local High = nil;
local Low = nil;
local Absolute,Pips;
-- Routine
function Prepare(nameOnly)
    Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
	Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
	Absolute= instance.parameters.Absolute;
	Pips= instance.parameters.Pips;
	Type = instance.parameters.Type;
    source = instance.source;
    

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Type).. ", " .. tostring(Method1).. ", " .. tostring(Period1).. ", " .. tostring(Method2).. ", " .. tostring(Period2) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	One["O"]= core.indicators:create( Method1, source.open, Period1);
    Two["O"] = core.indicators:create( Method2, source.open, Period2);
    One["C"]= core.indicators:create( Method1, source.close, Period1);
    Two["C"] = core.indicators:create( Method2, source.close, Period2);
	One["H"]= core.indicators:create( Method1, source.high, Period1);
    Two["H"] = core.indicators:create( Method2, source.high, Period2);
	One["L"]= core.indicators:create( Method1, source.low, Period1);
    Two["L"] = core.indicators:create( Method2, source.low, Period2);
	
	first= One["O"].DATA:first();
	
	
	Open = instance:addStream("Open", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
    Close = instance:addStream("Close", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
    High = instance:addStream("High", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
    Low = instance:addStream("Low", core.Line, name .. "", "", core.rgb(0, 0, 0), first);
	instance:createCandleGroup("RSI", "RSI Candle", Open, High, Low, Close);
	
	 
    Open:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Open:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
    Open:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	
	
	Open:setPrecision(math.max(2, instance.source:getPrecision())); 
	Close:setPrecision(math.max(2, instance.source:getPrecision()));
	High:setPrecision(math.max(2, instance.source:getPrecision())); 
	Low:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    One["H"]:update(mode);
	Two["H"]:update(mode);
	One["L"]:update(mode);
	Two["L"]:update(mode);
	One["C"]:update(mode);
	Two["C"]:update(mode);
	One["O"]:update(mode);
	Two["O"]:update(mode); 
	
    if period < first   then
	return;
	end
	

		
		if Type  ==  "Price/MA" then
			Open[period] = source.open[period]-One["O"].DATA[period];
			Close[period] =source.close[period]-One["C"].DATA[period];
			High[period] = math.max(Open[period],Close[period],(source.high[period]-One["H"].DATA[period])) ;
			Low[period] = math.min(Open[period],Close[period],(source.low[period]-One["L"].DATA[period])) ;
		elseif Type  ==  "MA/Price" then
			Open[period] = One["O"].DATA[period]-source.open[period];
			Close[period] =One["C"].DATA[period]-source.close[period];
			High[period] = math.max(Open[period],Close[period],(One["H"].DATA[period]-source.high[period])) ;
			Low[period] = math.min(Open[period],Close[period],(One["L"].DATA[period]-source.low[period])) ;	
		elseif Type  ==  "MA1/MA2" then
		   Open[period] = One["O"].DATA[period]-Two["O"].DATA[period];
			Close[period] =One["C"].DATA[period]-Two["C"].DATA[period];
			High[period] = math.max(Open[period],Close[period],(One["H"].DATA[period] -Two["H"].DATA[period])) ;
			Low[period] = math.min(Open[period],Close[period],(One["L"].DATA[period]-Two["L"].DATA[period])) ;	
		elseif Type  ==  "MA2/MA1" then
		   Open[period] = Two["O"].DATA[period]-One["O"].DATA[period];
			Close[period] =Two["C"].DATA[period]-One["C"].DATA[period];
			High[period] = math.max(Open[period],Close[period],(Two["H"].DATA[period] -One["H"].DATA[period])) ;
			Low[period] = math.min(Open[period],Close[period],(Two["L"].DATA[period]-One["L"].DATA[period])) ;		
		end  
 
	    	if Absolute  then
			Open[period] = math.abs(Open[period] );
			Close[period] =math.abs(Close[period] );
			High[period] =math.abs(High[period] );
			Low[period] = math.abs(Low[period] );
			end
			
			if Pips  then 
			Open[period] =  Open[period] /source:pipSize();
			Close[period] =Close[period] /source:pipSize();
			High[period] =High[period] /source:pipSize();
			Low[period] = Low[period] /source:pipSize(); 
			end
end

