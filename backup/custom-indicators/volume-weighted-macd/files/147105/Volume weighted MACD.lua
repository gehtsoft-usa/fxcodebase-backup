-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72631

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
--|                                                                       https://mario-jemic.com/ |
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
    indicator:name("Volume weighted MACD");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period1", "Fast EMA", "", 12, 1, 2000);
    indicator.parameters:addInteger("Period2", "Slow EMA", "", 26, 1, 2000);
    indicator.parameters:addInteger("Period3", "Signal EMA", "", 9, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "MACD Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "Signal Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color3", "Histogram Line Color", "", core.rgb(0, 0, 255)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period1, Period2, Period3; 
local Indicator11, Indicator12,Indicator21, Indicator22 , Indicator3;
local MACD_Line, Signal_Line, Histogram;	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2 .. "," ..  Period3 .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	

	first=source:first() +math.max(Period1,Period2); 
	
	
	VolumeClose = instance:addInternalStream(0, 0);
  --  macd = instance:addInternalStream(0, 0);	
	Indicator11= core.indicators:create("EMA", VolumeClose, Period1 ); 
	Indicator12= core.indicators:create("EMA", source.volume, Period1 ); 	
	
	Indicator21= core.indicators:create("EMA", VolumeClose, Period2 ); 
	Indicator22= core.indicators:create("EMA", source.volume, Period2 ); 		
	
    MACD_Line = instance:addStream("MACD", core.Line, name, "MACD", instance.parameters.color1, source:first() + math.max(Period1,Period2) );
    MACD_Line:setPrecision(math.max(2, instance.source:getPrecision()));
    MACD_Line:setWidth(instance.parameters.width);
    MACD_Line:setStyle(instance.parameters.style);
    MACD_Line:addLevel(0);	
 
	Indicator3= core.indicators:create("EMA", MACD_Line, Period3 );  
	
    Signal_Line = instance:addStream("SIGNAL", core.Line, name, "SIGNAL", instance.parameters.color2, source:first() + math.max(Period1,Period2)+Period3  );
    Signal_Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal_Line:setWidth(instance.parameters.width);
    Signal_Line:setStyle(instance.parameters.style);
    Signal_Line:addLevel(0);	

    Histogram = instance:addStream("Histogram", core.Bar, name, "Histogram", instance.parameters.color3, source:first() + math.max(Period1,Period2)+Period3 );
    Histogram:setPrecision(math.max(2, instance.source:getPrecision())); 
    Histogram:addLevel(0);
	
	

end


function Update(period, mode)


	 if period <= source:first()  then
	 return;
	 end	

     VolumeClose[period]=source.volume[period]*source.close[period];

  	 Indicator11:update(mode); 
  	 Indicator12:update(mode);  
  	 Indicator21:update(mode); 
  	 Indicator22:update(mode); 

	 if period <= source:first() + math.max(Period1,Period2)   then
	 return;
	 end	  
	 
	 
	
	 


	local Fast=( Indicator11.DATA[period]/Indicator12.DATA[period]);
	local Slow=	( Indicator21.DATA[period]/Indicator22.DATA[period]); 
	
	
	if Indicator12.DATA[period]== 0 or Indicator22.DATA[period]== 0  then
	MACD_Line[period]=MACD_Line[period-1];
    else	
	MACD_Line[period]=Fast-Slow;
	end
	
  	Indicator3:update(mode); 	
	if period <= first+Period3  then
	return;
	end	 	
	 

	Signal_Line[period]=Indicator3.DATA[period];
	Histogram[period]=MACD_Line[period]-Signal_Line[period];
	
end

 