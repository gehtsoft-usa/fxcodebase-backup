-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73668

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
    indicator:name("Even better Sinewave");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Duration", "Duration", "", 39, 1, 2000);
    indicator.parameters:addInteger("LowerBand", "Lower Band", "", 9, 1, 2000);	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 255));  
	 
    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 0.85);
	indicator.parameters:addDouble("Level2", "2. Level","", -0.85); 
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
local Duration,LowerBand; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Duration=instance.parameters.Duration;
	LowerBand=instance.parameters.LowerBand;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Duration .. "," ..LowerBand.. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
 
	angle = ((360*math.pi)/180)/Duration
	alpha1 = (1-math.sin(angle))/math.cos(angle)	
	ang = math.sqrt(2)*math.pi/LowerBand
	a1 = math.exp(-ang)
	b1 = 2*a1*math.cos(ang)
	c2 = b1
	c3 = -a1*a1
	c1 = 1 - c2 - c3	
	 
	first=source:first()+1; 
	
	
	HP = instance:addInternalStream(0, 0);
	filt = instance:addInternalStream(0, 0); 
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first+4 );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);
    Line:addLevel(1);
    Line:addLevel(-1);	

	Line:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Line:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	
	 	
 
end


function Update(period, mode)

	---Indicator:update(mode); 

	if period <= first
	or  not source:hasData(period) 
	then
	return;
	end
	
    HP[period] = 0.5*(1+alpha1)*(source[period]-source[period-1])+alpha1*HP[period-1]	

	if period <= first+2
	or  not source:hasData(period) 
	then
	return;
	end	
	filt[period] = c1*(HP[period] + (HP[period-1]))/2 + c2*(filt[period-1]) + c3*(filt[period-2])

	if period <= first+4
	or  not source:hasData(period) 
	then
	return;
	end		
	  
    local Wave = (filt[period]+filt[period-1]+filt[period-2])/3
    local Pwr = (filt[period]*filt[period]+filt[period-1]*filt[period-1]+filt[period-2]*filt[period-2])/3

 

 
	Line[period]= Wave/ math.sqrt(Pwr);
    Line:setColor(period, instance.parameters.color);		
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