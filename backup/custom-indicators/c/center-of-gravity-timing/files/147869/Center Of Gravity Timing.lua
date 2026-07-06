-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72829

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
    indicator:name("Center Of Gravity Timing");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "", 5, 1, 2000);
    indicator.parameters:addDouble("Level1", "1. Level", "", 4);	
    indicator.parameters:addDouble("Level2", "2. Level", "", 8);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "1. Top Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "2. Top Line Color", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("color3", "1. Bottom Line Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("color4", "2. Bottom Line Color", "", core.rgb(255, 0, 0));

	 indicator.parameters:addColor("Up", "Up Candle Color", "", core.COLOR_UPCANDLE );
	 indicator.parameters:addColor("Down", "Down Candle Color", "", core.COLOR_DOWNCANDLE );	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period; 
local Level1, Level2;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	Level1=instance.parameters.Level1;
	Level2=instance.parameters.Level2;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=source:first()+Period ; 
	
	
	Range = instance:addInternalStream(0, 0);
 
	
	
    ul1 = instance:addStream("Upper1", core.Line, name, "Upper level 1", instance.parameters.color1, first );
    ul1:setPrecision(math.max(2, instance.source:getPrecision()));
    ul1:setWidth(instance.parameters.width);
    ul1:setStyle(instance.parameters.style);
    ul1:addLevel(0);

    ul2 = instance:addStream("Upper2", core.Line, name, "Upper level 2", instance.parameters.color2, first );
    ul2:setPrecision(math.max(2, instance.source:getPrecision()));
    ul2:setWidth(instance.parameters.width);
    ul2:setStyle(instance.parameters.style);
    ul2:addLevel(0);	
	
    ll1 = instance:addStream("Lower1", core.Line, name, "Lower level 1", instance.parameters.color3, first );
    ll1:setPrecision(math.max(2, instance.source:getPrecision()));
    ll1:setWidth(instance.parameters.width);
    ll1:setStyle(instance.parameters.style);
    ll1:addLevel(0);

    ll2 = instance:addStream("Lower2", core.Line, name, "Lower level 2", instance.parameters.color4, first );
    ll2:setPrecision(math.max(2, instance.source:getPrecision()));
    ll2:setWidth(instance.parameters.width);
    ll2:setStyle(instance.parameters.style);
    ll2:addLevel(0);	
	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);	
	
 
end


function Update(period, mode)

	--  Indicator:update(mode); 
	
	ul1[period]=Level1;
	ul2[period]=Level2;
 
 	ll1[period]=-Level1;
	ll2[period]=-Level2;
 
	Range[period]=(source.high[period]-source.low[period])/5;
	 if period <= first then
	 return;
	 end
	
	
 
    local am = mathex.avg(source.median, period-Period+1, period);
    local ar = mathex.avg(Range, period-Period+1, period);	
 

 
	if ar ~= 0 then 
	open[period] = (source.open[period]-am)/ar
	high[period] = (source.high[period]-am)/ar
	low[period] = (source.low[period]-am)/ar
	close[period] = (source.close[period]-am)/ar
	end 

    if close[period] > open[period] then   
	open:setColor(period,instance.parameters.Up);	
    else
	open:setColor(period,instance.parameters.Down);		
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
 
 