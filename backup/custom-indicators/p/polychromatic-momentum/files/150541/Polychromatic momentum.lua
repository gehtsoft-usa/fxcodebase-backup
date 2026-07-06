-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73635

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
   indicator:name("Polychromatic momentum");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	 
    indicator.parameters:addInteger("inpMomPeriod", "Polychromatic momentum period", "", 20, 1, 2000);
    indicator.parameters:addInteger("inpSmoothPeriod", "Smoothing period", "", 5, 1, 2000);
	
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
local inpMomPeriod, inpSmoothPeriod; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	inpMomPeriod=instance.parameters.inpMomPeriod;
	inpSmoothPeriod=instance.parameters.inpSmoothPeriod;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  inpMomPeriod.. "," ..  inpSmoothPeriod  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    alpha=2.0/(1.0+math.sqrt(inpSmoothPeriod));	
	 
	first=source:first() ; 
	
	
	ema1 = instance:addInternalStream(0, 0);
 	ema2 = instance:addInternalStream(0, 0); 
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color1, first +inpMomPeriod );
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
	  
    ema1[period]=ema1[period-1]+alpha*(source[period]-ema1[period-1])
    ema2[period]=ema2[period-1]+alpha*(ema1[period]-ema2[period-1])
	

	if period <= first + inpMomPeriod 
	or  not source:hasData(period) 
	then
	return;
	end

	
	  local  sumMom = 0;
      local  sumWgh = 0;
      for k=0,   inpMomPeriod-1 , 1 do 
         weight=math.sqrt(inpMomPeriod-k);
         sumMom =sumMom+ (ema2[period]-ema2[period-k-1])/weight;
         sumWgh =sumWgh+ weight;
        end
 
    
	
	if sumWgh~=0 then
	Line[period]= sumMom/sumWgh;
	else
	Line[period]= 0;	
	end
	
	if Line[period] > Line[period-1] then
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