-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71899

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
    indicator:name("High Volume Bar Breakout");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "", 14, 1, 2000); 
	
	indicator.parameters:addBoolean("Show", "Show Lines", "", true);
	
	indicator.parameters:addGroup("Arrow Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
   indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);	 
	
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "High Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "Low Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period;  
local Show;
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	Show=instance.parameters.Show;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 	
	first=source:first()+Period; 
	
 
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);
 
 
 
    if Show then 
		High = instance:addStream("High", core.Line, name, "High", instance.parameters.color1, first );
		High:setPrecision(math.max(2, instance.source:getPrecision()));
		High:setWidth(instance.parameters.width);
		High:setStyle(instance.parameters.style);
		High:addLevel(0);	
		
		Low = instance:addStream("Low", core.Line, name, "Low", instance.parameters.color2, first );
		Low:setPrecision(math.max(2, instance.source:getPrecision()));
		Low:setWidth(instance.parameters.width);
		Low:setStyle(instance.parameters.style);
		Low:addLevel(0);
    else
	   High = instance:addInternalStream(0, 0);
	   Low = instance:addInternalStream(0, 0);
    end	
end


function Update(period, mode)

 

	 if period < first then
	 return;
	 end
	 
	 
    up:setNoData(period);
    down:setNoData(period);		 
	 
    local min, max= mathex.minmax(source.volume, period-Period+1, period);
	
	High[period]=High[period-1];
	Low[period]=Low[period-1];	
	
	
    if max==source.volume[period] then 
	High[period]=source.high[period];
	Low[period]=source.low[period];		
	end
	
	
	
	if source.close[period]> High[period] 
	and  source.close[period-1]<= High[period-1] 
	then
	up:set(period, source.high[period], "\217", source.high[period]);		
	end
	
	if source.close[period]< Low[period] 
	and  source.close[period-1]>= Low[period-1] 
	then
	down:set(period, source.low[period], "\218", source.low[period]);	
	end	
 

end