-- Id: 2974
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3274

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

function Init()
    indicator:name("Moving Average Convergence/Divergence");
    indicator:description("A trend-following momentum indicator that shows the relationship between two moving averages of prices.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Selection"); 
	indicator.parameters:addBoolean("H", "Histogram On", "", true);
	indicator.parameters:addBoolean("M", "Macd On", "", true);
	indicator.parameters:addBoolean("S", "Signal On", "", true);
    
	indicator.parameters:addGroup("Calculation"); 	
    indicator.parameters:addInteger("SN", "Short MA", "The period of the short EMA.", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long MA", "The period of the long EMA.", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal line", "The number of periods for the signal line.", 9, 2, 1000);
	
	 indicator.parameters:addGroup("Short MA Method");
    indicator.parameters:addString("Method1", "Method", "", "EMA");
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
	
	 indicator.parameters:addGroup("Long MA Method");
    indicator.parameters:addString("Method2", "Method", "", "EMA");
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
	
	 indicator.parameters:addGroup("Signal MA Method");
    indicator.parameters:addString("Method3", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method3", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method3", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method3", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method3", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method3", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method3", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method3", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method3", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method3", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method3", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method3", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method3", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method3", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method3", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method3", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method3", "JSmooth", "", "JSmooth");
 
  	
	indicator.parameters:addGroup("Type"); 
    indicator.parameters:addString("Type", "Method", "" , "Absolute");
    indicator.parameters:addStringAlternative("Type", "Absolute", "" , "Absolute");
    indicator.parameters:addStringAlternative("Type", "Relativ", "Relativ" , "Relativ");	
	
	 indicator.parameters:addBoolean("MH", "MACD as Histogram", "", false);
	
	
	indicator.parameters:addGroup("Style"); 
	indicator.parameters:addColor("MACD_color_UP", "MACD Up color", "The color of MACD.", core.rgb(255, 0, 0));
	indicator.parameters:addColor("MACD_color_DN", "MACD Down color", "The color of MACD.", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "MACD Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("SIGNAL_color", "Signal color", "The color of SIGNAL.", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width2", "Signal Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
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
local MH;

local firstPeriodMACD;

local firstPeriodSIGNAL;
local source = nil;

local EMAS = nil;
local EMAL = nil;
local MVAI = nil;

-- Streams block
local MACD = nil;
local SIGNALOUT = nil;
local SIGNAL=nil;
local HISTOGRAM=nil;
local OUT;
local Type;

local Method1,Method2, Method3;

-- Routine
 function Prepare(nameOnly) 
    MH=instance.parameters.MH;
  
     Method1=instance.parameters.Method1
	  Method2=instance.parameters.Method2;
	  Method3=instance.parameters.Method3;
    Type= instance.parameters.Type;
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
	M = instance.parameters.M;
    H = instance.parameters.H;
	S = instance.parameters.S;
    source = instance.source;


	
	
    local name;
	
    -- Base name of the indicator.
	if  not MH then    
	name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. LN .. ", " .. IN .. ", ".. Type .. ", " ..Method1 .. ", " ..Method2 .. ", " .. Method3 ..")";
	elseif  MH  then
	name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. LN .. ", " .. Type .. ", " ..Method1 .. ", " .. Method2 .. ")";
	end
	
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
    
	
	    -- Check parameters
    if (LN <= SN) then
       error("The short MA period must be smaller than long MA period");
    end

    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator"); 
  
	 EMAS = core.indicators:create("AVERAGES", source, Method2, SN, false);
    EMAL = core.indicators:create("AVERAGES", source, Method2, LN, false);
	--end
	
	MACD = instance:addInternalStream(0,0); 
	SIGNAL = instance:addInternalStream(0,0); 
	
    -- Create the output stream for the MACD. The first period is equal to the
    -- biggest first period of source EMA streams
    firstPeriodMACD = EMAL.DATA:first();	
	
	
	if MH then
	H= false;
	S= false;	
	OUT = instance:addStream("MACD", core.Bar, name .. ".MACD", "MACD", instance.parameters.MACD_color_UP, firstPeriodMACD);
    OUT:setPrecision(math.max(2, instance.source:getPrecision()));
    OUT:setPrecision(math.max(2, instance.source:getPrecision()));
	else
	OUT = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_color_UP, firstPeriodMACD);
	OUT:setWidth(instance.parameters.width1);
    OUT:setStyle(instance.parameters.style1);
	end
          
		  
	
    -- Create MVA for the MACD output stream.	
	
	MVAI = core.indicators:create("AVERAGES", MACD, Method3, IN, false);
	
	
    -- Create output for the signal and histogram
    firstPeriodSIGNAL = MVAI.DATA:first();
	if not  MH then 
			SIGNALOUT = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color, firstPeriodSIGNAL);
            SIGNALOUT:setPrecision(math.max(2, instance.source:getPrecision()));
			SIGNALOUT:setWidth(instance.parameters.width2);
            SIGNALOUT:setStyle(instance.parameters.style2);
			if  Type == "Absolute" then
			HISTOGRAM = instance:addStream("HISTOGRAM", core.Bar, name .. "HISTOGRAM", "HISTOGRAM", instance.parameters.UPHISTOGRAM_color, firstPeriodSIGNAL);
    HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));
			end
	end
end

-- Indicator calculation routine
function Update(period, mode)
    -- and update short and long EMAs for the source.
    EMAS:update(mode);
    EMAL:update(mode);
	
	if Type == "Absolute" then

				if (period >= firstPeriodMACD) then
					-- calculate MACD output
					MACD[period] = EMAS.DATA[period] - EMAL.DATA[period];
				
					if (M) then
					OUT[period]=MACD[period];	

                             	 
									 if OUT[period] > OUT[period-1] then
									OUT:setColor(period, instance.parameters.MACD_color_UP);                     
									else
									OUT:setColor(period, instance.parameters.MACD_color_DN); 
									end		
						        					
					end 
				end

				-- update MVA on the MACD
				MVAI:update(mode);
				if (period >= firstPeriodSIGNAL) then
					SIGNAL[period] = MVAI.DATA[period]; 
					if (S) and  not  MH  then 
					SIGNALOUT[period] = SIGNAL[period];
					end
					-- calculate histogram as a difference between MACD and signal
					if (H)  and not  MH then
					HISTOGRAM[period] = MACD[period] - SIGNAL[period];
					
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
                    	
				
					if (M) then
					OUT[period]=MACD[period];		
					 
					
						if MH then
								 if OUT[period] > OUT[period-1] then
								OUT:setColor(period, instance.parameters.MACD_color_UP);                     
								else
								OUT:setColor(period, instance.parameters.MACD_color_DN); 
								end		
						end  	
					end
					
				end

				-- update MVA on the MACD
				MVAI:update(mode);
				if (period >= firstPeriodSIGNAL) and  not  MH then
					SIGNAL[period] = MVAI.DATA[period]; 
					if (S) then 
					SIGNALOUT[period] = SIGNAL[period];
					end
				end	
	end
end


