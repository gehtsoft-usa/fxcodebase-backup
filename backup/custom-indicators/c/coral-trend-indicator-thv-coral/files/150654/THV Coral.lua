-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73666

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
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
    indicator:name("THV Coral");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
  
  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("SM", "SM", "", 21, 1, 2000);
    indicator.parameters:addDouble("CD", "CD", "", 0.4, 0, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local SM,CD; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	SM=instance.parameters.SM;
	CD=instance.parameters.CD;
	source = instance.source
	
	dii = (SM - 1.0) / 2.0 + 1.0
	c1 = 2 / (dii + 1.0)
	c2 = 1 - c1
	c3 = 3.0 * (CD * CD + CD * CD * CD)
	c4 = -3.0 * (2.0 * CD * CD + CD + CD * CD * CD)
	c5 = 3.0 * CD + 1.0 + CD * CD * CD + 3.0 * CD * CD
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  SM.. "," ..  CD  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end 
	
	first=source:first()+SM ; 
	
	
    i1 = instance:addInternalStream(0, 0);
    i2 = instance:addInternalStream(0, 0);
    i3 = instance:addInternalStream(0, 0);
    i4 = instance:addInternalStream(0, 0);
    i5 = instance:addInternalStream(0, 0);
    i6 = instance:addInternalStream(0, 0);
 
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color1, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)
  

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
	 i1[period] = c1*source[period] + c2*i1[period-1]
	 i2[period] = c1*i1[period] + c2*i2[period-1]
	 i3[period] = c1*i2[period] + c2*i3[period-1]
	 i4[period] = c1*i3[period] + c2*i4[period-1]
	 i5[period] = c1*i4[period] + c2*i5[period-1]
	 i6[period] = c1*i5[period] + c2*i6[period-1]
	  
	  	
	Line[period]= -CD*CD*CD*i6[period] + c3*(i5[period]) + c4*(i4[period]) + c5*(i3[period]);
	
	if Line[period]> Line[period-1] then
    Line:setColor(period, instance.parameters.color1);	
    else
    Line:setColor(period, instance.parameters.color2);		
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