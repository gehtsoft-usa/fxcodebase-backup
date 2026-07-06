-- Id: 14935
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62787

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
    indicator:name("Center Of Gravity");
    indicator:description("Center Of Gravity");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addInteger("BarsBack", "Bars Back", "", 300);
	indicator.parameters:addInteger("Smoothing", "Smoothing", "", 30);
	indicator.parameters:addDouble("Ext", "Ext", "", 25);
	 
    indicator.parameters:addColor("Color1", "Color of 3. Top Line", "Color of 3. Top Line", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Color2", "Color of 2. Top Line", "Color of 2. Top Line", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Color3", "Color of 1. Top Line", "Color of 1. Top Line", core.rgb(255, 0, 0));
	
	indicator.parameters:addColor("Color4", "Color of Central Line", "Color of Central Line", core.rgb(0, 0, 255));
	
	indicator.parameters:addColor("Color5", "Color of 1. Bottom Line", "Color of 1. Bottom Line", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Color6", "Color of 2. Bottom Line", "Color of 2. Bottom Line", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Color7", "Color of 3. Bottom Line", "Color of 3. Bottom Line", core.rgb(0, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local BarsBack,Smoothing,Ext;
-- Streams block
local Line = {};
local Color={};
 
 
-- Routine
function Prepare(nameOnly)
    source = instance.source;   
	BarsBack=instance.parameters.BarsBack;
	Smoothing=instance.parameters.Smoothing;
	Ext=instance.parameters.Ext;
	
	first = source:first()+BarsBack;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if (not (nameOnly)) then
	    for i= 1, 7,1 do
		Color[i]=instance.parameters:getDouble("Color" .. i);
        Line[i] = instance:addStream("Line"..i, core.Line, name, i..". Line", Color[i], first);
		end
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    if period < first +1
	or not  source:hasData(period) 
	or period < source:size()-1
	then
	return;
	end
	
	for i=BarsBack-1,0,-1 do
	  Line[5][period-i] = f0_9(period-i, Smoothing);
      Line[3][period-i] = f0_0(period-i, Smoothing);
      Line[4][period-i] = (Line[5][period-i] + Line[3][period-i]) / 2.0;
      Line[6][period-i] = f0_5(period-i, Smoothing);
      Line[2][period-i] = f0_21(period-i, Smoothing);
      Line[7][period-i] = f0_4(period-i, Smoothing);
      Line[1][period-i] = f0_16(period-i, Smoothing);
	end	
	
	for i= 1,7,1 do
        Line[i][period-BarsBack] = nil;
    end
end




 -- for j = 1, s, 1 do
function f0_9( ai_0,  ai_4)  
   local  ld_8 = 0.0;
   for   li_16 = (ai_0),  ai_0 - ai_4+1,-1  do
   ld_8 =ld_8+ f0_20(li_16);
   end
   return (ld_8 / ai_4);
   
end
 
function f0_0( ai_0,  ai_4)  
   local ld_8 = 0.0;
   for   li_16 = (ai_0),  ai_0 - ai_4+1,-1  do
   ld_8 =ld_8+ f0_14(li_16);
    end
   return (ld_8 / ai_4);
end

 
function f0_5( ai_0,  ai_4) 
   local ld_8 = 0.0;
   for   li_16 = (ai_0),  ai_0 - ai_4+1,-1  do
   ld_8 =ld_8+ f0_6(li_16);
    end
   return (ld_8 / ai_4);
end

 
function f0_21( ai_0,  ai_4) 
   local ld_8 = 0.0;
   for   li_16 = (ai_0),  ai_0 - ai_4+1,-1  do  
   ld_8 =ld_8+ f0_2(li_16);
    end
   return (ld_8 / ai_4);
end

 
function f0_4( ai_0,  ai_4)  
   local ld_8 = 0.0;
   for  li_16 = (ai_0),  ai_0 - ai_4+1,-1  do 
   ld_8 =ld_8+ f0_1(li_16);
    end
   return (ld_8 / ai_4);
end

 
function f0_16( ai_0,  ai_4)  
   local ld_8 = 0.0;
   for   li_16 = (ai_0),  ai_0 - ai_4+1,-1  do
   ld_8 =ld_8+ f0_3(li_16);
    end
   return (ld_8 / ai_4);
end
 
function f0_11( ai_0)  
   local ld_4 = (source.high[ai_0 - 1] + source.low[ai_0 - 1] + source.close[ai_0 - 1]) / 3;
   return (ld_4);
end
 
function f0_20( ai_0)  
   local ld_4 = (((Ext / 100.0) + 2.0) * source.low[ai_0]) - (((Ext / 100.0) + 1.0) * f0_11(ai_0));
   return (ld_4);
end

 
function f0_14( ai_0) 
   local ld_4 = (((Ext / 100.0) + 2.0) * source.high[ai_0]) - (((Ext / 100.0) + 1.0) * f0_11(ai_0));
   return (ld_4);
end

 
function f0_6( ai_0) 
   local ld_4 = (((Ext / 100.0) + 2.0) * source.low[ai_0]) - (((Ext / 100.0) + 1.0) * f0_14(ai_0));
   return (ld_4);
end

 
function f0_2( ai_0)  
   local ld_4 = (((Ext / 100.0) + 2.0) * source.high[ai_0]) - (((Ext / 100.0) + 1.0) * f0_20(ai_0));
   return (ld_4);
end
 
function f0_1( ai_0)  
   local ld_4 = (((Ext / 100.0) + 2.0) * source.low[ai_0]) - (((Ext / 100.0) + 1.0) * f0_2(ai_0));
   return (ld_4);
end

 
function f0_3( ai_0)  
   local ld_4 = (((Ext / 100.0) + 2.0) * source.high[ai_0]) - (((Ext / 100.0) + 1.0) * f0_6(ai_0));
   return (ld_4);
end