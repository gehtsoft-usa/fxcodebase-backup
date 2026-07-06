-- Id: 16338

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63648

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
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Super Passband Filter");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
	
 
	indicator.parameters:addInteger("Period1", "1. Period", "", 40 );
	indicator.parameters:addInteger("Period2", "2. Period", "", 60 );
    indicator.parameters:addInteger("Average", "Average Period", "", 50 );

    indicator.parameters:addColor("color1","PB Line Color","", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2"," + RMS Line Color","", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color3","- RMS Line Color","", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);

 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first;
local source = nil; 
local Period1,Period2,Average;
local PB,PRMS, NRMS;
local a1, a2;
-- Routine
 function Prepare(nameOnly)   

    Period1= instance.parameters.Period1;
	Period2= instance.parameters.Period2;
    Average= instance.parameters.Average;
	
    source = instance.source;
	first=source:first()+2; 
	 
	
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name); 
	
	if   (nameOnly) then
        return;
    end
   
 
	PB = instance:addStream("PB", core.Line, name .. "PB", "PB", instance.parameters.color1, first);
    PB:setPrecision(math.max(2, instance.source:getPrecision()));
	PB:setWidth(instance.parameters.width1);
    PB:setStyle(instance.parameters.style1);
	
	PRMS = instance:addStream("PRMS", core.Line, name .. "PRMS", "PRMS", instance.parameters.color2, first+Average);
    PRMS:setPrecision(math.max(2, instance.source:getPrecision()));
	PRMS:setWidth(instance.parameters.width2);
    PRMS:setStyle(instance.parameters.style2);
	
	NRMS = instance:addStream("NRMS", core.Line, name .. "NRMS", "NRMS", instance.parameters.color3, first+Average);
    NRMS:setPrecision(math.max(2, instance.source:getPrecision()));
	NRMS:setWidth(instance.parameters.width3);
    NRMS:setStyle(instance.parameters.style3);
	
	a1 = 5 / Period1;
    a2 = 5 / Period2;
	
	 
	 
end
 




-- Indicator calculation routine
function Update(period)



     if period < first then
	 return;
	 end
	 
	 
	 PB[period] = (a1 - a2)*source[period] + (a2*(1 - a1) - a1*(1 - a2))*source[period-1] + ((1 - a1) + (1 - a2))*PB[period-1] - (1 - a1)*(1 - a2)*PB[period-2];
	 
	 
	 
	 if period < first  + Average then
	 return;
	 end
	 
local RMS = 0;
for count = 0, Average-1, 1 do
RMS = RMS + PB[period-count]*PB[period-count];
end
RMS = math.sqrt(RMS / Average);

 PRMS[period]= RMS;
 NRMS[period]= -RMS;
 
end

 