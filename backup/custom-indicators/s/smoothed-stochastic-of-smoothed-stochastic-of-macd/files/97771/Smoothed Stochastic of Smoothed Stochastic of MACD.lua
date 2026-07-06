-- Id: 13268

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61607

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
    indicator:name("Smoothed Stochastic of Smoothed Stochastic of MACD");
    indicator:description("Smoothed Stochastic of Smoothed Stochastic of MACD");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("StochasticLength", "StochasticLength", "StochasticLength", 32);
    indicator.parameters:addInteger("SmoothEMA", "SmoothEMA", "SmoothEMA", 9);
    indicator.parameters:addInteger("SignalEMA", "SignalEMA", "SignalEMA", 5);
    indicator.parameters:addInteger("MacdFast", "MacdFast", "MacdFast", 12);
    indicator.parameters:addInteger("MacdSlow", "MacdSlow", "MacdSlow", 26);
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("DSS_color_Up", "Color of DSS Up", "Color of DSS", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("DSS_color_Down", "Color of DSS Down", "Color of DSS", core.rgb(0, 200, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("SIGNAL_color_Up", "Color of SIGNAL Up", "Color of SIGNAL", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("SIGNAL_color_Down", "Color of SIGNAL Down", "Color of SIGNAL", core.rgb(200, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local StochasticLength;
local SmoothEMA;
local SignalEMA;
local MacdFast;
local MacdSlow;

local first;
local source = nil;

-- Streams block
local DSS = nil;
local SIGNAL = nil;
local alpha,beta;
local MACD;
local DDS1,DDS2,DDS3;
-- Routine
function Prepare(nameOnly)
    StochasticLength = instance.parameters.StochasticLength;
    SmoothEMA = instance.parameters.SmoothEMA;
    SignalEMA = instance.parameters.SignalEMA;
    MacdFast = instance.parameters.MacdFast;
    MacdSlow = instance.parameters.MacdSlow;
    source = instance.source;
	
	alpha = 2.0 / (1.0+SignalEMA);
	beta = 2.0 / (1.0+SmoothEMA);
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(StochasticLength) .. ", " .. tostring(SmoothEMA) .. ", " .. tostring(SignalEMA) .. ", " .. tostring(MacdFast) .. ", " .. tostring(MacdSlow) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        DDS1= instance:addInternalStream(0, 0);
        DDS2= instance:addInternalStream(0, 0);
        DDS3= instance:addInternalStream(0, 0);
        MACD= instance:addInternalStream(0, 0); 
        Fast = core.indicators:create("EMA", source, MacdFast);
        Slow = core.indicators:create("EMA", source,  MacdSlow );
        first = math.max(Slow.DATA:first(),Fast.DATA:first());
    
        DSS = instance:addStream("DSS", core.Line, name .. ".DSS", "DSS", instance.parameters.DSS_color_Up, first+StochasticLength*2);
    DSS:setPrecision(math.max(2, instance.source:getPrecision()));
		DSS:setWidth(instance.parameters.width1);
        DSS:setStyle(instance.parameters.style1);
        SIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color_Up, first+StochasticLength*2);
    SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
		SIGNAL:setWidth(instance.parameters.width2);
        SIGNAL:setStyle(instance.parameters.style2);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    Slow:update(mode);
	Fast:update(mode);
	
    if period < first or not source:hasData(period) then
	return;
	end
	
	MACD[period]= Fast.DATA[period]-Slow.DATA[period];
	
		
	
        Calculate(period);
        SIGNAL[period] =   SIGNAL[period-1]+alpha*(DSS[period]- SIGNAL[period-1]); 
		if  SIGNAL[period] >  SIGNAL[period-1] then
		SIGNAL:setColor(period, instance.parameters.SIGNAL_color_Up);
		else
		SIGNAL:setColor(period, instance.parameters.SIGNAL_color_Down);
		end
    
end

function Calculate (period)
 
  local min,max;
  min,max=mathex.minmax(MACD, period-StochasticLength+1, period);
  
  if min~= max then
  DDS1[period]= 100*(MACD[period]-min)/(max-min);
  else
  DDS1[period]=0;
  end
  
  DDS2[period] = DDS2[period-1]+beta*( DDS1[period]- DDS2[period-1]);
  min,max=mathex.minmax(DDS2, period-StochasticLength+1, period);  
  
  if min~= max then
  DDS3[period]=(100*(DDS2[period]-min)/(max-min));  
  else
  DDS3[period]=0;
  end
  
  DSS[period]=DSS[period-1]+beta*( DDS3[period]- DSS[period-1]);
  
  
        if  DSS[period] >  DSS[period-1] then
		DSS:setColor(period, instance.parameters.DSS_color_Up);
		else
		DSS:setColor(period, instance.parameters.DSS_color_Down);
		end
end
