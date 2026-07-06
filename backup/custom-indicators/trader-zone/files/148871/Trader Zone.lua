-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73099

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Trader Zone");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "", 100); 
	
	 indicator.parameters:addGroup("Top Line Style");	
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	 indicator.parameters:addColor("color1", "Line Color", "", core.rgb(102,102,102)); 
	 
	 indicator.parameters:addGroup("Bottom Line Style");	
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);	
	 indicator.parameters:addColor("color2", "Line Color", "", core.rgb(102,102,102)); 	 


	 indicator.parameters:addGroup("Support Line Style");	
    indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);	
	 indicator.parameters:addColor("color3", "Line Color", "", core.rgb(0,128,0)); 
	 
	 indicator.parameters:addGroup("Resistance Line Style");	
    indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);	
	 indicator.parameters:addColor("color4", "Line Color", "", core.rgb(128,0,0)); 	 
	 
	 indicator.parameters:addGroup("Center Line Style");	
    indicator.parameters:addInteger("width5", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style5", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style5", core.FLAG_LINE_STYLE);	
	 indicator.parameters:addColor("color5", "Line Color", "", core.rgb(102,102,102)); 
	 
	 indicator.parameters:addGroup("Crecio Line Style");	
    indicator.parameters:addInteger("width6", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style6", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style6", core.FLAG_LINE_STYLE);	
	 indicator.parameters:addColor("color6", "Line Color", "", core.rgb(0,0,255)); 	 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
	first=source:first()+Period; 
	
 
	
    Line1 = instance:addStream("Line1", core.Line, name, "Top", instance.parameters.color1, first );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width1);
    Line1:setStyle(instance.parameters.style1);
    Line1:addLevel(0);	
 
 
    Line2 = instance:addStream("Line2", core.Line, name, "Bottom", instance.parameters.color2, first );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width2);
    Line2:setStyle(instance.parameters.style2);
    Line2:addLevel(0);	


    Line3 = instance:addStream("Line3", core.Line, name, "Support", instance.parameters.color3, first );
    Line3:setPrecision(math.max(2, instance.source:getPrecision()));
    Line3:setWidth(instance.parameters.width3);
    Line3:setStyle(instance.parameters.style3);
    Line3:addLevel(0);	

    Line4 = instance:addStream("Line4", core.Line, name, "Resistance", instance.parameters.color4, first );
    Line4:setPrecision(math.max(2, instance.source:getPrecision()));
    Line4:setWidth(instance.parameters.width4);
    Line4:setStyle(instance.parameters.style4);
    Line4:addLevel(0);	
	
	
    Line5 = instance:addStream("Line5", core.Line, name, "Center", instance.parameters.color5, first );
    Line5:setPrecision(math.max(2, instance.source:getPrecision()));
    Line5:setWidth(instance.parameters.width5);
    Line5:setStyle(instance.parameters.style5);
    Line5:addLevel(0);	


    Line6 = instance:addStream("Line6", core.Line, name, "Crecio", instance.parameters.color6, first );
    Line6:setPrecision(math.max(2, instance.source:getPrecision()));
    Line6:setWidth(instance.parameters.width6);
    Line6:setStyle(instance.parameters.style6);
    Line6:addLevel(0);		
	
end


function Update(period, mode)

	 

	 if period <= first then
	 return;
	 end
	 
	local min, max=mathex.minmax(source, period-Period+1, period); 
	  
	  
	local High=source.high[period]-source.close[period]
    local Low=source.low[period]+source.open[period]

	local delta = max - min
	local cla = delta * 0.26
	local cla1 = delta * 1
	local cla2 = delta * 1
 
	Line1[period] = max - cla
	Line2[period] = min + cla
	Line3[period] = max - cla1
	Line4[period] = min + cla2  
    Line5[period] = (max + min) /2 
    Line6[period] = (High + Low) / 2

 
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