-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72695

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

function Init()
    indicator:name("Endpoint Moving Average");
    indicator:description("Endpoint Moving Average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Length", "Length", "", 14); 
    indicator.parameters:addInteger("Offset", "Offset", "", 4); 	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 128, 128));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first; 
local EPMA=nil;

function Prepare(nameOnly)
    source = instance.source;
    Length=instance.parameters.Length;
	Offset=instance.parameters.Offset;
    local name = profile:id() .. "(" .. source:name() .. ", " .. Length.. ", " .. Offset  .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end 
 
	first = source:first()+Length;
	
    EPMA = instance:addStream("EPMA", core.Line, name .. ".EPMA", "EPMA", instance.parameters.clr, first);
    EPMA:setPrecision(math.max(2, instance.source:getPrecision()));
    EPMA:setWidth(instance.parameters.widthLinReg);
    EPMA:setStyle(instance.parameters.styleLinReg);
    EPMA:addLevel(30);
    EPMA:addLevel(70);
end

function Update(period, mode)

 
	
   if (period<first) then
   return;
   end
   
   local sum=0;
   local weightSum=0;   
   for i=0, Length-1, 1  do   
    weight = Length - i - Offset
    sum = sum + (source[period-i] * weight)
    weightSum = weightSum + weight   
   end
   
  
  
   EPMA[period]= 1 / weightSum * sum;
 
    
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+