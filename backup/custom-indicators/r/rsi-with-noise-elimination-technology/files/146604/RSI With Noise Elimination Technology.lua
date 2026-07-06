-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72457

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("RSI With Noise Elimination Technology");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

 
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("rsi_len", "RSI Length", "", 14, 1, 2000);
    indicator.parameters:addInteger("net_len", "NET Length", "", 14, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "NET Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "RSI Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local rsi_len, net_len; 
local Indicator;
local Denom;	
-- Routine
 function Prepare(nameOnly)   
 
    
	rsi_len=instance.parameters.rsi_len;
	net_len=instance.parameters.net_len;
	source = instance.source
    Denom = .5*net_len*(net_len - 1);
 


    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  rsi_len.. "," ..  net_len  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	 
	first=source:first() + 1 ; 
 
    diff = instance:addInternalStream(0, 0);
	
    NET = instance:addStream("NET", core.Line, name, "NET", instance.parameters.color1, first +rsi_len );
    NET:setPrecision(math.max(2, instance.source:getPrecision()));
    NET:setWidth(instance.parameters.width);
    NET:setStyle(instance.parameters.style);
    NET:addLevel(0);	
 
 
    RSI = instance:addStream("RSI", core.Line, name, "RSI", instance.parameters.color2, first +rsi_len );
    RSI:setPrecision(math.max(2, instance.source:getPrecision()));
    RSI:setWidth(instance.parameters.width);
    RSI:setStyle(instance.parameters.style);
    RSI:addLevel(0);	
end


function Update(period, mode)



	 if period <= first then
	 return;
	 end
	 
     diff[period] = source[period] - source[period - 1];
			
	 if period <= first +rsi_len  then
	 return;
	 end	
	 
	 local sump=0;
	 local sumn=0;
	 
	            for i = period - rsi_len + 1, period do
     
                if (diff[i] >= 0) then
                    sump = sump +  diff[i];
                else
                    sumn = sumn - diff[i];
                end
            end
 
	 
    RSI[period] =  (sump - sumn) / (sump + sumn); 
  
    local Num = 0;
	for count = 1, net_len-1, 1 do
		for K = 0,  count , 1 do
		Num=Num -Sign(RSI[period-count] - RSI[period-count + K]); 
		end
	end 
	
	NET[period]= Num/Denom;
	
end
 

function Sign(Value)

if Value > 0 then
return 1;
elseif Value < 0 then
return -1;
else
return 0;
end 
 end