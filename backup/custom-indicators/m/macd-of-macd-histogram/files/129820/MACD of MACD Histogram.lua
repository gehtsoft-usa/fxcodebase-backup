-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69139

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("MACD of MACD Histogram");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("1. MACD Calculation"); 
    indicator.parameters:addInteger("Period1", "Short Period", "", 12, 1, 2000);
    indicator.parameters:addInteger("Period2", "Long Period", "", 26, 1, 2000);
	
    indicator.parameters:addInteger("Period3", "Signal Period", "", 9, 1, 2000);
	
	indicator.parameters:addGroup("2. MACD Calculation"); 
	  indicator.parameters:addInteger("Period5", "Smoothing Period", "", 2, 1, 2000);
     indicator.parameters:addInteger("Period4", "Signal Period", "", 9, 1, 2000);
	
	indicator.parameters:addGroup("MACD Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("Signal Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0 ,0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("Historam Style"); 	
    indicator.parameters:addColor("color3", "Bar Color", "", core.rgb(0, 0 ,255)); 
	indicator.parameters:addInteger("width3", "Bar Width", "", 3, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period1,Period2,Period3, Period4, Period5; 
local first;
local source = nil;
 
local Oscillator;  
 
local MACD,macd,Raw_MACD;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
	Period3= instance.parameters.Period3;
	Period4= instance.parameters.Period4;
	Period5= instance.parameters.Period5;
	
	local Parameters= Period1..", "..Period2..", "..Period3..", "..Period5..", "..Period4;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	
	
	macd = core.indicators:create("MACD", source, Period1, Period2, Period3);
	
	Raw_MACD= instance:addInternalStream(0, 0);
	
	
	Smoothing = core.indicators:create("MVA", Raw_MACD, Period5);
	
	MACD = instance:addStream("MACD" , core.Line, " MACD"," MACD",instance.parameters.color1, macd.HISTOGRAM:first()+Period5  );
	MACD:setWidth(instance.parameters.width1);
    MACD:setStyle(instance.parameters.style1);
    MACD:setPrecision(math.max(2, source:getPrecision()));
	
	MVA = core.indicators:create("MVA", MACD, Period4);
    first=MVA.DATA:first();
	
	
   
 
	Signal = instance:addStream("Signal" , core.Line, " Signal", " Signal",instance.parameters.color2, macd.HISTOGRAM:first()  );
	Signal:setWidth(instance.parameters.width2);
    Signal:setStyle(instance.parameters.style2);
    Signal:setPrecision(math.max(2, source:getPrecision()));
	
	
	Histogram = instance:addStream("Histogram" , core.Bar, " Histogram", " Histogram",instance.parameters.color3, macd.HISTOGRAM:first()  );
	Histogram:setWidth(instance.parameters.width3);
	
	
end

-- Indicator calculation routine
function Update(period, mode)

    macd:update(mode);
	
	if period < macd.HISTOGRAM:first()
	then
	return;	
	end
 
	
	Raw_MACD[period]=(macd.HISTOGRAM[period]-macd.HISTOGRAM[period-1])/source:pipSize();
	
	if period < macd.HISTOGRAM:first() +Period5
	then
	return;	
	end
	
	
	Smoothing:update(mode);
	
	MACD[period]= Smoothing.DATA[period];
	
    MVA:update(mode);
	
	if period < macd.HISTOGRAM:first() +Period4 then 
	return;	
	end
	
	Signal[period]=MVA.DATA[period];
	Histogram[period]=MACD[period]-Signal[period];
end 