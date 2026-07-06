-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72136

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
    indicator:name("Impulse MACD");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

 
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period1", "Master MA", "", 34, 1, 2000);
    indicator.parameters:addInteger("Period2", "Signal MA", "", 9, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "MACD Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Signal Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2; 
local Indicator1,Indicator2, Indicator3;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator1= core.indicators:create("SMMA", source.high, Period1);
	Indicator2= core.indicators:create("SMMA", source.low, Period1);
	Indicator3= core.indicators:create("LWMA", source.weighted, Period1);
	first= Indicator1.DATA:first() ; 
	
	
	--Stream = instance:addInternalStream(0, 0);
 
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color1, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
	
	Indicator4= core.indicators:create("MVA", Line, Period2);	
	
    Signal = instance:addStream("Signal", core.Bar, name, "Signal", instance.parameters.color2, Indicator4.DATA:first() );
    Signal:setPrecision(math.max(2, instance.source:getPrecision())); 
    Signal:addLevel(0);		
 
end


function Update(period, mode)

	  Indicator1:update(mode); 
	  Indicator2:update(mode); 
	  Indicator3:update(mode); 
	  
	 if period <= first then
	 return;
	 end
	 
    local Count=0;	 
 
 
	if(Indicator3.DATA[period]>Indicator1.DATA[period]) then
    Line[period]=Indicator3.DATA[period]-Indicator1.DATA[period];
 	end      
	
	
    
	if(Indicator3.DATA[period]<Indicator2.DATA[period]) then
    Line[period]=Indicator3.DATA[period]-Indicator2.DATA[period];  
	end 
 
	Indicator4:update(mode);
	
	Signal[period]= Indicator4.DATA[period];
	  
end

 
