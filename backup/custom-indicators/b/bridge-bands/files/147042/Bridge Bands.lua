-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72611

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
    indicator:name("Bridge Bands");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);



   
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("length", "Length", "", 15, 1, 2000);
    indicator.parameters:addInteger("trendLength", "Trend Length", "", 63, 1, 2000);
    indicator.parameters:addInteger("resolution", "Resolution", "", 0, 0, 2000);


    indicator.parameters:addBoolean("Bands", "Show Bands", "", true);
    indicator.parameters:addBoolean("Trend", "Show Trend", "", true);

	
	 indicator.parameters:addGroup("Bands Line Style");	

	
	 indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color3", "Central Line Color", "", core.rgb(128, 128, 128)); 
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);	 
	 
	 indicator.parameters:addGroup("Trend Line Style");		 
	 indicator.parameters:addColor("color4", "Trend Line Color", "", core.rgb(0, 0, 255)); 	
    indicator.parameters:addInteger("width2", "Line width", "", 5, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local length, trendLength,lengthMinus1,logLength; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	length=instance.parameters.length;
	trendLength=instance.parameters.trendLength; 
    lengthMinus1 = length - 1;	
    logLength = math.log(length);	
	
	source = instance.source
	Source=source.close;
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  length.. "," ..  trendLength    .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	ATR= core.indicators:create("ATR", source, length);
	WMA= core.indicators:create("WMA", source, length);	
	first=source:first()+length; 
	 
	if instance.parameters.Bands then
    Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color1, first );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
    Top:addLevel(0);	
 
    Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color2, first );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
    Bottom:addLevel(0);	

    Central = instance:addStream("Central", core.Line, name, "Central", instance.parameters.color3, first );
    Central:setPrecision(math.max(2, instance.source:getPrecision()));
    Central:setWidth(instance.parameters.width);
    Central:setStyle(instance.parameters.style);
    Central:addLevel(0);	
	else
    Top = instance:addInternalStream(0, 0);
    Bottom = instance:addInternalStream(0, 0);
    Central = instance:addInternalStream(0, 0);	
	end
	if instance.parameters.Trend  then
    Trend = instance:addStream("Trend", core.Line, name, "Trend", instance.parameters.color4, first );
    Trend:setPrecision(math.max(2, instance.source:getPrecision()));
    Trend:setWidth(instance.parameters.width2);
    Trend:setStyle(instance.parameters.style2);
    Trend:addLevel(0);		
	else
    Trend = instance:addInternalStream(0, 0);	
	end
end


function Update(period, mode)

	ATR:update(mode); 
    WMA:update(mode);
	 
	 if period <= first then
	 return;
	 end
	 
    local sd = mathex.stdev(source.close, period-length, period)	
    local min,max=mathex.minmax(source, period-length, period );	 
	 
    local slope = (Source[period] - Source[period-lengthMinus1]) / lengthMinus1	 
	
	
 
	local m = 100000000.0  
	for i = 0 , lengthMinus1, 1 do
	m = math.min(m, Source[period-lengthMinus1 + i] - (Source[period-lengthMinus1] + (slope * i)))
	end
	local mindiff=m
 
	local m = -100000000.0
	for i = 0, lengthMinus1, 1  do 
	m = math.max(m, Source[period-lengthMinus1 + i] - (Source[period-lengthMinus1] + (slope * i)))
	end
	local maxdiff=m	
	
	
	local bridgerangebottom = Source[period] + mindiff	 
	local bridgerangetop = Source[period] + maxdiff	
 
 
	
    local hurst = (math.log(max - min) - math.log(ATR.DATA[period])) / logLength
	
	
 
	 
	local bbbottom = WMA.DATA[period] - (sd * 2)	 
	local bbtop = WMA.DATA[period] + (sd * 2)	
	
	Top[period]= bbtop - ((bbtop - bridgerangetop) * math.abs((hurst * 2) - 1))
	Bottom[period]= bbbottom + ((bridgerangebottom - bbbottom) *  math.abs((hurst * 2) - 1))
	Central[period]= (Top[period]+Bottom[period])/2;
	
	
    Trend[period] = min + (max - min) / 2; 
	
	if source.close[period]> 	Trend[period] then
	Trend:setColor(period,   instance.parameters.color1);	
    else	
	Trend:setColor(period,   instance.parameters.color2);	 	 
    end
  
	
end

 
 