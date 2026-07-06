-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73698

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
    indicator:name("MACD Z-Score standardized value");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
 
    indicator.parameters:addInteger("Period1", "Fast Period", "", 12, 1, 2000);
    indicator.parameters:addInteger("Period2", "Slow Period", "", 26, 1, 2000);
    indicator.parameters:addInteger("Period3", "Signal Period", "", 9, 1, 2000);	
    indicator.parameters:addInteger("SamplePeriod", "SamplePeriod ", "", 2000, 1, 2000);	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "MACD Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "Signal Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color3", "Histohram Bar Color", "", core.rgb(0, 0, 255)); 
	 
    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 1);
	indicator.parameters:addDouble("Level2", "2. Level","", 2);
	indicator.parameters:addDouble("Level3", "3. Level","", 3); 
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
local Period1, Period2,Period3,SamplePeriod; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;
	SamplePeriod=instance.parameters.SamplePeriod;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period1.. "," ..  Period2 .. "," ..  Period3   .. "," .. SamplePeriod .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator= core.indicators:create("MACD", source, Period1, Period2, Period3);
	MACD= core.indicators:create("MVA", Indicator.MACD, SamplePeriod);
	SIGNAL= core.indicators:create("MVA", Indicator.SIGNAL, SamplePeriod);
	HISTOGRAM= core.indicators:create("MVA", Indicator.HISTOGRAM, SamplePeriod);	
	first=Indicator.HISTOGRAM:first() ; 
	

	
    MACD_Z = instance:addStream("MACD_Z", core.Line, name, "MACD_Z", instance.parameters.color1, first+ SamplePeriod*2 );
    MACD_Z:setPrecision(math.max(2, instance.source:getPrecision()));
    MACD_Z:setWidth(instance.parameters.width);
    MACD_Z:setStyle(instance.parameters.style);
    MACD_Z:addLevel(0);	
	
	MACD_Z:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	MACD_Z:addLevel(-instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	MACD_Z:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	MACD_Z:addLevel(-instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	MACD_Z:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	MACD_Z:addLevel(-instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);

    SIGNAL_Z = instance:addStream("SIGNAL_Z", core.Line, name, "SIGNAL_Z", instance.parameters.color2, first+ SamplePeriod*2 );
    SIGNAL_Z:setPrecision(math.max(2, instance.source:getPrecision()));
    SIGNAL_Z:setWidth(instance.parameters.width);
    SIGNAL_Z:setStyle(instance.parameters.style);
	
    HISTOGRAM_Z = instance:addStream("HISTOGRAM_Z", core.Bar, name, "HISTOGRAM_Z", instance.parameters.color3, first+ SamplePeriod*2 );
    HISTOGRAM_Z:setPrecision(math.max(2, instance.source:getPrecision()));	
 
end


function Update(period, mode)

	Indicator:update(mode); 
	MACD:update(mode);
	HISTOGRAM:update(mode);
	SIGNAL:update(mode);	
	
	if period <= first + SamplePeriod*2
	or  not source:hasData(period) 
	then
	return;
	end
	
	
	macd = mathex.stdev(Indicator.MACD, period-SamplePeriod+1, period);
 	signal= mathex.stdev(Indicator.SIGNAL, period-SamplePeriod+1, period);
 	histogram = mathex.stdev(Indicator.DATA, period-SamplePeriod+1, period);
	  	
	MACD_Z[period]=(Indicator.MACD[period]-MACD.DATA[period])/macd; 	
	SIGNAL_Z[period]=(Indicator.SIGNAL[period]-SIGNAL.DATA[period])/signal; 	
	HISTOGRAM_Z[period]=(Indicator.HISTOGRAM[period]-HISTOGRAM.DATA[period])/histogram; 		
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