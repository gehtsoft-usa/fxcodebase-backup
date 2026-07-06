-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72614

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
    indicator:name("Volume Rsi oversold overbought");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
	
	indicator.parameters:addString("Source", "RSI Source", "Source" , "Price");
    indicator.parameters:addStringAlternative("Source", "Price", "Price" , "Price");
    indicator.parameters:addStringAlternative("Source", "Volume", "Volume" , "Volume");
	
    indicator.parameters:addInteger("Period", "Period", "", 14, 1, 2000);
    indicator.parameters:addDouble("Upper", "Upper", "", 70, 0, 100);
    indicator.parameters:addDouble("Lower", "Lower", "", 30, 0, 100);	
	 indicator.parameters:addGroup("Line Style");	 
	
	 indicator.parameters:addColor("color1", "Up Bar Color", "", core.rgb(0, 128, 0)); 
	 indicator.parameters:addColor("color2", "Down Bar Color", "", core.rgb(128, 0, 0)); 
	 
	 indicator.parameters:addColor("color3", "Overbought Up Bar Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color4", "Overbought Down Bar Color", "", core.rgb(255, 0, 0)); 


	 indicator.parameters:addColor("color5", "Oversold Up Bar Color", "", core.rgb(0, 64, 0)); 
	 indicator.parameters:addColor("color6", "Oversold Down Bar Color", "", core.rgb(64, 0, 0)); 
	 
  
	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Source, Period, Lower; 
local Indicator,Bar;
	
-- Routine
 function Prepare(nameOnly)   
 
    Source=instance.parameters.Source;
	Period=instance.parameters.Period;
	Upper=instance.parameters.Upper;
	Lower=instance.parameters.Lower;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name() .. "," .. Source .. "," ..  Period.. "," ..  Upper.. "," ..  Lower  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	if Source=="Price" then
	Indicator= core.indicators:create("RSI", source.close, Period);
	else
	Indicator= core.indicators:create("RSI", source.volume, Period);	
	end
	first=Indicator.DATA:first() ; 
 
 
	
	
    Bar = instance:addStream("Line", core.Bar, name, "Line", instance.parameters.color1, first );
    Bar:setPrecision(math.max(2, instance.source:getPrecision())); 
    Bar:addLevel(0);	
 
end


function Update(period, mode)

	  Indicator:update(mode); 

	 if period <= first then
	 return;
	 end 
	
	Bar[period]= source.volume[period];
	
	if Indicator.DATA[period]>= Upper then
		if source.close[period]> source.open[period] then	
		Bar:setColor(period,   instance.parameters.color3);	
		else
		Bar:setColor(period,   instance.parameters.color4);			
		end		
	elseif Indicator.DATA[period]<= Lower then	
		if source.close[period]> source.open[period] then	
		Bar:setColor(period,   instance.parameters.color5);	
		else
		Bar:setColor(period,   instance.parameters.color6);			
		end		
	else
		if source.close[period]> source.open[period] then	
		Bar:setColor(period,   instance.parameters.color1);	
		else
		Bar:setColor(period,   instance.parameters.color2);			
		end
	end
	
	
end