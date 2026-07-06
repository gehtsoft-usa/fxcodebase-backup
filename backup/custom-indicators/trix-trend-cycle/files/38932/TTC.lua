-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22578
-- Id: 7164

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Trix Trend Cycle");
    indicator:description("Trix Trend Cycle");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("TrixPeriod", "Period", "Period", 4);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("TTC_color", "Color of TTC", "Color of TTC", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local TrixPeriod;

local first;
local source = nil;
local alphaCD      = 2.0 / (1.0 + 3.0);
-- Streams block
local TTC = nil;
local trix_buffer1, trix_buffer2, trix_buffer3,raw;
local  cdBuffer,fastKBuffer,fastDBuffer,fastKKBuffer;
-- Routine
function Prepare(nameOnly)
    TrixPeriod = instance.parameters.TrixPeriod;
    source = instance.source;   

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(TrixPeriod) .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	fastDBuffer= instance:addInternalStream(0, 0);
	fastKKBuffer= instance:addInternalStream(0, 0);
	fastKBuffer= instance:addInternalStream(0, 0);
	raw= instance:addInternalStream(0, 0);
	cdBuffer= instance:addInternalStream(0, 0);
	trix_buffer1=core.indicators:create("SMMA", raw, TrixPeriod);
	trix_buffer2=core.indicators:create("SMMA", trix_buffer1.DATA, TrixPeriod);
	trix_buffer3=core.indicators:create("EMA", trix_buffer2.DATA, TrixPeriod);
	
	 first = trix_buffer3.DATA:first();
	

    if (not (nameOnly)) then
        TTC = instance:addStream("TTC", core.Line, name, "TTC", instance.parameters.TTC_color, first);
    TTC:setPrecision(math.max(2, instance.source:getPrecision()));
		TTC:setWidth(instance.parameters.width);
        TTC:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

   raw[period]= source.close[period]+source.high[period]+source.low[period];
   
    trix_buffer1:update(mode);
	trix_buffer2:update(mode);
	trix_buffer3:update(mode);
	
    if period < first or not  source:hasData(period) then
	return;
	end
	
	
	
	     cdBuffer[period]   = cdBuffer[period-1]+alphaCD*(trix_buffer3.DATA[period]-trix_buffer3.DATA[period-1]);
		 
	
	  local  lowCd  =  mathex.min (cdBuffer, period- TrixPeriod+1 , period );
      local  highCd =  mathex.max (cdBuffer, period- TrixPeriod+1 , period )-lowCd;
	  
      if highCd > 0 then
       fastKBuffer[period] = 100*((cdBuffer[period]-lowCd)/highCd);
      else 
	   fastKBuffer[period] = fastKBuffer[period-1];
	   end
	   
         fastDBuffer[period] = fastDBuffer[period-1]+0.5*(fastKBuffer[period]-fastDBuffer[period-1]);
	   
	   
	   ---------------------------------------
	   
	 local  lowStoch    =  mathex.min (fastDBuffer, period- TrixPeriod+1 , period );
     local  highStoch  =  mathex.max (fastDBuffer, period- TrixPeriod+1 , period )-lowStoch; 
      
	    if highStoch > 0 then
	    fastKKBuffer[period] = 100*((fastDBuffer[period]-lowStoch)/highStoch);
        else  
		fastKKBuffer[period] = fastKKBuffer[period-1];
		end
		 
                   

        TTC[period] =  TTC[period-1]+0.5*(fastKKBuffer[period]-TTC[period-1]);
    
end

