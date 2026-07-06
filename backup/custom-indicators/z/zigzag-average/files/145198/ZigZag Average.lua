-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71927

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
    indicator:name("ZigZag Average");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "MA Period", "", 12);	
    indicator.parameters:addInteger("P1", "Depth", "the minimal amount of bars where there will not be the second maximum", 12);
    indicator.parameters:addInteger("P2", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5);
    indicator.parameters:addInteger("P3", "Backstep", "The minimal amount of bars between maximums/minimums", 3);
	
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
local Period; 
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Period=instance.parameters.Period;
	P1=instance.parameters.P1;
	P2=instance.parameters.P2;
	P3=instance.parameters.P3;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..    Period .. "," ..  P1.. "," ..  P2 .. "," ..  P3  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end


    LastZigZag = instance:addInternalStream(0, 0);
	
	ZigZag= core.indicators:create("ZIGZAG", source, instance.parameters.P1, instance.parameters.P2,instance.parameters.P3);	
	first=ZigZag.DATA:first() ; 
 
	
 
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end

local Last;

function Update(period, mode)


	 if period < first then
	 return;
	 end
 
	if Last~= source:serial(period) then

	 if period < source:size()-1 then
	 ZigZag:update(core.mode );   
	 else
	 ZigZag:update(core.UpdateAll );  
	 end



	Last= source:serial(period);
	end

LastZigZag[period]=LastZigZag[period-1];

	for i= period, first, -1 do

		if ZigZag.DATA[i]== source.high[period]then
		LastZigZag[period]=1;
		elseif ZigZag.DATA[i]== source.low[period]then
		LastZigZag[period]=-1;		
		end


	end


if 	LastZigZag[period] == 0 then
return;
end


	if LastZigZag[period]== 1 then
	Line[period]= mathex.avg(source.high, period-Period+1, period);
	else
	Line[period]= mathex.avg(source.low, period-Period+1, period);	
	end
end