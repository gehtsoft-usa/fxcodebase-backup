-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71937

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
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
    indicator:name("MACD Prediction");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("stochper", "Stochastic Period", "", 30, 1, 2000);
    indicator.parameters:addInteger("slowing", "Stochastic Slowing", "", 5, 1, 2000);
    indicator.parameters:addInteger("Period", "Period", "", 2, 1, 2000); 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0)); 
	 
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
local stochper, slowing,Period; 
local mav1, mav2;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	stochper=instance.parameters.stochper;
	slowing=instance.parameters.slowing;
	Period=instance.parameters.Period;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  stochper.. "," ..  slowing.. "," ..  Period  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	mav1= core.indicators:create("WMA", source.close, Period);
	mav2= core.indicators:create("WMA", mav1.DATA, Period);
	mav3= core.indicators:create("WMA", mav2.DATA, Period);	
	mav4= core.indicators:create("WMA", mav3.DATA, Period);		
	first=mav4.DATA:first() ; 
	RBW = instance:addInternalStream(0, 0);
 	Data1 = instance:addInternalStream(0, 0);
 	Data2 = instance:addInternalStream(0, 0);	
	
    Line1 = instance:addStream("Line1", core.Line, name, "1. Line", instance.parameters.color1, first+stochper );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:addLevel(0);	
 
    Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color2, first+stochper+slowing );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:addLevel(0);	
	
	Line1:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Line1:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Line1:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	
end


function Update(period, mode)

	mav1:update(mode); 
	mav2:update(mode); 	
 	mav3:update(mode); 	
 	mav4:update(mode); 	
	if period < first then
	return;
	end
	
	RBW[period] = 5 * mav1.DATA[period]; 
	RBW[period] = RBW[period]+ 4 * mav2.DATA[period]; 
	RBW[period] = RBW[period]+ 3 * mav3.DATA[period]; 	
	RBW[period] = RBW[period]+ 2 * mav4.DATA[period]; 

    RBW[period]  =  RBW[period]/20; 	
	
	if period < first+stochper then
	return;
	end
	
	local min,max=mathex.minmax(RBW, period-stochper+1, period);
	Data1[period]=RBW[period]-min;
	Data2[period]=max-min;	
	
	if period < first+stochper+slowing then
	return;
	end	

	local Sum1=mathex.sum(Data1, period-slowing+1, period);
	local Sum2=mathex.sum(Data2, period-slowing+1, period);
	
	Line1[period]= 100 * Sum1 / ( Sum2 + 0.0001 ); 
    
    local x = 0.1 * ( Line1[period] - 50 ); 
    Line2[period]  = ( ( math.exp( 2 * x ) - 1 ) / ( math.exp( 2 * x ) + 1 ) + 1 ) * 50; 

end

 