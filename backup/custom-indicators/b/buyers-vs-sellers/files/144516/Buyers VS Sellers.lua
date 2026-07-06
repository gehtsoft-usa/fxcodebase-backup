-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71725

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
    indicator:name("Buyers VS Sellers");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");  
    indicator.parameters:addInteger("rsiMFIperiod", "MFI Period", "", 60, 1, 2000);
    indicator.parameters:addInteger("rsiMFIMultiplier", "MFI Area multiplier", "", 175, 1, 2000);	
    indicator.parameters:addDouble("rsiMFIPosY", "MFI Area Y Pos", "", 1.5, 1, 2000);
 
	 
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

 
local rsiMFIperiod,rsiMFIMultiplier,rsiMFIPosY ;
local first;
local source = nil;
 
local Oscillator;  
 
-- Routine
 function Prepare(nameOnly)   
 
 
    rsiMFIperiod= instance.parameters.rsiMFIperiod;
    rsiMFIMultiplier= instance.parameters.rsiMFIMultiplier;
	rsiMFIPosY= instance.parameters.rsiMFIPosY; 
	
	
	local Parameters= rsiMFIperiod..", "..rsiMFIMultiplier..", "..rsiMFIPosY;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+rsiMFIperiod;
	
	Raw = instance:addInternalStream(0, 0);
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.Up, first);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

    Raw[period]=((source.close[period]- source.open[period]) / (source.high[period] - source.low[period])) * rsiMFIMultiplier;
	
	if period < first
	then
	return;
	end 
	
    Oscillator[period]= mathex.avg(Raw, period- rsiMFIperiod+1, period) - rsiMFIPosY;
	if Oscillator[period] > 0 then
    Oscillator:setColor(period, instance.parameters.Up); 	
	else
    Oscillator:setColor(period, instance.parameters.Down); 		
	end
end
 