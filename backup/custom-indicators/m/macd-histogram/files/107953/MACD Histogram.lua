-- Id: 16601

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63834

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
function Init()
    indicator:name("MACD Histogram");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SN", "Short EMA", "", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long EMA", "", 26, 2, 1000);
    --indicator.parameters:addInteger("IN", "Signal Line", "", 9, 2, 1000);
	
	indicator.parameters:addGroup("Style");
 
    indicator.parameters:addColor("UpUp", "Color of Up in Up Trend", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UpDown", "Color of Down in Up Trend", "", core.rgb(0, 200, 0));
    indicator.parameters:addColor("DownUp", "Color of Up in Down Trend", "", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("DownDown", "Color of Down in Down Trend", "", core.rgb(200, 0, 0));
 	
end

-- Indicator instance initialization routine

-- Parameters block
local SN;
local LN;
 

local firstPeriodMACD;
local EMAS = nil;
local EMAL = nil;
local HISTOGRAM = nil;

-- Routine
function Prepare(nameOnly)
    SN = instance.parameters.SN;
    LN = instance.parameters.LN
    source = instance.source;
	UpUp= instance.parameters.UpUp;
	DownDown= instance.parameters.DownDown;
	UpDown= instance.parameters.UpDown;
	DownUp= instance.parameters.DownUp;

    -- Check parameters
    if (LN <= SN) then
       error("The short EMA period must be smaller than long EMA period");
    end

    -- Create short and long EMAs for the source
    EMAS = core.indicators:create("EMA", source, SN);
    EMAL = core.indicators:create("EMA", source, LN);

    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. LN  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    -- Create the output stream for the MACD. The first period is equal to the
    -- biggest first period of source EMA streams
    firstPeriodMACD = EMAL.DATA:first();
    HISTOGRAM = instance:addStream("MACD", core.Bar, name .. ".MACD", "MACD", UpUp, firstPeriodMACD);
	
	HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));

end

-- Indicator calculation routine
function Update(period, mode)
    -- and update short and long EMAs for the source.
    EMAS:update(mode);
    EMAL:update(mode);

    if (period < firstPeriodMACD) then
	return;
	end

         HISTOGRAM[period] = EMAS.DATA[period] - EMAL.DATA[period];
 
     
  
        if HISTOGRAM[period] > 0    then
			if HISTOGRAM[period]> HISTOGRAM[period-1] then
			HISTOGRAM:setColor(period, UpUp);
			else
			HISTOGRAM:setColor(period, UpDown);  
			end 		
        elseif HISTOGRAM[period] < 0 then
		    if HISTOGRAM[period]> HISTOGRAM[period-1] then
            HISTOGRAM:setColor(period, DownUp); 
            else  			
		    HISTOGRAM:setColor(period, DownDown); 
            end  		 
        end
 
end


