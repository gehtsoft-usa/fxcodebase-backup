-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72777

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
    indicator:name("Attributable Volume");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addDouble("thresh", "RVOL Threshold", "", 2.5, 1, 2000);
    indicator.parameters:addInteger("len", "RVOL lookback length", "", 20, 1, 2000);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "Attributable_Volume");
    indicator.parameters:addStringAlternative("Method", "Attributable Volume RVOL", "Attributable Volume RVOL" , "Attributable_Volume_RVOL");
    indicator.parameters:addStringAlternative("Method", "RVOL", "RVOL" , "RVOL");	
    indicator.parameters:addStringAlternative("Method", "Attributable Volume", "Attributable Volume" , "Attributable_Volume");
    indicator.parameters:addStringAlternative("Method", "Volume", "Volume" , "Volume");		
 
	indicator.parameters:addGroup("Line Style");	 
	indicator.parameters:addColor("Up", "Up Bar Color", "", core.rgb(0, 255, 0)); 
    indicator.parameters:addColor("Down", "Down Bar Color", "", core.rgb(255, 0, 0)); 	 
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
local thresh, len; 
local Indicator;
local Method;	
-- Routine
 function Prepare(nameOnly)   
 
    
	thresh=instance.parameters.thresh;
	len=instance.parameters.len;
	Method=instance.parameters.Method;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  thresh.. "," ..  len .. "," ..  Method   .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 
	first=source:first() ; 
	
	
	attributable_volume = instance:addInternalStream(0, 0);
    rvol = instance:addInternalStream(0, 0);
    rvol_attr = instance:addInternalStream(0, 0);
	
 
    Bar = instance:addStream(Method, core.Bar, name, Method, instance.parameters.Up, first );
    Bar:setPrecision(math.max(2, instance.source:getPrecision()));
    Bar:addLevel(0);	
	Bar:addLevel(thresh, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
 
end


function Update(period, mode)

	--  Indicator:update(mode); 

	 if period <= first then
	 return;
	 end
	 
 
    if source.close[period]>source.open[period] then
	green =true;
	else
	green = false;
	end
	
    local wick_bottom = math.min(source.close[period],source.open[period])-source.low[period];
    local wick_top = source.high[period] - math.max(source.close[period],source.open[period])
    local solid_len = math.abs(source.close[period]-source.open[period])	
	
	if green then
	attributable_volume[period]=(source.volume[period] * (solid_len+wick_bottom)/(solid_len+wick_top+wick_bottom))
	else
	attributable_volume[period]=(source.volume[period] * (solid_len+wick_top)/(solid_len+wick_top+wick_bottom))
    end
	
	
	if period < source:first() +len then
	return;
	end
	
	
	
	rvol[period] = source.volume[period] /mathex.avg(source.volume,period-len+1, period)
    rvol_attr[period] = attributable_volume[period]/mathex.avg(attributable_volume,period-len+1, period)  
 


    if Method == "Attributable_Volume_RVOL" then
	Bar[period]= rvol_attr[period];
    elseif Method == "RVOL" then	
	Bar[period]= rvol[period];	
    elseif Method == "Attributable_Volume" then
	Bar[period]= attributable_volume[period];
    elseif Method == "Volume" then	
	Bar[period]= source.volume[period];		
	end
	
	
	if green then
	Bar:setColor(period,  instance.parameters.Up);
	else
	Bar:setColor(period,  instance.parameters.Down);	
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