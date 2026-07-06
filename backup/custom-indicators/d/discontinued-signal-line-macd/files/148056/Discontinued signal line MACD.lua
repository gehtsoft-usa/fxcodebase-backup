-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72874

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
    indicator:name("Discontinued signal line MACD");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("FastEma", "Fast MA", "", 12, 1, 2000);
    indicator.parameters:addInteger("SlowEma", "Slow MA", "", 26, 1, 2000);
    indicator.parameters:addInteger("SignalPeriod", "Signal MA", "", 9, 1, 2000);
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(128, 128, 128)); 
	indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(128, 128, 128)); 
	indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(128, 128, 128)); 	 

	indicator.parameters:addColor("OB", "OB Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("OS", "OS Line Color", "", core.rgb(255, 0, 0)); 	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local FastEma, SlowEma,SignalPeriod,alpha; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	FastEma=instance.parameters.FastEma;
	SlowEma=instance.parameters.SlowEma;
	SignalPeriod=instance.parameters.SignalPeriod;	
	source = instance.source
	
    alpha = 2.0/(1.0+SignalPeriod)	
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  FastEma.. "," ..  SlowEma .. "," ..  SignalPeriod       .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	MA1= core.indicators:create("EMA", source, FastEma);
	MA2= core.indicators:create("EMA", source, SlowEma);	
	first=math.max(MA1.DATA:first(),MA2.DATA:first()) ; 
	
	 
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
	
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color1, first );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
    Top:addLevel(0);	

    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color2, first );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
    Bottom:addLevel(0);
 
end


function Update(period, mode)

	MA1:update(mode); 
	MA2:update(mode); 
	
	 if period <= first then
	 return;
	 end
	  
	  
    Line[period]= MA1.DATA[period]-MA2.DATA[period];	  
	
	Top[period]=Top[period-1];
	Bottom[period]=Bottom[period-1];
	
	if Line[period]>0 then
	 Top[period] = Top[period-1]+alpha*(Line[period]-Top[period-1])
	end  
	if Line[period]<0 then
	 Bottom[period] = Bottom[period-1]+alpha*(Line[period]-Bottom[period-1])
	end 
	
	
	if Line[period] > Top[period] then
	Line:setColor(period,  instance.parameters.OB);	
	elseif Line[period] < Bottom[period] then
	Line:setColor(period,  instance.parameters.OS);	
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
