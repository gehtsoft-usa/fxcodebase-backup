-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72180
 
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
    indicator:name("Price Real Value Convergence Divergence");
    indicator:description("Price Real Value Convergence Divergence");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
	
	indicator.parameters:addGroup("Price Smoothing Calculation");	
    indicator.parameters:addInteger("Price ", "Period", "", 9);	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("MACD Calculation");
	indicator.parameters:addInteger("P1", "Short Period", "", 29);
	indicator.parameters:addInteger("P2", "Long Period", "", 9); 
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "MACD Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", "Signal Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("color3", "Histogram Line Color", "", core.rgb(0, 0, 255));
end
 
local first; 
local MACD, Signal, Histogram
function Prepare(nameOnly)

 
    source = instance.source;  
	
    assert(core.indicators:findIndicator("REAL VALUE") ~= nil, "Please, download and install REAL VALUE.LUA indicator");
	Slow = core.indicators:create("REAL VALUE", source, instance.parameters.P1);
	MA = core.indicators:create(instance.parameters.Method, source.close, instance.parameters.Price);	
	
    local name;
    name = profile:id() .. "(" .. instance.source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	 first=math.max(Slow.DATA:first(), MA.DATA:first());
   

    MACD = instance:addStream("MACD", core.Line, name, "MACD", instance.parameters.color1, first);
    MACD:setPrecision(0);
	
	
	signal = core.indicators:create("MVA",MACD, instance.parameters.P2);
	
	Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.color2, signal.DATA:first());
	Histogram = instance:addStream("Histogram", core.Bar, name, "Histogram", instance.parameters.color3, signal.DATA:first());
end

function Update(period, mode)
 
		
		 
		Slow:update(mode);
		MA:update(mode);		
		
		if period < first then
		return;
		end
		
		MACD[period]=MA.DATA[period]-Slow.DATA[period];
		
		signal:update(mode);
		
		if period < signal.DATA:first() then
		return;
		end
		
		Signal[period]=signal.DATA[period];
		
		Histogram[period]= MACD[period]-Signal[period];
 
end

