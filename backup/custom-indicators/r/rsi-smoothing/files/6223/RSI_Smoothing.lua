-- Id: 2374
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2742

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("RSI MA");
    indicator:description("RSI MA");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Price Smoothing"); 
    indicator.parameters:addInteger("RSIFrame", "RSI Period", "", 14,2, 2000);	
	
	indicator.parameters:addBoolean("PriceON", "Price Smoothing", "", false);		
	indicator.parameters:addInteger("PriceFrame", "Price  Smoothing Period", "", 7,1, 2000);
	indicator.parameters:addString("Type0",  "Price Smoothing Method", "", "MVA");
    indicator.parameters:addStringAlternative("Type0", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Type0", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Type0", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Type0", "TMA", "", "TMA");	
	
	indicator.parameters:addGroup("RSI Smoothing"); 
	indicator.parameters:addBoolean("RSION", "RSI Smoothing", "", true);	
	indicator.parameters:addInteger("MAFrame1", "1. RSI  Smoothing Line Period", "", 7 ,1, 2000);
    indicator.parameters:addString("Type1",  "1. RSI Smoothing Method", "", "MVA");
    indicator.parameters:addStringAlternative("Type1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Type1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Type1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Type1", "TMA", "", "TMA");
    indicator.parameters:addInteger("MAFrame2", "2. RSI  Smoothing Line Period", "", 7 ,1, 2000);	
    indicator.parameters:addString("Type2",  "2. RSI Moving Average Method", "", "EMA");
	indicator.parameters:addStringAlternative("Type2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Type2", "MVA", "", "MVA");    
    indicator.parameters:addStringAlternative("Type2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Type2", "TMA", "", "TMA");
	
	indicator.parameters:addGroup("RSI Style");
	 indicator.parameters:addBoolean("Hide", "Hide RSI", "", false);
	indicator.parameters:addInteger("widthRSI", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleRSI", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleRSI", core.FLAG_LINE_STYLE);		
    indicator.parameters:addColor("RSI_color", "Color of RSI", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addGroup("1. RSI Smoothing  Line Style");
	indicator.parameters:addInteger("widthMVA", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleMVA", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleMVA", core.FLAG_LINE_STYLE);		
    indicator.parameters:addColor("MVA_color", "Color of 1. Line", "", core.rgb(0, 0, 255));
	
	indicator.parameters:addGroup("2. RSI Smoothing  Line Style");
	 indicator.parameters:addBoolean("HideTWO", "Hide 2. RSI Smoothing  Line", "", true);
	indicator.parameters:addInteger("widthEMA", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleEMA", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleEMA", core.FLAG_LINE_STYLE);		
    indicator.parameters:addColor("EMA_color", "Color of 2. Line", "", core.rgb(0, 255, 0));	
	
	indicator.parameters:addGroup("Overbought/oversold Level");
    indicator.parameters:addInteger("overbought", "Overbought Level", "", 30, 0, 100);
    indicator.parameters:addInteger("oversold", "Oversold Level", "", 70, 0, 100);
    indicator.parameters:addInteger("level_overboughtsold_width", "Over Bought/Sold Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Over Bought/Sold Line Style", "", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "Over Bought/Sold Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);	
 
     indicator.parameters:addInteger("Lookback", "Lookback Period", "", 0);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local RSIFrame;
local MAFrame1, MAFrame2;
local RSION;
local PriceOn;
local HideTWO;

local Hide;

local Type0,Type1, Type2;

local first, first2, first1;
local source = nil;

-- Streams block
local RSI = nil;
local MA = {};
local Indicator={};
local Lookback;
local Price;
local PriceFrame;
local dummy;

-- Routine
 function Prepare(nameOnly)   
    HideTWO  = instance.parameters.HideTWO;
    RSION  = instance.parameters.RSION;
    PriceFrame  = instance.parameters.PriceFrame;
    PriceON  = instance.parameters.PriceON;
    Type0  = instance.parameters.Type0; 
    Type1  = instance.parameters.Type1;
	Type2  = instance.parameters.Type2;
    Lookback  = instance.parameters.Lookback;
	Hide = instance.parameters.Hide;
    RSIFrame = instance.parameters.RSIFrame;
    MAFrame1 = instance.parameters.MAFrame1;
	 MAFrame2 = instance.parameters.MAFrame2;
    source = instance.source;
    first = source:first();
	
	
	 local name;

	if PriceON  and RSION  then
    name = profile:id() .. "(" .. source:name() .. ", " .. RSIFrame .. ", " .. PriceFrame .. ", " .. Type0 ..", " .. MAFrame1 ..", " .. MAFrame2 ..", " .. Type1..", " ..  Type2.. ")";
	elseif PriceON  and not RSION  then
	name = profile:id() .. "(" .. source:name() .. ", " .. RSIFrame .. ", ".. PriceFrame .. ", " .. Type0.. ")";
	elseif  not PriceON  and  RSION  then
	name = profile:id() .. "(" .. source:name() .. ", " .. RSIFrame .. ", "  .. MAFrame1 ..", " .. MAFrame2.. ", " .. Type1..", " ..  Type2.. ")";
	 else
	 name = profile:id() .. "(" .. source:name() .. ", " .. RSIFrame ..")";  
	end
	 
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	Indicator[4]= core.indicators:create( Type0, source , PriceFrame);
	
	
	
	if PriceON then
	Indicator[1]= core.indicators:create("RSI", Indicator[4].DATA, RSIFrame);
	else
	Indicator[1]= core.indicators:create("RSI", source, RSIFrame);	
	end
	
	first = math.max(first, Indicator[1].DATA:first());
	
	if RSION then
	Indicator[2]= core.indicators:create( Type1, Indicator[1].DATA , MAFrame1);
	Indicator[3]= core.indicators:create( Type2, Indicator[1].DATA , MAFrame2);
	first1 = Indicator[2].DATA:first();
	first2= Indicator[3].DATA:first();
	end
	
	
	
	
	if Hide then
	RSI =  instance:addInternalStream (first, 0)
	else	   
    RSI = instance:addStream("RSI", core.Line, name .. ".RSI", "RSI", instance.parameters.RSI_color, first);	
	RSI:setWidth(instance.parameters.widthRSI);
    RSI:setStyle(instance.parameters.styleRSI);
    RSI:setPrecision(2); 
	end
	
	 if  RSION then
    MA[1] = instance:addStream("MA"..1, core.Line, name .. Type1, Type1, instance.parameters.MVA_color, first1);	
	MA[1]:setWidth(instance.parameters.widthMVA);
    MA[1]:setStyle(instance.parameters.styleMVA);
    MA[1]:setPrecision(2);  	
		if not HideTWO  then
		  MA[2] = instance:addStream("MA"..2, core.Line, name .. Type2, Type2, instance.parameters.EMA_color, first2);
		MA[2]:setWidth(instance.parameters.widthEMA);
		MA[2]:setStyle(instance.parameters.styleEMA);
		MA[2]:setPrecision(2);		
		end
	end
	
	dummy  = instance:addStream("dummy", core.Line, "", "", core.rgb(128, 128, 128), first);
    dummy:setPrecision(math.max(2, instance.source:getPrecision()));
	dummy:setStyle(core.LINE_NONE );
	dummy:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    dummy:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	dummy:addLevel(50);
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    
	
	if period < first   then
	return;
	end
	
		
	if Lookback ~= 0 and period < source:size()-1- Lookback then
	return;
	end
	    if  PriceON then
	    Indicator[4]:update(mode);
		end
		
		
		Indicator[1]:update(mode);
		RSI[period] = Indicator[1].DATA[period];
		
		if RSION then
		Indicator[2]:update(mode);
		if period > first1 then
		MA[1][period] = Indicator[2].DATA[period];
		end
			if not HideTWO  then
			Indicator[3]:update(mode);
			if period > first2 then
			MA[2][period] = Indicator[3].DATA[period];
			end
			end
		end
		
		 
		
end
