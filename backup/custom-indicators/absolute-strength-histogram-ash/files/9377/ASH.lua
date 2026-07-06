-- Id: 3529
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3836

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
    indicator:name("Absolute Strength Histogram");
    indicator:description("Absolute Strength Histogram");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	

	indicator.parameters:addString("Mode", "Calculation Mode", "", "RSI");
    indicator.parameters:addStringAlternative("Mode", "RSI", "", "RSI");
    indicator.parameters:addStringAlternative("Mode", "STOCH", "", "STOCH")
	indicator.parameters:addInteger("Length", "Length", "", 9, 2, 2000);   
	indicator.parameters:addInteger("Smooth", "Smoothing Period", "", 2, 2, 2000); 
	indicator.parameters:addString("Price", "MA Price Source", "", "close");
	indicator.parameters:addStringAlternative("Price", "Open", "", "open");
	indicator.parameters:addStringAlternative("Price", "High", "", "high");
	indicator.parameters:addStringAlternative("Price", "Low", "", "low");
	indicator.parameters:addStringAlternative("Price", "Close/Tick", "", "close");
	indicator.parameters:addStringAlternative("Price", "Median", "", "median");
	indicator.parameters:addStringAlternative("Price", "Typical", "", "typical");
	indicator.parameters:addStringAlternative("Price", "Weighted", "", "weighted");
    indicator.parameters:addString("Method", "Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");	
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");   
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
 
    indicator.parameters:addColor("Bulls_color", "Color of Bulls", "Color of Bulls", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Bears_color", "Color of Bears", "Color of Bears", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Mode;
local Length;
local Smooth;
local Price;
local Method;

local first,FIRST;
local source = nil;
local MAsource;

-- Streams block

local AvgBulls;
local AvgBears;

local BullsOut = nil;
local BearsOut = nil;

local SmthBulls = nil;
local SmthBears = nil;

local Bulls = nil;
local Bears = nil;

-- Routine
function Prepare(nameOnly)   
	Method = instance.parameters.Method;
    Smooth = instance.parameters.Smooth;
    Mode = instance.parameters.Mode;
	Length= instance.parameters.Length;
	Price= instance.parameters.Price;
    source = instance.source;
   
	
	if Price == "open" then
        MAsource = source.open;
    elseif Price == "high" then
        MAsource = source.high;
    elseif Price == "low" then
        MAsource = source.low;
    elseif Price == "close" then
        MAsource = source.close;
    elseif Price == "median" then
        MAsource = source.median;
    elseif Price == "typical" then
        MAsource = source.typical;
    elseif Price == "weighted" then
        MAsource = source.weighted;
    else
        MAsource = source.close;
    end
	
	FIRST = source:first()+1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Mode).. ", " .. tostring(Length).. ", " .. tostring(Smooth).. ", " .. tostring(Price).. ", " .. tostring(Method) ..  ")";
    instance:name(name);

    if (not (nameOnly)) then
	
        Bulls=instance:addInternalStream (FIRST, 0);
        Bears=instance:addInternalStream (FIRST, 0);
        
        AvgBulls= core.indicators:create(Method, Bulls, Length);
        AvgBears= core.indicators:create(Method, Bears, Length);
        
        SmthBulls= core.indicators:create(Method, AvgBulls.DATA, Smooth);
        SmthBears= core.indicators:create(Method, AvgBears.DATA, Smooth);
        
         first = SmthBulls.DATA:first();
        BullsOut = instance:addStream("Bulls", core.Line, name .. ".Bulls", "Bulls", instance.parameters.Bulls_color, first);
        BearsOut = instance:addStream("Bears", core.Line, name .. ".Bears", "Bears", instance.parameters.Bears_color, first);
		
		BullsOut:setPrecision(math.max(2, instance.source:getPrecision()));
		BearsOut:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period < FIRST + Length  or not source:hasData(period) then
	return;
	end
	
	      if Mode == "RSI" then
		  Bulls[period]=0.5*(math.abs(MAsource[period]-MAsource[period-1]))+(MAsource[period]-MAsource[period-1]);
          Bears[period]=0.5*(math.abs(MAsource[period]-MAsource[period-1]))-(MAsource[period]-MAsource[period-1]);
		  else
		  local  smax=mathex.max(source.high, period- Length, period);
          local smin=mathex.min(source.low, period- Length, period);
          Bulls[period]=MAsource[period] - smin;
          Bears[period]=smax - MAsource[period];		  
		  end
	  
		  
		  AvgBulls:update(mode);
		  AvgBears:update(mode);
		  
		  SmthBulls:update(mode);
		  SmthBears:update(mode);
		  
		  if not SmthBulls.DATA:hasData(period) or not SmthBears.DATA:hasData(period) then
		  return;
		  end  	  
		
		   BullsOut[period] = SmthBulls.DATA[period]/ source:pipSize();
           BearsOut[period] =SmthBears.DATA[period]/ source:pipSize();	
		   
end

