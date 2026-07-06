-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=36832
-- Id: 9139

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
    indicator:name("Velocity and Accerlation Moving Average");
    indicator:description("Velocity and Accerlation Moving Average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 15);
    indicator.parameters:addBoolean("Use", "Use Double Smooth", "Use Double Smooth", true);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of Up VAMA", "Color of VAMA", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down VAMA", "Color of VAMA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Use;
local MA1, MA2,Raw; 
local source = nil;

-- Streams block
local VAMA = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    Use = instance.parameters.Use;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Use) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        MA1= core.indicators:create("EMA", source, Period);
        
        Raw = instance:addInternalStream(0, 0);
        
        
        if Use then
        MA2= core.indicators:create("EMA", Raw, Period/4);
        end
        VAMA = instance:addStream("VAMA", core.Line, name, "VAMA", instance.parameters.Up, source:first()+Period/4);
		VAMA:setWidth(instance.parameters.width);
        VAMA:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    MA1:update(mode);
	
    if period < MA1.DATA:first() + Period/4  then
	return;
	end
	
	
	  local vel = MA1.DATA[period]-MA1.DATA[period-Period/4];                                                                    
      local acc = MA1.DATA[period]-2*MA1.DATA[period-Period/4]+MA1.DATA[period-Period/8];                                                
      local aaa = MA1.DATA[period]-3*MA1.DATA[period-Period/4]+3*MA1.DATA[period-Period/8]-MA1.DATA[period-Period/12];                                                                                                  
      Raw[period] = MA1.DATA[period]+vel+acc/2+aaa/6;                                                                
	
	
	if Use then
	MA2:update(mode);
	VAMA[period] = MA2.DATA[period];
	else
	  VAMA[period] = Raw[period];
	end
	
  if VAMA[period] > VAMA[period-1] then     
  VAMA:setColor(period, instance.parameters.Up);
  else
  VAMA:setColor(period, instance.parameters.Down);
  end
end

