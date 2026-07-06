-- Id: 15404
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1294

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("MA Angle");
    indicator:description(" Determines MA Angle");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addString("Price", "Price Source", "", "median");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method", "DEMA", "DEMA" , "DEMA");
	indicator.parameters:addStringAlternative("Method", "TEMA", "TEMA" , "TEMA");
    indicator.parameters:addInteger("F", "Period", "Period", 50, 2, 2000);
    indicator.parameters:addInteger("S", "Shift", "Shift", 6, 0, 2000);
	indicator.parameters:addDouble("T", "Treshold", "Treshold", 0.3 , 0, 100);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Top", "Positiv Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Bottom", "Negativ Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Zero", "Neutral Color", "", core.rgb(255, 215, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame=nil;
local Shift=nil;
local Treshold = nil;
local Method;
local first;
local source = nil;

-- Streams block
local ANGLE = nil;
local Flag = nil;
local mFactor=nil;
local dFactor=nil;

local BC=nil;
local ZC=nil;
local TC=nil;

local MA=nil;
local Price;  
-- Routine
function Prepare(nameOnly)

    BC=instance.parameters.Bottom;
    ZC=instance.parameters.Zero;
    TC=instance.parameters.Top;
	Method=instance.parameters.Method;
	Price=instance.parameters.Price;

    Frame = instance.parameters.F;
    Shift = instance.parameters.S;
	Treshold = instance.parameters.T;
    source = instance.source;
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. Price.. ", " .. Frame ..  ", " ..  Shift .. ", " .. Treshold .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end 
   
	assert(core.indicators:findIndicator(Method) ~= nil, "Please, download and install " ..  Method .. ".LUA indicator");
		
	
	MA = core.indicators:create(Method, source[Price], Frame);
	first = MA.DATA:first()+ Shift;

   
    ANGLE = instance:addStream("ANGLE", core.Bar, name, "ANGLE", ZC, first);
    ANGLE:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)


    MA:update(mode);
  
    if period >= first  and source:hasData(period) then
        	      
      ANGLE[period] = ( MA.DATA[period] - MA.DATA[period-Shift])/ source:pipSize();
	  
	
      
      if ANGLE[period] >= Treshold then
      ANGLE:setColor(period, TC);
      elseif ANGLE[period] <=  -Treshold then
        ANGLE:setColor(period, BC); 
      else 
	  ANGLE:setColor(period, ZC);
	  end

	  
	
    end
end