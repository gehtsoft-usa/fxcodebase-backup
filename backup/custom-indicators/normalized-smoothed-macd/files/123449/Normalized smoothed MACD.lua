--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=50&t=67287


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Normalized smoothed MACD");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SN",   "Short EMA Period", "", 12, 1, 1000);
    indicator.parameters:addInteger("LN", "Long EMA Period", "", 26, 1, 1000);
    indicator.parameters:addInteger("IN", "Signal MA Period", "", 9, 1, 1000);
	
	
	indicator.parameters:addInteger("Smoothing", "Smoothing period", "", 5, 1, 1000);
	indicator.parameters:addInteger("Normalization", "Smoothing period", "", 20, 1, 1000);
	 
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MACD_color_Up", "MACD Up Line Color","", core.rgb(0, 255, 0));
    indicator.parameters:addColor("MACD_color_Down", "MACD Down Line Color","", core.rgb(255, 0, 0));
	
    indicator.parameters:addColor("Signal_Color_Up", "Signal Up Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Signal_Color_Down", "Signal Down Line Color", "", core.rgb(100, 100, 100));
	indicator.parameters:addInteger("widthSignal", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleSignal", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSignal", core.FLAG_LEVEL_STYLE);
 
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local SN;
local LN;
local IN;

local Smoothing;
local Normalization;

local firstPeriodMACD;

local firstPeriodSignal;
local source = nil;

local EMAS = nil;
local EMAL = nil;
local MVAI = nil;

-- Streams block
local MACD = nil;
local Signal = nil;

local Raw; 
local Data;
-- Routine
function Prepare(nameOnly)
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
	
	Smoothing = instance.parameters.Smoothing;
    Normalization = instance.parameters.Normalization;
    source = instance.source;

   

    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. LN .. ", " .. IN .. ", " .. Smoothing .. ", " .. Normalization .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	 -- Check parameters
    if (LN <= SN) then
       error("The short EMA period must be smaller than long EMA period");
    end

    -- Create short and long EMAs for the source
    EMAS = core.indicators:create("EMA", source, SN);
    EMAL = core.indicators:create("EMA", source, LN);
	
 
    
 
    firstPeriodMACD = EMAL.DATA:first();
 
	 
	Raw = instance:addInternalStream(0, 0);
	Data= instance:addInternalStream(0, 0);
	
	smoothing = core.indicators:create("EMA", Raw, Smoothing);
   
    MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_color_Up, smoothing.DATA:first()); 
	MACD:setPrecision(math.max(2, instance.source:getPrecision()));
	
	
	
	
	MVAI = core.indicators:create("MVA", MACD, IN);
 
   
    firstPeriodSignal= MVAI.DATA:first();
	
	
	Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Signal_Color_Up,firstPeriodSignal);
    Signal:setWidth(instance.parameters.widthSignal);
    Signal:setStyle(instance.parameters.styleSignal);
 
	
	Signal:setPrecision(math.max(2, instance.source:getPrecision()));

	

end


function Update(period, mode)
    -- and update short and long EMAs for the source.
    EMAS:update(mode);
    EMAL:update(mode);

    if (period <= firstPeriodMACD) then
	return;
	end
	
    Raw[period]= EMAS.DATA[period] - EMAL.DATA[period];
    
		
	
    
	if (period <= firstPeriodMACD+Normalization) then
	return;
	end
	 
    local min,max=mathex.minmax(Raw, period-Normalization+1, period);
	
	
	 if min~=max then 
	  Data[period] = 2.0*(Raw[period]-min)/(max-min)-1.0 
	 else
	  Data[period] = 0
	 end
      
	  
	  smoothing:update(mode);
	  
	  if period < smoothing.DATA:first() then
	  return;
	  end
	  
	  MACD[period]=smoothing.DATA[period];
	  
 
        if MACD[period] > MACD[period-1] then
		 MACD:setColor(period, instance.parameters.MACD_color_Up);
		 else
	     MACD:setColor(period, instance.parameters.MACD_color_Down);
		 end 

 

    -- update MVA on the MACD
    MVAI:update(mode);
	
    if (period >= firstPeriodSignal) then
        Signal[period] = MVAI.DATA[period];       
        if Signal[period]> Signal[period-1] then
        Signal:setColor(period, instance.parameters.Signal_Color_Up);
		else
	    Signal:setColor(period, instance.parameters.Signal_Color_Down);		
		end
    end
	
	
end
