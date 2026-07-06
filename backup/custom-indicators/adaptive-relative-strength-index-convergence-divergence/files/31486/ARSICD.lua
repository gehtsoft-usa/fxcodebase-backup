-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=17171
-- Id: 6440

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
    indicator:name("Adaptive Relative Strength Index Convergence-Divergence");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("SN", "ARSI Period", "", 14, 2, 1000);
	indicator.parameters:addInteger("LN", "MA of ARSI Period", "", 14, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal Line", "", 9, 2, 1000);
	
    indicator.parameters:addColor("ARSI_color", "ARSI color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("ARSI_width", "ARSI Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("ARSI_style", "ARSI Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("ARSI_style", core.FLAG_LINE_STYLE);
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

local MVAI = nil;
local MVAII = nil;

-- Streams block
local ARSI = nil;
local SIGNAL = nil;
local HISTOGRAM = nil;
local _ARSI;
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

	
	_ARSI=core.indicators:create("ARSI", source, SN);


    ARSI = instance:addStream("ARSI", core.Line, name .. ".ARSI", "ARSI", instance.parameters.ARSI_color, _ARSI.DATA:first());
	ARSI:setWidth(instance.parameters.ARSI_width);
    ARSI:setStyle(instance.parameters.ARSI_style);
	
 
    MVAI = core.indicators:create("MVA", _ARSI.DATA, LN);
	
 

    SIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color, MVAI.DATA:first());
	SIGNAL:setWidth(instance.parameters.SIGNAL_width);
    SIGNAL:setStyle(instance.parameters.SIGNAL_style);
	
	
	MVAII = core.indicators:create("MVA", ARSI, IN);
	
	
    HISTOGRAM = instance:addStream("HISTOGRAMUP", core.Bar, name .. ".HISTOGRAMUP", "HISTOGRAMUP", instance.parameters.HISTOGRAM_color, MVAII.DATA:first());
	
	ARSI:setPrecision(math.max(2, instance.source:getPrecision()));
	SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
	HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));
  
end

-- Indicator calculation routine
function Update(period, mode)
   
    _ARSI:update(mode);   
    MVAI:update(mode);
    
    if period < MVAI.DATA:first() then
	return;
	end
	
	 ARSI[period] = _ARSI.DATA[period]-MVAI.DATA[period];	
	 
	 
	 if period < MVAII.DATA:first() then
	return;
	end
	
	 MVAII:update(mode);
	 
     
      
        
    if period < MVAII.DATA:first() +1  then
	return;
	end
		
	 SIGNAL[period] = MVAII.DATA[period];	
		
		 HISTOGRAM[period] = ARSI[period] - SIGNAL[period];
		 
            if( HISTOGRAM[period] > HISTOGRAM[period - 1]) then
             HISTOGRAM:setColor(period, instance.parameters.HISTOGRAM_color);  
            else
              HISTOGRAM:setColor(period, instance.parameters.HISTOGRAM2_color);  
            end
              
    end







