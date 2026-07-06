-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72703

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
    indicator:name("RSI + BB + Dispersion");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("forrsi", "RSI Period", "", 14, 1, 2000);
    indicator.parameters:addInteger("forma", "BB Period", "", 20, 1, 2000);
    indicator.parameters:addDouble("formult", "Stdev", "", 2, 0, 2000);
    indicator.parameters:addDouble("forsigma", "Dispersion", "", 0.1, 0, 2000);
	
	 indicator.parameters:addGroup("RSI Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("Neutral", "Neutral Line Color", "", core.rgb(255, 255, 0)); 
	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);	
	indicator.parameters:addColor("color1", "Line Color", "", core.rgb(128, 128, 128)); 


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
local forrsi, forma; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	forrsi=instance.parameters.forrsi;
	forma=instance.parameters.forma;
	formult=instance.parameters.formult;
	forsigma=instance.parameters.forsigma;	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  forrsi.. "," ..  forma.. "," ..  formult.. "," ..  forsigma  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	rsi= core.indicators:create("RSI", source, forrsi);
	bb= core.indicators:create("BB", rsi.DATA, forma);	
	first=rsi.DATA:first() ;  
	
    RSI = instance:addStream("RSI", core.Line, name, "RSI", instance.parameters.Up, first );
    RSI:setPrecision(math.max(2, instance.source:getPrecision()));
    RSI:setWidth(instance.parameters.width);
    RSI:setStyle(instance.parameters.style); 
 	RSI:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
 	RSI:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
 	RSI:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);	
	
    BBTop = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color1, first );
    BBTop:setPrecision(math.max(2, instance.source:getPrecision()));
    BBTop:setWidth(instance.parameters.width1);
    BBTop:setStyle(instance.parameters.style1);	
	
    BBBottom = instance:addStream("BBBottom", core.Line, name, "BBBottom", instance.parameters.color1, first );
    BBBottom:setPrecision(math.max(2, instance.source:getPrecision()));
    BBBottom:setWidth(instance.parameters.width1);
    BBBottom:setStyle(instance.parameters.style1);	

    BBCentral = instance:addStream("BBCentral", core.Line, name, "BBCentral", instance.parameters.color1, first );
    BBCentral:setPrecision(math.max(2, instance.source:getPrecision()));
    BBCentral:setWidth(instance.parameters.width1);
    BBCentral:setStyle(instance.parameters.style1);	


    DispersionTop = instance:addStream("DispersionTop", core.Line, name, "DispersionTop", instance.parameters.color1, first );
    DispersionTop:setPrecision(math.max(2, instance.source:getPrecision()));
    DispersionTop:setWidth(instance.parameters.width1);
    DispersionTop:setStyle(instance.parameters.style1);	
	
    DispersionBottom = instance:addStream("DispersionBottom", core.Line, name, "DispersionBottom", instance.parameters.color1, first );
    DispersionBottom:setPrecision(math.max(2, instance.source:getPrecision()));
    DispersionBottom:setWidth(instance.parameters.width1);
    DispersionBottom:setStyle(instance.parameters.style1);		
end


function Update(period, mode)

	rsi:update(mode); 

	 if period <= first then
	 return;
	 end
	
	RSI[period]=rsi.DATA[period];
	
	bb:update(mode); 	 
	 if period <= first + forma  then
	 return;
	 end 
	 
	
	
	BBTop[period]= bb.TL[period];
	BBBottom[period]= bb.BL[period];	
	BBCentral[period]= bb.AL[period];		
	DispersionTop[period]=bb.AL[period]+(BBTop[period]-BBBottom[period])*forsigma;
	DispersionBottom[period]=bb.AL[period]-(BBTop[period]-BBBottom[period])*forsigma;	
	
	
	if RSI[period]>=DispersionTop[period] then 
    RSI:setColor(period,   instance.parameters.Up);	
	elseif RSI[period]<=DispersionBottom[period] then 
    RSI:setColor(period,   instance.parameters.Down);	
	else
    RSI:setColor(period,   instance.parameters.Neutral);	
	end 	
 
 
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

 
