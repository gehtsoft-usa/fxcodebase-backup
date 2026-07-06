-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72684

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



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Refracted EMA");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("MAlen", "EMA Length", "", 24, 1, 2000);
    indicator.parameters:addInteger("bspLen", "Average Buying/Selling Pressure", "", 24, 1, 2000);
    indicator.parameters:addDouble("mult", "Factor", "", 1, 0, 2000);	
 
 
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 
	indicator.parameters:addColor("Top", "Top Lines Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("Bottom", "Bottom Lines Color", "", core.rgb(0, 255, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local MAlen, bspLen,mult; 
local Indicator;
local Top={};
local Bottom={};	
-- Routine
 function Prepare(nameOnly)   
 
    
	MAlen=instance.parameters.MAlen;
	bspLen=instance.parameters.bspLen;
	mult=instance.parameters.mult;	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  MAlen .. "," ..  bspLen.. "," ..  mult   .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	EMA= core.indicators:create("EMA", source.close, MAlen);
	first=source:first()+MAlen ; 
	
	
	bp = instance:addInternalStream(0, 0);
 	sp = instance:addInternalStream(0, 0);
	
	bpma= core.indicators:create("EMA", bp, bspLen);
	spma= core.indicators:create("EMA", sp, bspLen);	
	
	
    Central = instance:addStream("Central", core.Line, name, "Central", instance.parameters.color, first );
    Central:setPrecision(math.max(2, instance.source:getPrecision()));
    Central:setWidth(instance.parameters.width);
    Central:setStyle(instance.parameters.style); 
	
	
	for i=1, 5 , 1 do
    Top[i] = instance:addStream("Top"..i , core.Line, name, i.. ". Top", instance.parameters.Top, first );
    Top[i]:setPrecision(math.max(2, instance.source:getPrecision()));
    Top[i]:setWidth(instance.parameters.width);
    Top[i]:setStyle(instance.parameters.style); 
 
    Bottom[i] = instance:addStream("Bottom"..i , core.Line, name, i.. ". Bottom", instance.parameters.Bottom, first );
    Bottom[i]:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom[i]:setWidth(instance.parameters.width);
    Bottom[i]:setStyle(instance.parameters.style);  
    end
end


function Update(period, mode)



	 if period <= source:first() then
	 return;
	 end
	 
	local High = math.max(source.high[period], source.high[period-1])
	local Low = math.min(source.low[period], source.low[period-1])
	bp[period] = source.close[period] - Low --buying_pressure
	sp[period] = High - source.close[period] --selling_pressure
	

	  EMA:update(mode); 
	  bpma:update(mode);
	  spma:update(mode);	  
	 if period <= first then
	 return;
	 end
	 
	Central[period]= EMA.DATA[period];	 
	 

    Top[1][period] = Central[period] + bpma.DATA[period]  * mult  
	Top[2][period] = Top[1][period] + bpma.DATA[period] * mult
	Top[3][period] = Top[2][period] + bpma.DATA[period] * mult	
	Top[4][period] = Top[3][period] + bpma.DATA[period] * mult	
	Top[5][period] = Top[4][period] + bpma.DATA[period] * mult
	
	Bottom[1][period] = Central[period] - spma.DATA[period] * mult
	Bottom[2][period] = Bottom[1][period] - spma.DATA[period] * mult
	Bottom[3][period] = Bottom[2][period] - spma.DATA[period] * mult
	Bottom[4][period] = Bottom[3][period] - spma.DATA[period] * mult
	Bottom[5][period] = Bottom[4][period] - spma.DATA[period] * mult	

	
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+


 
