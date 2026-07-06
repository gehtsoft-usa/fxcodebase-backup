-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71945

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
    indicator:name("3x Ideal MA");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addDouble("x1", "x1", "", 0.1, 0, 2000);
    indicator.parameters:addDouble("x2", "x2", "", 0.1, 0, 2000);
    indicator.parameters:addDouble("z1", "z1", "", 0.1, 0, 2000);
    indicator.parameters:addDouble("z2", "z2", "", 0.1, 0, 2000);	
    indicator.parameters:addDouble("w1", "w1", "", 0.1, 0, 2000);
    indicator.parameters:addDouble("w2", "w2", "", 0.1, 0, 2000);		
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	x1=instance.parameters.x1;
	x2=instance.parameters.x2;

	z1=instance.parameters.z1;
	z2=instance.parameters.z2;

	w1=instance.parameters.w1;
	w2=instance.parameters.w2;

	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  x1.. "," ..  x2.. "," ..  z1.. "," ..  z2 .. "," ..  w1.. "," ..  w2   .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
  

    assert(core.indicators:findIndicator("IDEAL MA") ~= nil, "Please, download and install IDEAL MA.LUA indicator");
	
	Indicator1= core.indicators:create("IDEAL MA", source, x1, x2);
	Indicator2= core.indicators:create("IDEAL MA", Indicator1.DATA, z1, z2);
	Indicator3= core.indicators:create("IDEAL MA", Indicator2.DATA, w1, w2);
	
	first=Indicator3.DATA:first(); 	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode) 


	Indicator1:update(mode); 
	Indicator2:update(mode); 
	Indicator3:update(mode); 	
	 if period <= first then
	 return;
	 end
	 
 
	 
	Line[period]= Indicator3.DATA[period];
	
 
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