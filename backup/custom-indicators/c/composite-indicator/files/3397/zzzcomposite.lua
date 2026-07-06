-- Id: 2277
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1708

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
    indicator:name("Composite");
    indicator:description("Composite");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	
	local i;
	local Label= {"RSI", "CCI", "EMA", "AROON", "DMI", "FRAMA", "SAR", "SLOPE_DIRECTION_LINE", "KRI","TRIX" , "MOMENTUM", "WMA", "KAMA", "VORTEX", "DEM", "FORECAST", "RLW", "TMACD", "SUPERTREND", "HA", "ROC", "ADX", "DMI" };
	for i = 1, 23, 1 do
		if i== 23 then
		indicator.parameters:addGroup(Label[i] .. "2 Parameters");
		else
		indicator.parameters:addGroup(Label[i] .. " Parameters");
		end
	local Test=nil;
	Test = core.indicators:findIndicator(Label[i] );
		 if Test == nil then
        indicator.parameters:addString("Select"..i, Label[i].." (Not Available)", "It is Available on FXCODEBASE.COM", "No");
        indicator.parameters:addStringAlternative("Select"..i, "No", "", "No");

        elseif Test ~= nil then
        indicator.parameters:addString("Select"..i, Label[i], Label[i], "Yes");
        indicator.parameters:addStringAlternative("Select"..i, "Yes", "", "Yes");
        indicator.parameters:addStringAlternative("Select"..i, "No", "", "No");		
        end
		indicator.parameters:addBoolean("Inverse"..i,  "Inverse Indicator", "", false);	
		
		if i == 1 then
		 indicator.parameters:addInteger("RSIFrame", "RSI Period", "RSI Period", 10,2,2000);
		elseif i == 2 then
		indicator.parameters:addInteger("CCIFrame", "CCI Period", "CCI Period", 10,2,2000);
		elseif i == 3 then
		indicator.parameters:addInteger("EMAFrame", "EMA Period", "EMA Period", 10,2,2000);
		elseif i == 4 then
		indicator.parameters:addInteger("AROONFrame", "AROON Period", "AROON Period", 10,2,2000);
		elseif i == 5 then
		indicator.parameters:addInteger("DMIFrame", "DMI Period", "DMI Period", 10,2,2000);
		
		elseif i == 6 then
		indicator.parameters:addInteger("FRAMAFrame", "FRAMA Period", "FRAMA Period", 10,2,2000);
		elseif i == 7 then
		indicator.parameters:addDouble("Step", "SAR Step", "The sensitivity of SAR.", 0.02, 0.001, 1);
		 indicator.parameters:addDouble("Max", "SAR Max", "The maximum value of Step.", 0.2, 0.001, 10);
		elseif i == 8 then
		indicator.parameters:addInteger("SDLFrame", "SDL Period", "SDL Period", 10,2,2000);
		elseif i == 9 then
		indicator.parameters:addInteger("KRIFrame", "KRI Period", "KRI Period", 10,2,2000);
		elseif i == 10 then
		indicator.parameters:addInteger("TRIXFrame", "TRIX Period", "TRIX Period", 10,2,2000);
		
		elseif i == 11 then
		indicator.parameters:addInteger("MOMENTUMFrame", "MOMENTUM Period", "MOMENTUM Period", 10,2,2000);
		elseif i == 12 then
		indicator.parameters:addInteger("WMAFrame", "WMA Period", "WMA Period", 10,2,2000);
		elseif i == 13 then
		indicator.parameters:addInteger("KAMAFrame", "KAMA Period", "KAMA Period", 10,2,2000);
		elseif i == 14 then
		indicator.parameters:addInteger("VORTEXFrame", "VORTEX Period", "VORTEX Period", 10,2,2000);
		elseif i == 15 then
		indicator.parameters:addInteger("DEMARKERFrame", "DEMARKER Period", "DEMARKER Period", 10,2,2000);
		
		elseif i == 16 then
		indicator.parameters:addInteger("FORECASTFrame", "FORECAST Period", "FORECAST Period", 10,2,2000);
		elseif i == 17 then
		indicator.parameters:addInteger("RLWFrame", "RLW Period", "RLW Period", 10,2,2000);
		elseif i == 18 then
		indicator.parameters:addInteger("TMACDLongFrame", "TMACD Long Period", "TMACD Long Period", 10,2,2000);
	    indicator.parameters:addInteger("TMACDShortFrame", "TMACD Short Period", "TMACD Short Period", 5,2,2000);
		elseif i == 19 then
		indicator.parameters:addInteger("SUPERTRENDFrame", "SUPERTREND Period", "SUPERTREND Period", 10,2,2000);
	     indicator.parameters:addDouble("Multiplier", "Super Trend Multiplier", "No description", 1.5);
		elseif i == 20 then		
		elseif i == 21 then
		indicator.parameters:addInteger("ROCFrame", "ROC Period", "ROC Period", 14,2,2000);		
		elseif i == 22 then
		indicator.parameters:addInteger("ADXFrame", "ADX Period", "ADX Period", 14,2,2000);	
		indicator.parameters:addDouble("ADX_Level", "ADX Level ", "ADX Level", 25);
		elseif i == 23 then
		indicator.parameters:addInteger("DMIFrame2", "DMI Period 2", "DMI Period", 14,2,2000);	
		indicator.parameters:addDouble("DMI_Level", "DMI Level ", "DMI Level", 25);
        end 		
	end   		
	indicator.parameters:addGroup( "Parameters");
	indicator.parameters:addBoolean("Live", "Ignore Last period ", "Ignore Last period", true);

	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("CI_color", "Color of CI", "Color of CI", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block


local ADX_Level,DMI_Level;
local Frame=nil;

local first;
local source = nil;

-- Streams block
local CI = nil;

local RSI=nil;
local RSIFrame=nil;

local CCI=nil;
local CCIFrame=nil;

local STEP=nil;
local MAX=nil;

local EMAFrame=nil;
local EMA=nil;

local AROON=nil;
local AROONFrame=nil;

local SAR=nil;

local DMI=nil;
local DMIFrame=nil;

local FRAMA=nil;
local FRAMAFrame=nil;

local SDL=nil;
local SDLFrame=nil;

local KRI=nil;
local KRIFrame=nil;

local TRIX=nil;
local TRIXFrame=nil;

local MOMENTUM=nil;
local MOMENTUMFrame=nil;

local WMA=nil;
local WMAFrame=nil;

local KAMA=nil;
local KAMAFrame=nil;

local VORTEX=nil;
local VORTEXFrame=nil;

local DEMARKER=nil;
local DEMARKERFrame=nil;

local FORECAST=nil;
local FORECASTFrame=nil;

local RLW=nil;
local RLWFrame=nil;

local SUPERTREND=nil;
local SUPERTRENDFrame=nil;
local Multiplier=nil;

local TMACD=nil;
local TMACDShortFrame=nil;
local TMACDLongFrame=nil;
local HA=nil;

local ROC=nil;
local ROCFrame=nil;

local Live=nil;

local ON={};

local Inverse={};

local ADX, DMI2;
local DMIFrame2, ADXFrame;


local Count=0;

-- Routine
 function Prepare(nameOnly)   
 
 
    source = instance.source;
    first = source:first();
	
	 local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    local IndicatorList= {"RSI", "CCI", "EMA", "AROON", "DMI", "FRAMA", "SAR", "SLOPE_DIRECTION_LINE", "KRI","TRIX" , "MOMENTUM", "WMA", "KAMA", "VORTEX", "DEM", "FORECAST", "RLW", "TMACD", "SUPERTREND", "HA", "ROC", "ADX", "DMI" };
	
	for i = 1, 23, 1 do
	ON[i]= (instance.parameters:getString("Select" .. i) == "Yes");
	Inverse[i]=  instance.parameters:getBoolean ("Inverse"..i);
		if ON[i] then
		assert(core.indicators:findIndicator(IndicatorList[i]) ~= nil, "Please, download and install ".. IndicatorList[i].. ".LUA indicator");
		end
	end
	
	Live = instance.parameters.Live;
	
    
	if ON[1] then	
	RSIFrame = instance.parameters.RSIFrame;
	RSI = core.indicators:create("RSI", source.close, RSIFrame);	
	end
	if ON[2] then
	CCIFrame = instance.parameters.CCIFrame;
	CCI = core.indicators:create("CCI", source, CCIFrame);
	end
	if ON[3] then
	EMAFrame = instance.parameters.EMAFrame;
	EMA = core.indicators:create("EMA", source.close, EMAFrame);
	end
	if ON[4] then
    AROONFrame = instance.parameters.AROONFrame;
	AROON = core.indicators:create("AROON", source, AROONFrame);
	end
	
	if ON[7] then
	STEP=instance.parameters.Step;
    MAX=instance.parameters.Max;
	SAR = core.indicators:create("SAR", source, STEP, MAX);
	end
	if ON[5] then
	DMIFrame = instance.parameters.DMIFrame;
	DMI = core.indicators:create("DMI", source, DMIFrame);
	end
	if ON[6] then
	FRAMAFrame = instance.parameters.FRAMAFrame;
   -- assert(core.indicators:findIndicator("FRAMA") ~= nil, "FRAMA" .. " indicator must be installed");
	FRAMA = core.indicators:create("FRAMA", source, FRAMAFrame);
	end
	if ON[8] then
	SDLFrame = instance.parameters.SDLFrame;
  --  assert(core.indicators:findIndicator("SLOPE_DIRECTION_LINE") ~= nil, "SLOPE_DIRECTION_LINE" .. " indicator must be installed");
	SDL = core.indicators:create("SLOPE_DIRECTION_LINE", source.close, SDLFrame, "MVA", "close", true);
	end
	if ON[9] then
	KRIFrame = instance.parameters.KRIFrame;
	KRI = core.indicators:create("KRI", source, KRIFrame);
	end
	if ON[10] then
	TRIXFrame = instance.parameters.TRIXFrame;
   -- assert(core.indicators:findIndicator("TRIX") ~= nil, "TRIX" .. " indicator must be installed");
	TRIX = core.indicators:create("TRIX", source.close, Frame, "EMA", "EMA", "EMA", TRIXFrame, "EMA");
	end
	if ON[11] then
	MOMENTUMFrame = instance.parameters.MOMENTUMFrame;
   -- assert(core.indicators:findIndicator("MOMENTUM") ~= nil, "MOMENTUM" .. " indicator must be installed");
	MOMENTUM = core.indicators:create("MOMENTUM", source.close, MOMENTUMFrame);
	end
	if ON[12] then
	WMAFrame = instance.parameters.WMAFrame;
	WMA = core.indicators:create("WMA", source.close, WMAFrame);
	end
	if ON[13] then
	KAMAFrame = instance.parameters.KAMAFrame;
	KAMA = core.indicators:create("KAMA", source.close, KAMAFrame);
	end
	if ON[14] then
	VORTEXFrame = instance.parameters.VORTEXFrame;
   -- assert(core.indicators:findIndicator("VORTEX") ~= nil, "VORTEX" .. " indicator must be installed");
	VORTEX = core.indicators:create("VORTEX", source, VORTEXFrame);
	end
	if ON[15] then
	DEMARKERFrame = instance.parameters.DEMARKERFrame;
   -- assert(core.indicators:findIndicator("DEM") ~= nil, "DEM" .. " indicator must be installed");
	DEMARKER =core.indicators:create("DEM", source, DEMARKERFrame);
	end
	if ON[16] then
	FORECASTFrame = instance.parameters.FORECASTFrame;
   -- assert(core.indicators:findIndicator("FORECAST") ~= nil, "FORECAST" .. " indicator must be installed");
	FORECAST =core.indicators:create("FORECAST", source.close, FORECASTFrame);
	end
	if ON[17] then
	RLWFrame = instance.parameters.RLWFrame;
	RLW =core.indicators:create("RLW", source, RLWFrame);
	end
	if ON[19] then
	Multiplier = instance.parameters.Multiplier;
	SUPERTRENDFrame = instance.parameters.SUPERTRENDFrame;
  --  assert(core.indicators:findIndicator("SUPERTREND") ~= nil, "SUPERTREND" .. " indicator must be installed");
	SUPERTREND =core.indicators:create("SUPERTREND", source, SUPERTRENDFrame, Multiplier);
	end
	if ON[18] then
	TMACDShortFrame = instance.parameters.TMACDShortFrame;	
	TMACDLongFrame = instance.parameters.TMACDLongFrame;	
	TMACD =core.indicators:create("TMACD", source.close, TMACDShortFrame, TMACDLongFrame);
		 if (TMACDLongFrame <= TMACDShortFrame) then
		   error("The short TMA period must be smaller than long TMA period");
		end
	end
	if ON[20] then
	HA =core.indicators:create("HA", source);
	end
	
	if ON[21] then
	ROCFrame = instance.parameters.ROCFrame;
	ROC =core.indicators:create("ROC", source.close, ROCFrame);
	end
	
	
 
	if ON[23] then
	ADXFrame=  instance.parameters.ADXFrame;
	ADX_Level=  instance.parameters.ADX_Level;
	ADX =core.indicators:create("ADX", source, ADX_Level);
	end
	
	if ON[22] then
	DMIFrame2=  instance.parameters.DMIFrame2;
	DMI_Level=  instance.parameters.DMI_Level;
	DMI2 =core.indicators:create("DMI", source, DMIFrame2);
	end
	 
   
    CI = instance:addStream("CI", core.Line, name, "CI", instance.parameters.CI_color, first);
    CI:setPrecision(math.max(2, instance.source:getPrecision()));
	CI:setWidth(instance.parameters.width);
    CI:setStyle(instance.parameters.style);
	CI:addLevel(0);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period < first+1 or not source:hasData(period) then
	return;
	end
	
	if  Live then
		 period=period-1;
	end 
	
	 CI[period] = 0;
	
	 
		
		 -- 1. RSI(10) > 50 = +1 < 50 = -1   
	if ON[1] then	
		 RSI:update(mode);
		 if RSI.DATA:hasData(period) then 
		     if RSI.DATA[period] > 50 then
			 Plus(1,period);
			 elseif RSI.DATA[period] < 50 then
			 Minus(1,period);		 
			 end
		 end
	end	 
--   2. CCI(10) > 0 = +1 < 0 = -1 		 
	if ON[2] then		
		 CCI:update(mode);
		 if CCI.DATA:hasData(period) then 
	 
				 if CCI.DATA[period] > 50 then
				 Plus(2,period);
				 elseif CCI.DATA[period] < 50 then
				 Minus(2,period);		 
				 end
		 end
	end	 
	 
       
    
--   3. EMA(10)...Current price > EMA(10) = +1 < EMA(10) = -1 
    if ON[3] then 
         EMA:update(mode);
		 if EMA.DATA:hasData(period) then
			 if EMA.DATA[period] < source.close[period] then
			 Plus(3,period);
			 elseif EMA.DATA[period] > source.close[period] then
			 Minus(3,period);		 
			 end
		 end
	end	 
	 
       
        
--   4. AroonUp(10) > AroonDown(10) = +1 AroonUp(10) < AroonDown(10) = -1

    if ON[4] then
           AROON:update(mode);
		 if AROON.UP:hasData(period) and AROON.DOWN:hasData(period) then
				 if  AROON.UP[period] >  AROON.DOWN[period] then
				 Plus(4,period);
				 elseif  AROON.UP[period] <  AROON.DOWN[period] then
				 Minus(4,period);		 
				 end  
		 end
	end	 
		 
--    5.  Parabolic SAR Below Current bar = +1 Above Current Bar = -1
    if ON[7] then
        SAR:update(mode);
		  if  SAR.DN:hasData(period)  then
				 Plus(7,period);
		 elseif  SAR.UP:hasData(period) then
				 Minus(7,period);
		 end
    end
    
 --   6.   DMI(10) Di+ > Di- = +1 Di+ < Di- = -1    
    if ON[5] then
         DMI:update(mode);
		 if  DMI.DIP:hasData(period) and DMI.DIM:hasData(period) then
				 if  DMI.DIP[period] >  DMI.DIM[period] then
				 Plus(5,period);
				 elseif  DMI.DIP[period] <  DMI.DIM[period] then
				 Minus(5,period);		 
				 end  
		end 
    end
--    7.  FRAMA(10) Current Price > Frama = +1 < Frama = -1 

     if ON[6] then
         FRAMA:update(mode);
		 if FRAMA.DATA:hasData(period) then
				 if  FRAMA.DATA[period] <  source.close[period] then
				 Plus(6,period);
				 elseif  FRAMA.DATA[period] >  source.close[period] then
				 Minus(6,period);		 
				 end  
		 end
    end
--    8.  Slope Direction Line(10) Positive Slope = +1 Negative Slope = -1
    if ON[8] then
         SDL:update(mode);
		 if SDL.DATA:hasData(period) then
				 if  SDL.DATA[period-1] <  SDL.DATA[period] then
				 Plus(8,period);
				 elseif  SDL.DATA[period-1] >  SDL.DATA[period] then
				 Minus(8,period);		 
				 end  
		 end
    end

--    9.  Kari Relative Index(10) > 0 = +1 < 0 = -1 
    if ON[9] then
         KRI:update(mode);
		 if KRI.DATA:hasData(period) then
			 if  KRI.DATA[period] >  0 then
			 Plus(9,period);
			 elseif  KRI.DATA[period] < 0 then
			 Minus(9,period);		 
			 end  
		 end
    end
     
--    10.  TRIX(10) EMA's > 0 = +1 < 0 = -1
    if ON[10] then
          TRIX:update(mode);
		 if TRIX.T:hasData(period) and TRIX.S:hasData(period) then
			 if  TRIX.T[period] > TRIX.S[period] then
			 Plus(10,period);
			 elseif  TRIX.T[period] < TRIX.S[period] then
			 Minus(10,period);		 
			 end  
		 end
    end


--    11.  Momentum(10) > 100 = +1 < 100 = -1
    if ON[11] then
         MOMENTUM:update(mode);
		 if MOMENTUM.DATA:hasData(period) then
			 if  MOMENTUM.DATA[period] >  100 then
			 Plus(11,period);
			 elseif  MOMENTUM.DATA[period] < 100 then
			 Minus(11,period);		 
			 end  
		 end
	end	 
		 
--    12. Wilders MA(10) Current price > = +1 Current price < = -1 		
    if ON[12] then
         WMA:update(mode);
		  if WMA.DATA:hasData(period) then
				 if  WMA.DATA[period] < source.close[period] then
				 Plus(12,period);
				 elseif  WMA.DATA[period] > source.close[period] then
				 Minus(12,period);		 
				 end   
		 end
	end	 
--    13. Kaufman Adaptive MA(10) Current price > = +1 Current Price < = -1	
    if ON[13] then
         KAMA:update(mode);
		 if KAMA.DATA:hasData(period) then
				 if  KAMA.DATA[period] < source.close[period] then
				 Plus(13,period);
				 elseif  KAMA.DATA[period] > source.close[period] then
				 Minus(13,period);		 
				 end 	 
		 end
	end	 
--     14.  Vortex(10) Vi+ > Vi- = +1 Vi+ < Vi- = -1
	 if ON[14] then
		 VORTEX:update(mode);
		 if VORTEX.VIP:hasData(period)  and  VORTEX.VIM:hasData(period) then
				 if  VORTEX.VIP[period] > VORTEX.VIM[period] then
				 Plus(14,period);
				 elseif  VORTEX.VIP[period] < VORTEX.VIM[period] then
				 Minus(14,period);		 
				 end 
		end 
	end	 
--     15. DeMarker(10) > 50 = +1 < 50 = -1		
    if ON[15] then
         DEMARKER:update(mode);
		 if DEMARKER.DATA:hasData(period) then
				 if  DEMARKER.DATA[period] > 0.5 then
				 Plus(15,period);
				 elseif  DEMARKER.DATA[period] < 0.5 then
				 Minus(15,period);		 
				 end 	
		 end
	end	 
--     16.  Forecast Osc(10) > 0 = +1 < 0 = -1	
     if ON[16] then
        FORECAST:update(mode);
		 if FORECAST.DATA:hasData(period) then
			 if  FORECAST.DATA[period] > 0 then
			 Plus(16,period);
			 elseif  FORECAST.DATA[period] < 0 then
			 Minus(16,period);		 
			 end 	 
		 end
	end	 
--     17.  Williams% Range(10) > -50 = +1 < -50 = -1	
	 if ON[17] then
          RLW:update(mode);
		  if RLW.DATA:hasData(period) then
				 if  RLW.DATA[period] > -50 then
				 Plus(17,period);
				 elseif  RLW.DATA[period] <  -50 then
				 Minus(17,period);		 
				 end  
		 end
    end

--     18.Supertrend(10, Multiplier 1.25) Uptrend = +1 Downtrend = -1

    if ON[19] then
         SUPERTREND:update(mode);
		 if SUPERTREND.UP:hasData(period) then
				
				 Plus(19,period);
		 elseif SUPERTREND.DN:hasData(period) then
				 Minus(19,period);		 
				 
		 end
    end    

--    19.If HA is Positive (Uptrend) = +1 If HA is Negative (Downtrend) = -1
    if ON[20] then
        HA:update(mode);
		  if HA.close:hasData(period) then
				 if  HA.close[period] >  HA.open[period] then
				 Plus(20,period);
				 elseif  HA.close[period] <  HA.open[period] then
				 Minus(20,period);		 
				 end  
		 end
    end
--    20.TMACD(5,10) > 0 = +1 < 0 = -1
    if ON[18] then
         TMACD:update(mode);
		 if TMACD.DATA:hasData(period) then
				 if  TMACD.DATA[period] >  0 then
				 Plus(18,period);
				 elseif  TMACD.DATA[period] <  0 then
				 Minus(18,period);		 
				 end  
		 end
    end
	
--    21.ROC(14) > 0 = +1 < 0 = -1
    if ON[21] then
         ROC:update(mode);
		 if ROC.DATA:hasData(period) then
			 if  ROC.DATA[period] >  0 then
			 Plus(21,period);
			 elseif  ROC.DATA[period] <  0 then
			 Minus(21,period);		 
			 end  
		 end
    end
	
	

	
--    DMI > DMI Level Plus
        
    if ON[22] then
         DMI2:update(mode);
		 
		 
		     if DMI2.DATA:hasData(period) then
				 if  DMI2.DIP[period] >  DMI_Level then
					 Plus(22,period);
				 end  
				 
				  if  DMI2.DIM[period] >  DMI_Level then
					 Minus(22,period);
					 
				 end  
			 end
    end
	
       
		--    22.ADX > ADX Level = 1
	 
    if ON[23] then
         ADX:update(mode);
		 if ADX.DATA:hasData(period) then
				 if  ADX.DATA[period] >  ADX_Level and CI[period]> 0  then
				 Plus(23,period);			 	 
				 end  
				 
				  if  ADX.DATA[period] >  ADX_Level and CI[period]< 0  then
				 Minus(23,period);			 	 
				 end 
		 end
    end	
		
  
end

 
function Plus(j,period)
	if Inverse[j] then	
	CI[period]=CI[period]-1;
	else	
	CI[period]=CI[period]+1;
	end
end

function Minus(j,period)
    if Inverse[j] then	
	CI[period]=CI[period]+1;
	else	
    CI[period]=CI[period]-1;
	end
end

