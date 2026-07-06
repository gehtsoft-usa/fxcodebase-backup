-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71842

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
    indicator:name("McNamara Tally");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("length", "Length", "", 20, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("Up", "Up Trend Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("UpDown", "Down in Up Trend Line Color", "", core.rgb(0, 200, 0)); 
	 indicator.parameters:addColor("DownUp", "Up in Down Trend Line Color", "", core.rgb(255, 0, 0)); 	 
	 indicator.parameters:addColor("Down", "Down Trend Line Color", "", core.rgb(200, 0, 0)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local length; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    length=instance.parameters.length;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  length  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
    mact = instance:addInternalStream(0, 0);	
	

	first=source:first()+1 ; 
	
 
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.Up, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
	
	WMA= core.indicators:create("WMA", Line, length);
 
end


function Update(period, mode)



	 if period < first then
	 return;
	 end
	 
    local trh = math.max(source.high[period], source.close[period-1]);
    local trl = math.min(source.low[period], source.close[period-1]);
	
	mact[period]=(((source.close[period] - trl) - (trh - source.close[period])) / (trh - trl)) * source.volume[period];
	
	Line[period]= Line[period-1]+mact[period];
	
	WMA:update(mode);
	
	 if period < WMA.DATA:first() then
	 return;
	 end	
	 
	 
	if Line[period] > WMA.DATA[period] then
	
	   if Line[period] > Line[period-1] then
       Line:setColor(period, instance.parameters.Up);	   
	   else
       Line:setColor(period, instance.parameters.UpDown);	   	   
	   end
	   
	else

	   if Line[period] > Line[period-1] then
       Line:setColor(period, instance.parameters.DownUp);		   
	   else
       Line:setColor(period, instance.parameters.Down);		   
	   end
	   
	end	
end

