-- Id: 12198
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
   indicator.parameters:addInteger("SSP", "SSP", "Period Priority Line", 75);
    indicator.parameters:addInteger("SSK", "SSK", "Tolerance Second Line", 75);
	
	
     
	indicator.parameters:addGroup("Style");
	indicator.parameters:addBoolean("M", "Additional Lines", "Draw Middle Line and Shenkou Line", false);
	
    indicator.parameters:addColor("clrTS", "S/L Line", "Stop-Order Line", core.rgb(255, 255, 0));
	
    indicator.parameters:addColor("clrSSA", "Priority Line", "1st Leading Line", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrSSB", "Tolerance Second Line", "2nd Leading Line", core.rgb(0, 0, 255));
    indicator.parameters:addColor("clrCloudup", "Cloud UP", "Cloud Color UP", core.rgb(0, 255, 0));
	indicator.parameters:addColor("clrClouddn", "Cloud DN", "Cloud Color DN", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("transp", "Transparence", "Cloud Transparence", 80, 0, 100);
    
    indicator.parameters:addColor("clrKS", "Middle Line", "Middle Line of Priority Line and overdue Line", core.rgb(0, 255, 255));
    indicator.parameters:addColor("clrCS", "Chikou Span", "Chikou Span Lagging Line Closed Price Backwards", core.rgb(0, 255, 0));

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local SSP,SSK;
local SN,LN,IN;
local first;
local source = nil;
local Method;
-- Streams block
local SA,SB,TL,KL,CL;
local MACD,macd;

-- Routine
function Prepare(nameOnly)
 
	
	SSP = instance.parameters.SSP;
    SSK = instance.parameters.SSK;
    M = instance.parameters.M;
	 
	SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
	Method = instance.parameters.Method;
    source = instance.source;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. SN.. ", " .. LN.. ", " .. IN .. ", " .. Method .. ", " .. SSP  .. ", " .. SSK   .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    assert(core.indicators:findIndicator("MACD CANDLE") ~= nil, "Please, download and install MACD CANDLE.LUA indicator");  
  	 assert(core.indicators:findIndicator("ALTERNATE ICHIMOKU") ~= nil, "Please, download and install ALTERNATE ICHIMOKU.LUA indicator");  
	
	MACD  = core.indicators:create("MACD CANDLE", source, SN,LN,IN,Method);
	macd= MACD:getCandleOutput (0);
    ICH  = core.indicators:create("ALTERNATE ICHIMOKU", macd, SSP,SSK,true);
	
	first = ICH.CS:first() ;
   
    SL = instance:addStream("SL", core.Line, name .. ".SL", "SL", instance.parameters.clrTS, source:first())
    SL:setPrecision(math.max(2, instance.source:getPrecision()));
    
	if M then 
	ML = instance:addStream("ML", core.Line, name .. ".ML", "ML", instance.parameters.clrKS, source:first())
    ML:setPrecision(math.max(2, instance.source:getPrecision()));
	CS = instance:addStream("CS", core.Line, name .. ".CS", "CS", instance.parameters.clrCS, source:first(),-SSP)
    CS:setPrecision(math.max(2, instance.source:getPrecision()));
	else
	ML = instance:addInternalStream(0, 0);
    CS = instance:addInternalStream(0, -SSP);
	end
    SA = instance:addStream("SA", core.Line, name .. ".SA", "SA", instance.parameters.clrSSA, source:first())
    SA:setPrecision(math.max(2, instance.source:getPrecision()));
    SB = instance:addStream("SB", core.Line, name .. ".SB", "SB", instance.parameters.clrSSB,  source:first())
    SB:setPrecision(math.max(2, instance.source:getPrecision()));
 
    instance:createChannelGroup("SA-SB", "SA-SB", SA, SB, instance.parameters.clrCloudup, 100 - instance.parameters.transp);	 
	
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

     MACD:update(mode);
	 ICH:update(mode);
	 
	if period < source:first() + first   then
	return;
	end	
	
	
 	
        SL[period] = ICH.SL[period];
        ML[period] = ICH.ML[period];
		
	    if period >SSP then
        CS[period-SSP] = ICH.CS[period-SSP];
		end
		 
        SA[period] = ICH.SA[period];
		SB[period] = ICH.SB[period];
		
		
		 if (SA[period] > SB[period]) then
            SA:setColor(period, instance.parameters.clrCloudup);
        else
            SA:setColor(period, instance.parameters.clrClouddn);
        end
   
end

