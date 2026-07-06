-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71840

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
    indicator:name("Smooth And Lazy Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("length", "Length", "", 10, 1, 2000);
    indicator.parameters:addInteger("smooth", "Extra Smooth [1 = None]", "", 3, 1, 2000);
    indicator.parameters:addDouble("mult", "StdDev", "", 0.3, 0.05, 3);	
 
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local length, smooth,mult; 
local baseline,cprice;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	length=instance.parameters.length;
	smooth=instance.parameters.smooth;
	mult=instance.parameters.mult;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  length.. "," ..  smooth.. "," ..  mult  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	baseline= core.indicators:create("WMA", source, length);
	first=baseline.DATA:first() ; 
	
   cprice= instance:addInternalStream(0, 0);

	WMA1= core.indicators:create("WMA", cprice, length);
	WMA2= core.indicators:create("WMA", WMA1.DATA, smooth);	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.Up,  WMA2.DATA:first() );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)

	  baseline:update(mode); 

	 if period < first then
	 return;
	 end
	 
    local dev= mathex.stdev(source, period-length+1, period)*mult;
 
	local upper       = baseline.DATA[period] + dev
	local lower       = baseline.DATA[period] - dev
	
	if source[period] > upper  then
	cprice[period]=upper;
	elseif source[period] < lower then
	cprice[period]=lower;
    else
	cprice[period]=source[period];	
    end	
	
	WMA1:update(mode); 
	WMA2:update(mode); 	  
	
	 if period < WMA2.DATA:first() then
	 return;
	 end	
	 
	Line[period]= WMA2.DATA[period];
	
	if Line[period] > Line[period-1] then
	Line:setColor(period, instance.parameters.Up);
	else
	Line:setColor(period, instance.parameters.Down);	
	end
	
end


