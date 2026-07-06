-- Id: 22661
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66902

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
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


-- Indicator profile initialization routine

function Init()
    indicator:name("MBFX Timing");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
 
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Len", "Len", "", 7, 1, 2000);
    indicator.parameters:addDouble("Filter", "Filter", "", 0);
 
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Len, Filter; 
local first;
local source = nil;
 
local  ld_0=0;
local  ld_8=0;
local  ld_16=0;
local  ld_24=0;
local  ld_32=0;
local  ld_40=0;
local  ld_48=0;
local  ld_56=0;
local  ld_64=0;
local  ld_72=0;
local  ld_80=0;
local  ld_88=0;
local  ld_96=0;
local  ld_104=0;
local  ld_112=0;
local  ld_120=0;
local  ld_128=0;
local  ld_136=0;
local  ld_144=0;
local  ld_152=0;
local  ld_160=0;
local  ld_168=0;
local  ld_176=0;
local  ld_184=0;
local  ld_192=0;
local  ld_200=0;
local  ld_208=0; 
 

local Oscillator;  
local Indicator={};

-- Routine
 function Prepare(nameOnly)   
 
 
 
    Len= instance.parameters.Len;
	Filter= instance.parameters.Filter; 
	
	
	local Parameters= Len ..  ", " .. Filter;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. "," ..   Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

     
			
    source = instance.source;  
	first=source:first() ;
	
	
	
	ld_8 = instance:addInternalStream(0, 0);
	ld_16 = instance:addInternalStream(0, 0);
	ld_24 = instance:addInternalStream(0, 0);
	ld_32 = instance:addInternalStream(0, 0);
	ld_40 = instance:addInternalStream(0, 0);
	ld_48 = instance:addInternalStream(0, 0);
	ld_56 = instance:addInternalStream(0, 0);
	ld_64 = instance:addInternalStream(0, 0);
	ld_72 = instance:addInternalStream(0, 0);
	ld_80 = instance:addInternalStream(0, 0);
	ld_88 = instance:addInternalStream(0, 0); 
	ld_112 = instance:addInternalStream(0, 0);
	ld_120 = instance:addInternalStream(0, 0);
	ld_128 = instance:addInternalStream(0, 0);
	ld_136 = instance:addInternalStream(0, 0);
	ld_144 = instance:addInternalStream(0, 0);
	ld_152 = instance:addInternalStream(0, 0);
	ld_160 = instance:addInternalStream(0, 0);
	ld_168 = instance:addInternalStream(0, 0);
	ld_176 = instance:addInternalStream(0, 0);
	ld_184 = instance:addInternalStream(0, 0);
	ld_192 = instance:addInternalStream(0, 0);
	ld_200 = instance:addInternalStream(0, 0);
	ld_208 = instance:addInternalStream(0, 0);
	 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.Up, first);
    Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
	
	
	Oscillator:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Oscillator:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
	Oscillator:addLevel(50, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 	
		
    ld_96 = 3.0 / (Len + 2.0);
	ld_104 = 1.0 - ld_96 ;
	
	if (Len - 1 >= 5) then
	ld_0 = Len - 1.0;  
	else
	ld_0 = 5.0;
	end
	
end

-- Indicator calculation routine
function Update(period, mode) 
	
    if period < first then
	return;
	end 
	
 

      if (ld_8[period-1] == 0.0)then 
	 
         ld_8[period] = 1.0;
         ld_16[period] = 0.0;
		 
		 
		 
		 ld_88[period] = ld_88[period-1];
         ld_32[period] = ld_32[period-1];
         ld_112[period] = ld_112[period-1];
         ld_120[period] =ld_120[period-1];
         ld_40[period] = ld_40[period-1];
         ld_128[period] =ld_128[period-1];
         ld_208[period] =ld_208[period-1];
         ld_48[period] = ld_48[period-1];
         ld_136[period] =ld_136[period-1];
         ld_152[period] = ld_152[period-1];
         ld_56[period] = ld_56[period-1];
         ld_160[period] = ld_160[period-1];
         ld_168[period] = ld_168[period-1];
         ld_64[period] = ld_64[period-1];
         ld_176[period] = ld_176[period-1];
         ld_184[period] = ld_184[period-1];
         ld_144[period] = ld_144[period-1];
         ld_192[period] = ld_192[period-1];
         ld_200[period] = ld_200[period-1];
         ld_72[period] = ld_72[period-1];
		 
			 
		 
         ld_80[period] = 100.0 * ((source.high[period] + source.low[period] + source.close[period]) / 3.0);
         
         
     else 
	 
         if (ld_0 <= ld_8[period-1])then		 
		 ld_8[period] = ld_0 + 1.0;
         else 
		 ld_8[period] =ld_8[period-1]+ 1.0;
		 end
		 
		 
		 
         ld_88[period] = ld_80[period-1];
         ld_80[period] = 100.0 * ((source.high[period] + source.low[period] + source.close[period]) / 3.0);
         ld_32[period] = ld_80[period] - ld_88[period];
         ld_112[period] = ld_104 * ld_112[period-1] + ld_96 * ld_32[period];
         ld_120[period] = ld_96 * ld_112[period] + ld_104 * ld_120[period-1];
         ld_40[period] = 1.5 * ld_112[period] - ld_120[period] / 2.0;
         ld_128[period] = ld_104 * ld_128[period-1] + ld_96 * ld_40[period];
         ld_208[period] = ld_96 * ld_128[period] + ld_104 * ld_208[period-1];
         ld_48[period] = 1.5 * ld_128[period] - ld_208[period] / 2.0;
         ld_136[period] = ld_104 * ld_136[period-1] + ld_96 * ld_48[period];
         ld_152[period] = ld_96 * ld_136[period] + ld_104 * ld_152[period-1];
         ld_56[period] = 1.5 * ld_136[period] - ld_152[period] / 2.0;
         ld_160[period] = ld_104 * ld_160[period-1] + ld_96 * math.abs(ld_32[period]);
         ld_168[period] = ld_96 * ld_160[period] + ld_104 * ld_168[period-1];
         ld_64[period] = 1.5 * ld_160[period] - ld_168[period] / 2.0;
         ld_176[period] = ld_104 * ld_176[period-1] + ld_96 * ld_64[period];
         ld_184[period] = ld_96 * ld_176[period] + ld_104 * ld_184[period-1];
         ld_144[period] = 1.5 * ld_176[period] - ld_184[period] / 2.0;
         ld_192[period] = ld_104 * ld_192[period-1] + ld_96 * ld_144[period];
         ld_200[period] = ld_96 * ld_192[period] + ld_104 * ld_200[period-1];
         ld_72[period] = 1.5 * ld_192[period] - ld_200[period] / 2.0;
		 
		 
		 
         if (ld_0 >= ld_8[period] and ld_80[period] ~= ld_88[period]) then 
		 ld_16[period] = 1.0;
         else
		 ld_16[period] = ld_16[period-1];
		 end
		 
         if (ld_0 == ld_8[period] and ld_16[period] == 0.0) then 
		 ld_8[period] = 0.0;
		 end
		 
      end
	

	
	  if (ld_0 < ld_8[period] and ld_72[period] > 0.0000000001) then

         Oscillator[period] = 50.0 * (ld_56[period] / ld_72[period] + 1.0);
		 
         if (Oscillator[period] > 100.0) then Oscillator[period] = 100.0; end
         if (Oscillator[period] < 0.0)  then Oscillator[period] = 0.0; end
		 
      else
	  Oscillator[period]=50.0
	  end
	  
	  
	   local Delta =(Oscillator[period]-Oscillator[period-1]);

	   
	     if Delta > Filter then
		 Oscillator:setColor(period, instance.parameters.Up);
		 elseif Delta < -Filter then
		 Oscillator:setColor(period, instance.parameters.Down);
		 else
		 Oscillator:setColor(period, instance.parameters.Neutral);
		 end

end


     
 