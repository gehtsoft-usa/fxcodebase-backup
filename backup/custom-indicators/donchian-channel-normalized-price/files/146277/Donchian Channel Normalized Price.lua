-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72339

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
    indicator:name("Donchian Channel Normalized Price");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addBoolean("Show", "Show Channels", "Show Channels", true);	
	indicator.parameters:addBoolean("Shift", "Shift", "Shift", true);	
    indicator.parameters:addInteger("Period", "Period", "", 21, 1, 2000); 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color", "Price Line Color", "", core.rgb(0, 0, 255)); 
	indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0)); 
		 
    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 0.7);
	indicator.parameters:addDouble("Level2", "2. Level","", 0.3); 
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
local Period; 
local Indicator;
local Level={};	
local Shift;
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	Show=instance.parameters.Show;
	Shift=instance.parameters.Shift;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	 
	first=source:first()+Period +1; 
	
	

 
	

    Price = instance:addStream("Price", core.Line, name, "Price", instance.parameters.color, first );
    Price:setPrecision(math.max(2, instance.source:getPrecision()));
    Price:setWidth(instance.parameters.width);
    Price:setStyle(instance.parameters.style);  	 

	
	if not Show	then    
	Price:addLevel(0);	
    Price:addLevel(1);	
    Price:addLevel(0.5);
	Price:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Price:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);

	end

    if Show	then  
    Level[1] = instance:addStream("OBLevel", core.Line, name, "OBLevel", instance.parameters.color1, first );
    Level[1]:setPrecision(math.max(2, instance.source:getPrecision()));
    Level[1]:setWidth(instance.parameters.width);
    Level[1]:setStyle(instance.parameters.style);    
	
    Level[2] = instance:addStream("CentralLevel", core.Line, name, "CentralLevel", instance.parameters.color, first );
    Level[2]:setPrecision(math.max(2, instance.source:getPrecision()));
    Level[2]:setWidth(instance.parameters.width);
    Level[2]:setStyle(instance.parameters.style);    

    Level[3] = instance:addStream("OSLevel", core.Line, name, "OSLevel", instance.parameters.color2, first );
    Level[3]:setPrecision(math.max(2, instance.source:getPrecision()));
    Level[3]:setWidth(instance.parameters.width);
    Level[3]:setStyle(instance.parameters.style);     
	end
	
	
end


function Update(period, mode)

 

	 if period <= first then
	 return;
	 end
 
	local min,max;
	if Shift then
	min,max=mathex.minmax(source, period-1-Period+1, period-1);	
	else
	min,max=mathex.minmax(source, period-Period+1, period);
	end
	
	
	local dcMiddle = (max+min)/2.0			
    
	if Show	then		
	Top  = max-dcMiddle
	Bottom  = min-dcMiddle
	Price[period]  = (source[period]-dcMiddle)	
	
	Level[1][period]=Bottom  + (Top -Bottom  )*instance.parameters.Level1
	Level[2][period]=Bottom   + (Top -Bottom  )*0.5
	Level[3][period]=Bottom 	 + (Top -Bottom  )*instance.parameters.Level2
	else	

		local  diff = (max-min)
				  if (diff ~= 0) then
				   Price[period] = (source.close[period]-min)/diff;
				  else
				   Price[period] = 0;
				  end

    end
end
 