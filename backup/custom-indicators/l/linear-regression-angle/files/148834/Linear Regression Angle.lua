-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73089

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
    indicator:name("Linear Regression Angle");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
  
   	indicator.parameters:addGroup("Selector"); 
    indicator.parameters:addBoolean("ShowSlope", "Show Slope", "", false);
	indicator.parameters:addBoolean("ShowAngle", "Show Angle", "", true);	

 
	
 	indicator.parameters:addGroup("Calculation");	
	
	indicator.parameters:addBoolean("Use1", "Use 1. Line", "", true);	
	indicator.parameters:addBoolean("Use2", "Use 2. Line", "", true);	
	indicator.parameters:addBoolean("Use3", "Use 3. Line", "", true);	
	indicator.parameters:addBoolean("Use4", "Use 4. Line", "", true);	
	
    indicator.parameters:addInteger("Period5", "Period", "", 300, 1, 2000);	
    indicator.parameters:addInteger("Period1", "1. Line Period", "", 100, 1, 2000);
    indicator.parameters:addInteger("Period2", "2. Line Period", "", 50, 1, 2000);
    indicator.parameters:addInteger("Period3", "3. Line Period", "", 30, 1, 2000);
    indicator.parameters:addInteger("Period4", "4. Line Period", "", 15, 1, 2000);
	

    indicator.parameters:addInteger("slope_len", "Slope MA Length", "", 3, 1, 2000);
    indicator.parameters:addDouble("slope_multi", "Slope Multiplier", "", 5   );	
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(0, 255, 255)); 
	 indicator.parameters:addColor("color3", "3. Line Color", "", core.rgb(255, 255, 0)); 
	 indicator.parameters:addColor("color4", "4. Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color", "Average Line Color", "", core.rgb(0, 0, 255)); 


    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 50);
	indicator.parameters:addDouble("Level2", "2. Level","", 25);
    indicator.parameters:addDouble("Level3", "3. Level","", -25);
	indicator.parameters:addDouble("Level4", "4. Level","", -50);
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
local Period={}; 
local Angle={};
local Slope={};	
local MA={};
local ROC={};
local Use={};

-- Routine
 function Prepare(nameOnly)   
 
  
    MAX=0;
	for i= 1, 5, 1 do
	Period[i]=instance.parameters:getInteger("Period" .. i);  
	MAX=math.max(MAX,Period[i])
    end	
	
	ShowSlope=instance.parameters.ShowSlope;
	ShowAngle=instance.parameters.ShowAngle;
	slope_len=instance.parameters.slope_len;
	slope_multi=instance.parameters.slope_multi;
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	

	first=source:first()+Period[5] ; 
	
	
	Range = instance:addInternalStream(0, 0); 
 
 	for i= 1, 5, 1 do	
	
	if i <=4 then
	Use[i]= instance.parameters:getBoolean("Use" .. i);
	end
	
	ROC[i]= instance:addInternalStream(0, 0);	
	MA[i]= core.indicators:create("MVA", ROC[i], slope_len);	
	end
	
	for i= 1, 4, 1 do	
	    if ShowAngle then
		Angle[i] = instance:addStream("Angle".. i , core.Line, name, i.. ". Angle", instance.parameters:getColor("color" .. i), first+Period[i]);
		Angle[i]:setPrecision(math.max(2, instance.source:getPrecision()));
		Angle[i]:setWidth(instance.parameters.width);
		Angle[i]:setStyle(instance.parameters.style);
		Angle[i]:addLevel(0);
		else
	    Angle[i] = instance:addInternalStream(0, 0);		
		end	
	end
  
	for i= 1, 4, 1 do
		if ShowSlope then
		Slope[i] = instance:addStream("Slope".. i , core.Line, name, i.. ". Slope", instance.parameters:getColor("color" .. i), first+Period[i] );
		Slope[i]:setPrecision(math.max(2, instance.source:getPrecision()));
		Slope[i]:setWidth(instance.parameters.width);
		Slope[i]:setStyle(instance.parameters.style);
		Slope[i]:addLevel(0);	
		else
	    Slope[i] = instance:addInternalStream(0, 0);		
		end
	end
	
	
	if ShowAngle then
    AverageAngle = instance:addStream("AverageAngle", core.Line, name, "Average Angle", instance.parameters.color,first+MAX );
    AverageAngle:setPrecision(math.max(2, instance.source:getPrecision()));
    AverageAngle:setWidth(instance.parameters.width);
    AverageAngle:setStyle(instance.parameters.style);
    AverageAngle:addLevel(0);		
 
 
	AverageAngle:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	AverageAngle:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	AverageAngle:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	AverageAngle:addLevel(instance.parameters.Level4, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
	else
	AverageAngle = instance:addInternalStream(0, 0);		
	end

	if ShowSlope then 
    AverageSlope = instance:addStream("AverageSlope", core.Line, name, "Average Slope", instance.parameters.color,first+MAX );
    AverageSlope:setPrecision(math.max(2, instance.source:getPrecision()));
    AverageSlope:setWidth(instance.parameters.width);
    AverageSlope:setStyle(instance.parameters.style);
    AverageSlope:addLevel(0);	 

	AverageSlope:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	AverageSlope:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	AverageSlope:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	AverageSlope:addLevel(instance.parameters.Level4, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);	
	else
	AverageSlope = instance:addInternalStream(0, 0);		
	end	
end


function Update(period, mode)


 

	 if period <= first then
	 return;
	 end
	 
	local min, max=mathex.minmax(source, period-Period[5]+1, period);
	Range[period]= max-min;
	  
	for i= 1, 4, 1 do  	
    LR_angle(i, period)  
    LR_slope(i, period)  
	end
	
	
	local angle_sum =0;
	local count =0;
	for i= 1, 4, 1 do
	angle_sum = angle_sum + Angle[i][period];
	count =count+1;	
	end
	
 
   AverageAngle[period] = angle_sum / count
   
   

   ROC[5][period] = AverageAngle[period]-AverageAngle[period-1];  
   
   
   AverageSlope[period]=mathex.avg(ROC[5], period-slope_len+1, period);

	
end

function LR_angle(i, period)  


    if period <= first + Period[i] 
	then
	return;
	end
	
	
    local slope = ( mathex.lreg (source, period-Period[i],period)  - mathex.lreg (source, period-1-Period[i],period-1)) / Range[period] * 100
    Angle[i][period] = math.deg(math.atan(slope));

end

function LR_slope(i, period)

 
    ROC[i][period] = Angle[i][period] - Angle[i][period-1];  
	
	MA[i]:update(mode); 
	
	if period <= MA[i].DATA:first() then
	return;
	end
	  	
	Slope[i][period] = MA[i].DATA[period]*slope_multi;
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