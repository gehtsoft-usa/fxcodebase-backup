-- Id: 8008

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27295

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
    indicator:name("GoldenFilter");
    indicator:description("GoldenFilter");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	 indicator.parameters:addGroup("MA Calulation");	
	 
	indicator.parameters:addString("GoldenLinesPrice1", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("GoldenLinesPrice1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("GoldenLinesPrice1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("GoldenLinesPrice1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("GoldenLinesPrice1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("GoldenLinesPrice1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("GoldenLinesPrice1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("GoldenLinesPrice1", "WEIGHTED", "", "weighted");	 
		 
	indicator.parameters:addString("GoldenLinesMethod1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("GoldenLinesMethod1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("GoldenLinesMethod1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("GoldenLinesMethod1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("GoldenLinesMethod1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("GoldenLinesMethod1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("GoldenLinesMethod1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("GoldenLinesMethod1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("GoldenLinesMethod1", "WMA", "WMA" , "WMA");
	indicator.parameters:addInteger("GoldenLinesPeriod1", "Period", "Period", 5);
	
	indicator.parameters:addString("GoldenLinesPrice2", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("GoldenLinesPrice2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("GoldenLinesPrice2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("GoldenLinesPrice2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("GoldenLinesPrice2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("GoldenLinesPrice2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("GoldenLinesPrice2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("GoldenLinesPrice2", "WEIGHTED", "", "weighted");	 
	
	indicator.parameters:addString("GoldenLinesMethod2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("GoldenLinesMethod2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("GoldenLinesMethod2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("GoldenLinesMethod2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("GoldenLinesMethod2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("GoldenLinesMethod2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("GoldenLinesMethod2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("GoldenLinesMethod2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("GoldenLinesMethod2", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("GoldenLinesPeriod2", "Period", "Period", 15);
	
	indicator.parameters:addGroup("Momentum Calculation");	

	indicator.parameters:addInteger("MP", "Momentum Period", "Period", 5);
	indicator.parameters:addString("MS", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("MS", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("MS", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("MS", "LOW", "", "low");
    indicator.parameters:addStringAlternative("MS","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("MS", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("MS", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("MS", "WEIGHTED", "", "weighted");	

	 indicator.parameters:addGroup("Force Index Calculation");
	  indicator.parameters:addInteger("N1", "Smoothing Periods", "", 13, 1, 1000);
	
	 indicator.parameters:addGroup("DeMarker Calculation");
    indicator.parameters:addInteger("N2", "Number of periods for smoothing", "", 14);
    indicator.parameters:addString("MA", "Smoothing Method", "", "MVA");
    indicator.parameters:addStringAlternative("MA", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA", "TMA", "", "TMA");
    indicator.parameters:addStringAlternative("MA", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MA", "Vidya (1995)", "", "VIDYA");
    indicator.parameters:addStringAlternative("MA", "Wilders*", "", "WMA");

     indicator.parameters:addGroup("RSI Calculation");

	indicator.parameters:addString("RP", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("RP", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("RP", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("RP", "LOW", "", "low");
    indicator.parameters:addStringAlternative("RP","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("RP", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("RP", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("RP", "WEIGHTED", "", "weighted");	
	 indicator.parameters:addInteger("R", "Period", "", 21);
	 
     indicator.parameters:addGroup("MACD Calculation");	 
	 indicator.parameters:addString("MACD", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("MACD", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("MACD", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("MACD", "LOW", "", "low");
    indicator.parameters:addStringAlternative("MACD","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("MACD", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("MACD", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("MACD", "WEIGHTED", "", "weighted");	
	 indicator.parameters:addInteger("ShortP", "Short Period", "", 8);
	 indicator.parameters:addInteger("LongP", "Long Period", "", 17);
	 indicator.parameters:addInteger("SignalP", "Signal Period", "", 9);
	 
	  indicator.parameters:addGroup("DMI Calculation");	
	  indicator.parameters:addInteger("DMIP", "Period", "", 14);
	  
     indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("UP", "Color of UP", "Color of UP", core.rgb(0,255, 0));
	indicator.parameters:addColor("DN", "Color of DN", "Color of DN", core.rgb( 255, 0, 0));
	indicator.parameters:addInteger("FontSize", "Font size", "", 10);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local UP, DN;
local FontSize;
local first;
local source = nil;
local GoldenLinesMethod2, GoldenLinesMethod1, GoldenLinesPrice2, GoldenLinesPrice1, GoldenLinesPeriod2, GoldenLinesPeriod1;
local N1, N2, MA,DMIP;
-- Streams block
local Up = {};
local Dn = {};
local Short={};
local Dammy;
local Indicator={};
local MP, MS,Momentum;
local R, RP;
local MACD, SignalP, ShortP, LongP;
-- Routine
function Prepare(nameOnly)
    R = instance.parameters.R;
	RP = instance.parameters.RP;
	MACD= instance.parameters.MACD;
	ShortP= instance.parameters.ShortP;
	LongP= instance.parameters.LongP;
	SignalP= instance.parameters.SignalP;
	
    MP = instance.parameters.MP;
	DMIP = instance.parameters.DMIP;
	MS = instance.parameters.MS
    UP = instance.parameters.UP;
	DN = instance.parameters.DN;
	GoldenLinesPeriod2 = instance.parameters.GoldenLinesPeriod2;
	GoldenLinesPeriod1 = instance.parameters.GoldenLinesPeriod1;
	GoldenLinesMethod2 = instance.parameters.GoldenLinesMethod2;
	GoldenLinesMethod1 = instance.parameters.GoldenLinesMethod1;
	GoldenLinesPrice2 = instance.parameters.GoldenLinesPrice2;
	GoldenLinesPrice1 = instance.parameters.GoldenLinesPrice1;
	N1 = instance.parameters.N1;
	
	N2 = instance.parameters.N2;
	MA = instance.parameters.MA;

	
	
	FontSize = instance.parameters.FontSize;
    source = instance.source;
   

    local name = profile:id() .. "(" .. source:name()   .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	assert(core.indicators:findIndicator("AEFI") ~= nil, "Please, download and install AEFI.LUA indicator");
	assert(core.indicators:findIndicator("DEM") ~= nil, "Please, download and install DEM.LUA indicator");
	
    assert(core.indicators:findIndicator(GoldenLinesMethod1) ~= nil, GoldenLinesMethod1 .. " indicator must be installed");
	Indicator[41] = core.indicators:create(GoldenLinesMethod1, source[GoldenLinesPrice1], GoldenLinesPeriod1);
    assert(core.indicators:findIndicator(GoldenLinesMethod2) ~= nil, GoldenLinesMethod2 .. " indicator must be installed");
	Indicator[42] = core.indicators:create(GoldenLinesMethod2, source[GoldenLinesPrice2], GoldenLinesPeriod2);
	Short[41]= Indicator[41].DATA;
	Short[42]= Indicator[42].DATA;
	
	Indicator[21] = core.indicators:create("AEFI", source, true, N1);
	Indicator[22] = core.indicators:create("DEM", source, N2,MA);
	Short[21]= Indicator[21].DATA;
	Short[22]= Indicator[22].DATA;
	
	Indicator[31] = core.indicators:create("RSI", source[RP], R);
	Short[31]= Indicator[31].DATA;
	
	Indicator[32] = core.indicators:create("MACD", source[MACD], ShortP, LongP, SignalP);
	Short[32]= Indicator[32].MACD;
    Short[33]= Indicator[32].SIGNAL;
	
	Indicator[33] = core.indicators:create("DMI", source, DMIP);
	Short[34]= Indicator[33].DIP;
	Short[35]= Indicator[33].DIM;
    Momentum = instance:addInternalStream(source:first()+MP, 0);
	
	 first =math.max(Short[41]:first(), Short[42]:first(),source:first() + MP, Short[21]:first(),Short[22]:first(),Short[31]:first() ,Short[33]:first(),Short[35]:first() )+1;

 
	    Dammy = instance:addStream("Dammy", core.Line, name, "", UP, first);		
    Dammy:setPrecision(math.max(2, instance.source:getPrecision()));
		Dammy:addLevel(6, core.LINE_NONE, 1, UP);
		Dammy:addLevel(-2, core.LINE_NONE, 1, DN);    
		
        Up[1] = instance:createTextOutput ("Broken Up", "Broken Up", "Wingdings", FontSize, core.H_Center, core.V_Center, UP, first);
        Dn[1] = instance:createTextOutput ("Broken Down", "Broken Down", "Wingdings", FontSize, core.H_Center, core.V_Center, DN, first);
		Up[2] = instance:createTextOutput ("Golden Up", "Golden Up", "Wingdings",FontSize, core.H_Center, core.V_Center, UP, first);
        Dn[2] = instance:createTextOutput ("Golden Down", "Golden Down", "Wingdings", FontSize, core.H_Center, core.V_Center, DN, first);
		Up[3] = instance:createTextOutput ("Cross Up", "Cross Up", "Wingdings", FontSize, core.H_Center, core.V_Center, UP, first);
        Dn[3] = instance:createTextOutput ("Cross Down", "Cross Down", "Wingdings", FontSize, core.H_Center, core.V_Center, DN, first);
		Up[4] = instance:createTextOutput ("Lines Up", "Lines Up", "Wingdings", FontSize, core.H_Center, core.V_Center, UP, first);
        Dn[4] = instance:createTextOutput ("Lines Trend Down", "Lines Down", "Wingdings", FontSize, core.H_Center, core.V_Center, DN, first);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    local i;
	for i = 1, 4, 1 do
	   Up[i]:setNoData (period);
	   Dn[i]:setNoData (period);	   
    end
  
	
	 Indicator[41]:update(mode);
	 Indicator[42]:update(mode);
	Indicator[21]:update(mode);
	 Indicator[22]:update(mode);
    Indicator[31]:update(mode);
	 Indicator[32]:update(mode);
	 Indicator[33]:update(mode); 
	if period < first   then
	return;
	end
	
	 Momentum[period]=source[MS][period]*100./source[MS][period-MP];
	
	
	
	if core.crossesOver(Short[41], Short[42],period)  then
	Up[4]:set(period, 4, "\225");
	elseif core.crossesUnder(Short[41], Short[42],period)  then
	Dn[4]:set(period, 4, "\226"); 
	end
	
	if  Momentum[period] > 100   then
	Up[1]:set(period, 1, "\110");
	elseif Momentum[period] < 100    then
	Dn[1]:set(period, 1, "\110"); 
	end
	
	
	if  Short[21][period] > 0  and Short[22][period] > 0.5 then
	Up[2]:set(period, 2, "\110");
	elseif Short[21][period]  < 0  and Short[22][period] < 0.5    then
	Dn[2]:set(period, 2, "\110"); 	
	end
	
    if  Short[31][period] > 50  and Short[32][period] > Short[33][period] and Short[34][period] > Short[35][period] then
	Up[3]:set(period, 3, "\110");
	elseif Short[31][period]  < 50  and Short[32][period] < Short[33][period] and Short[34][period] < Short[35][period]   then
	Dn[3]:set(period, 3, "\110"); 	
	end
	
end

