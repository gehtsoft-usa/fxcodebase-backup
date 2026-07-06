-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71782

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
    indicator:name("Relative Volume");
    indicator:description("EMA Template");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation"); 	 
    indicator.parameters:addString("TF", "Timeframe", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_BARPERIODS);	
    indicator.parameters:addInteger("Period", "MA Period", "MA Period", 14);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
	local Period;
	local first;
	local source = nil;
	local TF;
 
-- Streams block
    local Volume = nil;

local PeriodSize;

function Prepare(nameOnly)   
 
    TF = instance.parameters.TF; 
    Period = instance.parameters.Period;
	
    local name = profile:id() .. "(" ..  instance.source:name() .. "," ..  TF.. "," ..  Period .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
    source = instance.source;
    first = source:first();	
   
    local s1, e1 = core.getcandle(TF, 0, 0, 0);
    local s2, e2 = core.getcandle(source:barSize(), 0, 0, 0);	
	PeriodSize=(e1-s1)/(e2-s2);
	
 

        Volume = instance:addStream("Volume", core.Bar, name, "Volume", instance.parameters.color, source:first()); 
		Volume:setPrecision(math.max(2, instance.source:getPrecision()));
   
end


 
local prevDate;
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
		
	    if period < first then
		return;
		end
		
		local Sum=0;
		local Count=0;
		for i= period, first, -PeriodSize  do
        Sum= Sum+source.volume[i];
		Count=Count+1;		
		
			if Count >= Period then
			break;
			end
			
		end

		Volume[period]= (source.volume[period]-(Sum/Count));
		
 
end
 


