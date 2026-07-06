-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=13334
-- Id: 5813

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
function Init()
    indicator:name("MACD Alert");
    indicator:description("MACD Alert");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
	 indicator.parameters:addInteger("SN", "Short EMA", "(SN)No Description", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long EMA", "(LN)No Description", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal Line", "(IN)No Description", 9, 2, 1000);

    indicator.parameters:addGroup("Alerts");  
    indicator.parameters:addBoolean("PlaySound", "Play Sound Alert", "", true);
	
	
	indicator.parameters:addBoolean("Histogram", "Play Histogram Sound Alert", "", true);
    indicator.parameters:addFile("HistogramOver", "Histogram Cross Over", "", "");
    indicator.parameters:setFlag("HistogramOver", core.FLAG_SOUND);
   
    indicator.parameters:addFile("HistogramUnder", "Histogram Cross Under", "", "");
    indicator.parameters:setFlag("HistogramUnder", core.FLAG_SOUND);
	
	indicator.parameters:addBoolean("Signal", "Play Signal Line Sound Alert", "", true);
	
	indicator.parameters:addFile("SignalOver", "Signal Line Cross Over", "", "");
    indicator.parameters:setFlag("SignalOver", core.FLAG_SOUND);
   
    indicator.parameters:addFile("SignalUnder", "Signal Line Cross Under", "", "");
    indicator.parameters:setFlag("SignalUnder", core.FLAG_SOUND);
   	
	
	   indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MACD_color", "MACD color", "(MACD Color)Red", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("MACD_width", "MACD Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("MACD_style", "MACD Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("MACD_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("SIGNAL_color", "Signal color", "(Signal Color) Blue", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("SIGNAL_width", "SIGNAL Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("SIGNAL_style", "SIGNAL Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("SIGNAL_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("HISTOGRAM_color", "Up Histogram", "Up Histogram", core.rgb(0, 255, 0));
    indicator.parameters:addColor("HISTOGRAM2_color", "Down Histogram", "Down Histogram", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local SoundFile = nil;
local PlaySound;
local first;
local source = nil;
local done = false;

local SN;
local LN;
local IN;

local firstPeriodMACD;
local firstPeriodSIGNAL;

local EMAS = nil;
local EMAL = nil;
local MVAI = nil;

-- Streams block
local MACD = nil;
local SIGNAL = nil;
local HISTOGRAM = nil;
local HISTOGRAM2 = nil;

local Histogram;
local Signal;


local Activ;
require("proAudioRt");

local Last;

-- Routine
function Prepare(nameOnly)
    SoundFile = instance.parameters.SoundFile;
	PlaySound = instance.parameters.PlaySound;
	Histogram= instance.parameters.Histogram;
	Signal= instance.parameters.Signal;
	SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
	
    source = instance.source;
    first = source:first();
	Activ= false;
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. LN .. ", " .. IN .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	if (LN <= SN) then
       error("The short EMA period must be smaller than long EMA period");
    end
	
	 EMAS = core.indicators:create("EMA", source, SN);
    EMAL = core.indicators:create("EMA", source, LN);

    if (not (nameOnly)) then
     firstPeriodMACD = EMAL.DATA:first();
    MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_color, firstPeriodMACD);
	MACD:setWidth(instance.parameters.MACD_width);
    MACD:setStyle(instance.parameters.MACD_style);
	MACD:setPrecision (4);


    -- Create MVA for the MACD output stream.
    MVAI = core.indicators:create("MVA", MACD, IN);
    
    -- Create output for the signal and histogram
    firstPeriodSIGNAL = MVAI.DATA:first();
    SIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color, firstPeriodSIGNAL);
	SIGNAL:setWidth(instance.parameters.SIGNAL_width);
    SIGNAL:setStyle(instance.parameters.SIGNAL_style);
	SIGNAL:setPrecision (4);
    HISTOGRAM = instance:addStream("HISTOGRAM", core.Bar, name .. ".HISTOGRAM", "HISTOGRAM", instance.parameters.HISTOGRAM_color, firstPeriodSIGNAL);
	HISTOGRAM:setPrecision (4);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    -- and update short and long EMAs for the source.
    EMAS:update(mode);
    EMAL:update(mode);

    if (period >= firstPeriodMACD) then
         MACD[period] = EMAS.DATA[period] - EMAL.DATA[period];
    end


    MVAI:update(mode);
    
    if (period >= firstPeriodSIGNAL) then
        SIGNAL[period] = MVAI.DATA[period];
        
        local diff = MACD[period] - SIGNAL[period];
        HISTOGRAM[period] = MACD[period] - SIGNAL[period];
        
        if(period >= firstPeriodSIGNAL + 2) then
		
		 HISTOGRAM[period] = MACD[period] - SIGNAL[period];
		 
            if( HISTOGRAM[period] > HISTOGRAM[period - 1]) then
             HISTOGRAM:setColor(period, instance.parameters.HISTOGRAM_color);  
            else
              HISTOGRAM:setColor(period, instance.parameters.HISTOGRAM2_color);  
            end
        end        
    end
	
	
	if period == source:size()-1 then
	
	
			if Histogram then
					if core.crossesOver(HISTOGRAM,  0 , period) then 	
						playSound(instance.parameters.HistogramOver);
					elseif core.crossesUnder(HISTOGRAM,  0 , period) then 	
						playSound(instance.parameters.HistogramUnder);
					end	
			end

			if Signal then 	
			    if core.crossesOver(MACD, SIGNAL  , period) then 	
				playSound(instance.parameters.SignalOver);
				elseif core.crossesOver(MACD, SIGNAL, period) then 	
				playSound(instance.parameters.SignalUnder);
				end
			end	
	end	
		
	
end


function playSound(SoundFile)


     if source:serial(source:size()-1) ~=  Last then
     Last = source:serial(source:size()-1);
	 else
     return;	  
	 end  

     if not PlaySound then
	 return;
	 end

    -- create an audio device using default parameters and exit in case of errors
    if not proAudio.create() and not Activ then
	error("Cannot create device");
	-- proAudio.destroy();
	 --return;
	 else
	 Activ = true;
	end

    -- load and play a sample:
    sample = proAudio.sampleFromFile(SoundFile)
    if sample then proAudio.soundPlay(sample) end

    -- wait until the sound has finished:
    while proAudio.soundActive()>0 do 
        proAudio.sleep(0.05)
    end

    -- close audio device
  -- proAudio.destroy()

end

