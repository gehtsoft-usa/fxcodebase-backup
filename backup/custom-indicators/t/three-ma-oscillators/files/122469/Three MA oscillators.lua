-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67040

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("Three MA oscillators");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("1. MA Calculation"); 
	
 
    indicator.parameters:addString("Method1", "Method", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method1", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method1", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method1", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method1", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method1", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method1", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method1", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method1", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method1", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method1", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method1", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method1", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method1", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method1", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method1", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method1", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method1", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "HPF", "", "HPF");
    indicator.parameters:addStringAlternative("Method1", "VAMA", "", "VAMA");
	
    indicator.parameters:addInteger("Period1", "Period", "", 14, 1, 2000);
 
 
	
	indicator.parameters:addGroup("2. MA Calculation"); 
	
 
    indicator.parameters:addString("Method2", "Method", "", "EMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method2", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method2", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method2", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method2", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method2", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method2", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method2", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method2", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method2", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method2", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method2", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method2", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method2", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method2", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method2", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method2", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method2", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "HPF", "", "HPF");
    indicator.parameters:addStringAlternative("Method2", "VAMA", "", "VAMA");
	
    indicator.parameters:addInteger("Period2", "Period", "", 28, 1, 2000);
 
	
	indicator.parameters:addGroup("3. MA Calculation"); 
	
 
    indicator.parameters:addString("Method3", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method3", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method3", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method3", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method3", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method3", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method3", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method3", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method3", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method3", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method3", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method3", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method3", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method3", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method3", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method3", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method3", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method3", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "HPF", "", "HPF");
    indicator.parameters:addStringAlternative("Method3", "VAMA", "", "VAMA");
	
    indicator.parameters:addInteger("Period3", "Period", "", 1, 1, 2000);
	
	
	
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method1 , Period1;
local Method2 , Period2; 
local Method3 , Period3; 
local first;
local source = nil;
 
local Oscillator;  
local Indicator={};

-- Routine
 function Prepare(nameOnly)    
 
    Period1= instance.parameters.Period1;
    Method1= instance.parameters.Method1;
    
	
	Period2= instance.parameters.Period2;
    Method2= instance.parameters.Method2;
 
	
	Period3= instance.parameters.Period3;
    Method3= instance.parameters.Method3;
   
	
	
	local Parameters= Period1 ..  ", " .. Method1  ..  ", " ..Period2 ..  ", " .. Method2 ..  ", " ..Period3 ..  ", " .. Method3 ;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. "," ..   Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");
  
    Indicator[1] = core.indicators:create("AVERAGES", source , Method1, Period1);
    Indicator[2] = core.indicators:create("AVERAGES", source , Method2, Period2);
	Indicator[3] = core.indicators:create("AVERAGES", source , Method3, Period2);
    
    first=math.max(Indicator[1].DATA:first(), Indicator[2].DATA:first(), Indicator[3].DATA:first());
	
	 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    
	
	Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    Indicator[1]:update(mode);
    Indicator[2]:update(mode);
	Indicator[3]:update(mode);
	
    if period < first then
	return;
	end
	
 
     Oscillator[period]=(Indicator[1].DATA[period]-Indicator[2].DATA[period])/Indicator[3].DATA[period];
				  
end

