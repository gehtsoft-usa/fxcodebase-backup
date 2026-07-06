-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=12602
-- Id: 5707

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Moving Average Relative Position");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Algorithm");  
  indicator.parameters:addString("Algorithm", "Algorithm Type", "" , "Historic");
    indicator.parameters:addStringAlternative("Algorithm", "Historic", "" , "Historic");
    indicator.parameters:addStringAlternative("Algorithm", "Live", "" , "Live");
	 
	indicator.parameters:addGroup("Method One");
	indicator.parameters:addInteger("Short", "First Averege Period", "First Averege  Period", 20);
	indicator.parameters:addString("Method1", "Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addString("Type1", "Price Type", "", "close");
    indicator.parameters:addStringAlternative("Type1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Type1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Type1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Type1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Type1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Type1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Type1", "WEIGHTED", "", "weighted");
	
	
	indicator.parameters:addGroup("Method Two");
	indicator.parameters:addInteger("Long", "Second Averege Period", "Second Averege Period", 100);
	indicator.parameters:addString("Method2", "Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");

	
	
	indicator.parameters:addString("Type2", "Price Type", "", "close");
    indicator.parameters:addStringAlternative("Type2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Type2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Type2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Type2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Type2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Type2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Type2", "WEIGHTED", "", "weighted");
	 
   indicator.parameters:addGroup("Style");	
   indicator.parameters:addColor("Up", "Line Color", "", core.rgb( 0, 255, 0));  
    indicator.parameters:addColor("Dn", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Method1=nil;
local Method2=nil;
local Short, Long, Type1, Type2;

local first;
local source = nil;
local DMS;
local Algorithm;
-- Streams block
local SHORT, LONG;
local Algo;
local RAW;
-- Routine
function Prepare(nameOnly)
    Algorithm= instance.parameters.Algorithm;
    Type1= instance.parameters.Type1;
	Type2= instance.parameters.Type2;
    Short = instance.parameters.Short;
	Long = instance.parameters.Long;
	Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
    source = instance.source;
    

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Short) .. ", " .. tostring(Method1).. ", " .. tostring(Long).. ", " .. tostring(Method2).. ")";
    instance:name(name);
	
    if (not (nameOnly)) then
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
		SHORT= core.indicators:create(Method1, source[Type1], Short);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
		LONG= core.indicators:create(Method2, source[Type2], Long);
		
		first = math.max(SHORT.DATA:first(),LONG.DATA:first());
	
        DMS = instance:addStream("DMS", core.Line, name, "DMS", instance.parameters.Up, first);
    DMS:setPrecision(math.max(2, instance.source:getPrecision()));
		DMS:setWidth(instance.parameters.width);
		DMS:setStyle(instance.parameters.style);
		RAW = instance:addInternalStream(first, 0);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first   or not  source:hasData(period) then
	return;
	end
    SHORT:update(mode);
	LONG:update(mode);
	
	     if Short < Long then
		   RAW[period] = (SHORT.DATA[period]-LONG.DATA[period]) /  (LONG.DATA[period] / 100);
		   else
		   RAW[period] = (LONG.DATA[period]-SHORT.DATA[period])/  (SHORT.DATA[period] / 100);
          end
	
	
	
	local i;
	local min1, min2, max1, max2, min, max;
 
   if Algorithm == "Live" then
		  DMS[period] = RAW[period];
		  
		  
		    if DMS[period] >   DMS[period-1] then
			DMS:setColor(period, instance.parameters.Up);
			else
			DMS:setColor(period, instance.parameters.Dn);
			end
	elseif period < source:size()-1 or period < first  then
	return;
	else
	
	    
		 
		
		   min, max= mathex.minmax (RAW , first , source:size()-1 );
		   local PlusRange=0; 
		   local MinusRange=0;

		   if min < 0 then
		   MinusRange  = 0 - min;		 
		   end
		   
		   if max >  0 then
		   PlusRange  = max-0;		  
		   end
		   
		   local Range = math.max(PlusRange , MinusRange);
		 
		 
		          for i = first ,source:size()-1, 1 do
				  

  				       DMS[i] = RAW[i]/ (Range/100);
					   
					    if DMS[i] >   DMS[i-1] then
						DMS:setColor(i, instance.parameters.Up);
						else
						DMS:setColor(i, instance.parameters.Dn);
						end
				  
				  end
		 
	
	end	
  
   
end

