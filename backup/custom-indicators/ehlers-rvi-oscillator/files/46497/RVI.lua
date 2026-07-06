-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1735
-- Id: 7953

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
    indicator:name("Relative Vigor Index ");
    indicator:description("Relative Vigor Index ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addBoolean("Smooth", "Smooth", "Use Smoothing", true);
	
	indicator.parameters:addInteger("P1", "Smoothed  Period", "Smoothed  Period", 10);
    indicator.parameters:addInteger("P2", "Signal  Period", "Signal  Period", 4);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("RVI_color", "Color of RVI", "Color of RVI", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("SIGNAL_color", "Color of Signal", "Color of Signal", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local P1;
local P2;
local Smooth;

local first;
local source = nil;
local RAW;
-- Streams block
local RVI = nil;
local SIGNAL;
local MA1, MA2;
-- Routine
function Prepare(nameOnly)
    P1 = instance.parameters.P1;
    P2 = instance.parameters.P2;
	Smooth = instance.parameters.Smooth;
    source = instance.source;
  

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(P1) .. ", " .. tostring(P2) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
	
	    RAW = instance:addInternalStream(source:first(), 0);
		
		
        if Smooth then
		MA1=core.indicators:create("MVA", RAW, P1);
		 first = MA1.DATA:first();
		else
		  first = source:first();
		end
		 
        RVI = instance:addStream("RVI", core.Line, name, "RVI", instance.parameters.RVI_color, first);
    RVI:setPrecision(math.max(2, instance.source:getPrecision()));
		RVI:setWidth(instance.parameters.width1);
        RVI:setStyle(instance.parameters.style1);
		
		MA2=core.indicators:create("MVA", RVI, P2);
		SIGNAL = instance:addStream("SIGNAL", core.Line, name, "SIGNAL", instance.parameters.SIGNAL_color, MA2.DATA:first());
    SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
		SIGNAL:setWidth(instance.parameters.width2);
        SIGNAL:setStyle(instance.parameters.style2);
		
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    
	
	  
	RAW[period] = (source.close[period] - source.open[period]) / (source.high[period] - source.low[period]);
		
	if period < first  then
	return;
	end
		
	
       if Smooth then
	    MA1:update(mode);
	    RVI[period] = MA1.DATA[period];   
	   else	   	
        RVI[period] = RAW[period];     
	   end
	   
	   if period < MA2.DATA:first()  then
	  return;
	  end
	  
	  MA2:update(mode);
	  SIGNAL[period]= MA2.DATA[period];
end

