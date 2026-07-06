-- Id: 24661
 
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68327

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
function Init()
    indicator:name("Martingale Check");
    indicator:description("Martingale Check");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
 
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Minimum", "Minimum for Negative Trade", "", 2);
	indicator.parameters:addInteger("Period1", "MA Period", " Period", 14);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
  indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
 
 
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Color", "Color", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Minimum; 
local Period1, Method1;
local first;
local source = nil;
local Indicator
 local SignalA,SignalB;
local Martingale;
-- Routine
function Prepare(nameOnly)
    Minimum = instance.parameters.Minimum;
	Method1 = instance.parameters.Method1; 
	Period1 = instance.parameters.Period1; 
    source = instance.source;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period1)   .. ", " .. tostring(Method1)  .. ")";
    instance:name(name);

    if (not (nameOnly)) then 
	
	 
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
	    Indicator = core.indicators:create(Method1, source, Period1);
		first = Indicator.DATA:first();
		
		SignalA = instance:addInternalStream(0, 0);
		SignalB = instance:addInternalStream(0, 0);
		
        Martingale = instance:addStream("Martingale", core.Bar, name, "Martingale", instance.parameters.color, first);	
		
		Martingale:setPrecision(math.max(2, instance.source:getPrecision()));
 
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    Indicator:update(mode);
   
   if period < first then
   return;
   end
   
    SignalA[period]=0;
	
    if (source[period]> Indicator.DATA[period]  and source[period-1]<=Indicator.DATA[period-1] )
	then
	SignalA[period]=1;
	elseif (source[period]< Indicator.DATA[period]  and source[period-1]>=Indicator.DATA[period-1] )
    then
	SignalA[period]=-1;
	end
	
    SignalB[period]=0;
	
	if SignalA[period]~=0 then 
	CheckA(period)
	end
	
	
	CheckB(period);
   
end


function CheckA(period)

  
   local Return=0;
   local Shift=period-1;
  
   
    
   
   for i=Shift, first, -1 do
     
	  if SignalA[i]~=0 then
	  
		  if source[period]> source[i] then
			  if SignalA[i]==1 then
			  SignalB[i]=1;
			  else
			  SignalB[i]=-1;
			  end
		  elseif source[period]< source[i] then
			  if SignalA[i]==-1 then
			  SignalB[i]=1;
			  else
			  SignalB[i]=-1;
			  end
			  
		  end
	  
	  break;
	  end
	   
   end
   
end
 
 
 function CheckB(period)

  
   local Return=0;
   local Shift=period;
   local Count=0;
   
    
   
   for i=Shift, first, -1 do
   
   
      if SignalB[i]==1 then
	  break;
	  end
	  
	  if SignalB[i]==-1 then
	  Count=Count+1;
	  end
	  
	   if Count >= Minimum then
	   break;
	  end
        
   end
   
   
     if Count >= Minimum then
	  Martingale[period]=1;
	  else
	  Martingale[period]=0;
      end	
   
end