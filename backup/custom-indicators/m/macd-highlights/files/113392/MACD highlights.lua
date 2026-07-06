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

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=64889


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("MACD highlights");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SN",   "Short EMA Period", "", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long EMA Period", "", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal MA Period", "", 9, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MACD_color_Up", "MACD Bar Color","", core.rgb(0, 255, 0));
    indicator.parameters:addColor("MACD_color_Down", "MACD Bar Color","", core.rgb(255, 0, 0));
	
    indicator.parameters:addColor("Signal_Color_Up", "Signal Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Signal_Color_Down", "Signal Line Color", "", core.rgb(255, 0, 0));
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

local firstPeriodMACD;

local firstPeriodSignal;
local source = nil;

local EMAS = nil;
local EMAL = nil;
local MVAI = nil;

-- Streams block
local MACD = nil;
local Signal = nil;

 
-- Routine
function Prepare(nameOnly)
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
    source = instance.source;

   

    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. LN .. ", " .. IN .. ")";
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
	

    local precision = math.max(2, source:getPrecision());
    
 
    firstPeriodMACD = EMAL.DATA:first();
 
	 
   
    MACD = instance:addStream("MACD", core.Bar, name .. ".MACD", "MACD", instance.parameters.MACD_color_Up, firstPeriodMACD);
    MACD:setPrecision(precision); 
	
	  MVAI = core.indicators:create("MVA", MACD, IN);
 
   
    firstPeriodSignal= MVAI.DATA:first();
	
	
	Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Signal_Color_Up,firstPeriodSignal);
    Signal:setWidth(instance.parameters.widthSignal);
    Signal:setStyle(instance.parameters.styleSignal);
    Signal:setPrecision(precision);

	

end


function Update(period, mode)
    -- and update short and long EMAs for the source.
    EMAS:update(mode);
    EMAL:update(mode);

    if (period >= firstPeriodMACD) then
        -- calculate MACD output
         MACD[period] = EMAS.DATA[period] - EMAL.DATA[period];
		 if MACD[period] > MACD[period-1] then
		 MACD:setColor(period, instance.parameters.MACD_color_Up);
		 else
	     MACD:setColor(period, instance.parameters.MACD_color_Down);
		 end
	
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
