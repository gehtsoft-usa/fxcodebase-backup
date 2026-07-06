-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71583

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("TrendWave");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "1. Period", "", 10, 1, 2000);	
    indicator.parameters:addInteger("Period2", "2. Period", "", 10, 1, 2000);
    indicator.parameters:addInteger("Period3", "3. Period", "", 21, 1, 2000);	
    indicator.parameters:addInteger("Period4", "4. Period", "", 4, 1, 2000);
    indicator.parameters:addDouble("Delta", "Delta", "", 0.015);	
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 60);
	indicator.parameters:addDouble("Level2", "2. Level","", 50);

    indicator.parameters:addDouble("Level3", "3. Level","", -50);
	indicator.parameters:addDouble("Level4", "4. Level","", -60);
 
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);	
	
end
 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period1,Period2, Period3, Period4; 
local first;
local source = nil;
 
local Line1, Line2;
local MA1,Delta,MA2;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period1= instance.parameters.Period1;
	Period2= instance.parameters.Period2;
    Period3= instance.parameters.Period3;
	Period4= instance.parameters.Period4;
    Delta= instance.parameters.Delta;	
	
	local Parameters= Period1..", "..Period2..", "..Period3..", "..Period4..", "..Delta;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	source = instance.source; 

	
	MA1= core.indicators:create("EMA", source, Period1);
	Delta1 = instance:addInternalStream(0, 0);
	MA2= core.indicators:create("EMA", Delta1, Period2);
	Delta2 = instance:addInternalStream(0, 0);
	MA3= core.indicators:create("EMA", Delta2, Period3);
	MA4= core.indicators:create("MVA", MA3.DATA, Period4); 

    first=MA1.DATA:first() ;	
 
 
	Line1 = instance:addStream("Line1" , core.Line, " Line1"," Line1",instance.parameters.color1, first+Period1+Period2+Period3+Period4 );
	Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:setPrecision(math.max(2, source:getPrecision()));

	Line2 = instance:addStream("Line2" , core.Line, " Line2"," Line2",instance.parameters.color2,first+Period1+Period2+Period3+Period4 );
	Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:setPrecision(math.max(2, source:getPrecision()));	

	Line1:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Line1:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Line1:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Line1:addLevel(instance.parameters.Level4, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Line1:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
 
end

-- Indicator calculation routine
function Update(period, mode)

    MA1:update(mode);
	if period < first
	then
	return;
	end 
	
	Delta1[period] = math.abs(source[period]- MA1.DATA[period]);
	
	if period < first+Period2
	then
	return;
	end 	
	
    MA2:update(mode);	
	
	
	Delta2[period] = (source[period]- MA1.DATA[period]) / (Delta * MA2.DATA[period])
	
	MA3:update(mode);

	if period < first+Period2+Period3
	then
	return;
	end 	

	MA4:update(mode);

	if period < first+Period2+Period3+Period4
	then
	return;
	end 	
	
   Line1[period]=MA3.DATA[period];	
   Line2[period]=MA4.DATA[period];	 

				  
end

 
