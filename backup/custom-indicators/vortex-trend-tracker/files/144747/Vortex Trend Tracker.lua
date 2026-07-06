-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71794

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
    indicator:name("Vortex Trend Tracker");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("vortexLen", "Length for Vortex", "", 30, 1, 2000);
    indicator.parameters:addInteger("emaLen", "Length of Positive and Negative EMA's", "", 10, 1, 2000);
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "Down Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color3", "Difference Bar Color", "", core.rgb(0, 0, 255)); 	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local vortexLen, emaLen;  
	
-- Routine
 function Prepare(nameOnly)   
 
    
	vortexLen=instance.parameters.vortexLen;
	emaLen=instance.parameters.emaLen;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  vortexLen.. "," ..  emaLen  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	

	first=source:first()+1 ; 
	

	

	pos = instance:addInternalStream(0, 0);
	neg = instance:addInternalStream(0, 0);
	
	ATR = core.indicators:create("ATR", source, 1);
	vPlus = instance:addInternalStream(0, 0);
	vNeg = instance:addInternalStream(0, 0);
	
	EMA1 = core.indicators:create("EMA", vPlus, emaLen);
	EMA2 = core.indicators:create("EMA", vNeg, emaLen);	
	
    Plus = instance:addStream("Plus", core.Line, name, "Plus", instance.parameters.color1, first+vortexLen+emaLen );
    Plus:setPrecision(math.max(2, instance.source:getPrecision()));
    Plus:setWidth(instance.parameters.width);
    Plus:setStyle(instance.parameters.style);
    Plus:addLevel(0);	
 
    Minus = instance:addStream("Minus", core.Line, name, "Minus", instance.parameters.color2, first+vortexLen+emaLen );
    Minus:setPrecision(math.max(2, instance.source:getPrecision()));
    Minus:setWidth(instance.parameters.width);
    Minus:setStyle(instance.parameters.style);
    Minus:addLevel(0);	 
	
    Diff = instance:addStream("Diff", core.Bar, name, "Diff", instance.parameters.color3, first+vortexLen+emaLen );
    Diff:setPrecision(math.max(2, instance.source:getPrecision())); 
    Diff:addLevel(0);	 	
end


function Update(period, mode)


	ATR:update(mode);	 
	
	 if period < first then
	 return;
	 end
	 
	 pos[period]= math.abs(source.high[period] - source.low[period-1]); 
	 neg[period]= math.abs(source.low[period] - source.high[period-1]);
	 

 
	 if period < first+vortexLen then
	 return;
	 end
	 
	local  tRange=mathex.sum(ATR.DATA, period-vortexLen+1, period);	 
	local  posSum=mathex.sum(pos, period-vortexLen+1, period);
	local  negSum=mathex.sum(neg, period-vortexLen+1, period);
	 
	 
	vPlus[period] = posSum / tRange
    vNeg[period] = negSum / tRange 
 
	 if period < first+vortexLen+emaLen then
	 return;
	 end
	 
	EMA1:update(mode);
 	EMA2:update(mode); 
	
	Plus[period]= EMA1.DATA[period];	
	Minus[period]= EMA2.DATA[period];	
 
    Diff[period] = math.abs(Plus[period] - Minus[period])
end