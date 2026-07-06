-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72195

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


function Init()
    indicator:name("SSI with MA");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
    indicator.parameters:addInteger("Period", "MA Period","", 34);
    indicator.parameters:addColor("color1", "SSI Line Color", "", core.colors().Red); 
    indicator.parameters:addColor("color2", "MA Line Color", "", core.colors().Blue);	
	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);	
end

local source;
local ssi;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
	
 
    instance:name(name);
    if nameOnly then
        return ;
    end
	
	Period=instance.parameters.Period;
 
    ssi = core.indicators:create("SSI", source, "SSI"); 
	
	SSI = instance:addStream("SSI" , core.Line, " SSI"," SSI",instance.parameters.color1, source:first());
	SSI:setWidth(instance.parameters.width);
    SSI:setStyle(instance.parameters.style);
    SSI:setPrecision(math.max(2, source:getPrecision()));
	
	MA = instance:addStream("MA" , core.Line, " MA"," MA",instance.parameters.color2, source:first());
	MA:setWidth(instance.parameters.width);
    MA:setStyle(instance.parameters.style);
    MA:setPrecision(math.max(2, source:getPrecision()));
	
    core.host:execute ("setTimer", 3 , 3);
end

function Update(period, mode)
    ssi:update(mode); 
	
	if period < Period then
	return;
	end
	
    SSI[period]=ssi.DATA[period]
    MA[period]=mathex.avg(ssi.DATA, period- Period+1 , period)	
	
end

function AsyncOperationFinished(cookie, successful, message )
    if cookie== 3 
	then
	 instance:updateFrom(0);  
	end
	
	    return core.ASYNC_REDRAW;
end