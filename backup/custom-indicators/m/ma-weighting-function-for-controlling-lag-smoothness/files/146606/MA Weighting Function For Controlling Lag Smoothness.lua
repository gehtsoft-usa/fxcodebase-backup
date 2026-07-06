-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72458

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
    indicator:name("MA Weighting Function For Controlling Lag & Smoothness");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
 
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("length", "length", "", 50, 1, 2000);
    indicator.parameters:addDouble("beta", "beta (-Lag)", "", 3, 1, 10);
    indicator.parameters:addDouble("alpha", "alpha (+Lag)", "", 3, 1, 10);	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local length, beta,alpha; 
local w;
local den;	
-- Routine
 function Prepare(nameOnly)   
 
    
	length=instance.parameters.length;
	beta=instance.parameters.beta;
	alpha=instance.parameters.alpha;	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  length.. "," ..  beta.. "," ..  alpha   .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
    w={};	
	local x;
	den=0;
	
	    for i = 0, length-1 , 1 do
        x = i/(length-1)
        w[i] = math.pow(x,alpha-1)*math.pow(1-x,beta-1)
		den=den+w[i];
		end
		
 
	first=source:first() +length ;  
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", core.COLOR_LABEL , first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);
	
	RSI = core.indicators:create("RSI", Line, length);
end


function Update(period, mode)



	 if period <= first then
	 return;
	 end
	 
 
	local sum = 0.
    for i = 0 , length-1,  1 do
    sum = sum + source[period-i]*w[i]
	end
 
	
	Line[period]= sum/den
	
	
	 if period <= first +length then
	 return;
	 end	
	
    RSI:update(mode);	
	
   local R=255-(255/100) * RSI.DATA[period];
   local G=(255/100)*RSI.DATA[period];
   
   Line:setColor(period,  core.rgb(R, G, 0));	
 	
end



