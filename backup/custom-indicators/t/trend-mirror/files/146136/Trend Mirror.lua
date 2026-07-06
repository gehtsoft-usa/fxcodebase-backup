-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72232

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
    indicator:name("Trend Mirror");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("MovingPeriod", "MovingPeriod", "", 20, 1, 2000);
    indicator.parameters:addInteger("MovingShift", "MovingShift", "", 0, 0, 2000); 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local MovingPeriod, MovingShift; 
local first;
local source = nil;
 
local Oscillator;  
local Indicator={};

-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    MovingPeriod= instance.parameters.MovingPeriod;
    MovingShift = instance.parameters.MovingShift;
	
	
	local Parameters= MovingPeriod ..  ", " .. MovingShift;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    
  
    Indicator1 = core.indicators:create("MVA", source.close, MovingPeriod);
    Indicator2 = core.indicators:create("MVA", source.open, MovingPeriod);
    
    first=Indicator1.DATA:first();
	
	 
   
 
	Line1 = instance:addStream("Line1" , core.Line, "1.  Line"," 1. Line",instance.parameters.color1, first);
	Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:setPrecision(math.max(2, source:getPrecision()));
	

	Line2 = instance:addStream("Line2" , core.Line, "2.  Line"," 2. Line",instance.parameters.color2, first);
	Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:setPrecision(math.max(2, source:getPrecision()));	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    Indicator1:update(mode);
    Indicator2:update(mode);
	
	
    if period <= first+MovingShift then
	return;
	end
	
	Line1[period]= Indicator1.DATA[period-MovingShift] -Indicator2.DATA[period-MovingShift];
	Line2[period]= Indicator2.DATA[period-MovingShift] -Indicator1.DATA[period-MovingShift];
				  
end

