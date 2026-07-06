-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71925

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
    indicator:name("Velocity");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Line Calculation");	
    indicator.parameters:addInteger("Period1", "Period", "", 8, 1, 2000);
    indicator.parameters:addDouble("Vfactor1", "Vfactor", "", 0.7, 0, 2000);
 
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0)); 
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2, Period3; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1; 
    Vfactor1=instance.parameters.Vfactor1;
 
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Vfactor1  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	

	MA11= core.indicators:create("EMA", source, Period1);	
	MA12= core.indicators:create("EMA", MA11.DATA, Period1);	
	Data11 = instance:addInternalStream(0, 0);

	
	MA13= core.indicators:create("EMA", Data11, Period1);	
	MA14= core.indicators:create("EMA", MA13.DATA, Period1);
	Data12 = instance:addInternalStream(0, 0);
		
	Data13 = instance:addInternalStream(0, 0);
	MA15= core.indicators:create("EMA", Data12, Period1);	
	MA16= core.indicators:create("EMA", MA15.DATA, Period1);		
	
	Data14 = instance:addInternalStream(0, 0);
	MA17= core.indicators:create("EMA", source, Period1);	
	MA18= core.indicators:create("EMA", MA17.DATA, Period1);	
	
	Data15 = instance:addInternalStream(0, 0);	
	MA19= core.indicators:create("EMA", Data14, Period1);	
	MA110= core.indicators:create("EMA", MA19.DATA, Period1);	
	
	Data16 = instance:addInternalStream(0, 0);	
	MA111= core.indicators:create("EMA", Data15, Period1);	
	MA112= core.indicators:create("EMA", MA111.DATA, Period1);	
	
	
 
 


	first=source:first() ; 
	
 
	
	
    Line1 = instance:addStream("Line1", core.Line, name, "1. Line", instance.parameters.color1, MA112.DATA:first() );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:addLevel(0);	
 
 
end


function Update(period, mode)

	MA11:update(mode);
	MA12:update(mode);
	if period < MA12.DATA:first() then
	return;
	end
 
	Data11[period]= MA11.DATA[period]*(1+Vfactor1)- MA12.DATA[period]*Vfactor1;

	MA13:update(mode);
	MA14:update(mode);
	if period < MA14.DATA:first() then
	return;
	end
	
	Data12[period]= MA13.DATA[period]*(1+Vfactor1)- MA14.DATA[period]*Vfactor1;	 
		
	MA15:update(mode);
	MA16:update(mode);
	if period < MA16.DATA:first() then
	return;
	end
	
	Data13[period]= MA15.DATA[period]*(1+Vfactor1)- MA16.DATA[period]*Vfactor1;	 
	
	MA17:update(mode);
	MA18:update(mode);
	if period < MA18.DATA:first() then
	return;
	end	
	
	Data14[period]= MA17.DATA[period]*(1+Vfactor1/2)- MA18.DATA[period]*Vfactor1/2;	 
	
	MA19:update(mode);
	MA110:update(mode);
	if period < MA110.DATA:first() then
	return;
	end	
	
	Data15[period]= MA19.DATA[period]*(1+Vfactor1/2)- MA110.DATA[period]*Vfactor1/2;

	MA111:update(mode);
	MA112:update(mode);
	if period < MA112.DATA:first() then
	return;
	end	
	
	Data16[period]= MA111.DATA[period]*(1+Vfactor1/2)- MA112.DATA[period]*Vfactor1/2;	 	
    Line1[period] = Data13[period] - Data16[period-1];
	
	
	
end
 