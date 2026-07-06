-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71130

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   Dogecoin : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine

function Init()
    indicator:name("Rate Of Change With Bands");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "1. Period", "", 12, 1, 2000);
    indicator.parameters:addInteger("Period2", "2. Period", "", 3, 1, 2000);
	
    indicator.parameters:addInteger("Period3", "3. Period", "", 9, 1, 2000);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Top", "Top Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Bottom", "Bottom Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period1,Period2,Period3; 
local first;
local source = nil;
 
local Oscillator;  
local RateOfChg;
local EMA;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
	Period3= instance.parameters.Period3;
	
	
	local Parameters= Period1..", "..Period2..", "..Period3;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+Period1;
	
	RateOfChg= instance:addInternalStream(0, 0);
	
	EMA = core.indicators:create("EMA", RateOfChg, Period2);
	
	RateOfChg_RateOfChg= instance:addInternalStream(0, 0);
   
 
	Oscillator = instance:addStream("MaRateOfChg" , core.Line, " MaRateOfChg"," MaRateOfChg",instance.parameters.color1, first);
	Oscillator:setWidth(instance.parameters.width1);
    Oscillator:setStyle(instance.parameters.style1);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	Top = instance:addStream("Top" , core.Line, " Top"," Top",instance.parameters.Top, first);
	Top:setWidth(instance.parameters.width2);
    Top:setStyle(instance.parameters.style2);
    Top:setPrecision(math.max(2, source:getPrecision()));
	
	
	Bottom = instance:addStream("Bottom" , core.Line, " Bottom"," Bottom",instance.parameters.Bottom, first);
	Bottom:setWidth(instance.parameters.width2);
    Bottom:setStyle(instance.parameters.style2);
    Bottom:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period <first
	then
	return;
	end
 
 
    RateOfChg[period]=((source[period]-source[period-Period1+1])/source[period-Period1+1])*100;
	RateOfChg_RateOfChg[period]=RateOfChg[period]*RateOfChg[period];
	
	if period <first+Period3
	then
	return;
	end
	
	local AvrgOfSquares= mathex.sum(RateOfChg_RateOfChg,period-Period3, period)/Period3;
	
    
    local  ROCDEV=math.sqrt(AvrgOfSquares);
	
	EMA:update(mode);
	
	if period <first+Period3
	then
	return;
	end
	
	 
    Oscillator[period] =EMA.DATA[period]
    Top[period]=ROCDEV;
    Bottom[period]=-ROCDEV;	
				  
end

