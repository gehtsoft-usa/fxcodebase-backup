-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72603

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
    indicator:name("Andean Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("length", "Length", "", 50, 1, 2000);
    indicator.parameters:addInteger("sig_length", "Signal Length", "", 9, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "Bull Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "Bear Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color3", "Signal Line Color", "", core.rgb(0, 0, 255)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local length, sig_length,alpha; 
 
-- Routine
 function Prepare(nameOnly)   
 
    
	length=instance.parameters.length;
	sig_length=instance.parameters.sig_length;
	source = instance.source
	
    alpha = 2/(length+1)	
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  length.. "," ..  sig_length  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
	first=source:first()+1 ; 
	
	
	up1 = instance:addInternalStream(0, 0);
	up2 = instance:addInternalStream(0, 0);
	dn1 = instance:addInternalStream(0, 0);
	dn2 = instance:addInternalStream(0, 0);	
	

	
	
    Bull = instance:addStream("Bull", core.Line, name, "Bull", instance.parameters.color1, first );
    Bull:setPrecision(math.max(2, instance.source:getPrecision()));
    Bull:setWidth(instance.parameters.width);
    Bull:setStyle(instance.parameters.style);
    Bull:addLevel(0);	
 
 
    Bear = instance:addStream("Bear", core.Line, name, "Bear", instance.parameters.color2, first );
    Bear:setPrecision(math.max(2, instance.source:getPrecision()));
    Bear:setWidth(instance.parameters.width);
    Bear:setStyle(instance.parameters.style);
    Bear:addLevel(0);	
	
	Source= instance:addInternalStream(0, 0);
    EMA= core.indicators:create("EMA", Source,sig_length);		

    Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.color3, EMA.DATA:first() );
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal:setWidth(instance.parameters.width);
    Signal:setStyle(instance.parameters.style);
    Signal:addLevel(0);		 
end


function Update(period, mode)


	 
	 up1[period]=source.close[period];
	 up2[period]=source.close[period]*source.close[period];
	 
	 dn1[period]=source.close[period];
	 dn2[period]=source.close[period]*source.close[period];	 
	 if period <= first then
	 return;
	 end
	 
	up1[period]= math.max(source.close[period], source.open[period], up1[period-1] - (up1[period-1] - source.close[period]) * alpha)
	up2[period]=  math.max(source.close[period] * source.close[period], source.open[period] * source.open[period],  up2[period-1] - (up2[period-1] - source.close[period] * source.close[period]) * alpha) 

	dn1[period]= math.min(source.close[period], source.open[period],  dn1[period-1] + (source.close[period] - dn1[period-1]) * alpha)
	dn2[period]= math.min(source.close[period] * source.close[period], source.open[period]* source.open[period],  dn2[period-1] + (source.close[period] * source.close[period] - dn2[period-1]) * alpha) 

 
	 
 
 	Bull[period]=  math.sqrt(dn2[period] - dn1[period] * dn1[period])
	Bear[period]=  math.sqrt(up2[period] - up1[period] * up1[period])
	
	
	Source[period]= math.max(Bull[period], Bear[period]);
	
	EMA:update(mode); 	
	if period < EMA.DATA:first() then
	return;
	end
	
	Signal[period]= EMA.DATA[period];
	
end


 