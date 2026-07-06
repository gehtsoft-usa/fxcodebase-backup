-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73353

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
    indicator:name("Body momentum");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Lookback", "Lookback Period", "", 14, 1, 2000);
    indicator.parameters:addInteger("Smoothing", "Smoothing Period", "", 3, 1, 2000);
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "OB Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "OS Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color3", "Neutral Line Color", "", core.rgb(255, 191, 0)); 
	
    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 30);
	indicator.parameters:addDouble("Level2", "2. Level","", 50);
	indicator.parameters:addDouble("Level3", "3. Level","", 70); 
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
local Lookback, Smoothing; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Lookback=instance.parameters.Lookback;
	Smoothing=instance.parameters.Smoothing;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Lookback.. "," ..  Smoothing  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	

	first=source:first()+Lookback ;  
	BM = instance:addInternalStream(0, 0);
 
	Average= core.indicators:create("MVA", BM, Smoothing);	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color1, first+Smoothing );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
	
	Line:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Line:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Line:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	
 
end


function Update(period, mode)
 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
	local Bup = 0
	local Bdn = 0

	for i = 0 , Lookback , 1 do 
		if(source.close[period-i]>source.open[period-i]) then
		  Bup = Bup + 1
		else
		  Bdn = Bdn + 1
		end
	end	
	  
    BM[period] = (Bup/(Bup+Bdn))*100
	
	Average:update(mode);	
	
	if period <= first + Smoothing
	then
	return;
	end	
	  	
	Line[period]= Average.DATA[period];
	
	if Line[period] > instance.parameters.Level3 then
    Line:setColor(period, instance.parameters.color1);		
	elseif Line[period] < instance.parameters.Level1 then	
    Line:setColor(period, instance.parameters.color2);	
	else
    Line:setColor(period, instance.parameters.color3);	
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