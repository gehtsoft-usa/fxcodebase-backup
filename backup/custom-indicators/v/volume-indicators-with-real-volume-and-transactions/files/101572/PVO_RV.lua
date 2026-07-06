-- Id: 14540

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62412

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Percentage Volume Oscillator with Real volume/Transactions");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Selection"); 
	indicator.parameters:addBoolean("H", "Histogram On", "", true);
	indicator.parameters:addBoolean("M", "PVO On", "", true);
	indicator.parameters:addBoolean("S", "Signal On", "", true);
    
	indicator.parameters:addGroup("Calculation"); 	
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
    indicator.parameters:addInteger("SN", "Short MA Period", "The period of the short MA.", 12, 2, 1000);
	indicator.parameters:addString("Method1", "Short MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addInteger("LN", "Long MA Period", "The period of the long MA.", 26, 2, 1000);
	indicator.parameters:addString("Method2", "Long MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	
    indicator.parameters:addInteger("IN", "Signal line Period", "The number of periods for the signal line.", 9, 2, 1000);
	indicator.parameters:addString("Method3", "Signal MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
	
	
	
	
	indicator.parameters:addGroup("Type"); 
    indicator.parameters:addString("Type", "Method", "" , "Absolute");
    indicator.parameters:addStringAlternative("Type", "Absolute", "" , "Absolute");
    indicator.parameters:addStringAlternative("Type", "Relativ", "Relativ" , "Relativ");
	
	
	indicator.parameters:addGroup("Style"); 
	indicator.parameters:addColor("MACD_color", "PVO color", "The color of PVO.", core.rgb(255, 0, 0));
    indicator.parameters:addColor("SIGNAL_color", "Signal color", "The color of SIGNAL.", core.rgb(0, 0, 255));
	indicator.parameters:addColor("UPHISTOGRAM_color", "Up Histogram color", "The color of Up Histogram.", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DOWNHISTOGRAM_color", "Down Histogram color", "The color of Down Histogram.", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local SN;
local LN;
local IN;
local M;
local H;
local S;
local Method1, Method2,Method3;
local firstPeriodMACD;

local firstPeriodSIGNAL;
local source = nil;

local EMAS = nil;
local EMAL = nil;
local MVAI = nil;

-- Streams block
local MACD = nil;
local SIGNAL=nil;
local HISTOGRAM=nil;
local Type;
local Ind;

local FirstStart;
local LastTime;

-- Routine
function Prepare(nameOnly)
    Type= instance.parameters.Type;
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
	M = instance.parameters.M;
    H = instance.parameters.H;
	S = instance.parameters.S;
    source = instance.source;
	Method1= instance.parameters.Method1;
	Method2= instance.parameters.Method2;
	Method3= instance.parameters.Method3;
	
	    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. LN .. ", " .. IN .. ", ".. Method1 .. ", ".. Method2 .. ", ".. Method3 .. ", ".. Type..")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	

    -- Check parameters
    if (LN <= SN) then
       error("The short MA period must be smaller than long MA period");
    end
	
	 assert(source:supportsVolume(), "The source must have volume");

     if instance.parameters.Ind=="Volume" then
      Ind=core.indicators:create("REAL VOLUME", source);
     else
      Ind=core.indicators:create("TRANSACTIONS", source);
     end
     FirstStart=true;
     LastTime=0;

    -- Create short and long EMAs for the source
    EMAS = core.indicators:create( Method1, Ind.DATA, SN);
    EMAL = core.indicators:create( Method2, Ind.DATA, LN);
	



    -- Create the output stream for the MACD. The first period is equal to the
    -- biggest first period of source EMA streams
    firstPeriodMACD = EMAL.DATA:first();
    if M then
	MACD = instance:addStream("PVO", core.Line, name .. ".PVO", "PVO", instance.parameters.MACD_color, firstPeriodMACD);
    MACD:setPrecision(math.max(2, instance.source:getPrecision()));
	else
	MACD = instance:addInternalStream(0,0); 
	end
	

    -- Create MVA for the MACD output stream.
    assert(core.indicators:findIndicator(Method3) ~= nil, Method3 .. " indicator must be installed");
    MVAI = core.indicators:create(Method3, MACD, IN);
    -- Create output for the signal and histogram
    firstPeriodSIGNAL = MVAI.DATA:first();
    if S then
    SIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color, firstPeriodSIGNAL);
    SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
	else
	SIGNAL = instance:addInternalStream(0,0);
	end
	--if  Type == "Absolute" then
	if H then
	HISTOGRAM = instance:addStream("HISTOGRAM", core.Bar, name .. "HISTOGRAM", "HISTOGRAM", instance.parameters.UPHISTOGRAM_color, firstPeriodSIGNAL);
    HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));
	else
	HISTOGRAM = instance:addInternalStream(0,0);
	end
	--end
end

function AsyncOperationFinished(cookie, success, message)

end

-- Indicator calculation routine
function Update(period, mode)
    -- and update short and long EMAs for the source.
    if period<firstPeriodMACD then
    	return;
   	end;

        Ind:update(mode);
        if not(Ind.DATA:hasData(period)) then
            if period==firstPeriodMACD then
                FirstStart=true;
            end    
            return;
        elseif FirstStart then
            FirstStart=false;
            instance:updateFrom(firstPeriodMACD);    
        elseif LastTime~=source:date(period) and period==source:size()-1 then
            LastTime=source:date(period);
            instance:updateFrom(period-10);
        end

    EMAS:update(mode);
    EMAL:update(mode);
	
	if Type == "Absolute" then

				if (period >= firstPeriodMACD) then
					-- calculate MACD output
					MACD[period] = EMAS.DATA[period] - EMAL.DATA[period];
				
				
				end

				-- update MVA on the MACD
				MVAI:update(mode);
				if (period >= firstPeriodSIGNAL) then
					SIGNAL[period] = MVAI.DATA[period]; 
					
					SIGNAL[period] = SIGNAL[period];
					
					-- calculate histogram as a difference between MACD and signal
					
					HISTOGRAM[period] = MACD[period] - SIGNAL[period];
					
					if (H) then
						 if HISTOGRAM[period] > HISTOGRAM[period-1] then
						  HISTOGRAM:setColor(period, instance.parameters.UPHISTOGRAM_color);
						 else
						   HISTOGRAM:setColor(period, instance.parameters.DOWNHISTOGRAM_color);
						 end
					
					end
				end
	else			if (period >= firstPeriodMACD) then
					-- calculate MACD output
					MACD[period] = (EMAS.DATA[period] - EMAL.DATA[period])/ ( EMAL.DATA[period]/100);					
				
					
				end

				-- update MVA on the MACD
				MVAI:update(mode);
				if (period >= firstPeriodSIGNAL) then
					SIGNAL[period] = MVAI.DATA[period]; 
					
					
					HISTOGRAM[period] = MACD[period] - SIGNAL[period];
					
					if (H) then
						 if HISTOGRAM[period] > HISTOGRAM[period-1] then
						  HISTOGRAM:setColor(period, instance.parameters.UPHISTOGRAM_color);
						 else
						   HISTOGRAM:setColor(period, instance.parameters.DOWNHISTOGRAM_color);
						 end
					
					end
				end	
	end
end


