-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72710

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
    indicator:name("Composite Momentum");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period1", "1. MA Period", "", 3, 1, 2000);
    indicator.parameters:addInteger("Period2", "2. MA Period", "", 9, 1, 2000);
    indicator.parameters:addInteger("Period3", "3. MA Period", "", 1, 1, 2000);	
    indicator.parameters:addInteger("Period4", "Summation Period", "", 5, 1, 2000);		
    indicator.parameters:addInteger("Period5", "Smoothing Period", "", 3, 1, 2000);		
    indicator.parameters:addInteger("Period6", "K Period", "", 5, 1, 2000);	
    indicator.parameters:addInteger("Period7", "D Period", "", 3, 1, 2000);		
    indicator.parameters:addInteger("Period8", "1. WMA Period", "", 3, 1, 2000);	
    indicator.parameters:addInteger("Period9", "2. WMA Period", "", 2, 1, 2000);		
 
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 


    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 0);
	indicator.parameters:addDouble("Level2", "2. Level","", 50);
	indicator.parameters:addDouble("Level3", "3. Level","", 80); 
	indicator.parameters:addDouble("Level4", "4. Level","", -50);
	indicator.parameters:addDouble("Level5", "5. Level","", -80); 	
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
local Period1, Period2, Period3,Period4; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;	
	Period4=instance.parameters.Period4;
	Period5=instance.parameters.Period5;
	Period6=instance.parameters.Period6;
	Period7=instance.parameters.Period7;	
	Period8=instance.parameters.Period8;
	Period9=instance.parameters.Period9;		
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2.. "," ..  Period3 .. "," ..  Period4.. "," ..  Period5 .. "," ..  Period6.. "," ..  Period7 .. "," ..  Period8.. "," ..  Period9 .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator1= core.indicators:create("MVA", source.close, Period1);
	Indicator2= core.indicators:create("MVA", source.close, Period2);	

	first=math.max(Indicator1.DATA:first(),Indicator2.DATA:first()) ; 
	
	
	Source = instance:addInternalStream(0, 0);
	Indicator3= core.indicators:create("EMA", Source, Period3);		
	Mom = instance:addInternalStream(0, 0);
	temp1 = instance:addInternalStream(0, 0);
	temp2 = instance:addInternalStream(0, 0);
    diffMOM= instance:addInternalStream(0, 0);
	diffMOMabs= instance:addInternalStream(0, 0);
	sumtemp1= instance:addInternalStream(0, 0);
	sumtemp2= instance:addInternalStream(0, 0);
	abssumdiff= instance:addInternalStream(0, 0);
	cc= instance:addInternalStream(0, 0);
	Indicator4= core.indicators:create("EMA", cc, Period5);			
	k= instance:addInternalStream(0, 0);	
	Indicator5= core.indicators:create("MVA", k, Period7);	
	
	Indicator6= core.indicators:create("WMA", Indicator5.DATA, Period8);	
	FinalSource= instance:addInternalStream(0, 0);
	Indicator7= core.indicators:create("WMA", FinalSource, Period9);		
	
    Composite = instance:addStream("Composite", core.Line, name, "Composite", instance.parameters.color, first+Period3+Period4+Period5+Period6+Period7 +Period8+Period9 );
    Composite:setPrecision(math.max(2, instance.source:getPrecision()));
    Composite:setWidth(instance.parameters.width);
    Composite:setStyle(instance.parameters.style);
	Composite:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Composite:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Composite:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Composite:addLevel(instance.parameters.Level4, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Composite:addLevel(instance.parameters.Level5, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
 
end


function Update(period, mode)

	Indicator1:update(mode); 
	Indicator2:update(mode); 

	  
	 if period <= first then
	 return;
	 end 
	 
	Source[period]= (Indicator1.DATA[period]-Indicator2.DATA[period])/Indicator1.DATA[period];
	
	Indicator3:update(mode); 	
	if period <= first +Period3 then
	return;
	end
	
	Mom[period]=Indicator3.DATA[period-1]*100;
	
	diffMOM[period]=Mom[period]-Mom[period-1];
	diffMOMabs[period]=math.abs(diffMOM[period]);
	
 
	
	if Mom[period]>Mom[period-1] then
	 temp1[period]=diffMOM[period]
	else
	 temp1[period]=0
	end
	if Mom[period]<Mom[period-1] then
	 temp2[period]=diffMOM[period]
	else
	 temp2[period]=0
	end
 	if period <= first +Period3 +Period4  then
	return;
	end	
	sumtemp1[period]=mathex.sum(temp1, period-Period4+1, period);
    sumtemp2[period]=mathex.sum(temp2, period-Period4+1, period);
    abssumdiff[period]=mathex.sum(diffMOMabs, period-Period4+1, period);
	
	local aa=((sumtemp1[period-1]-(sumtemp1[period-1]/5)+temp1[period])/(abssumdiff[period-1]-(abssumdiff[period-1]/5)+diffMOMabs[period])*100)
	local bb=((sumtemp2[period-1]-(sumtemp2[period-1]/5)+temp2[period])/(abssumdiff[period-1]-(abssumdiff[period-1]/5)+diffMOMabs[period])*100)
	cc[period]=aa-math.abs(bb)	
	
    Indicator4:update(mode); 		


 	if period <= first +Period3 +Period4 +Period5 +Period6  then
	return;
	end			
	
	local Low, High= mathex.minmax(source, period-Period6+1, period);
	k[period]=((source.close[period]-Low)/(High-Low))*100	
	
	
	Indicator5:update(mode); 	
	Indicator6:update(mode); 	
	
 	if period <= first +Period3 +Period4 +Period5 +Period6 +Period7+Period8  then
	return;
	end	
	
    local xtl=Indicator6.DATA[period]*2-100; 	

    FinalSource[period]=(2*Indicator4.DATA[period]+xtl)/3;
	
	Indicator7:update(mode); 	
	
 	if period <= first +Period3 +Period4 +Period5 +Period6 +Period7+Period8 +Period9 then
	return;
	end	
	
    Composite[period]=Indicator7.DATA[period];
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

 
