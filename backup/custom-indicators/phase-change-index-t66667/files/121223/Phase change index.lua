-- Id: 22323
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66667

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine

function Init()
    indicator:name("Phase change index");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
 
 
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("inpLength", "Phase change index period", "", 30, 1, 2000);	 
    indicator.parameters:addDouble("inpLevelHigh", "Period", "", 80, 0, 100);
	indicator.parameters:addDouble("inpLevelLow", "Period", "", 20, 0, 100);
	indicator.parameters:addInteger("inpSmooth", "Smoothing Period", "", 30, 1, 2000);	 
	
	indicator.parameters:addInteger("Pow", "Pow", "", 10 , 1, 10);	 
	indicator.parameters:addDouble("R", "R", "", 2.5 , 0.5, 2.5);
	
	indicator.parameters:addBoolean("inpInverted", "Inverted", "Inverted", true);
	
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "OB Color", "", core.rgb(0, 288, 0));
	indicator.parameters:addColor("Down", "OS Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local inpLength, inpLevelHigh, inpLevelLow, inpSmooth, inpInverted,Pow,R;
local first;
local source = nil;
local alpha, beta; 
local Oscillator;  
local Up,Down,Neutral;
local Filt0,Det0, Filt1, Det1; 
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    inpLength= instance.parameters.inpLength;
	inpLevelHigh= instance.parameters.inpLevelHigh;
	inpLevelLow= instance.parameters.inpLevelLow;
	inpSmooth= instance.parameters.inpSmooth;
	inpInverted= instance.parameters.inpInverted;
	Pow  = instance.parameters.Pow;
	R = instance.parameters.R;
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Neutral = instance.parameters.Neutral;
 
			
    source = instance.source;
    first=source:first()+inpLength;
	
	Filt0= instance:addInternalStream(0, 0);
	Det0= instance:addInternalStream(0, 0);
	Filt1= instance:addInternalStream(0, 0);
	Det1= instance:addInternalStream(0, 0); 
	
	
	 beta = 0.45 * (inpSmooth - 1) / (0.45 * (inpSmooth - 1) + 2)
 
	 if Pow == 1 then
	  alpha = beta
	 elseif Pow == 2 then
	  alpha = beta * beta
	 elseif Pow == 3 then
	  alpha = beta * beta * beta
	 elseif Pow== 4 then
	  alpha = beta * beta * beta * beta
	 elseif Pow == 5 then
	  alpha = beta * beta * beta * beta * beta
	 elseif Pow == 6 then
	  alpha = beta * beta * beta * beta * beta * beta
	 elseif Pow == 7 then
	  alpha = beta * beta * beta * beta * beta * beta * beta
	 elseif Pow == 8 then
	  alpha = beta * beta * beta * beta * beta * beta * beta * beta
	 elseif Pow == 9 then
	  alpha = beta * beta * beta * beta * beta * beta * beta * beta * beta
	 elseif Pow == 10 then
	  alpha = beta * beta * beta * beta * beta * beta * beta * beta * beta
	 end
  
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.Neutral, first);
    Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    
	Oscillator:addLevel(inpLevelHigh, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Oscillator:addLevel(inpLevelLow, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	
end

-- Indicator calculation routine
function Update(period, mode)

  
	
	
    if period <= first then
	return;
	end
	
		
   local  imomentum = source[period]-source[period-inpLength+1]
   
   
local sumUpDi  = 0
local sumDnDi  = 0


for j=1 , inpLength, 1 do
 gradient  = source[period-inpLength+1]+imomentum*(inpLength-j)/(inpLength);
 deviation = source[period-j+1]-gradient;
 if (deviation > 0) then
  sumUpDi = sumUpDi+deviation
 else
  sumDnDi = sumDnDi-deviation
 end
end
 
local val;
--PCI calculation
if sumUpDi+sumDnDi~=0 then
 val = 100.0*sumUpDi/(sumUpDi+sumDnDi)
end
if inpInverted then
 val=100-val
end

local levup;
if val>inpLevelHigh then
 levup = 100
elseif val<inpLevelLow then
 levup =0
else
 levup=50
end
 
 

 
  
  Filt0[period] = (1 - alpha) * val + alpha * Filt0[period-1]
  Det0[period] = (val - Filt0[period]) * (1 - beta) + beta * Det0[period-1]
  Filt1[period] = Filt0[period] + R * Det0[period]
  Det1[period] = (Filt1[period] - Oscillator[period-1]) * ((1 - alpha) * (1 - alpha)) + (alpha * alpha) * Det1[period-1]
  Oscillator[period] = Oscillator[period-1] + Det1[period];
 
 
 
 
	 
	  if Oscillator[period]>inpLevelHigh then
	  Oscillator:setColor(period, Up);
	  elseif Oscillator[period]<inpLevelLow then
	  Oscillator:setColor(period, Down);
	  else
	  Oscillator:setColor(period, Neutral);
	  end
	 
				  
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+


--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+