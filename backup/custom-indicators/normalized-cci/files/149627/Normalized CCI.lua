-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=73352

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
function Init()
    indicator:name("Normalized CCI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator); 

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period1", "CCI Period","", 14, 2, 1000); 
    indicator.parameters:addInteger("Period2", "Normalization Period","", 14, 2, 1000); 	
	
	
	indicator.parameters:addString("Method", "Normalization Method", "" , "Deviation");
    indicator.parameters:addStringAlternative("Method", "Period MinMax Range", "" , "MinMax");
    indicator.parameters:addStringAlternative("Method", "Period Deviation", "" , "Deviation");
    indicator.parameters:addStringAlternative("Method", "Bollinger Range ", "" , "Bollinger");
	
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", " Up Line Color","", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", " Down Line Color","", core.rgb(255, 0, 0));	
    indicator.parameters:addInteger("width", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
    
    indicator.parameters:addGroup("Levels"); 
    indicator.parameters:addInteger("overbought", "OB Level","", 0, 0, 100);
    indicator.parameters:addInteger("oversold", "OS Level","", 0, 0, 100);
    indicator.parameters:addInteger("level_overboughtsold_width", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style","Line Style","", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(255, 255, 0));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
	
	
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block 

local first;
local source = nil; 

-- Streams block
local CCI = nil;

local Up, Down;
local Period1, Period2,Method;
-- Routine
function Prepare()
   
   
   Up= instance.parameters.Up;
   Down= instance.parameters.Down;

    Period1 = instance.parameters.Period1;
    Period2 = instance.parameters.Period2;	
	Method = instance.parameters.Method;
    source = instance.source;


    local name = profile:id() .. "(" .. source:name() .. ", " .. Period1 .. ", " .. Period2.. ")";
    instance:name(name);
	cci = core.indicators:create("CCI", source, Period1);
	bb = core.indicators:create("BB", cci.DATA, Period2);	
	first = cci.DATA:first()+Period1;
	
	CCI = instance:addStream("CCI", core.Line, name, "CCI", instance.parameters.Up, first);
    CCI:setWidth(instance.parameters.width);
    CCI:setStyle(instance.parameters.style);
    CCI:setPrecision(2); 
    CCI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    CCI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	
end

-- Indicator calculation routine
function Update(period)
    cci:update(mode);
	bb:update(mode);
	if period <= first  then
	return;
	end
	
	
	if Method== "MinMax" then
	local min,max=mathex.minmax(cci.DATA, period-Period2+1, period); 
    CCI[period]=(cci.DATA[period]-min) /((max-min)/100)-50; 
	elseif Method== "Deviation" then 
    local MVA= mathex.avg(cci.DATA, period-Period2+1, period)
    local Deviation= mathex.stdev(cci.DATA, period-Period2+1, period)
    CCI[period]=(cci.DATA[period]-MVA) /(0.015*Deviation); 	
	elseif Method== "Bollinger" then 	
    CCI[period]=(cci.DATA[period]-bb.BL[period]) /((bb.TL[period]-bb.BL[period])/100)-50; 
	end
 
	
	if CCI[period] > CCI[period-1] then
	CCI:setColor(period, Up);
	else
	CCI:setColor(period,Down); 
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