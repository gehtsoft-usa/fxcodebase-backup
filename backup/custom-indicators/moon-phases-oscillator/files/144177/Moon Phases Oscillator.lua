-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71624

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

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine

function Init()
    indicator:name("Moon Phases Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
 

	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addDate ("StartDate", "Start Date", "Start Date",  core.datetime (2010, 1, 7, 3, 41, 0));
    indicator.parameters:addDouble ("Duration", "Duration", "Duration", 29.53);
    indicator.parameters:addDouble ("Correction", "Correction", "Correction",  0.3051);	
	
  
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local StartDate,Duration; 
local first;
local source = nil;
 
local Oscillator;  
local Period; 
-- Routine
 function Prepare(nameOnly)   
 
 
    StartDate= instance.parameters.StartDate;
	Duration= (instance.parameters.Duration-(instance.parameters.Duration*instance.parameters.Correction))/2;
	
	
	local Parameters="" ;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

     
    source = instance.source; 
    first=source:first();
	
	
	--local s, e = core.getcandle(source:barSize(), 0, 0, 0);


 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first);
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
    
	
	local StartPeriod=core.findDate (source, StartDate, false); 
--	local EndPeriod=core.findDate (source, StartDate+365, false); 	
	
	if StartPeriod < 0  
--or EndPeriod < 0 
	then
	return;
	end

	
 	--Period=((EndPeriod-StartPeriod)/(365/Duration))/2; 
 
    Oscillator[period] = math.cos(math.pi * ( (period-StartPeriod)/Duration) );
		 
				  
end


 
