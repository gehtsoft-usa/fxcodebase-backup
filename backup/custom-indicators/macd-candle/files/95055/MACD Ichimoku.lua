-- Id: 12191
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60955

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
function Init()
    indicator:name("MACD Ichimoku");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("MACD  Calculation"); 
	 indicator.parameters:addInteger("SN", "Short EMA", "(SN)No Description", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long EMA", "(LN)No Description", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal Line", "(IN)No Description", 9, 2, 1000);
	
	indicator.parameters:addString("Method", "Candle Method", "Method" , "MACD");
    indicator.parameters:addStringAlternative("Method", "MACD", "MACD" , "MACD");
    indicator.parameters:addStringAlternative("Method", "SIGNAL", "SIGNAL" , "SIGNAL");
    indicator.parameters:addStringAlternative("Method", "HISTOGRAM", "HISTOGRAM" , "HISTOGRAM");
 
    indicator.parameters:addGroup("Ichimoku Calculation");
    indicator.parameters:addInteger("X", "Tenkan-sen period","", 9, 1, 10000);
    indicator.parameters:addInteger("Y", "Kijun-sen period","", 26, 1, 10000);
    indicator.parameters:addInteger("Z","Senkou Span B period","", 52, 1, 10000);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrTS", "Tenkan-sen Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("widthTL", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleTL","Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleTL", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrKS", "Kijun-sen Line Color","", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("widthKS", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleKS", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleKS", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrCS", "Chinkou Span Line Color","", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthCS", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleCS", " Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleCS", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrSSA", "Senkou span A Line Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthSSA", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleSSA", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSSA", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrSSB", "Senkou span B Line Color","", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthSSB", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleSSB", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSSB", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addInteger("transp", "Cloud transparency %","", 80, 0, 100);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local X,Y,Z;
local SN,LN,IN;
local first;
local source = nil;
local Method;
-- Streams block
local SA,SB,TL,KL,CL;
local MACD,macd;

-- Routine
function Prepare(nameOnly)
    X = instance.parameters.X;
	Y = instance.parameters.Y;
	Z = instance.parameters.Z;
	SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
	Method = instance.parameters.Method;
    source = instance.source;
     
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. SN.. ", " .. LN.. ", " .. IN .. ", " .. Method .. ", " .. X  .. ", " .. Y  .. ", " .. Z .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    assert(core.indicators:findIndicator("MACD CANDLE") ~= nil, "Please, download and install MACD CANDLE.LUA indicator");  
  	
	
	MACD  = core.indicators:create("MACD CANDLE", source, SN,LN,IN,Method);
	macd= MACD:getCandleOutput (0);
    ICH  = core.indicators:create("ICH", macd, X,Y,Z);
	
	first = ICH.CS:first() ;
    TL = instance:addStream("TL", core.Line, name .. "TL", "TL", instance.parameters.clrTS, ICH.SL:first());
    TL:setPrecision(math.max(2, instance.source:getPrecision()));
	TL:setWidth(instance.parameters.widthTL);
    TL:setStyle(instance.parameters.styleTL);
    KL = instance:addStream("KL", core.Line, name .. "KL", "KL", instance.parameters.clrKS, ICH.TL:first());
    KL:setPrecision(math.max(2, instance.source:getPrecision()));
	KL:setWidth(instance.parameters.widthKS);
    KL:setStyle(instance.parameters.styleKS);
    CL = instance:addStream("CL", core.Line, name .. "CL", "CL", instance.parameters.clrCS, ICH.CS:first(),-Y);
    CL:setPrecision(math.max(2, instance.source:getPrecision()));
	CL:setWidth(instance.parameters.widthCS);
    CL:setStyle(instance.parameters.styleCS);
    SB = instance:addStream("SB", core.Line, name .. "SB", "SB", instance.parameters.clrSSB, ICH.SB:first(),Y);
    SB:setPrecision(math.max(2, instance.source:getPrecision()));
	SB:setWidth(instance.parameters.widthSSB);
    SB:setStyle(instance.parameters.styleSSB);
	SA = instance:addStream("SA", core.Line, name .. "SA", "SA", instance.parameters.clrSSA, ICH.SA:first(),Y);
    SA:setPrecision(math.max(2, instance.source:getPrecision()));
	SA:setWidth(instance.parameters.widthSSA);
    SA:setStyle(instance.parameters.styleSSA);
	
	instance:createChannelGroup("SA-SB", "SA-SB", SA, SB, instance.parameters.clrSSA, 100 - instance.parameters.transp);
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

     MACD:update(mode);
	 ICH:update(mode);
	 
	if period < source:first() + first   then
	return;
	end	
	
	
 	
        TL[period] = ICH.SL[period];
        KL[period] = ICH.TL[period];
		
		if period > ICH.CS:first() +Y then
        CL[period-Y] = ICH.CS[period-Y];
		end
        SA[period+Y] = ICH.SA[period+Y];
		SB[period+Y] = ICH.SB[period+Y];
		
		
		 if (SA[period+Y] > SB[period+Y]) then
            SA:setColor(period+Y, instance.parameters.clrSSB);
        else
            SA:setColor(period+Y, instance.parameters.clrSSA);
        end
   
end

