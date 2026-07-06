-- Id: 22290
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66648

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

-- Indicator profile initialization routine

function Init()
    indicator:name("Low Frequency Filter Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addInteger("Period", "Period", "", 15, 1, 2000);
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("colorUp", "1. Line Color Up", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("colorDown", "1. Line Color Down", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local first;
local source = nil;
local Period;

 
local input, b,v, close;
local ATR;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	Period=instance.parameters.Period;
    
			
    source = instance.source; 
	ATR = core.indicators:create("ATR", source, Period);
	first=source:first();
	
	b = instance:addInternalStream(0, 0);
	input= instance:addInternalStream(0, 0);
   
 
	v = instance:addStream("v" , core.Line, " v"," v",instance.parameters.colorUp, first);
	v:setWidth(instance.parameters.width1);
    v:setStyle(instance.parameters.style1);
	
	close = instance:addStream("close" , core.Line, " close"," close",instance.parameters.color2, first);
	close:setWidth(instance.parameters.width2);
    close:setStyle(instance.parameters.style2);
	
	
	v:setPrecision(math.max(2, instance.source:getPrecision()));
	close:setPrecision(math.max(2, instance.source:getPrecision()));
    
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    ATR:update(mode);
	
	
    if period <= first then
	return;
	end
	
	close[period]= source.close[period];
	
	
	if period== first then
	v[period]=0;
    b[period]=1;
    end
	
	local a=ATR.DATA[period];
    local tau=Period/3.5
	
 
 if (math.abs(source.median[period]-v[period-1]))<=(a) then
  input[period]=input[period-1]
  b[period]=b[period-1]+1
 else
  input[period]=source.median[period]-v[period-1]
  b[period]=1
  end
 v[period]=v[period-1]+(input[period]*(1-math.exp(-b[period]/tau)))
 

		
     if v[period]> v[period-1] then
	 v:setColor(period, instance.parameters.colorUp);
	 else
	 v:setColor(period, instance.parameters.colorDown);
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