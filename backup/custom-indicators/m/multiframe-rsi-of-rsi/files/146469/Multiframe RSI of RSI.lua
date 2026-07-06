-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72411

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
    indicator:name("Multiframe RSI of RSI");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addDouble("corr", "Multiplier Period", "", 2, 1, 2000);
    indicator.parameters:addInteger("Period1", "1. EMA Period", "", 130, 1, 2000);
    indicator.parameters:addInteger("Period2", "2. EMA Period", "", 26, 1, 2000);	 
    indicator.parameters:addInteger("Period3", "Deviation Period", "", 22, 1, 2000);	 	
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

local corr, Period1, Period2, Period3; 
local first;
local source = nil;
 
local Oscillator;  
local Indicator={};

-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
    Period3 = instance.parameters.Period3;  
    corr = instance.parameters.corr;
	
	
	local Parameters= corr ..  ", " .. Period1 ..  ", " .. Period2 ..  ", " .. Period3 ;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    
  
    EMA1 = core.indicators:create("EMA", source , Period1);
    EMA2 = core.indicators:create("EMA", EMA1.DATA , Period2);  
    first=  EMA2.DATA:first() ;
	
 
	 
   
 
	Line1 = instance:addStream("Line1" , core.Line, " 1. Line "," 1. Line ",instance.parameters.color1, first);
	Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:setPrecision(math.max(2, source:getPrecision()));
	
	Line2 = instance:addStream("Line2" , core.Line, " 2. Line "," 2. Line ",instance.parameters.color2, first);
	Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:setPrecision(math.max(2, source:getPrecision()));	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    EMA1:update(mode);
    EMA2:update(mode);
	
	
    if period <= first then
	return;
	end
	
	
	Line1[period]=100*(EMA1.DATA[period]-EMA2.DATA[period])/EMA2.DATA[period];
		
    if period < first + Period3 then
	return;
	end
	
	local st= mathex.stdev(Line1  , period- Period3+1 , period);
	
	
	local basso=Line1[period]-corr*st
    local alto=Line1[period]+corr*st
	
	Line2[period]=Line2[period-1];
	
	
	if Line1[period] < Line2[period] 
	and Line1[period-1] >= Line2[period-1]
	then
    Line2[period]=alto
    end 
    if Line1[period]> Line2[period]
    and Line1[period-1]<=Line2[period-1]
    then
    Line2[period]=basso
    end 
	
	
	if Line1[period]>Line2[period] then
	  if basso>Line2[period] then
	   Line2[period]=basso
	  end 
	 end 
	 if Line1[period]<Line2[period] then
	  if alto<Line2[period] then
	   Line2[period]=alto
	  end 
	 end 
  
				  
end

 