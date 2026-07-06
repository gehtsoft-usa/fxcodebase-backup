-- Id: 3650
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3923

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Stochastic histogram");
    indicator:description("Stochastic histogram");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
  	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("K", "Number of periods for %K", "", 14, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "", 3, 2, 1000);
   
	
	indicator.parameters:addString("KS", "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("KS", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("KS", "EMA","", "EMA");
    indicator.parameters:addStringAlternative("KS", "FS","", "FS");
   	
	indicator.parameters:addGroup("Zero Line");  
	indicator.parameters:addString("Mode", "Zero Line Mode", "", "ZERO");
    indicator.parameters:addStringAlternative("Mode", "Zero Line", "", "ZERO");
    indicator.parameters:addStringAlternative("Mode", "MA Line","", "MA");
	
	indicator.parameters:addInteger("D", "The number of periods for Zero Line.", "", 50, 2, 1000);
	
	indicator.parameters:addString("DS", "Smoothing type for Zero Line", "", "MVA");
    indicator.parameters:addStringAlternative("DS", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("DS", "EMA", "", "EMA"); 	
	
    indicator.parameters:addGroup("Style");   
    indicator.parameters:addColor("Up_color", "Color of Up Bar", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down_color", "Color of Down Bar", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local K,SD,KS;
local Mode;
local D, DS;


local first;
local source = nil;

-- Streams block
local Stochastic = nil;
local Indicator;

-- Routine
function Prepare(nameOnly)
    Mode = instance.parameters.Mode; 
    DS = instance.parameters.DS;
    D = instance.parameters.D;		
    KS = instance.parameters.KS;	
	SD = instance.parameters.SD;
	K = instance.parameters.K;
    source = instance.source;
   

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(K) .. ", " .. tostring(SD) .. ", " .. tostring(KS)..  ", " ..
                                                            	tostring(Mode).. ", " .. tostring(D).. ", " .. tostring(DS) ..")";
	                                              
    instance:name(name);
	
	
    if (not (nameOnly)) then
        Indicator=  core.indicators:create("STOCHASTIC", source, K,SD,D,KS,DS);
        if Mode == "ZERO" then
        first =Indicator.DATA:first();
        else
        first =Indicator.D:first();
        end
        Stochastic = instance:addStream("Stochastic", core.Bar, name, "Stochastic", instance.parameters.Up_color, first);
    Stochastic:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not source:hasData(period) then
        return;
    end
	
	Indicator:update(mode);
	if Mode == "ZERO" then
	Stochastic[period]=Indicator.DATA[period]-50;
	else
	Stochastic[period]=Indicator.K[period]-Indicator.D[period];
	end
	if Stochastic[period]> 0 then
	Stochastic:setColor(period, instance.parameters.Up_color);
	else
	Stochastic:setColor(period, instance.parameters.Down_color);
	end
end

