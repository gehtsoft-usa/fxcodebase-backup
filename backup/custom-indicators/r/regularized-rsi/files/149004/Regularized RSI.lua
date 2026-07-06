-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73161

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
    indicator:name("Regularized RSI");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period", "RSI Period", "", 14, 1, 2000);
    indicator.parameters:addDouble("Lamda", "Lamda", "", 0.1, 0.5, 4);
	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Signl Line Color", "", core.rgb(255, 0, 0)); 
	 
	 
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
local Lamda, Period,alpha; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Lamda=instance.parameters.Lamda;
	Period=instance.parameters.Period; 
	alpha = 1/(Period+1);	
	TF=instance.parameters.TF;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," .. Period .. "," ..  Lamda  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=source:first() ; 
	
	
	P = instance:addInternalStream(0, 0);
	N = instance:addInternalStream(0, 0); 
	
    KRSI = instance:addStream("KRSI", core.Line, name, "Regularized RSI", instance.parameters.color1, first );
    KRSI:setPrecision(math.max(2, instance.source:getPrecision()));
    KRSI:setWidth(instance.parameters.width);
    KRSI:setStyle(instance.parameters.style);
	KRSI:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
 	KRSI:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	KRSI:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	
 
 
    SMRSI = instance:addStream("SMRSI", core.Line, name, "Signal", instance.parameters.color2, first );
    SMRSI:setPrecision(math.max(2, instance.source:getPrecision()));
    SMRSI:setWidth(instance.parameters.width);
    SMRSI:setStyle(instance.parameters.style);
 

 
end


function Update(period, mode)

	--Indicator:update(mode); 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	  
	  
	  
	P[period] = 0;
	N[period] = 0; 
	local W = 0;
	local S = 0; 		
			
			
	local diff = source[ period ] - source[ period - 1 ];
	 
	if( diff > 0 ) then W = diff; end
	if( diff < 0 )  then S = -diff;	 end	
			
 

			
	P[period] = (P[period-1] + alpha*(W-P[period-1]) + Lamda*(P[period-1]+(P[period-1]-P[period-2])))/(1+Lamda);
	N[period] = (N[period-1] + alpha*(S-N[period-1]) + Lamda*(N[period-1]+(P[period-1]-N[period-2])))/(1+Lamda);
			
			
	KRSI[period]=100 * P[period] / ( P[period] + N[period] );		
	  	
	SMRSI[period]=   ( 4*KRSI[period] + 3 * KRSI[period-1] + 2 * KRSI[period-2] + KRSI[period-3] ) / 10;
	
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