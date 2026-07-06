-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64776
-- Id: 18405

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
    indicator:name("Relative Strength Index Convergence-Divergence");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("SN", "Fast RSI Period", "", 12, 2, 1000);
	indicator.parameters:addInteger("LN", "Slow RSI Period", "", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal Line", "", 9, 2, 1000);
	
    indicator.parameters:addColor("color1", "RSICD color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("SIGNAL_color", "Signal color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("SIGNAL_width", "SIGNAL Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("SIGNAL_style", "SIGNAL Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("SIGNAL_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("HISTOGRAM_color", "Up Histogram", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("HISTOGRAM2_color", "Down Histogram", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local SN;
local IN;
local LN;
local source = nil;
 

-- Streams block
local ARSI = nil;
local SIGNAL = nil;
local HISTOGRAM = nil;
local RSI1,RSI2,MVA;
-- Routine
function Prepare(nameOnly)
    SN = instance.parameters.SN;
    IN = instance.parameters.IN;
	LN = instance.parameters.LN; 
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. SN.. ", " .. LN .. ", " .. IN .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	RSI1=core.indicators:create("RSI", source.close, SN);
	RSI2=core.indicators:create("RSI", source.close, LN);

    RSICD = instance:addStream("RSICD", core.Line, name .. ".RSICD", "RSICD", instance.parameters.color1, math.max(RSI1.DATA:first(),RSI2.DATA:first() ));
    RSICD:setPrecision(math.max(2, instance.source:getPrecision()));
	RSICD:setWidth(instance.parameters.width1);
    RSICD:setStyle(instance.parameters.style1);
	
 
    MVA = core.indicators:create("MVA", RSICD, IN);
	
 

    SIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color, MVA.DATA:first());
    SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
	SIGNAL:setWidth(instance.parameters.SIGNAL_width);
    SIGNAL:setStyle(instance.parameters.SIGNAL_style);
	
	

	
	
    HISTOGRAM = instance:addStream("HISTOGRAM", core.Bar, name .. ".HISTOGRAM", "HISTOGRAM", instance.parameters.HISTOGRAM_color, MVA.DATA:first());
    HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));
  
end

-- Indicator calculation routine
function Update(period, mode)
   
    RSI1:update(mode);   
    RSI2:update(mode);
	
	
	if period < math.max(RSI1.DATA:first(),RSI2.DATA:first() ) then
	return;	
	end
	
   
	 RSICD[period] = RSI1.DATA[period]-RSI2.DATA[period];	
	 
	 

	 MVA:update(mode);
	 
     
      
        
    if period < MVA.DATA:first() then
	return;
	end
		
	 SIGNAL[period] = MVA.DATA[period];	
		
		 HISTOGRAM[period] = RSICD[period] - SIGNAL[period];
		 
            if( HISTOGRAM[period] > HISTOGRAM[period - 1]) then
             HISTOGRAM:setColor(period, instance.parameters.HISTOGRAM_color);  
            else
              HISTOGRAM:setColor(period, instance.parameters.HISTOGRAM2_color);  
            end
              
    end







