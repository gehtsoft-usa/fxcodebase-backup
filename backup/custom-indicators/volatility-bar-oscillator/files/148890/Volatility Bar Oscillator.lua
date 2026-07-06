-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73103

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
    indicator:name("Volatility Bar Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period", "Period", "", 20, 1, 2000); 
	
 	indicator.parameters:addGroup("Zones");	
 
    indicator.parameters:addDouble("LineLevel1", "1. Level", "", -0.5); 	
    indicator.parameters:addDouble("LineLevel2", "2. Level", "", 0.5); 	
    indicator.parameters:addDouble("LineLevel3", "3. Level", "", 1.5);  
	
	
 	indicator.parameters:addGroup("Zone Style");		
	indicator.parameters:addBoolean("Lines", "Show Lines", "", false);
	
	indicator.parameters:addColor("Color1", "1. Zone Color", "", core.rgb(0, 0, 255)); 
	indicator.parameters:addColor("Color2", "2. Zone Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("Color3", "3. Zone Color", "", core.rgb(255, 0, 0)); 
	--indicator.parameters:addColor("color4", "4. Zone Color", "", core.rgb(255, 0, 0)); 

	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);		
	
	 indicator.parameters:addGroup("Line Style");	  
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 255)); 

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
local tAbs = math.abs;
local LastAtr;	
local Level1, Level2, Level3;
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	LineLevel1=instance.parameters.LineLevel1;
	LineLevel2=instance.parameters.LineLevel2;
	LineLevel3=instance.parameters.LineLevel3;
	Color1=instance.parameters.Color1;
	Color2=instance.parameters.Color2;
	Color3=instance.parameters.Color3;
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	LastAtr=nil;
	
 
	first=source:first()+1 ;  
	TrueRange = instance:addInternalStream(0, 0);
 
	
	
    Volatility = instance:addStream("Volatility", core.Bar, name, "Volatility", instance.parameters.color, first );
    Volatility:setPrecision(math.max(2, instance.source:getPrecision())); 
  
	if instance.parameters.Lines then
	Volatility:addLevel(Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Volatility:addLevel(Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Volatility:addLevel(Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	end
 
end

function getTrueRange(period)
    local hl = tAbs(source.high[period] - source.low[period]);
    local hc = tAbs(source.high[period] - source.close[period - 1]);
    local lc = tAbs(source.low[period] - source.close[period - 1]);

    local tr = hl;
    if (tr < hc) then
        tr = hc;
    end
    if (tr < lc) then
        tr = lc;
    end
    return tr;
end



function Update(period, mode)

 

	 if period <= first then
	 return;
	 end
	 
    TrueRange[period] = getTrueRange(period);	 
	
    if period < source:size()-1 then
    return;
    end
	
	local StDev= mathex.stdev(source, first, source:size()-1);	
	local Atr= mathex.avg(TrueRange, first, source:size()-1);	
	
	if LastAtr~= Atr then		
	    LastAtr= Atr;
		
		for i= first+Period, period, 1 do	
		
		    Volatility[i]= (mathex.avg(TrueRange, i-Period+1, i) - Atr)/StDev;
		 
			if Volatility[i] <  LineLevel1 then
			Volatility:setColor(i, Color1);	
			elseif Volatility[i] >=  LineLevel2 and Volatility[i]<  LineLevel3 then	
			Volatility:setColor(i, Color2);	
			elseif Volatility[i] >=  LineLevel3  then	
			Volatility:setColor(i, Color3);	 
			end
		end
	else
            Volatility[period]= (mathex.avg(TrueRange, period-Period+1, period) - Atr)/StDev;	 
	 
	        if Volatility[period] <  LineLevel1 then
			Volatility:setColor(period, Color1);	
			elseif Volatility[period] >=  LineLevel2 and Volatility[period]<  LineLevel3 then	
			Volatility:setColor(period, Color2);	
			elseif Volatility[period] >=  LineLevel3  then	
			Volatility:setColor(period, Color3);	 
			end
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