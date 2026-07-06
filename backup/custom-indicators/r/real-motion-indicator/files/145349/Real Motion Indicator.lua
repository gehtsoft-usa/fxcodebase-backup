-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71968

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Real Motion Indicator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("PrimaryAverage", "PrimaryAverage", "", 200, 1, 2000);
    indicator.parameters:addInteger("RealMotionAverageSlow", "RealMotionAverageSlow", "", 200, 1, 2000);
    indicator.parameters:addInteger("RealMotionAverageFast", "RealMotionAverageFast", "", 50, 1, 2000);
	
    indicator.parameters:addDouble("NumDevsUp", "NumDevsUp", "", 2, 0, 2000);
    indicator.parameters:addDouble("NumDevsDn", "NumDevsDn", "", 2, 0, 2000);
 
 
	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "Real Motion Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "Slow Real Motion Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color3", "Fast Real Motion Line Color", "", core.rgb(0, 0, 255)); 
	
	indicator.parameters:addColor("color4", "Top Line Color", "", core.rgb(128, 128, 128)); 
	indicator.parameters:addColor("color5", "Bottom Line Color", "", core.rgb(128, 128, 128)); 	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local PrimaryAverage, RealMotionAverageSlow,RealMotionAverageFast,NumDevsUp,NumDevsDn ; 
local Indicator;
local RealMotion,SlowRealMotion,FastRealMotion; 	
-- Routine
 function Prepare(nameOnly)   
 
    
	PrimaryAverage=instance.parameters.PrimaryAverage;
	RealMotionAverageSlow=instance.parameters.RealMotionAverageSlow;
	RealMotionAverageFast=instance.parameters.RealMotionAverageFast;
	NumDevsUp=instance.parameters.NumDevsUp;
	NumDevsDn=instance.parameters.NumDevsDn;	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  PrimaryAverage.. "," ..  RealMotionAverageSlow .. "," ..  RealMotionAverageFast.. "," ..  NumDevsUp .. "," ..  NumDevsDn .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator1= core.indicators:create("MVA", source, PrimaryAverage);
	first=Indicator1.DATA:first() ; 
	
 
	
	
    RealMotion = instance:addStream("RealMotion", core.Line, name, "RealMotion", instance.parameters.color1,  Indicator1.DATA:first() );
    RealMotion:setPrecision(math.max(2, instance.source:getPrecision()));
    RealMotion:setWidth(instance.parameters.width);
    RealMotion:setStyle(instance.parameters.style);
    RealMotion:addLevel(0);	
	
	Indicator2= core.indicators:create("MVA", RealMotion, RealMotionAverageSlow);
	Indicator3= core.indicators:create("MVA", RealMotion, RealMotionAverageFast);	
	
    SlowRealMotion = instance:addStream("SlowRealMotion", core.Line, name, "SlowRealMotion", instance.parameters.color2,  math.max(Indicator2.DATA:first(),Indicator3.DATA:first()) );
    SlowRealMotion:setPrecision(math.max(2, instance.source:getPrecision()));
    SlowRealMotion:setWidth(instance.parameters.width);
    SlowRealMotion:setStyle(instance.parameters.style);
    SlowRealMotion:addLevel(0);		
	
    FastRealMotion = instance:addStream("FastRealMotion", core.Line, name, "FastRealMotion", instance.parameters.color3, math.max(Indicator2.DATA:first(),Indicator3.DATA:first()) );
    FastRealMotion:setPrecision(math.max(2, instance.source:getPrecision()));
    FastRealMotion:setWidth(instance.parameters.width);
    FastRealMotion:setStyle(instance.parameters.style);
    FastRealMotion:addLevel(0);		
	
	
    Up = instance:addStream("Up", core.Line, name, "Up", instance.parameters.color4, math.max(Indicator2.DATA:first(),Indicator3.DATA:first()) );
    Up:setPrecision(math.max(2, instance.source:getPrecision()));
    Up:setWidth(instance.parameters.width);
    Up:setStyle(instance.parameters.style);
    Up:addLevel(0);			
 
    Down = instance:addStream("Down", core.Line, name, "Down", instance.parameters.color5, math.max(Indicator2.DATA:first(),Indicator3.DATA:first()) );
    Down:setPrecision(math.max(2, instance.source:getPrecision()));
    Down:setWidth(instance.parameters.width);
    Down:setStyle(instance.parameters.style);
    Down:addLevel(0);			
end


function Update(period, mode)

	  Indicator1:update(mode); 

	 if period < Indicator1.DATA:first() then
	 return;
	 end
	 
	 
	 RealMotion[period]= (source[period] / Indicator1.DATA[period]-1)*100;
 
 
	  Indicator2:update(mode); 
	  Indicator3:update(mode); 	  
	  
    if period <   math.max(Indicator2.DATA:first(),Indicator3.DATA:first()) then
    return;
	end
	
	
   	
	SlowRealMotion[period]=Indicator2.DATA[period];
	FastRealMotion[period]=Indicator3.DATA[period];
 
	 local Std= mathex.stdev(RealMotion, period-RealMotionAverageFast+1, period)
	 Up[period]= FastRealMotion[period] + (Std * NumDevsUp) 
	 Down[period] = FastRealMotion[period] - (Std * NumDevsDn) 
	 
end	 