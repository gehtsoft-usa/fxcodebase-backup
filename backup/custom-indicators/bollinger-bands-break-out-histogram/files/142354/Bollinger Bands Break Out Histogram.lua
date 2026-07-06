-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71240

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
    indicator:name("Bollinger Bands Break Out Histogram");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 20, 1, 2000);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 2, 0, 2000);
 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("ob_color", "OB Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("os_color", "OS Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("neutral_color", "Neutral Color", "", core.rgb(128, 128, 128));	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period,Deviation; 
local first;
local source = nil;
 
local Oscillator;  
local Indicator;

-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
    Deviation= instance.parameters.Deviation;
	
	
	local Parameters= Period..", "..Deviation;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	Indicator = core.indicators:create("BB", source, Period,Deviation);
    first=Indicator.TL:first() ;
	
 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",instance.parameters.neutral_color, first ); 
	Oscillator:addLevel(50);
	Oscillator:addLevel(-50);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

    Indicator:update(mode);
	
	if period < first
	then
	return;
	end
 
     local Range=(Indicator.TL[period]-Indicator.BL[period])/100;
     Oscillator[period]=( (source[period]-Indicator.BL[period])/Range)-50;
	 if Oscillator[period] > 50 then
	 Oscillator:setColor(period,instance.parameters.ob_color);
	 elseif Oscillator[period] <- 50 then
	 Oscillator:setColor(period,instance.parameters.os_color);	 
	 else
	 Oscillator:setColor(period,instance.parameters.neutral_color);
	 end			  
end

 
