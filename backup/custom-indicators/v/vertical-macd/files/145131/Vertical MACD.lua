-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71911

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
function Init()
    indicator:name("Vertical MACD Horizontal");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("P1", "Short EMA", "(SN)No Description", 12, 2, 1000);
    indicator.parameters:addInteger("P2", "Long EMA", "(LN)No Description", 26, 2, 1000);
    indicator.parameters:addInteger("P3", "Signal Line", "(IN)No Description", 9, 2, 1000);
    indicator.parameters:addInteger("Period", "Period ", "", 26);	
	indicator.parameters:addGroup("Style");
 
	indicator.parameters:addDouble("transparency", "Transparency", "Transparency", 50); 
	indicator.parameters:addColor("Histogram", "Histogram Color", "", core.rgb(0,  255,0));
	indicator.parameters:addColor("MACD", "MACD Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("SIGNAL", "Signal Color", "", core.rgb(0, 0, 255)); 
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
 
 
local source = nil; 
local first; 
local Period;
local Transparency; 
local Max;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
	Period = instance.parameters.Period;
 
 
  
    source = instance.source;

	MACD = core.indicators:create("MACD", source, instance.parameters.P1, instance.parameters.P2, instance.parameters.P3);
	
	first = MACD.HISTOGRAM:first();
	
	instance:setLabelColor(instance.parameters.Histogram);
	instance:ownerDrawn(true);
end


local init;

-- Indicator calculation routine
function Update(period)
    

    MACD:update(mode); 
	if period  <= first +Period then
	Max=0;
	return;
	end
	
	local Max1=math.abs(mathex.max(MACD.MACD, period-Period+1, period));
	local Max2=math.abs(mathex.max(MACD.SIGNAL, period-Period+1, period));
	local Max3=math.abs(mathex.max(MACD.HISTOGRAM, period-Period+1, period));	
	
	Max=math.max(Max1, Max2, Max3);
end





 
function Draw (stage, context)

    if stage  ~= 2 then
	return;
	end		 
	
	local Box=(context:bottom () - context:top ())/Period;	
	
	if not init then
	init=true;
	context:createSolidBrush (1, instance.parameters.Histogram); 
	context:createPen (2, context:convertPenStyle (instance.parameters.style), context:pointsToPixels (instance.parameters.width), instance.parameters.MACD)
	context:createPen (3, context:convertPenStyle (instance.parameters.style), context:pointsToPixels (instance.parameters.width), instance.parameters.SIGNAL)
	Transparency= context:convertTransparency (instance.parameters.transparency)
	end
	 
	if Max==0 then
    return;
    end

	
	local x= context:right()-200;
   
   
    local x1=context:bottom();
    local x2=context:bottom();	
	for i = 1, Period, 1 do  
		y0=context:top ()+(i)*Box;
	    y1=context:top ()+(i-1)*Box;
		
		Value1=(MACD.HISTOGRAM[source:size()-1-i+1]/Max);
		Value2=(MACD.HISTOGRAM[source:size()-1-i]/Max);	
		context:drawRectangle (-1, 1, x, y1 , x+Value1*200, y1+Box,Transparency);
	 		
 		Value2=(MACD.MACD[source:size()-1-i+1]/Max);
		Value1=(MACD.MACD[source:size()-1-i]/Max);	
		context:drawLine (2, x+Value1*200, y0, x+Value2*200, y1, Transparency);
 
		
 		Value2=(MACD.SIGNAL[source:size()-1-i+1]/Max);
		Value1=(MACD.SIGNAL[source:size()-1-i]/Max);	
		context:drawLine (3, x+Value1*200, y0, x+Value2*200, y1, Transparency);		
	
    end
	
end	 

 