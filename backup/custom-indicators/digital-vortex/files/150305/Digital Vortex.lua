-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73565

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
    indicator:name("Digital Vortex");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period1", "1. Period", "", 14, 1, 2000);
    indicator.parameters:addInteger("Period2", "2. Period", "", 3, 1, 2000);
	indicator.parameters:addInteger("Period3", "3. Period", "", 5, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "Digitale stochastic Line Color", "", core.rgb(0, 0, 255)); 
	indicator.parameters:addColor("color2", "Vortex+ Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color3", "Vortex- Line Color", "", core.rgb(255, 0, 0)); 
	
    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 0.7);
	indicator.parameters:addDouble("Level2", "2. Level","", 0);
	indicator.parameters:addDouble("Level3", "3. Level","", -0.7); 
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
     
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2.. "," ..  Period3  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	

	first=source:first()+Period1; 
	
	
	fastk = instance:addInternalStream(0, 0);
	slowk= instance:addInternalStream(0, 0); 
	sum = instance:addInternalStream(0, 0); 
	EMA= core.indicators:create("EMA", sum, Period3);
	ATR= core.indicators:create("ATR", source, Period1);	
	averagesum = instance:addInternalStream(0, 0); 
	
	VP = instance:addInternalStream(0, 0); 
	VM = instance:addInternalStream(0, 0); 
	
    Line1 = instance:addStream("Line1", core.Line, name, "Digitale stochastic", instance.parameters.color1, first+Period2+Period3 );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style); 
 
    Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color2, first+Period1 );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style); 
	
    Line3 = instance:addStream("Line3", core.Line, name, "3. Line", instance.parameters.color3, first+Period1);
    Line3:setPrecision(math.max(2, instance.source:getPrecision()));
    Line3:setWidth(instance.parameters.width);
    Line3:setStyle(instance.parameters.style); 	
	
	

	
	Line1:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Line1:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Line1:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);

		
end


function Update(period, mode)


	ATR:update(mode); 
	
	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
 
 
 	local VPS=mathex.avg(VP, period-Period1+1, period)
	local VMS=mathex.avg(VM, period-Period1+1, period)
 
 
	Line2[period]=VPS/ATR.DATA[period]
	Line3[period]=VMS/ATR.DATA[period]
	
	
	VP[period]=math.abs(source.high[period] -source.low[period-1])
	VM[period]=math.abs(source.low[period]-source.high[period-1]) 
	
	local min, max= mathex.minmax(source, period-Period1+1, period);
	fastk[period] = ((source.close[period] - min) / (max - min) ) * 100	  

	if period <= first + Period2
	or  not source:hasData(period) 
	then
	return;
	end

	
	slowk[period] = mathex.avg(fastk, period-Period2+1, period)
 
	if (22* slowk[period] + 8* fastk[period]) / 30 > 50 then
	 sum[period] = 1
	else
	 sum[period]= -1
	end 
	
	EMA:update(mode); 
	if period <= first + Period3 
	or  not source:hasData(period) 
	then
	return;
	end	
	
    Line1[period]=EMA.DATA[period];
 
 

	

 
 
 
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