-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72601

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
    indicator:name("Candle Strength Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("ma_len", "MA period", "", 10, 1, 2000);
    indicator.parameters:addInteger("smooth_len", "Smoothing period", "", 5, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
	 indicator.parameters:addColor("color1", "Up in Up Trend Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Down in Up Trend Line Color", "", core.rgb(0, 200, 0)); 
	 indicator.parameters:addColor("color3", "Up in Down Trend Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color4", "Down in Down Trend Line Color", "", core.rgb(200, 0, 0)); 	 
	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local ma_len, smooth_len; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	ma_len=instance.parameters.ma_len;
	smooth_len=instance.parameters.smooth_len;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  ma_len.. "," ..  smooth_len  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
	first=source:first() ;  
	m = instance:addInternalStream(0, 0); 
	ma= instance:addInternalStream(0, 0);  
	
    Line = instance:addStream("Line", core.Bar, name, "Line", instance.parameters.color1, first + ma_len +smooth_len );
    Line:setPrecision(math.max(2, instance.source:getPrecision())); 
    Line:addLevel(0);	
 
end


function Update(period, mode)


	  
	local upBar = (source.high[period] - source.open[period]) / source.open[period] * 1000 + (source.close[period] - source.open[period]) / source.open[period] * 1000
	local downBar = (source.low[period] - source.open[period]) / source.open[period] * 1000 + (source.close[period] - source.open[period]) / source.open[period] * 1000 	  
    m[period]= (upBar+downBar)/2;
	
	if period <= first + ma_len then
	return;
	end
	
    ma[period]= mathex.avg(m , period-ma_len+1, period);	 
      	
	if period <= first + ma_len +smooth_len then
	return;
	end

	Line[period]= mathex.avg(ma , period-smooth_len+1, period);	 
	
	if Line[period]> 0 and  Line[period]>  Line[period-1] then
    Line:setColor(period,  instance.parameters.color1);		
	elseif Line[period]> 0 and  Line[period]<=  Line[period-1] then
    Line:setColor(period,  instance.parameters.color2);			
	elseif Line[period]<= 0 and  Line[period]>  Line[period-1] then
    Line:setColor(period,  instance.parameters.color3);			
	elseif Line[period]<=0 and  Line[period]<=  Line[period-1] then	
    Line:setColor(period,  instance.parameters.color4);			
	end
	
end

 