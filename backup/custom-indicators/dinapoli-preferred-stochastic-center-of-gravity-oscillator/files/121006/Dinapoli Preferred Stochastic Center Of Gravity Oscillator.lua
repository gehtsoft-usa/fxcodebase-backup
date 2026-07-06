-- Id: 22254
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66628

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
    indicator:name("Dinapoli Preferred Stochastic Center Of Gravity Oscillator ");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Center Of Gravity Oscillator Calculation"); 	
	indicator.parameters:addInteger("FIR_N", "FIR (LWMA) number of periods", "No description", 10);
    indicator.parameters:addInteger("S_N", "Signal Line Smoothing Periods", "No description", 3);
    indicator.parameters:addString("PM", "Price Mode", "", "C");
    indicator.parameters:addStringAlternative("PM", "Close", "", "C");
    indicator.parameters:addStringAlternative("PM", "Median", "", "M");
    indicator.parameters:addStringAlternative("PM", "Typical", "", "T");
    indicator.parameters:addStringAlternative("PM", "Weighted", "", "W");
	
	
	
	indicator.parameters:addGroup("Dinapoli Preferred Stochastic Calculation");
    indicator.parameters:addInteger("K", "Number of periods for %K", "The number of periods for %K.", 10, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "The number of periods for slow %D.", 5, 2, 1000);
    indicator.parameters:addInteger("D", "Number of periods for %D", "The number of periods for %D.", 5, 2, 1000);
	
    
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Bar Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Bar Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Bar Color", "", core.rgb(0, 0, 255));
 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Indicator1, FIR_N, S_N, PM; 
local Indicator2, K,SD, D;
local first;
local source = nil;
local Up,Down, Neutral;
local Oscillator;   

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
   
   
    assert(core.indicators:findIndicator("JECOG") ~= nil, "Please, download and install JECOG.LUA indicator");  
    assert(core.indicators:findIndicator("DINAPOLI PREFERRED STOCHASTIC") ~= nil, "Please, download and install DINAPOLI PREFERRED STOCHASTIC.LUA indicator");	

	
    FIR_N = instance.parameters.FIR_N;
	S_N = instance.parameters.S_N;
	PM = instance.parameters.PM;
    Price2 = instance.parameters.Price2;
	
	K= instance.parameters.K;
	SD= instance.parameters.SD;
	D= instance.parameters.D;
	
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Neutral= instance.parameters.Neutral;
			
    source = instance.source;
    
  
    Indicator1  = core.indicators:create("JECOG", source, FIR_N, S_N, PM);
    Indicator2 = core.indicators:create("DINAPOLI PREFERRED STOCHASTIC", source, K, SD,D);    
    first=math.max(Indicator1.SIG:first(), Indicator2.D:first());
	
	 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",Neutral, first); 	
	Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    Indicator1:update(mode);
    Indicator2:update(mode);
	
	
    if period < first then
	return;
	end
	
	 if Indicator1.CG[period]> Indicator1.SIG[period]
	 and Indicator2.K[period]> Indicator2.D[period]
	 then
	 Oscillator[period]=1;
	 Oscillator:setColor(period, Up);
	 elseif Indicator1.CG[period]< Indicator1.SIG[period]
	 and Indicator2.K[period]< Indicator2.D[period]
	 then
	 Oscillator[period]=-1;
	  Oscillator:setColor(period, Down);
	 else	
     Oscillator[period]=0;
	 Oscillator:setColor(period, Neutral);
	 end
				  
end

