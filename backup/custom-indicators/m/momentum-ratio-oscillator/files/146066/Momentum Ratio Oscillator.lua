-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72201

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
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


-- Indicator profile initialization routine

function Init()
    indicator:name("Momentum Ratio Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup(" Calculation"); 
    indicator.parameters:addInteger("inpPeriod", "Period", "", 14, 1, 2000);
 
	 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local inpPeriod,alpha; 
local first;
local source = nil;
 
local Oscillator;  
local Indicator={};

-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    inpPeriod = instance.parameters.inpPeriod;
	alpha = 2.0/(1.0*inpPeriod);

	
	local Parameters= inpPeriod;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    ema= instance:addInternalStream(0, 0);
	emaa= instance:addInternalStream(0, 0);
	emab= instance:addInternalStream(0, 0);
			
    source = instance.source; 
    first=source:first();
	
	 
   
 
	val = instance:addStream("val" , core.Line, " val"," val",instance.parameters.Up, first);
	val:setWidth(instance.parameters.width);
    val:setStyle(instance.parameters.style);
    val:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(i, mode)

 
 
	
	
    if i <= first then
 
     ema[i] = source[i]; 
	 emaa[i] = 0;
	 emab[i] = 0; 
	 val[i] = 0; 
 
	return;
	end
	
	
	 ema[i] = ema[i-1] +  alpha*(source[i]-ema[i-1]);
            
         local  ratioa = ema[i]/ema[i-1];
         if ratioa<1.0 then
         emaa[i] = emaa[i-1] + alpha*(  ratioa   -emaa[i-1]);
		 else
		 emaa[i] = emaa[i-1] + alpha*(  0  -emaa[i-1]);
		 end
		 if ratioa>1.0 then
         emab[i] = emab[i-1] + alpha*( ratioa -emab[i-1]);
		 else
         emab[i] = emab[i-1] + alpha*(0 -emab[i-1]);
		 end 
		 
		 
         local  ratiob = ratioa/(ratioa + emab[i]);
		 
		 
            
         val[i]  = 2.0*ratioa/(ratioa + ratiob*emaa[i]) - 1.0;
   

		if val[i]> val[i-1] then
        val:setColor(i,  instance.parameters.Up);
		else
		val:setColor(i,  instance.parameters.Down);
		end
				  
end

