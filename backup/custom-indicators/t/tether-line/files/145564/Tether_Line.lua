-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72046

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
    indicator:name("Tether_Line");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Length", "Length", "", 55, 1, 2000);
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Length; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Length=instance.parameters.Length;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Length  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=source:first() +Length; 
	
	
	Median = instance:addInternalStream(0, 0);
 
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.Up, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
 
 	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom , instance.parameters.Up, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top, instance.parameters.Down, 0);
end


function Update(period, mode)

    up:setNoData(period);
    down:setNoData(period);	

	 if period <= first then
	 return;
	 end
	 
	local min,max=mathex.minmax(source, period-Length+1, period);
	Median[period]= (max+min)/2;
	
	 
    
	if source.close[period]> Median[period] then
    Line[period]=Median[period];
    Line:setColor(period,  instance.parameters.Up);		
    elseif source.close[period]< Median[period] then
    Line[period]=Median[period];
    Line:setColor(period,  instance.parameters.Down);		
    end
	  
	  
	 if period <= first+3 then
	 return;
	 end
	 
	if source.close[period]> Median[period] and  source.close[period-1]< Median[period]  and  source.close[period-3]< Median[period]  and  source.close[period-3]< Median[period] 
	then
	up:set(period, source.low[period], "\217", source.low[period]);		
	elseif source.close[period]< Median[period] and  source.close[period-1]> Median[period]  and  source.close[period-3]> Median[period]  and  source.close[period-3]> Median[period] 
	then
    down:set(period, source.high[period], "\218", source.high[period]);	
	end


 

end

 