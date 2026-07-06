-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73095

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Moving Average Angle (Stochastic)");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("MAPeriod", "MA Period", "", 40, 1, 2000);
    indicator.parameters:addInteger("SamplePeriod", "Sample Period ", "", 5, 1, 2000);
	indicator.parameters:addInteger("AngleThreshold", "Angle Threshold", "", 45, 1, 2000);
	
	indicator.parameters:addBoolean("Absolute", "Absolute Value", "", true);
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "1. Line Color", "", core.rgb(0, 0, 255)); 
	 indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("color2", "Down Line Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("color3", "Neutral Line Color", "", core.rgb(128, 128, 128));		 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local MAPeriod , SamplePeriod, AngleThreshold,Absolute; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	MAPeriod =instance.parameters.MAPeriod ;
	SamplePeriod=instance.parameters.SamplePeriod;
	AngleThreshold =instance.parameters.AngleThreshold ;	
	Absolute =instance.parameters.Absolute;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  MAPeriod .. "," ..  SamplePeriod  .. "," ..  AngleThreshold  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	MA1= core.indicators:create("MVA", source, MAPeriod);
	first=MA1.DATA:first() ; 
	
	
	MAAngle = instance:addInternalStream(0, 0);
 
	MA2= core.indicators:create("MVA", MAAngle, SamplePeriod);
	MA3= core.indicators:create("MVA", MAAngle, math.floor(SamplePeriod/2));	
	
    Line1 = instance:addStream("Line1", core.Line, name, "1. Line", instance.parameters.color1, first );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:addLevel(0);	
    Line1:addLevel(AngleThreshold);	 
	
	
    Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color, first+SamplePeriod );
    Line2:setPrecision(math.max(2, instance.source:getPrecision())); 
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:addLevel(0);	
    Line2:addLevel(AngleThreshold);	 	
end


function Update(period, mode)

	 MA1:update(mode); 

	 if period <= first then
	 return;
	 end
	  
	 MAAngle[period] = (math.sin(math.atan((MA1.DATA[period]-MA1.DATA[period-1])/MA1.DATA[period-1]*100)))*1000;
	 
	 
	 MA2:update(mode); 
	 MA3:update(mode); 	 
	 
	 
 	 if period <= first+SamplePeriod then
	 return;
	 end

	if Absolute then  	
	Line1[period] = math.abs(MA2.DATA[period])
	Line2[period] = math.abs(MA3.DATA[period])
	else
	Line1[period] = MA2.DATA[period]
	Line2[period] = MA3.DATA[period]	
	end
	
	
	if MA2.DATA[period]> AngleThreshold then
	Line1:setColor(period,  instance.parameters.color1);
	elseif MA2.DATA[period]< (-1* AngleThreshold) then
	Line1:setColor(period,  instance.parameters.color2);	
    else
	Line1:setColor(period,  instance.parameters.color3);	
    end	
	
	
end


 

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+


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