-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2564
-- Id: 2149

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
    indicator:name("Moving Average Convergence/Divergence 20in1 MA");
    indicator:description("A trend-following momentum indicator that shows the relationship between two moving averages of prices (20in1 MA)");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SN", "Short MA", "", 21, 2, 1000);
     indicator.parameters:addInteger("LN", "Long MA", "", 34, 2, 1000);
	 
    indicator.parameters:addString("MAMethod", "MA Method", "", "EMA");
    indicator.parameters:addStringAlternative("MAMethod", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MAMethod", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MAMethod", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("MAMethod", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MAMethod", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("MAMethod", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("MAMethod", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("MAMethod", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MAMethod", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("MAMethod", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("MAMethod", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("MAMethod", "T3", "", "T3");
    indicator.parameters:addStringAlternative("MAMethod", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("MAMethod", "Median", "", "Median");
    indicator.parameters:addStringAlternative("MAMethod", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("MAMethod", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("MAMethod", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("MAMethod", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("MAMethod", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("MAMethod", "JSmooth", "", "JSmooth");
		
    indicator.parameters:addInteger("IN", "Signal Line MA", "", 9, 2, 1000);
	 indicator.parameters:addString("SIGNALMethod", "MA Method", "", "MVA");
    indicator.parameters:addStringAlternative("SIGNALMethod", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("SIGNALMethod", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("SIGNALMethod", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("SIGNALMethod", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("SIGNALMethod", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("SIGNALMethod", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("SIGNALMethod", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("SIGNALMethod", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("SIGNALMethod", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("SIGNALMethod", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("SIGNALMethod", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("SIGNALMethod", "T3", "", "T3");
    indicator.parameters:addStringAlternative("SIGNALMethod", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("SIGNALMethod", "Median", "", "Median");
    indicator.parameters:addStringAlternative("SIGNALMethod", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("SIGNALMethod", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("SIGNALMethod", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("SIGNALMethod", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("SIGNALMethod", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("SIGNALMethod", "JSmooth", "", "JSmooth");  
	
	
	indicator.parameters:addGroup("Shift");	
	indicator.parameters:addInteger("MS", "MACD Lines Shift", "", 0 );
	indicator.parameters:addInteger("SS", "Signal Lines Shift", "", 0 );
	indicator.parameters:addInteger("HS", "Histogram Shift", "", 0 );
	
    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("MACD_color", "MACD Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthMACD", "MACD width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleMACD", "MACD Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleMACD", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("SIGNAL_color", "SIGNAL Color" , "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthSIGNAL", "SIGNAL Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleSIGNAL", "SIGNAL Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSIGNAL", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("UP", "Up HISTOGRAM Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DOWN", "Sown HISTOGRAM Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addBoolean("ColorMode", "Two Colors HISTOGRAM Mode ", "", true);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local SN,LN,IN,SIGNALMethod,MAMethod,ColorMode;

local first;
local source = nil;

local InitialMACD;
local InitialSIGNAL;
local InitialHISTOGRAM;

local ShiftedMACD;
local ShiftedSIGNAL;
local ShiftedHISTOGRAM;

local UP,DOWN;
local MS, SS, HS;
local LONG;
local SHORT;
local SMOOTH;

local MACDFIRST;
local SIGNALFIRST;
local HISTOGRAMFIRST;

-- Routine
function Prepare(nameOnly)

    source = instance.source;
    
	
	UP = instance.parameters.UP;
	DOWN = instance.parameters.DOWN;
	HS = instance.parameters.HS;
	MS = instance.parameters.MS;
	SS = instance.parameters.SS;
	
	
	
	SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
	
	ColorMode = instance.parameters.ColorMode;
	
	SIGNALMethod= instance.parameters.SIGNALMethod;
    MAMethod = instance.parameters.MAMethod;
		
	if (LN <= SN) then
       error("The short MA period must be smaller than long MA period");
    end	
	
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");

     local name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. LN .. ", " .. MAMethod ..", " .. IN .. ", ".. SIGNALMethod.. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    local precision = math.max(2, source:getPrecision());

	
	LONG = core.indicators:create("AVERAGES", source, MAMethod, LN , false);
	SHORT = core.indicators:create("AVERAGES", source, MAMethod, SN ,false);  
	
	 
    InitialMACD= instance:addInternalStream(math.max(LONG.DATA:first(),SHORT.DATA:first() ), 0);
	
	
	if  MS > 0 then
	MACDFIRST= InitialMACD:first() + MS;
	else
	MACDFIRST= InitialMACD:first();
	end
	
   
    ShiftedMACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_color,MACDFIRST, MS);
    ShiftedMACD:setWidth(instance.parameters.widthMACD);
    ShiftedMACD:setStyle(instance.parameters.styleMACD);
    ShiftedMACD:setPrecision(precision);
	
	
	SMOOTH = core.indicators:create("AVERAGES", InitialMACD, SIGNALMethod, IN , false);
	
	
	InitialSIGNAL= instance:addInternalStream(SMOOTH.DATA:first(), 0);
	
	
	if  SS > 0 then
	SIGNALFIRST= InitialSIGNAL:first() + SS;
	else
	SIGNALFIRST= InitialSIGNAL:first();
	end

    ShiftedSIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color, SIGNALFIRST, SS);
    ShiftedSIGNAL:setWidth(instance.parameters.widthSIGNAL);
    ShiftedSIGNAL:setStyle(instance.parameters.styleSIGNAL);
    ShiftedSIGNAL:setPrecision(precision);
	
	InitialHISTOGRAM= instance:addInternalStream(SMOOTH.DATA:first(), 0);
	
	if  HS > 0 then
	HISTOGRAMFIRST= InitialHISTOGRAM:first() + HS;
	else
	HISTOGRAMFIRST= InitialHISTOGRAM:first();
	end
	
	ShiftedHISTOGRAM = instance:addStream("HISTOGRAM", core.Bar, name .. ".HISTOGRAM", "HISTOGRAM",UP, HISTOGRAMFIRST, HS);
	ShiftedHISTOGRAM:setPrecision(precision);

	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   
	
    LONG:update(mode); 
	SHORT:update(mode); 
	
	 if period < InitialMACD:first()  then
	 return;
	 end
	
		 
			
			InitialMACD[period]=SHORT.DATA[period]-LONG.DATA[period];
			
			SMOOTH:update(mode); 
			
			
	 if period < InitialSIGNAL:first()  then
	 return;
	 end		
				 			
					InitialSIGNAL[period]=SMOOTH.DATA[period];
					
	 if period < InitialHISTOGRAM:first()  then
	 return;
	 end				
					
					InitialHISTOGRAM[period]=InitialMACD[period]- InitialSIGNAL[period] ;
					
						
					
					
			
		Shift(period);
			
	 
end

function Shift(period)

    local p;
	p= period+MS;	
	 
	
	   if  period+MS > MACDFIRST then
	    ShiftedMACD[p]= InitialMACD[period];
	   end
 

    p= period+SS;	
	 
	
	   if  period+SS > SIGNALFIRST then
	    ShiftedSIGNAL[p]= InitialSIGNAL[period];
	   end
	
 
	
	
	  p= period+HS;		
	
	   if  period+HS > HISTOGRAMFIRST then
	    ShiftedHISTOGRAM[p]= InitialHISTOGRAM[period];
		
		
		if ColorMode then
					if ShiftedHISTOGRAM[period+HS] > ShiftedHISTOGRAM[period-1+HS] then
					ShiftedHISTOGRAM:setColor(period+HS,UP);
					else
				     ShiftedHISTOGRAM:setColor(period+HS,DOWN);
					end
		end
		
	   end
	
 
    	
end


