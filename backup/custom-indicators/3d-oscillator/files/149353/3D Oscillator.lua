-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73293

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
    indicator:name("3D Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("D1RSIPer", "RSI Period", "", 13, 1, 2000);
    indicator.parameters:addInteger("D2StochPer", "Stoch Period", "", 8, 1, 2000);
    indicator.parameters:addInteger("D3tunnelPer", "Tunnel Period", "", 8, 1, 2000);	
 
    indicator.parameters:addInteger("hot", "Hot", "", 0.4, 0, 2000);
    indicator.parameters:addInteger("sigsmooth", "Signal Period", "", 4, 2, 2000);	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local D1RSIPer, D2StochPer,D3tunnelPer; 
 
	
-- Routine
 function Prepare(nameOnly)   
 
    
	D1RSIPer=instance.parameters.D1RSIPer;
	D2StochPer=instance.parameters.D2StochPer;
	D3tunnelPer=instance.parameters.D3tunnelPer;
	hot=instance.parameters.hot;
	sigsmooth=instance.parameters.sigsmooth;
	source = instance.source
	
	cs = D1RSIPer + D2StochPer + D3tunnelPer + hot + sigsmooth;
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  D1RSIPer.. "," ..  D2StochPer.. "," ..  D3tunnelPer.. "," ..  hot.. "," ..  sigsmooth .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	RSI= core.indicators:create("RSI", source.close, D1RSIPer);
	CCI= core.indicators:create("CCI", source, D3tunnelPer);	
	first=source:first()+cs ; 
	
    sk = 2 / (sigsmooth + 1);
    sk2 = 2 / (sigsmooth*0.8 + 1);	
	
	
    sig1n = instance:addInternalStream(0, 0);
    sig2n = instance:addInternalStream(0, 0);
	
	
    Line1 = instance:addStream("Line1", core.Line, name, "1. Line", instance.parameters.color1, first );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:addLevel(0);	


    Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color2, first );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:addLevel(0);	 
end


function Update(period, mode)

    if period <= source:first()
	or  not source:hasData(period) 
	then
	return;
	end

	RSI:update(mode); 
	CCI:update(mode); 	

    if period <= source:first()+D2StochPer
	or  not source:hasData(period) 
	or period <= source:first()+D3tunnelPer
	then
	return;
	end
	if period <= first
	then
	return;
	end
	
	
	
	local min, max=mathex.minmax(RSI.DATA, period-D2StochPer+1, period);
    local storsi = ((RSI.DATA[period] - min) / (max - min)*200 - 100);	
	local E3D = hot*CCI.DATA[period] + (1 - hot)*storsi;

    Line1[period] = sk*E3D + (1 - sk)*Line1[period-1];
    Line2[period] = sk2*Line1[period-1] + (1 - sk2)*Line2[period-1];
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