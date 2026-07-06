-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71732


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

function Init()
    indicator:name("Krypton Fear & Greed");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "K Length", "", 10, 1, 2000);
    indicator.parameters:addInteger("Period2", "D Length", "", 3, 1, 2000);
    indicator.parameters:addInteger("Period3", "Period", "", 4, 1, 2000);	
 
 
	
	indicator.parameters:addGroup("K Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);

	indicator.parameters:addGroup("D Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 50);
	indicator.parameters:addDouble("Level2", "2. Level","", -50); 
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);		
	
	

	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period1,Period2; 
local first;
local source = nil;
 
local Oscillator;  
local Indicator={};
local Average;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
    Period3= instance.parameters.Period3;
	
	
	local Parameters= Period1..", "..Period2..", "..Period3;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+Period1;
	
	diff= instance:addInternalStream(0, 0);
	rdiff= instance:addInternalStream(0, 0);  
	
    EMA1 = core.indicators:create("EMA", diff, Period2);
	EMA2 = core.indicators:create("EMA", rdiff, Period2);
	
	EMA3 = core.indicators:create("EMA", EMA1.DATA, Period2);
	EMA4 = core.indicators:create("EMA", EMA2.DATA, Period2);
	
	Raw= instance:addInternalStream(0, 0);
	
	EMA5 = core.indicators:create("EMA", Raw, Period2);
	EMA6 = core.indicators:create("EMA", Raw, Period3);		
 
	Line1 = instance:addStream("Line1" , core.Line, " Line1"," Line1",instance.parameters.color1, first+Period2*2+Period3);
	Line1:setWidth(instance.parameters.width1);
    Line1:setStyle(instance.parameters.style1);
    Line1:setPrecision(math.max(2, source:getPrecision()));
	Line1:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Line1:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);	
	
	
	Line2 = instance:addStream("Line2" , core.Line, " Line2"," Line2",instance.parameters.color2, first+Period2*2+Period3);
	Line2:setWidth(instance.parameters.width2);
    Line2:setStyle(instance.parameters.style2);
    Line2:setPrecision(math.max(2, source:getPrecision()));
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < first
	then
	return;
	end 
	
	
	--Range Calculation
	
	local min, max=mathex.minmax(source, period-Period1+1, period);
    diff[period]= max-min;  
    rdiff[period] = source.close[period] - (max + min) / 2

	EMA1:update(mode);
	EMA2:update(mode);	
	
	if period < first+Period2
	then
	return;
	end 	
	
	EMA3:update(mode);
	EMA4:update(mode);	
	
	if period < first+Period2*2
	then
	return;
	end 	
	
	if EMA4.DATA[period]== 0 then
	Raw[period]=0;
	else
    Raw[period]=EMA4.DATA[period] / (EMA3.DATA[period] / 2) * 100;
	end			
	
	EMA5:update(mode);
	EMA6:update(mode);	

	if period < first+Period2*2+Period3
	then
	return;
	end 	
	
	Line1[period]=EMA5.DATA[period];
	Line2[period]=EMA6.DATA[period];
end


-- 