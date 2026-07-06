-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71691

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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

--Support that the service we provide to the community be continued onward.
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
    indicator:name("The Hurst Coefficient Indicator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("length", "Length", "", 30, 1, 2000);
    indicator.parameters:addInteger("ssflength", "SuperSmoother filter Length", "", 20, 1, 2000);
	
 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0,255, 0));
    indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local length,ssflength; 
local first;
local source = nil;
 
local Oscillator,hurst,dimen;  


local a, b, c2, c3, c1, h1;
-- Routine
 function Prepare(nameOnly)   
 
 
    length= instance.parameters.length;
	ssflength= instance.parameters.ssflength;
	
	
	local Parameters= length..", "..ssflength;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+length;

    hurst= instance:addInternalStream(0, 0);
	dimen= instance:addInternalStream(0, 0);
	
	
	   a = math.exp(-math.sqrt(2) * math.pi  / ssflength);
	   b = 2 * a * math.cos(math.sqrt(2) * math.pi / ssflength);
	   c2 = b;
	   c3 = -math.pow(a, 2);
	   c1 = 1 - c2 - c3;
	   hl = math.ceil(length / 2);
 
   

   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.Up, first+ length );
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < first
	then
	return;
	end
	 
    GetValue(period);
				  
end


function GetValue(period)

   
   local ll, hh=mathex.minmax(source, period-length+1, period)
   local  n3 = (hh - ll) / length;
   local  n1 = (hh - ll) / hl;
  
	if period < first+length
	then
	return;
	end  
  
   local LL, HH=mathex.minmax(source, period-hl-length+1, period-hl)   
   local  n2 = (HH - LL) / hl;  
  
   if (n1 > 0 and n2 > 0 and n3 > 0) then
   dimen[period] = 0.5 * ( (math.log(n1 + n2) - math.log(n3)) / math.log(2) + dimen[period - 1]) 
   else
   dimen[period] = 0;
   end
                  
   hurst[period] = 2 - dimen[period];  

   local  s1 =  Oscillator[period - 1];
   local  s2 =  Oscillator[period - 2];                
  
    Oscillator[period] = c1 * (hurst[period] + hurst[period - 1]) / 2 + c2 * s1 + c3 * s2;
                        
    if Oscillator[period]> 0 then
	Oscillator:setColor(period, instance.parameters.Up);
	else
	Oscillator:setColor(period, instance.parameters.Down);   
	end
	  
end