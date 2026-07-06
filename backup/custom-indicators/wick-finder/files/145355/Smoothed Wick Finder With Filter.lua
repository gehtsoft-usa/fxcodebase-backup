-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71970

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
    indicator:name("Smoothed Wick Finder With Filter");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addBoolean("Filter", "Use Filter", "Use Filter", true);	
    indicator.parameters:addInteger("Period1", "Filter MA Period", "", 34); 			
    indicator.parameters:addInteger("Period2", "Wick Smoothed Period", "", 1); 
    indicator.parameters:addDouble("Minimal", "Minimal Wick Size", "", 40); 
	
	indicator.parameters:addGroup("Line Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
   indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);	
	indicator.parameters:addColor("color", "Bar Color", "", core.rgb(0, 0, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local Minimal;	
local first;
local source = nil;  
local up, down;
local Period1, Period2;
-- Routine
 function Prepare(nameOnly)   
  
	source = instance.source
	
	Minimal=instance.parameters.Minimal;
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;	
	Filter=instance.parameters.Filter;
 
    local name = profile:id() .. "(" ..  instance.source:name().. ", " ..  Period1 .. ", " ..  Period2 .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Top = instance:addInternalStream(0, 0);
	Bottom = instance:addInternalStream(0, 0); 
	HighLow = instance:addInternalStream(0, 0); 	
	first=source:first()+math.max(Period1,Period2);  
	
 
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top, instance.parameters.clrDN, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
 
end


function Update(period, mode)

 	Top[period]= source.high[period]-math.max(source.open[period],source.close[period]);
	Bottom[period]= math.min(source.open[period],source.close[period])-source.low[period];	
	HighLow[period]=source.high[period]-source.low[period];
	
	 if period < first then
	 return;
	 end
	
     
	local T=mathex.avg(Top, period-Period2+1, period);
	local B=mathex.avg(Bottom, period-Period2+1, period);
	local HL=mathex.avg(HighLow, period-Period2+1, period);
	local MA=mathex.avg(source, period-Period1+1, period);
	
    up:setNoData(period);
    down:setNoData(period);	
	


	
	if  (T/(HL/100)) > Minimal and (not Filter or Filter and source[period]> MA)then
    up:set(period, source.high[period], "\218", source.high[period]);	
	elseif  (B/(HL/100)) > Minimal and (not Filter or Filter and source[period]< MA) then 
    down:set(period, source.low[period], "\217", source.low[period]);	 
	end
	
	
	
end