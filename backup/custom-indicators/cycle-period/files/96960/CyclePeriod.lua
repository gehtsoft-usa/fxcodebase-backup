-- Id: 12921
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61420

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
    indicator:name("CYLE_PERIOD");
    indicator:description("CYLE_PERIOD");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addDouble("Alpha", "Alpha", "Alpha", 0.07);
    indicator.parameters:addColor("CYLE_PERIOD_color", "Color of CYLE_PERIOD", "Color of CYLE_PERIOD", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Alpha;

local first;
local source = nil;

local DeltaPhase;
local CPeriod;
local Smooth;
local Cycle;
local Q1;
local I1;
local InstPeriod;

-- Streams block
local CYLE_PERIOD = nil;
local Median;
-- Routine
function Prepare(nameOnly)
    Alpha = instance.parameters.Alpha;
    source = instance.source;
    first = source:first()+2;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Alpha) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        DeltaPhase = instance:addInternalStream(0, 0);
        CPeriod= instance:addInternalStream(0, 0);
        Smooth= instance:addInternalStream(0, 0);
        Cycle= instance:addInternalStream(0, 0);
        Q1= instance:addInternalStream(0, 0);
        I1= instance:addInternalStream(0, 0);
        InstPeriod= instance:addInternalStream(0, 0);
        CYLE_PERIOD = instance:addStream("CYLE_PERIOD", core.Line, name, "CYLE_PERIOD", instance.parameters.CYLE_PERIOD_color, first+6);
    CYLE_PERIOD:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


    if period < first or not source:hasData(period) then
	return;
	end
	
	local DC;
	
	   
        Smooth[period] = (source.median[period] + 2.0 * source.median[period-1] + 2.0 * source.median[period-2] + source.median[period-3]) / 6.0;
		
		
        Cycle[period] = (1.0 - 0.5 * Alpha) * (1.0 - 0.5 * Alpha) * (Smooth[period] - 2 * Smooth[period-1] + Smooth[period-2])  + 2.0 * (1.0 - Alpha) * Cycle[period-1]
            - (1.0 - Alpha) * (1.0 - Alpha) * Cycle[period- 2];
        if (period < 8)  then
            Cycle[period] = (source.median[period] - 2.0 * source.median[period-1] + source.median[period-2]) / 4.0;           
       end
	   
	   if period <   first + 6 then
	   return;
	   end
	   
        Q1[period] = (0.0962 * Cycle[period] + 0.5769 * Cycle[period- 2] - 0.5769 * Cycle[period- 4] - 0.0962 * Cycle[period- 6]) * (0.5 + 0.08 * InstPeriod[period- 1]);
		
        I1[period] = Cycle[period- 3];
        if (Q1[period] ~=  0.0 and Q1[period - 1] ~= 0.0)  then
            DeltaPhase[period] = (I1[period] / Q1[period] - I1[period- 1] / Q1[period- 1]) 
                / (1.0 + I1[period] * I1[period- 1] / (Q1[period] * Q1[period- 1]));
       end
        DeltaPhase[period] = math.max(0.1, DeltaPhase[period]);
        DeltaPhase[period] = math.min(1.1, DeltaPhase[period]);
		
        local  MedianDelta, DC;
        local  M={};
		for i= 1,5 ,1 do
		M[i]= DeltaPhase[period-i+1];
		end
		
		table.sort(M)
		MedianDelta= M[3];
      
        if (MedianDelta == 0.0)  then
            DC = 15.0;
         else  
            DC = 6.28318 / MedianDelta + 0.5;
        end
		
        InstPeriod[period] = 0.33 * DC + 0.67 * InstPeriod[period - 1];
       
	
        CYLE_PERIOD[period]   = 0.15 * InstPeriod[period] + 0.85 * CYLE_PERIOD[period - 1];
     
end

