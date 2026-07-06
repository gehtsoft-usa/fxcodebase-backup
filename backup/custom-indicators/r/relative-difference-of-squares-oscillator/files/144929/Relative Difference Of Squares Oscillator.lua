-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71850

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
    indicator:name("Relative Difference Of Squares Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Length", "Length", "", 20, 1, 2000);
    indicator.parameters:addInteger("RocLength", "ROC Length", "", 1, 1, 2000);	
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("Up", "Up Trend Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("UpDown", "Down in Up Trend Line Color", "", core.rgb(0, 200, 0)); 	 
	 indicator.parameters:addColor("DownUp", "Up in Down  Trend Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(200, 0, 0)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Length,RocLength; 
local Up, Down, Neutral;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	Length=instance.parameters.Length;
	RocLength=instance.parameters.RocLength;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Length.. "," ..  RocLength  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Up = instance:addInternalStream(0, 0);
	Down = instance:addInternalStream(0, 0);	
	Neutral = instance:addInternalStream(0, 0);	
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=source:first()+1 ; 
	
 
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.Up, first + Length  );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
end


function Update(period, mode)

	--  Indicator:update(mode); 
 
	 if period < first then
	 return;
	 end
	 
	 Up[period]=0;
	 Down[period]=0;
	 Neutral[period]=0;	
	 
	 if source[period]  > source[period-1] then
	 Up[period]=1;
	 elseif source[period]  < source[period-1] then
	 Down[period]=1; 
	 elseif source[period]  == source[period-1] then
	 Neutral[period]=1;	 
	 end
	 
 	 if period < first +Length then
	 return;
	 end
	 
    local  a = mathex.sum(Up,period-Length+1, period);
    local  d = mathex.sum(Down,period-Length+1, period);
    local  n = mathex.sum(Neutral,period-Length+1, period); 

    Line[period] = (math.pow(a, 2) - math.pow(d, 2)) / math.pow(a + n + d, 2);


 

	if Line[period] > Line[period-RocLength] then
		if Line[period]> Line[period-1] then	
		Line:setColor(period,instance.parameters.Up);
		else
		Line:setColor(period, instance.parameters.UpDown);
		end
	else
		if Line[period]> Line[period-1] then	
		Line:setColor(period, instance.parameters.DownUp);
		else
		Line:setColor(period, instance.parameters.Down);
		end	
	end 
	
end


--[[
a = sum(src > nz(src[1]) ? 1 : 0, length)
d = sum(src < nz(src[1]) ? 1 : 0, length)
n = sum(src == nz(src[1]) ? 1 : 0, length)
rdos = a > 0 or d > 0 or n > 0 ? (pow(a, 2) - pow(d, 2)) / pow(a + n + d, 2) : 0

roc = rdos - nz(rdos[rocLength])
sig = rdos > 0 ? roc > nz(roc[1]) ? 2 : 1 : rdos < 0 ? roc < nz(roc[1]) ? -2 : -1 : 0
alertcondition(crossover(sig, 1), "Strong Buy Signal", "Strong Bullish Change Detected")
alertcondition(crossunder(sig, -1), "Strong Sell Signal", "Strong Bearish Change Detected")
alertcondition(crossover(sig, 0), "Buy Signal", "Bullish Change Detected")
alertcondition(crossunder(sig, 0), "Sell Signal", "Bearish Change Detected")
rdosColor = sig > 1 ? color.green : sig > 0 ? color.lime : sig < -1 ? color.maroon : sig < 0 ? color.red : color.black
barcolor(bar ? rdosColor : na)
plot(rdos, title="RDOS", color=rdosColor, linewidth=2)
]]
 
