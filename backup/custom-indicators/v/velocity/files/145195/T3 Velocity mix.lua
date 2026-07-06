-- More information about this indicator can be found at:
-- http://fxcodebase.com

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
    indicator:name("Oscillator Template");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("1. Line Calculation");	
    indicator.parameters:addInteger("Period1", "Period", "", 8, 1, 2000);
    indicator.parameters:addDouble("Vfactor1", "Vfactor", "", 0.7, 0, 2000);	
	
 	indicator.parameters:addGroup("2. Line Calculation");		
    indicator.parameters:addInteger("Period2", "Period", "", 32, 1, 2000);
    indicator.parameters:addDouble("Vfactor2", "Vfactor", "", 0.7, 0, 2000);	
	
 	indicator.parameters:addGroup("3. Line Calculation");		
    indicator.parameters:addInteger("Period3", "Period", "", 64, 1, 2000);
    indicator.parameters:addDouble("Vfactor3", "Vfactor", "", 0.7, 1, 2000);	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color3", "3. Line Color", "", core.rgb(0, 0, 255)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2,Period3; 
local Vfactor1, Vfactor2, Vfactor3;
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;	
	Vfactor1=instance.parameters.Vfactor1;
	Vfactor2=instance.parameters.Vfactor2;
	Vfactor3=instance.parameters.Vfactor3;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Vfactor1.. "," ..  Period2.. "," ..  Vfactor2.. "," ..  Period3.. "," ..  Vfactor3  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
    assert(core.indicators:findIndicator("VELOCITY") ~= nil, "Please, download and install VELOCITY.LUA indicator");
	
	Indicator1= core.indicators:create("VELOCITY", source, Period1, Vfactor1);
	Indicator2= core.indicators:create("VELOCITY", source, Period2, Vfactor2);
	Indicator3= core.indicators:create("VELOCITY", source, Period3, Vfactor3);	
	
 
	
	
    Line1 = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color1, Indicator1.DATA:first() );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:addLevel(0);	

    Line2 = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color2, Indicator2.DATA:first() );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:addLevel(0);	

    Line3 = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color3, Indicator3.DATA:first() );
    Line3:setPrecision(math.max(2, instance.source:getPrecision()));
    Line3:setWidth(instance.parameters.width);
    Line3:setStyle(instance.parameters.style);
    Line3:addLevel(0);		
end


function Update(period, mode)

	Indicator1:update(mode); 
	Indicator2:update(mode);
	Indicator3:update(mode);
	
	 if period > Indicator1.DATA:first() then
     	Line1[period]= Indicator1.DATA[period];
	 end
	 
   
	 if period > Indicator2.DATA:first() then
     	Line2[period]= Indicator2.DATA[period];
	 end

	 if period > Indicator3.DATA:first() then
     	Line3[period]= Indicator3.DATA[period];
	 end	 
	
end