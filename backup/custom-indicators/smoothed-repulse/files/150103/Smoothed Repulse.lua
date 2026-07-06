-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73514

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
    indicator:name("Smoothed Repulse");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("per", "Period", "", 14, 1, 2000);
	
	indicator.parameters:addString("type", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("type", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("type", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("type", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("type", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("type", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("type", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("type", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("type", "WMA", "WMA" , "WMA")

 
    indicator.parameters:addInteger("avgmult", "Average Multiplier", "", 5, 1, 2000);
    indicator.parameters:addInteger("lvlper", "Level Period", "", 50, 1, 2000);
    indicator.parameters:addDouble("upper", "Upper Level %", "", 90, 1, 2000);
    indicator.parameters:addDouble("dnper", "Lower Level %", "", 10, 1, 2000);	
	
	
	indicator.parameters:addString("colortype", "Color Method", "Method" , "MiddleCross");
    indicator.parameters:addStringAlternative("colortype", "Middle Cross", "Middle Cross" , "MiddleCross");
    indicator.parameters:addStringAlternative("colortype", "Slope", "Slope" , "Slope")	
    indicator.parameters:addStringAlternative("colortype", "Level Cross", "Level Cross" , "LevelCross")		
 
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down Line Color", "", core.rgb(255, 0, 0))
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(128, 128, 128))	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local per, type,upper, dnper,avgmult, lvlper,colortype; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	per=instance.parameters.per;
	type=instance.parameters.type;
	upper=instance.parameters.upper;
	dnper=instance.parameters.dnper;
    avgmult=instance.parameters.avgmult;	
	lvlper=instance.parameters.lvlper;
	colortype=instance.parameters.colortype;
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  per.. "," ..  type .. "," ..  upper .. "," .. dnper  .. "," .. avgmult  .. "," .. lvlper.. "," .. colortype.. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	

	first=source:first()+per; 
	
	
	Stream1 = instance:addInternalStream(0, 0);
 	Stream2 = instance:addInternalStream(0, 0);
 	Color = instance:addInternalStream(0, 0);	
	bull= core.indicators:create(type, Stream1, per * avgmult);	
	bear= core.indicators:create(type, Stream2, per * avgmult);	
	
    rep = instance:addStream("rep", core.Line, name, "Smoothed Repulse", instance.parameters.color1, first + per * avgmult );
    rep:setPrecision(math.max(2, instance.source:getPrecision()));
    rep:setWidth(instance.parameters.width);
    rep:setStyle(instance.parameters.style);
    rep:addLevel(0);	
	
    fup = instance:addStream("fup", core.Line, name, "Top", instance.parameters.color, first + per * avgmult +lvlper);
    fup:setPrecision(math.max(2, instance.source:getPrecision()));
    fup:setWidth(instance.parameters.width);
    fup:setStyle(instance.parameters.style);
    fup:addLevel(0);	

    fdn = instance:addStream("fdn", core.Line, name, "Bottom", instance.parameters.color, first + per * avgmult+lvlper );
    fdn:setPrecision(math.max(2, instance.source:getPrecision()));
    fdn:setWidth(instance.parameters.width);
    fdn:setStyle(instance.parameters.style);
    fdn:addLevel(0);	

    mid = instance:addStream("mid", core.Line, name, "Central", instance.parameters.color, first + per * avgmult+lvlper);
    mid:setPrecision(math.max(2, instance.source:getPrecision()));
    mid:setWidth(instance.parameters.width);
    mid:setStyle(instance.parameters.style);
    mid:addLevel(0);	
	
 
end


function Update(period, mode)



	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
    local min,max= mathex.minmax(source,period- per+1, period)
 
 
    Stream1[period]=100 * (3.0 * source.close[period] - 2.0 * min- (source.open[period-per+1]))/source.close[period]
	Stream2[period]=100 * ((source.open[period-per+1]) + 2.0 * max - 3.0 * source.close[period])/source.close[period]
 
 
 	bull:update(mode); 
	bear:update(mode); 	
	
	if period <= first + per * avgmult then
	return;
	end
		
	rep[period] = bull.DATA[period] - bear.DATA[period]	
	
	if period <= first + per * avgmult+lvlper then
	return;
	end
	 
    local minf,maxf= mathex.minmax(rep,period- lvlper+1, period)
	
	local rn = maxf - minf
	fup[period]  = minf + rn * upper / 100.0
	fdn[period]  = minf + rn * dnper / 100.0
	mid[period]  = (fup[period] + fdn[period]) / 2.0

	if colortype == 'LevelCross' then 
	
		if rep[period] > fup[period] then
		Color[period]=1;
		elseif rep[period] < fdn[period] then
		Color[period]=-1;		
		elseif rep[period] < fup[period] and rep[period] > fdn[period] then
		Color[period]=0;
		else
		Color[period]=Color[period-1]
		end
		 
	elseif colortype == 'MiddleCross'  then
		if rep[period] > mid[period] then
		Color[period]=1		
		elseif rep[period] < mid[period] then
		Color[period]=-1				
		else
		Color[period]=Color[period-1]
		end
  		
	 
	else 
		if rep[period] > rep[period-1] then
		Color[period]=1;
		elseif rep[period] < rep[period-1] then
		Color[period]=-1;
		else
		Color[period]=Color[period-1]
		end 
	end	
	
    if Color[period]==1 then
 	rep:setColor(period, instance.parameters.color1);	  
    elseif Color[period]==-1 then
	rep:setColor(period, instance.parameters.color2);	   
    else
	rep:setColor(period, instance.parameters.color)	
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