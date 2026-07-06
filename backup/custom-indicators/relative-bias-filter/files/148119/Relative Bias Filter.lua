-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72886

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
    indicator:name("Relative Bias Filter");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("response", "Response", "", 50, 2, 2000);
    indicator.parameters:addInteger("cutoff", "Cutoff", "", 10, 1, 45); 
	indicator.parameters:addBoolean("complexMode", "Complex Mode", "", false);	
 
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	
    indicator.parameters:addGroup("Levels");	 
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);		
	
	

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Response, cutoff,dynamicMode,complexMode; 
local Indicator;
local btm, top;	
-- Routine
 function Prepare(nameOnly)   
 
    
	Response=instance.parameters.response;
	cutoff=instance.parameters.cutoff; 
	complexMode=instance.parameters.complexMode;	
	source = instance.source
	
    btm = 0   + cutoff
    top = 100 - cutoff	
	
 
	 Period = Response*2  
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Response.. "," ..  cutoff  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	MVA= core.indicators:create("MVA", source.typical, Period);	
	AB = instance:addInternalStream(0, 0);	 
	RSI1= core.indicators:create("RSI", MVA.DATA, Response);
	RSI2= core.indicators:create("RSI", AB, Period/2);	
	ADX= core.indicators:create("ADX", source , Period);	
	first=ADX.DATA:first() ; 
	
	 
	
	
    Line = instance:addStream("Line", core.Line, name, "Bias Filter", core.COLOR_LABEL , first  +  Period/2  );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
 	Line:addLevel(btm, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
 	Line:addLevel(top, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
end

 
function Update(period, mode)
	MVA:update(mode);
	RSI1:update(mode);  
	ADX:update(mode); 
	
	 if period <= first   then
	 return;
	 end
	
	 adxA   = ADX.DATA[period]
	 adxB   =   (ADX.DATA[period] + ADX.DATA[period-Period+1]) / 2 
	 
	 AB[period] = (adxA+adxB)/2;
	 
	RSI2:update(mode); 
	
	if period <= first +  Period/2  then
	return;
	end
	 
	if complexMode then
	 adxRsiOffset = (RSI2.DATA[period])/50
	 x = ((RSI1.DATA[period]-50)*adxRsiOffset)+50
	 x = (x + RSI1.DATA[period]) / 2  
	 Line[period] = math.min(top, math.max(btm, x))
	else
	 Line[period] = math.min(top, math.max(btm, RSI1.DATA[period]))
	end 
		 

    r = 50+(100-RSI1.DATA[period])*2
    g = 50+RSI1.DATA[period]*2
		 
    Line:setColor(period,  core.rgb(r, g, 50));			  
  
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
