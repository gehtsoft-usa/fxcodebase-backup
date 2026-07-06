-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72009

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
    indicator:name("DSL synthetic EMA momentum");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 
  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("inpPeriod1", "1. Period", "", 5, 1, 2000);
    indicator.parameters:addInteger("inpPeriod2", "2. Period", "", 20, 1, 2000);
    indicator.parameters:addInteger("inpPeriod3", "3. Period", "", 50, 1, 2000);
    indicator.parameters:addInteger("inpPeriod4", "4. Period", "", 100, 1, 2000);
    indicator.parameters:addInteger("inpPeriod5", "5. Period", "", 200, 1, 2000);
    indicator.parameters:addInteger("inpSignal", "Signal period", "", 9, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 
	 indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local alpha;
 
	
-- Routine
 function Prepare(nameOnly)   
 
    
	inpPeriod1=instance.parameters.inpPeriod1;
	inpPeriod2=instance.parameters.inpPeriod2;
	inpPeriod3=instance.parameters.inpPeriod3;
	inpPeriod4=instance.parameters.inpPeriod4;
	inpPeriod5=instance.parameters.inpPeriod5;
	inpSignal=instance.parameters.inpSignal;	
	source = instance.source
	
	alpha = 2.0/(1.0+inpSignal)
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  inpPeriod1.. "," ..  inpPeriod2.. "," ..  inpPeriod3.. "," ..  inpPeriod4.. "," ..  inpPeriod5.. "," ..  inpSignal  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator1= core.indicators:create("EMA", source, inpPeriod1);
	Indicator2= core.indicators:create("EMA", source, inpPeriod2);
	Indicator3= core.indicators:create("EMA", source, inpPeriod3);
	Indicator4= core.indicators:create("EMA", source, inpPeriod4);
	Indicator5= core.indicators:create("EMA", source, inpPeriod5);
	
	first=math.max(Indicator1.DATA:first(),Indicator2.DATA:first(),Indicator3.DATA:first(),Indicator4.DATA:first(),Indicator5.DATA:first())+4 ; 
	
 
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
	
	
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color1, first );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
    Top:addLevel(0);	


    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color2, first );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
    Bottom:addLevel(0);		
 
 
 
end


function Update(period, mode)

	Indicator1:update(mode); 
	Indicator2:update(mode); 
	Indicator3:update(mode); 
	Indicator4:update(mode); 
	Indicator5:update(mode); 
	
	if period < first then
	return;
	end
	
	local mom1 = 100*(Indicator1.DATA[period]-Indicator2.DATA[period])/Indicator2.DATA[period-1]
	local mom2 = 100*(Indicator2.DATA[period]-Indicator3.DATA[period-2])/Indicator3.DATA[period-2]
	local mom3 = 100*(Indicator3.DATA[period]-Indicator4.DATA[period-3])/Indicator4.DATA[period-3]
	local mom4 = 100*(Indicator4.DATA[period]-Indicator5.DATA[period-4])/Indicator5.DATA[period-4]	
    
    Line[period] = (mom4 +mom3*inpPeriod5/inpPeriod4+mom2*inpPeriod5/inpPeriod3+mom1*inpPeriod5/inpPeriod2)/4.0
 
Top[period]=Top[period-1];
Bottom[period]=Bottom[period-1];


 if Line[period]>0 then
 Top[period] = Top[period-1]+alpha*(Line[period]-Top[period-1])
 end
  if Line[period]<0 then
 Bottom[period] = Bottom[period-1]+alpha*(Line[period]-Bottom[period-1])
 end 


 
	
end


 