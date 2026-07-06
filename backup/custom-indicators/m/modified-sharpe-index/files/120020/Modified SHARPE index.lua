-- Id: 21715
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66288

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine

function Init()
    indicator:name("Modified SHARPE index");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
	
	indicator.parameters:addGroup("Calculation");
	


    indicator.parameters:addInteger("Period", "Period", "", 10);
	indicator.parameters:addInteger("NoRisk", "NoRisk", "", 0);

	

	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 25);
    indicator.parameters:addDouble("oversold","Oversold Level","", -25);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);


	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block


local first;
local source = nil;
 
local NoRisk, Period,a;

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	
    NoRisk= instance.parameters.NoRisk;
	Period= instance.parameters.Period;
	 
			
    source = instance.source;
	first=source:first()+Period;
	
	a= instance:addInternalStream(0, 0);
    
	
	Sharpe = instance:addStream("Sharpe" , core.Line, "Sharpe","Sharpe",instance.parameters.color, first);
    Sharpe:setPrecision(math.max(2, instance.source:getPrecision()));
	Sharpe:setWidth(instance.parameters.width);
    Sharpe:setStyle(instance.parameters.style);
    
	
	Sharpe:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Sharpe:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
	Sharpe:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 

end

-- Indicator calculation routine
function Update(period, mode)

 

	
	
    if period < first  then
	return;
	end
	
  
		  
	
    a[period]=math.log(source[period]/source[period-1])
local b=mathex.sum(a, period-Period+1,period);
local s=math.sqrt(254)*mathex.stdev(a, period-Period+1,period);

--Calculation
Sharpe[period]=(b-NoRisk/100)/(s*s)

				  
end


