-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72045

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
    indicator:name("Adaptive ATR");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("inpAtrPeriod", "Period", "", 14, 1, 2000);
	
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
local inpAtrPeriod; 
local m_fastEnd, m_slowEnd, m_periodDiff;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	inpAtrPeriod=instance.parameters.inpAtrPeriod;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  inpAtrPeriod  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 
    m_fastEnd    = math.max(inpAtrPeriod/2.0,1);
    m_slowEnd    = inpAtrPeriod*5;
    m_periodDiff = m_slowEnd - m_fastEnd;	
	
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=source:first() +inpAtrPeriod; 
	
	
	Price = instance:addInternalStream(0, 0);
	Difference = instance:addInternalStream(0, 0); 
	Signal = instance:addInternalStream(0, 0); 	
	Noise = instance:addInternalStream(0, 0); 

	Data = instance:addInternalStream(0, 0); 	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)

  
	Price[period]=(source.high[period]+source.low[period])*0.5; 
    Difference[period]=math.abs(Price[period]-Price[period-1])
	
	
	Data[period]=(source.high[period]-source.low[period]);
	
	 if period <= first +1 +inpAtrPeriod then
	 return;
	 end
	 
 
    Signal[period] = math.abs(Price[period]-Price[period-inpAtrPeriod+1]); 
    Noise[period]= mathex.sum( Difference , period-inpAtrPeriod, period); 
					   
				 
    local  averagePeriod = inpAtrPeriod;
	if Noise[period]~=0 then
	averagePeriod= (Signal[period]/Noise[period])*m_periodDiff+m_fastEnd
	end
	
	if averagePeriod<1 then
	averagePeriod=1;
	end

 	if period<= averagePeriod then
	return;
	end
	
	Line[period]= mathex.avg(Data , period-averagePeriod, period); 
     
 
	
end