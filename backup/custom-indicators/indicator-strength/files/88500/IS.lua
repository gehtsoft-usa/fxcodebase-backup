-- Id: 9699
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59078


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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Indicator Strength");
    indicator:description("Indicator Strength");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("MA", "Use MA Filter", "", true);
	indicator.parameters:addBoolean("MACD", "Use MACD Filter", "", true);
	indicator.parameters:addBoolean("STO", "Use Stochastic Filter", "", true);
    indicator.parameters:addBoolean("AVG", "Use Averaging", "", true);
	
	indicator.parameters:addString("Use", "Select Filter", "", "MA");
	indicator.parameters:addStringAlternative("Use", "MA", "", "MA");
    indicator.parameters:addStringAlternative("Use", "MACD", "", "MACD");
    indicator.parameters:addStringAlternative("Use", "Stochastic", "", "Stochastic");
	
    indicator.parameters:addGroup("MA Calculation");
	indicator.parameters:addString("Price", "Price", "", "close");
	indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	

	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addInteger("Short", "Short Period MA", "Short Period MA", 13);
    indicator.parameters:addInteger("Long", "Long Period MA", "Long Period MA", 21);
	
	
	
	indicator.parameters:addGroup("MACD Calculation");
    indicator.parameters:addInteger("SN", "Short EMA", "(SN)No Description", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long EMA", "(LN)No Description", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal Line", "(IN)No Description", 9, 2, 1000);
	
	indicator.parameters:addString("Price1", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price1", "close", "", "close");
    indicator.parameters:addStringAlternative("Price1", "open", "", "open");
    indicator.parameters:addStringAlternative("Price1", "high", "", "high");
    indicator.parameters:addStringAlternative("Price1", "low", "", "low");
    indicator.parameters:addStringAlternative("Price1", "median", "", "median");
    indicator.parameters:addStringAlternative("Price1", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "weighted", "", "weighted");
	
	
	indicator.parameters:addGroup("Stochastic Calculation");
    indicator.parameters:addInteger("K", "Number of periods for %K", "", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "", 3, 2, 1000);
    indicator.parameters:addInteger("D", "Number of periods for %D", "", 3, 2, 1000);

    indicator.parameters:addString("averageTypeK", "The type of smoothing algorithm for %K", "", "MVA");
    indicator.parameters:addStringAlternative("averageTypeK","MVA", "", "MVA");
    indicator.parameters:addStringAlternative("averageTypeK", "EMA", "", "EMA");
     

    indicator.parameters:addString("averageTypeD","The type of smoothing algorithm for %D", "", "MVA");
    indicator.parameters:addStringAlternative("averageTypeD", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("averageTypeD", "EMA", "", "EMA");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Positiv", "Color of Positiv", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Negativ", "Color of Negativ", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Short;
local Long;
local k;
local d;
local sd;
local averageTypeK = nil;
local averageTypeD = nil;
local AVG;
local SHORT, LONG;
local Method, Price;
local first;
local source = nil;
local Use;
-- Streams block
local Strength = nil;
local STOCHASTIC, MACD;

local SN;
local LN;
local IN;
local Price1;
local Pos, Neg;
local pos;
local neg;
-- Routine
function Prepare(nameOnly)
    AVG = instance.parameters.AVG;
    Short = instance.parameters.Short;
	Method = instance.parameters.Method;
	Price = instance.parameters.Price;
    Long = instance.parameters.Long;
	Use = instance.parameters.Use;
	
	averageTypeK=instance.parameters.averageTypeK;
    averageTypeD=instance.parameters.averageTypeD;
    k = instance.parameters.K;
    d = instance.parameters.D;
	sd = instance.parameters.SD;
	
	Price1 = instance.parameters.Price1;
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
	
    source = instance.source;
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Price) .. ", " .. tostring(Method) .. ", " .. tostring(Short) .. ", " .. tostring(Long)
	.. ", " .. Price1.. ", " .. SN .. ", " .. LN .. ", " .. IN
	.. ", " .. k .. ", " .. d .. ", " .. sd .. ", " .. averageTypeK .. ", " .. averageTypeD 
	.. ")";
    instance:name(name);

	
	 if   (nameOnly) then
        return;
    end
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	SHORT = core.indicators:create(Method, source[Price], Short);
    LONG = core.indicators:create(Method, source[Price], Long);
	
	MACD = core.indicators:create("MACD",source[Price1], SN , LN , IN);
	
	STOCHASTIC=core.indicators:create("STOCHASTIC", source, k , d , sd , averageTypeK, averageTypeD);
	
	Pos = instance:addInternalStream(0, 0);
    Neg = instance:addInternalStream(0, 0);	
	
	pos = instance:addInternalStream(0, 0);
    neg = instance:addInternalStream(0, 0);	
	
    first = math.max(SHORT.DATA:first(),LONG.DATA:first(),MACD.SIGNAL:first(),STOCHASTIC.D:first())

   
	
	
   
        Strength = instance:addStream("Strength", core.Bar, name, "Strength", instance.parameters.Positiv, first);
        Strength:setPrecision(math.max(2, instance.source:getPrecision())); 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    SHORT:update(mode);
	LONG:update(mode);
	MACD:update(mode);
	STOCHASTIC:update(mode);
	
	
	
	
    if period < first then
	return;
	end
	
	local Diff;
	
	Neg[period]=Neg[period-1];
	Pos[period]=Pos[period-1];
	neg[period]=neg[period-1];
	pos[period]=pos[period-1];
	
	if Use == "MA" then	
	Diff=(SHORT.DATA[period]-LONG.DATA[period]);
	Strength[period]=Diff;
		if Diff > 0 then
		Pos[period]= Pos[period]	+Diff;
		pos[period]=pos[period]+1;		
		else
		Neg[period]= Neg[period]	+Diff;
		neg[period]=neg[period]+1;
		end
	elseif Use == "MACD" then
	
	Diff = (MACD.MACD[period]-MACD.SIGNAL[period]);
	Strength[period]=Diff;
	    if Diff > 0 then
		Pos[period]= Pos[period]	+Diff;
		pos[period]=pos[period]+1;
		else
		Neg[period]= Neg[period]	+Diff;
		neg[period]=neg[period]+1;
		end
	
	else
	
	Diff = (STOCHASTIC.K[period]-STOCHASTIC.D[period]);
	Strength[period]=Diff;
	
	     if Diff > 0 then
		Pos[period]= Pos[period]	+Diff;
		pos[period]=pos[period]+1;
		else
		Neg[period]= Neg[period]	+Diff;
		neg[period]=neg[period]+1;
		end
	end
	

	
	if period == (source:size()-1) then 
	core.host:execute("drawLine", 1, source:date(first), Pos[period]/pos[period], source:date(source:size()-1),Pos[period]/pos[period], instance.parameters.Negativ);
    core.host:execute("drawLine", 2, source:date(first), Neg[period]/neg[period], source:date(source:size()-1), Neg[period]/neg[period], instance.parameters.Positiv);
	
	core.host:execute ("setStatus", " Positiv : " ..
	string.format("%." .. 5 .. "f",  Pos[period]/pos[period] )	
	.. " Negativ : " ..
	string.format("%." .. 5 .. "f", Neg[period]/neg[period]))
	
    end
	
	
	
			
		if Strength[period] > 0 then
		Strength:setColor(period, instance.parameters.Positiv);
		else
		Strength:setColor(period,instance.parameters.Negativ);
		end
    
end

