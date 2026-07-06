-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71943

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
    indicator:name("Ensign volatility stop");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addDouble("k", "k", "", 1, 0, 2000);
    indicator.parameters:addInteger("Period", "Period", "", 14, 0, 2000);	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local k; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	k=instance.parameters.k;
	Period=instance.parameters.Period;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," .. k.. "," .. Period  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	ATR= core.indicators:create("ATR", source, Period);
	first=ATR.DATA:first() ; 
	
    between = instance:addInternalStream(0, 0);
    up = instance:addInternalStream(0, 0);
	dn = instance:addInternalStream(0, 0);
	upcond = instance:addInternalStream(0, 0); 
	dncond = instance:addInternalStream(0, 0);	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)

	ATR:update(mode); 

	 if period < first or period < Period  then
	 return;
	 end
	 
    local VSraw=k*ATR.DATA[period];
	
	local min, max= mathex.minmax(source.close, period-Period+1, period);
	
	local loline=max-VSraw;
	local hiline=min+VSraw;
	
	
	
	if source.close[period] < hiline and source.close[period] > loline then
	between[period] = 1
	else
	between[period] = 0
	end
	
	
	if source.close[period]>hiline or (source.high[period] > source.high[period-1] and source.high[period] > hiline) then
	up[period] = 1
	else
	up[period] = 0
	end
 
	if source.close[period] < loline or (source.low[period] < source.low[period-1] and source.low[period] < loline) then
	dn[period] = 1
	else
	dn[period] = 0
	end
	
	
	if between==1 and barssince(up, period) < barssince(dn, period) then
	upcond[period] = 1
	else
	upcond[period] = 0
	end
	 
	if between==1 and barssince(dn, period) < barssince(up, period) then
	dncond[period] = 1
	else
	dncond[period] = 0
	end
 
	
	Line[period] = Line[period-1]
	
	if up[period]==1 or upcond[period]==1  then
	Line[period] = loline 
	elseif dn[period]==1  or dncond[period]==1  then
	Line[period]= hiline
	end
 

 
	 
end 


function barssince (Data, period)

     local Return=0;

	 for i= period, first, -1 do
		 if Data[i]==1 then
		 Return=period-i;
		 break;
		 end	 	 
	 end
 
    return Return;
end