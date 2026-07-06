-- Id: 10446
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59880

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
    indicator:name("Candle Codes");
    indicator:description("Candle Codes");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");	

	indicator.parameters:addDouble("BodySizeWeight", "BodySizeWeight","", 32);
	indicator.parameters:addDouble("UpperShadowWeight", "UpperShadowWeight","", 16);
	indicator.parameters:addDouble("LowerShadowWeight", "LowerShadowWeight","",16);
	indicator.parameters:addDouble("GapWeight", "GapWeight","", 8);
	indicator.parameters:addDouble("BodyColorWeight", "BodyColorWeight","", 32);
	
	indicator.parameters:addGroup("Selector");	
	indicator.parameters:addBoolean("Zero", "Use Raw Data",  "", false);
	indicator.parameters:addBoolean("One", "Use Single-Smoothing",  "", true);
	indicator.parameters:addBoolean("Two", "Use Double-Smoothing",  "", true);
	
	indicator.parameters:addGroup("Single-Smoothing");	
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
  indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
 
    indicator.parameters:addInteger("Period1", "Period","", 21);
	
	indicator.parameters:addGroup("Double-Smoothing");	
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
  indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
 
    indicator.parameters:addInteger("Period2", "Period","", 3);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("CandleCode_color", "Color of CandleCode", "Color of CandleCode", core.rgb(128, 128, 128));
	indicator.parameters:addColor("color1", "Color of Single-Smoothing", "Color of Single-Smoothing", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", "Color of Double-Smoothing", "Color of Color of Double-Smoothing", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Zero;
local Method2, Method1;
local Period1, Period2;
local first;
local source = nil;
local BodySizeWeight, UpperShadowWeight, LowerShadowWeight, GapWeight, BodyColorWeight;
local One, Two, one, two;
-- Streams block
local CandleCode = nil;
local CL, OP, HI, LO;
local AvgBodySize;
local AvgShadow;
local AvgGap;
local RawBody,RawUpper,RawLower,RawGap;
local Out1, Out2;
local BodyColor, BodySize, UpperShadow, LowerShadow, Gap;
-- Routine
function Prepare(nameOnly)
    Zero= instance.parameters.Zero;
    source = instance.source;
    first = source:first();
	One= instance.parameters.One;
	Two= instance.parameters.Two;
	Method2= instance.parameters.Method2;
	Method1= instance.parameters.Method1;
	Period1= instance.parameters.Period1;
	Period2= instance.parameters.Period2;
	BodySizeWeight= instance.parameters.BodySizeWeight;
	UpperShadowWeight= instance.parameters.UpperShadowWeight;
	LowerShadowWeight= instance.parameters.LowerShadowWeight;
	GapWeight= instance.parameters.GapWeight;
	BodyColorWeight= instance.parameters.BodyColorWeight;
	
	 CL=source.close;	 
	 OP=source.open;	
	 HI=source.high;	
	 LO=source.low;	

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	 
    if (not (nameOnly)) then
		RawBody = instance:addInternalStream(0, 0);
		RawUpper  = instance:addInternalStream(0, 0);
		RawLower = instance:addInternalStream(0, 0);
		RawGap= instance:addInternalStream(0, 0);
        Raw = instance:addInternalStream(0, 0);
		
		
		one = core.indicators:create(Method1, Raw, Period1);
		
		if One then
			 Out1= instance:addStream("One", core.Line, name, "One", instance.parameters.color1, one.DATA:first());
		else	 
		     Out1= instance:addInternalStream(0, 0);
		end
		
		
	   
		two = core.indicators:create(Method2, one.DATA, Period2);
		
		
		if Two then
		    Out2= instance:addStream("Two", core.Line, name, "Two", instance.parameters.color2, two.DATA:first());
		else	 
		     Out2= instance:addInternalStream(0, 0);
		end
		
		  if Zero then
	    	CandleCode= instance:addStream("CandleCode", core.Line, name, "CandleCode", instance.parameters.CandleCode_color, first);
		 else	 
		     CandleCode= instance:addInternalStream(0, 0);
          end
	       
		   
		   CandleCode:setPrecision(math.max(2, instance.source:getPrecision()));
		   Out2:setPrecision(math.max(2, instance.source:getPrecision()));
		   Out1:setPrecision(math.max(2, instance.source:getPrecision()));
	end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
  
     RawUpper[period]=(HI[period] - math.max(CL[period],OP[period]));
	 RawLower[period]=(math.min(CL[period],OP[period]) - LO[period]); 
	 RawBody[period]=math.abs(CL[period] - OP[period]);
	 RawGap[period]=(OP[period] - CL[period-1]) ;
	 
  if period < source:size()-1 then
  return;
  end
  
     AvgShadow =((mathex.sum(RawLower, first, source:size()-1 )+mathex.sum(RawUpper, first, source:size()-1 )))/ ((source:size()-1-first)*2);
	 AvgBodySize=mathex.avg(RawBody, first, source:size()-1 );
	 AvgGap=mathex.avg(RawGap, first, source:size()-1 );
 
	
    for period = first , source:size()-1 , 1 do
	Calculation(period, mode);	
	end
	 
	 
	 one:update(core.UpdateAll  );
	 two:update(core.UpdateAll   ); 
	 
	 local i;
	  for i = first , source:size()-1 , 1 do
	  
		   if i > one.DATA:first() then 
			Out1[i]=one.DATA[i];
		   end
	  
			if i > two.DATA:first() then 
		   Out2[i]=two.DATA[i];
		  end	
	 
             
	   CandleCode[i]=Raw[i];
	   	    
	end
    
end


function Calculation (period, mode)
local BodyColor, BodySize, UpperShadow, LowerShadow, Gap;
	
  
	
	 if(math.abs(CL[period] - OP[period]) >= AvgBodySize * 2) then
     BodySize = BodySizeWeight
     else
     BodySize = BodySizeWeight * math.abs(CL[period] - OP[period]) / (AvgBodySize * 2)
	 end

	
	 
	if(HI[period] - math.max(CL[period],OP[period]) >= AvgShadow * 2)then
		 UpperShadow = UpperShadowWeight
	else
		 UpperShadow = UpperShadowWeight * (HI[period] - math.max(CL[period],OP[period])) / (AvgShadow * 2)
	end


if(math.min(CL[period],OP[period]) - LO[period] >= AvgShadow * 2) then
     LowerShadow = LowerShadowWeight
else
     LowerShadow = LowerShadowWeight * (math.min(CL[period],OP[period]) - LO[period]) / (AvgShadow * 2)
end	 




  Gap  = GapWeight * (OP[period] - CL[period-1]) / AvgGap;

if(CL[period] > OP[period]) then
     BodyColor = BodyColorWeight
elseif(CL[period] < OP[period]) then
     BodyColor = -1 * BodyColorWeight
else 
     BodyColor = 0;
end	 
	   
	  
	   Raw[period] = BodyColor + BodySize + UpperShadow - LowerShadow + Gap;
	   	 
	 
end
