-- Id: 6134
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
    indicator:name("MAAngle");
    indicator:description(" Determines the angle between two EMAs");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("F", "Period", "Period", 50, 2, 2000);
    indicator.parameters:addInteger("S", "Shift", "Shift", 6, 0, 2000);
	indicator.parameters:addDouble("T", "Treshold", "Treshold", 0.3 , 0, 100);
	indicator.parameters:addString("Price", "Price Source", "", "median");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
	indicator.parameters:addString("Method", "Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "HMA" , "HMA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method", "VAMA", "VAMA" , "VAMA");	
	indicator.parameters:addStringAlternative("Method", "NONLAGMA", "NONLAGMA", "NONLAGMA"); 
	indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA", "VIDYA"); 
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Top", "Color of Top", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Bottom", "Color of Bottom", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Zero", "Color of Zero", "", core.rgb(255, 215, 0));
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
local UP=nil;
local DOWN = nil;
local ZERO=nil;

local first;
local source = nil;

-- Streams block
local Angle = nil;
local Flag = nil;


local BC=nil;
local ZC=nil;
local TC=nil;
local Price;
local MA=nil;
  
-- Routine
function Prepare()
    Method=instance.parameters.Method;
    Price=instance.parameters.Price;
    BC=instance.parameters.Bottom;
    ZC=instance.parameters.Zero;
    TC=instance.parameters.Top;

    Frame = instance.parameters.F;
    Shift = instance.parameters.S;
	Treshold = instance.parameters.T;
    source = instance.source;
    
	
		assert(core.indicators:findIndicator(Method) ~= nil, "Please, download and install " ..  Method ..".LUA indicator");
		
  
		
    if Method == "VAMA" then

	 	local p;
				 if Price == "open" then
					p = "O";
				elseif Price == "high" then
					p = "H";
				elseif Price == "low" then
					p = "L";
				elseif Price == "close" then
					p = "C";
				elseif Price == "median" then
					p = "M";
				elseif  Price == "weighted" then
					p = "W";
				 elseif  Price == "typical" then
				  p = "T"
   			  end
	
	
	MA = core.indicators:create(Method, source, Frame, p);
	else
	MA = core.indicators:create(Method, source[Price], Frame);
	end
	
	first = MA.DATA:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame ..  ", " ..  Shift .. ", " .. Treshold.. ", " .. Method .. ")";
    instance:name(name);
    Angle = instance:addStream("Angle", core.Bar, name, "Angle", TC, first);
    Angle:setPrecision(math.max(2, instance.source:getPrecision()));
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    MA:update(mode);
  
    if period < Frame + Shift  or not  source:hasData(period)  then
	return;
	end
        	      
      Angle[period] = ( MA.DATA[period] - MA.DATA[period-Shift])/ source:pipSize();	  
	
      
      if Angle[period] >= Treshold then
       Angle:setColor(period,TC);
      elseif Angle[period] <=  -Treshold then
        Angle:setColor(period,BC);
      else 
	    Angle:setColor(period,ZC);
	  end	
    
end

