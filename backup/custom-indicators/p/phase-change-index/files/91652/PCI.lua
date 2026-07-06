-- Id: 10739
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60141

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

function Init()
    indicator:name("Phase Change Index");
    indicator:description("Phase Change Index");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 34);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("PCI_Short", "Color of Short", "Color of Short", core.rgb(255, 0, 0));
    indicator.parameters:addColor("PCI_Long", "Color of Long", "Color of Long", core.rgb(0, 255, 0));
     indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 80);
    indicator.parameters:addDouble("oversold","Oversold Level","", 20);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);	
	
	 indicator.parameters:addInteger("transparency", "Channel transparency (%)", "", 70, 0, 100);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;
local Signal;
-- Streams block
local PCI, Central;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+Period;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		Signal= instance:addInternalStream(0, 0);
   
        PCI = instance:addStream("PCI", core.Line, name, "PCI", instance.parameters.PCI_Long, first);	
    PCI:setPrecision(math.max(2, instance.source:getPrecision()));
		PCI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		PCI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		Central=instance:addInternalStream(0, 0);
		instance:createChannelGroup("ch", "ch", PCI, Central, instance.parameters.PCI_Long, 100 - instance.parameters.transparency);

    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first  then
	return;
	end
	
	Central[period]=50;
	
	local Momentum;
	Momentum=(source[period]-source[period-Period+1])/Period;
	
	local i;
	local Gradient;
	
	Up=0;
	Down=0;
	
	
	for i= 0, Period, 1  do
	
	Gradient=source[period-Period]+Momentum*i;	
		
			 if  source[period-Period+i]-  Gradient > 0 then
					Up=Up+math.abs(source[period-Period+i]-  Gradient);
					Down=Down+0;
			  elseif  source[period-Period+i]-  Gradient < 0 then
					Up=Up+0;
					Down=Down+math.abs(source[period-Period+i]-  Gradient);
			  else
					Up=Up+0;
					Down=Down+0;
			
   			end
	 end
	
	
        PCI[period] = (Up / (Up + Down)) * 100;
		
		--=IF(F35>0,IF(J35<20,1,K34),IF(J35>80,-1,K34)
		
		if Momentum >0 then
		  if PCI[period] < 20 then
		   Signal[period]=1;
		  else
		   Signal[period]=Signal[period-1];
		  end
		else
		
		   if PCI[period] > 80 then
		   Signal[period]=-1;
		  else
		  Signal[period]=Signal[period-1];
		  end
		  
		end
		
	  if Signal[period]== 1 then
	  PCI:setColor(period, instance.parameters.PCI_Long);
	  else
	  PCI:setColor(period, instance.parameters.PCI_Short);
	  end
    
end

