-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71841

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
    indicator:name("Projection Bandwidth");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("length", "Length", "", 14, 1, 2000);
	
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
local lregh,lregl;	
local mHigh, mLow;
-- Routine
 function Prepare(nameOnly)   
 
    
	length=instance.parameters.length;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  length  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	lregh = instance:addInternalStream(0, 0);
	lregl = instance:addInternalStream(0, 0);
	mHigh = instance:addInternalStream(0, 0);
	mLow = instance:addInternalStream(0, 0);	
	first=source:first() +length; 
	
 
	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.Up, first );
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
	 
    lregh[period]=mathex.lreg (source.high, period-length+1, period);
    lregl[period]=mathex.lreg (source.low, period-length+1, period);
	
	 if period < first+1 then
	 return;
	 end
	 
    mHigh[period]=lregh[period]-lregh[period-1];	 
    mLow[period]=lregl[period]-lregl[period-1];

    local upperBand = source.high[period];
	local lowerBand = source.low[period];
	
	local vHigh=0;
	local vLow=0;
	
	for i = 0,length - 1, 1 do
    currH = source.high[period-i];
    currL = source.low[period-i];
    
    vHigh = currH + (mHigh[period-i] * i)
    vLow = currL + (mLow[period-i] * i)
	

    upperBand= math.max(vHigh, upperBand);
    lowerBand = math.min(vLow, lowerBand);
	end
	
	
    local middleBand = (upperBand + lowerBand) / 2;

	Line[period]= 200 * (upperBand - lowerBand) / (upperBand + lowerBand);
	
	if source.close[period]> middleBand then
	
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
 