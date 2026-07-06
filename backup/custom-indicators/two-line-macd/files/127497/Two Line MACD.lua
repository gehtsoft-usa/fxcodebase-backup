-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68699
-- Id:
 

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

function Init()
    indicator:name("Two Line MACD");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Selector");
	indicator.parameters:addString("Type", "Line Method", "", "MACD");
    indicator.parameters:addStringAlternative("Type", "MACD", "", "MACD");
    indicator.parameters:addStringAlternative("Type", "Signal", "", "Signal");
	indicator.parameters:addStringAlternative("Type", "Histogram", "", "Histogram");
	
	indicator.parameters:addGroup("1. MACD Calculation");
    indicator.parameters:addInteger("SN1", "Short MA", "", 12, 1, 1000);
    indicator.parameters:addInteger("LN1", "Long MA", "", 26, 1, 1000);
	indicator.parameters:addInteger("IN1", "Long MA", "", 8, 1, 1000); 
	 
    indicator.parameters:addString("MAMethod1", "MA Method", "", "EMA");
    indicator.parameters:addStringAlternative("MAMethod1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MAMethod1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MAMethod1", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("MAMethod1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MAMethod1", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("MAMethod1", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("MAMethod1", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("MAMethod1", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MAMethod1", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("MAMethod1", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("MAMethod1", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("MAMethod1", "T3", "", "T3");
    indicator.parameters:addStringAlternative("MAMethod1", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("MAMethod1", "Median", "", "Median");
    indicator.parameters:addStringAlternative("MAMethod1", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("MAMethod1", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("MAMethod1", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("MAMethod1", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("MAMethod1", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("MAMethod1", "JSmooth", "", "JSmooth");
		
   
	
    indicator.parameters:addGroup("2.MACD Calculation");
    indicator.parameters:addInteger("SN2", "Short MA", "", 24, 1, 1000);
    indicator.parameters:addInteger("LN2", "Long MA", "", 52, 1, 1000);
	indicator.parameters:addInteger("IN2", "Long MA", "", 18, 1, 1000);
	 
    indicator.parameters:addString("MAMethod2", "MA Method", "", "EMA");
    indicator.parameters:addStringAlternative("MAMethod2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MAMethod2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MAMethod2", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("MAMethod2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MAMethod2", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("MAMethod2", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("MAMethod2", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("MAMethod2", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MAMethod2", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("MAMethod2", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("MAMethod2", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("MAMethod2", "T3", "", "T3");
    indicator.parameters:addStringAlternative("MAMethod2", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("MAMethod2", "Median", "", "Median");
    indicator.parameters:addStringAlternative("MAMethod2", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("MAMethod2", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("MAMethod2", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("MAMethod2", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("MAMethod2", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("MAMethod2", "JSmooth", "", "JSmooth");
	
	
 
	
    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width1", "1. Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "1. LineStyle", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("color2", "2. Line Color" , "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width2", "SIGNAL Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "SIGNAL Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE)

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local SN1,LN1,IN1 ,MAMethod1;
local SN2,LN2,IN2 ,MAMethod2;
local SIGNALMethod,IN
local Type; 

 
local source = nil;

 
 

local LONG1;
local SHORT1;

local LONG2;
local SHORT2;

local MACD1, MACD2;

local Line1;
local Line2;

local first,FIRST;
-- Routine
function Prepare(nameOnly)

    source = instance.source;
	 
    Type = instance.parameters.Type;
	
	SN1 = instance.parameters.SN1;
    LN1 = instance.parameters.LN1; 
	IN1 = instance.parameters.IN1;
	MAMethod1 = instance.parameters.MAMethod1;
	
	
	SN2 = instance.parameters.SN2;
    LN2 = instance.parameters.LN2; 
	IN2 = instance.parameters.IN2;
	MAMethod2 = instance.parameters.MAMethod2;
	
 
	
 
 
		
	if (LN1 <= SN1) then
       error("The short MA period must be smaller than long MA period");
    end	
	
	if (LN2 <= SN2) then
       error("The short MA period must be smaller than long MA period");
    end	
	
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");

     local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    local precision = math.max(2, source:getPrecision());

	
	LONG1 = core.indicators:create("AVERAGES", source, MAMethod1, LN1 , false);
	SHORT1 = core.indicators:create("AVERAGES", source, MAMethod1, SN1 ,false);  
	LONG2 = core.indicators:create("AVERAGES", source, MAMethod2, LN2 , false);
	SHORT2 = core.indicators:create("AVERAGES", source, MAMethod2, SN2 ,false); 


    FIRST=math.max(LONG1.DATA:first(),LONG2.DATA:first(),SHORT1.DATA:first(),SHORT2.DATA:first());	
	
	if Type== "MACD" then 
    first=math.max(LONG1.DATA:first(),LONG2.DATA:first(),SHORT1.DATA:first(),SHORT2.DATA:first());
	else
	first=math.max(LONG1.DATA:first(),LONG2.DATA:first(),SHORT1.DATA:first(),SHORT2.DATA:first())+ math.max(IN1,IN2) ;
	end
	
	MACD1 = instance:addInternalStream(0, 0);
	MACD2 = instance:addInternalStream(0, 0);
	
	SMOOTH1 = core.indicators:create("AVERAGES", MACD1, SIGNALMethod1, IN1 , false);
    SMOOTH2 = core.indicators:create("AVERAGES", MACD2, SIGNALMethod2, IN2 , false);
	
   
    Line1 = instance:addStream("Line1", core.Line, name .. ".Line1", "Line1", instance.parameters.color1,first);
    Line1:setWidth(instance.parameters.width1);
    Line1:setStyle(instance.parameters.style1);
    Line1:setPrecision(precision);
	
	
	

    Line2 = instance:addStream("Line2", core.Line, name .. ".Line2", "Line2", instance.parameters.color2,first );
    Line2:setWidth(instance.parameters.width2);
    Line2:setStyle(instance.parameters.style2);
    Line2:setPrecision(precision);
	

 
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   
	
    LONG1:update(mode); 
	SHORT1:update(mode); 
	
	LONG2:update(mode); 
	SHORT2:update(mode); 
	
	 if period < FIRST  then
	 return;
	 end
	
		 
			
			MACD1[period]=(SHORT1.DATA[period]-LONG1.DATA[period])
			MACD2[period]=(SHORT2.DATA[period]-LONG2.DATA[period]);
			
			
			if Type== "MACD" then
			Line1[period]=MACD1[period];
			Line2[period]=MACD2[period];
			return;
			end
			
			
			SMOOTH1:update(mode); 
			SMOOTH2:update(mode); 
			
			
			 if period < first + math.max(IN1,IN2)  then
			 return;
			 end		
				 			
            
			if Type== "Signal" then
			Line1[period]=SMOOTH1.DATA[period];
			Line2[period]=SMOOTH2.DATA[period];
			return;
			end
			
			if Type== "Histogram" then
			Line1[period]=MACD1[period]-SMOOTH1.DATA[period];
			Line2[period]=MACD2[period]-SMOOTH2.DATA[period];
			return;
			end
		     
		    
end 