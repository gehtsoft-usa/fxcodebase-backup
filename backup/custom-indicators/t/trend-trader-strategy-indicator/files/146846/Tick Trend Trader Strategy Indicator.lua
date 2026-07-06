-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72536

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
    indicator:name("Trend Trader Strategy Indicator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
 
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Length", "Period", "", 21, 1, 2000);
    indicator.parameters:addDouble("Multiplier", "Multiplier", "", 3, 0.000001, 2000); 
	 
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Length, Multiplier; 
local first;
local source = nil;
 
local Oscillator;  
local Indicator={};

-- Routine
 function Prepare(nameOnly)   
 
 
 
 
    
    Length= instance.parameters.Length;
    Multiplier = instance.parameters.Multiplier;
	
	
	local Parameters= Length ..  ", " .. Multiplier;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    assert(core.indicators:findIndicator("TATR") ~= nil, "Please, download and install TATR.LUA indicator");    
			
    source = instance.source;
    
  
    atr = core.indicators:create("TATR", source, 1);
    wma = core.indicators:create("WMA", atr.DATA, Length); 
    first=wma.DATA:first();
 
	
	
	Line = instance:addStream("Line" , core.Line, " Line"," Line",instance.parameters.color, first);
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:setPrecision(math.max(2, source:getPrecision()));
	

 
   
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    atr:update(mode);
    wma:update(mode);

 
	
   
    if period < first then
	return;
	end
	
	
	local lowestC, highestC = mathex.minmax(source, period-1-Length+1 , period-1);
		
    local hiLimit = highestC -(wma.DATA[period-1] * Multiplier)
    local loLimit = lowestC + (wma.DATA[period-1] * Multiplier)
	
	
	Line[period]=Line[period-1];
	 if source [period] > hiLimit and source [period] > loLimit then
	 Line[period] =  hiLimit;
	 end

	 if source [period] < loLimit and source [period] < hiLimit then
	 Line[period] =  loLimit;
	 end				  
	 
	 
 
end
 